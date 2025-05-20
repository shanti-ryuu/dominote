import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Note> _notes = [];
  String? _currentFolderId;
  Note? _currentNote;
  
  List<Note> get notes => _notes;
  String? get currentFolderId => _currentFolderId;
  Note? get currentNote => _currentNote;
  
  Future<void> loadNotes({String? folderId}) async {
    _currentFolderId = folderId;
    
    if (folderId != null) {
      _notes = await _databaseService.getNotesByFolder(folderId);
    } else {
      _notes = await _databaseService.getAllNotes();
    }
    
    // Sort notes by updated date (newest first)
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    notifyListeners();
  }
  
  Future<void> createNote({required String title, required String content, required List<String> folderIds}) async {
    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      folderIds: folderIds,
    );
    
    await _databaseService.saveNote(note);
    await loadNotes(folderId: _currentFolderId);
  }
  
  Future<void> updateNote({
    required String id,
    String? title,
    String? content,
    List<String>? folderIds,
  }) async {
    final note = await _databaseService.getNoteById(id);
    
    if (note == null) return;
    
    final updatedNote = note.copyWith(
      title: title,
      content: content,
      folderIds: folderIds,
      updatedAt: DateTime.now(),
    );
    
    await _databaseService.saveNote(updatedNote);
    
    // If this is the current note, update it
    if (_currentNote?.id == id) {
      _currentNote = updatedNote;
    }
    
    await loadNotes(folderId: _currentFolderId);
  }
  
  Future<void> deleteNote(String id) async {
    await _databaseService.deleteNote(id);
    
    // If this is the current note, clear it
    if (_currentNote?.id == id) {
      _currentNote = null;
    }
    
    await loadNotes(folderId: _currentFolderId);
  }
  
  Future<void> setCurrentNote(String? id) async {
    if (id == null) {
      _currentNote = null;
    } else {
      _currentNote = await _databaseService.getNoteById(id);
    }
    
    notifyListeners();
  }
  
  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      await loadNotes(folderId: _currentFolderId);
      return;
    }
    
    _notes = await _databaseService.searchNotes(query);
    notifyListeners();
  }
}
