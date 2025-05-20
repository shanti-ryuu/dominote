import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../models/pin.dart';

class DatabaseService {
  static const String _notesBoxName = 'notes';
  static const String _foldersBoxName = 'folders';
  static const String _pinBoxName = 'pin';
  static const String _secureStorageKey = 'hive_encryption_key';

  late Box<Note> _notesBox;
  late Box<Folder> _foldersBox;
  late Box<Pin> _pinBox;
  
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<void> init() async {
    // Initialize Hive
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    } else {
      await Hive.initFlutter();
    }

    // Register adapters
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(PinAdapter());

    // Get encryption key for secure storage
    final encryptionKey = await _getEncryptionKey();

    // Open boxes
    _notesBox = await Hive.openBox<Note>(_notesBoxName, encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null);
    _foldersBox = await Hive.openBox<Folder>(_foldersBoxName, encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null);
    _pinBox = await Hive.openBox<Pin>(_pinBoxName, encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null);

    // Create default folder if none exists
    if (_foldersBox.isEmpty) {
      final defaultFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'All Notes',
        createdAt: DateTime.now(),
      );
      await _foldersBox.put(defaultFolder.id, defaultFolder);
    }
  }

  Future<List<int>?> _getEncryptionKey() async {
    try {
      const secureStorage = FlutterSecureStorage();
      final containsKey = await secureStorage.containsKey(key: _secureStorageKey);
      
      if (!containsKey) {
        final key = Hive.generateSecureKey();
        await secureStorage.write(key: _secureStorageKey, value: base64UrlEncode(key));
        return key;
      }
      
      final keyString = await secureStorage.read(key: _secureStorageKey);
      if (keyString != null) {
        return base64Url.decode(keyString);
      }
      return null;
    } catch (e) {
      // In web, secure storage might not be available
      if (kIsWeb) {
        return null;
      }
      rethrow;
    }
  }

  // PIN Management
  Future<bool> isPinSet() async {
    return _pinBox.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    if (_pinBox.isEmpty) return false;
    
    final storedPin = _pinBox.values.first;
    final hashedInput = _hashPin(pin);
    
    return storedPin.hashedPin == hashedInput;
  }

  Future<void> setPin(String pin) async {
    final hashedPin = _hashPin(pin);
    final now = DateTime.now();
    
    final pinModel = Pin(
      hashedPin: hashedPin,
      createdAt: now,
      updatedAt: now,
    );
    
    await _pinBox.clear();
    await _pinBox.add(pinModel);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Note Management
  Future<List<Note>> getAllNotes() async {
    return _notesBox.values.toList();
  }

  Future<List<Note>> getNotesByFolder(String folderId) async {
    return _notesBox.values
        .where((note) => note.folderIds.contains(folderId))
        .toList();
  }

  Future<Note?> getNoteById(String id) async {
    return _notesBox.get(id);
  }

  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<List<Note>> searchNotes(String query) async {
    query = query.toLowerCase();
    return _notesBox.values
        .where((note) => 
            note.title.toLowerCase().contains(query) || 
            note.content.toLowerCase().contains(query))
        .toList();
  }

  // Folder Management
  Future<List<Folder>> getAllFolders() async {
    return _foldersBox.values.toList();
  }

  Future<Folder?> getFolderById(String id) async {
    return _foldersBox.get(id);
  }

  Future<void> saveFolder(Folder folder) async {
    await _foldersBox.put(folder.id, folder);
  }

  Future<void> deleteFolder(String id) async {
    // Remove folder from all notes
    final notes = await getAllNotes();
    for (final note in notes) {
      if (note.folderIds.contains(id)) {
        note.folderIds.remove(id);
        await saveNote(note);
      }
    }
    
    // Delete the folder
    await _foldersBox.delete(id);
  }
  
  // Close boxes when app is closed
  Future<void> close() async {
    await _notesBox.close();
    await _foldersBox.close();
    await _pinBox.close();
  }
}
