import 'package:flutter/foundation.dart';
import '../models/folder.dart';
import '../services/database_service.dart';

class FoldersProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Folder> _folders = [];
  
  List<Folder> get folders => _folders;
  
  Future<void> loadFolders() async {
    _folders = await _databaseService.getAllFolders();
    
    // Sort folders by name
    _folders.sort((a, b) => a.name.compareTo(b.name));
    
    notifyListeners();
  }
  
  Future<void> createFolder(String name) async {
    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    
    await _databaseService.saveFolder(folder);
    await loadFolders();
  }
  
  Future<void> updateFolder({required String id, required String name}) async {
    final folder = await _databaseService.getFolderById(id);
    
    if (folder == null) return;
    
    final updatedFolder = folder.copyWith(name: name);
    
    await _databaseService.saveFolder(updatedFolder);
    await loadFolders();
  }
  
  Future<void> deleteFolder(String id) async {
    await _databaseService.deleteFolder(id);
    await loadFolders();
  }
  
  Future<Folder?> getFolderById(String id) async {
    return _databaseService.getFolderById(id);
  }
}
