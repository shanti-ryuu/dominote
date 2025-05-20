import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../providers/notes_provider.dart';
import '../providers/folders_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/note_card.dart';
import '../widgets/folder_item.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedFolderId;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load folders and notes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
    await foldersProvider.loadFolders();
    
    // Select the first folder by default
    if (foldersProvider.folders.isNotEmpty && _selectedFolderId == null) {
      setState(() {
        _selectedFolderId = foldersProvider.folders.first.id;
      });
    }
    
    // Load notes for the selected folder
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.loadNotes(folderId: _selectedFolderId);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final notesProvider = Provider.of<NotesProvider>(context);
    final foldersProvider = Provider.of<FoldersProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                style: theme.textTheme.titleMedium,
                autofocus: true,
                onChanged: (query) {
                  notesProvider.searchNotes(query);
                },
              )
            : Text(_getAppBarTitle(foldersProvider.folders)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  notesProvider.loadNotes(folderId: _selectedFolderId);
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 48,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Folders',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _showAddFolderDialog,
                          tooltip: 'Add Folder',
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ...foldersProvider.folders.map((folder) {
                    return FolderItem(
                      folder: folder,
                      isSelected: folder.id == _selectedFolderId,
                      onTap: () {
                        setState(() {
                          _selectedFolderId = folder.id;
                          _isSearching = false;
                          _searchController.clear();
                        });
                        notesProvider.loadNotes(folderId: folder.id);
                        Navigator.pop(context); // Close drawer
                      },
                      onEdit: () => _showEditFolderDialog(folder),
                      onDelete: () => _showDeleteFolderDialog(folder),
                    );
                  }),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _showLogoutDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      body: _buildNotesList(notesProvider.notes),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNoteEditor();
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  String _getAppBarTitle(List<Folder> folders) {
    if (_selectedFolderId == null || folders.isEmpty) {
      return AppConstants.appName;
    }
    
    final selectedFolder = folders.firstWhere(
      (folder) => folder.id == _selectedFolderId,
      orElse: () => Folder(
        id: '',
        name: AppConstants.appName,
        createdAt: DateTime.now(),
      ),
    );
    
    return selectedFolder.name;
  }
  
  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return EmptyState(
        icon: Icons.note_alt_outlined,
        title: 'No Notes Yet',
        message: 'Tap the + button to create your first note',
        actionLabel: 'Create Note',
        onActionPressed: () {
          _navigateToNoteEditor();
        },
      );
    }
    
    // Determine if we should use a grid or list based on screen width
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 600;
    
    if (isWideScreen) {
      return MasonryGridView.count(
        crossAxisCount: width > 900 ? 3 : 2,
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _navigateToNoteEditor(note: note),
            onDelete: () => _showDeleteNoteDialog(note),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _navigateToNoteEditor(note: note),
            onDelete: () => _showDeleteNoteDialog(note),
          );
        },
      );
    }
  }
  
  void _navigateToNoteEditor({Note? note}) {
    Navigator.pushNamed(
      context,
      AppConstants.noteEditorRoute,
      arguments: {
        'note': note,
        'folderId': _selectedFolderId,
      },
    ).then((_) {
      // Refresh notes when returning from editor
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      notesProvider.loadNotes(folderId: _selectedFolderId);
    });
  }
  
  Future<void> _showAddFolderDialog() async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Folder Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a folder name';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
                await foldersProvider.createFolder(textController.text.trim());
                
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showEditFolderDialog(Folder folder) async {
    final textController = TextEditingController(text: folder.name);
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Folder Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a folder name';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
                await foldersProvider.updateFolder(
                  id: folder.id,
                  name: textController.text.trim(),
                );
                
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showDeleteFolderDialog(Folder folder) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"? This will remove the folder from all notes.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
              await foldersProvider.deleteFolder(folder.id);
              
              // If the deleted folder was selected, select the first folder
              if (_selectedFolderId == folder.id && foldersProvider.folders.isNotEmpty) {
                setState(() {
                  _selectedFolderId = foldersProvider.folders.first.id;
                });
                
                final notesProvider = Provider.of<NotesProvider>(context, listen: false);
                await notesProvider.loadNotes(folderId: _selectedFolderId);
              }
              
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showDeleteNoteDialog(Note note) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title.isEmpty ? 'Untitled Note' : note.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final notesProvider = Provider.of<NotesProvider>(context, listen: false);
              await notesProvider.deleteNote(note.id);
              
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? You will need to enter your PIN again to access your notes.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.pinLoginRoute,
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
