import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/folders_provider.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  Note? _note;
  String? _initialFolderId;
  List<String> _selectedFolderIds = [];
  bool _isEditing = false;
  bool _isContentFocused = false;
  
  final FocusNode _contentFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    _contentFocusNode.addListener(() {
      setState(() {
        _isContentFocused = _contentFocusNode.hasFocus;
      });
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      _note = args['note'] as Note?;
      _initialFolderId = args['folderId'] as String?;
      
      if (_note != null) {
        _titleController.text = _note!.title;
        _contentController.text = _note!.content;
        _selectedFolderIds = List<String>.from(_note!.folderIds);
        _isEditing = true;
      } else if (_initialFolderId != null) {
        _selectedFolderIds = [_initialFolderId!];
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveAndGoBack,
        ),
        title: _isEditing
            ? Text(_note?.title.isEmpty ?? true ? 'Untitled Note' : _note!.title)
            : const Text('New Note'),
        actions: [
          if (_isEditing) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'txt') {
                  _exportAsTxt();
                } else if (value == 'pdf') {
                  _exportAsPdf();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'txt',
                  child: Row(
                    children: [
                      Icon(Icons.description),
                      SizedBox(width: 8),
                      Text('Export as TXT'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_isEditing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Edited ${DateFormat('MMM d, yyyy').format(_note!.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.folder_outlined, size: 16),
                    label: const Text('Folders'),
                    onPressed: _showFolderSelectionDialog,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    onChanged: (value) {
                      // Auto-save title changes
                      if (_isEditing && _note != null) {
                        _saveNote(updateTitle: true);
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Start typing...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isContentFocused
          ? null
          : BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder_outlined),
                    onPressed: _showFolderSelectionDialog,
                    tooltip: 'Manage Folders',
                  ),
                  if (_isEditing) ...[
                    IconButton(
                      icon: const Icon(Icons.description),
                      onPressed: _exportAsTxt,
                      tooltip: 'Export as TXT',
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: _exportAsPdf,
                      tooltip: 'Export as PDF',
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveAndGoBack,
                    tooltip: 'Save and Exit',
                  ),
                ],
              ),
            ),
    );
  }
  
  Future<void> _saveNote({bool updateTitle = false, bool updateContent = false}) async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    
    if (_isEditing && _note != null) {
      // Update existing note
      await notesProvider.updateNote(
        id: _note!.id,
        title: updateTitle ? _titleController.text : null,
        content: updateContent ? _contentController.text : null,
        folderIds: _selectedFolderIds,
      );
    } else {
      // Create new note
      await notesProvider.createNote(
        title: _titleController.text,
        content: _contentController.text,
        folderIds: _selectedFolderIds,
      );
    }
  }
  
  void _saveAndGoBack() async {
    await _saveNote(updateTitle: true, updateContent: true);
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  Future<void> _showFolderSelectionDialog() async {
    final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
    await foldersProvider.loadFolders();
    
    if (!mounted) return;
    
    final List<String> tempSelectedFolderIds = List<String>.from(_selectedFolderIds);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Folders'),
            content: SizedBox(
              width: double.maxFinite,
              child: foldersProvider.folders.isEmpty
                  ? const Center(
                      child: Text('No folders available'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: foldersProvider.folders.length,
                      itemBuilder: (context, index) {
                        final folder = foldersProvider.folders[index];
                        return CheckboxListTile(
                          title: Text(folder.name),
                          value: tempSelectedFolderIds.contains(folder.id),
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                tempSelectedFolderIds.add(folder.id);
                              } else {
                                tempSelectedFolderIds.remove(folder.id);
                              }
                            });
                          },
                        );
                      },
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
                onPressed: () {
                  setState(() {
                    _selectedFolderIds = tempSelectedFolderIds;
                  });
                  
                  if (_isEditing && _note != null) {
                    _saveNote();
                  }
                  
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _exportAsTxt() async {
    if (!_isEditing || _note == null) return;
    
    try {
      final exportService = ExportService();
      await exportService.exportAsTxt(_note!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note exported as TXT'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Future<void> _exportAsPdf() async {
    if (!_isEditing || _note == null) return;
    
    try {
      final exportService = ExportService();
      await exportService.exportAsPdf(_note!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note exported as PDF'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
