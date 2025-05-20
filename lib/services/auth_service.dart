import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _databaseService = DatabaseService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // PIN is stored in the database, not in secure storage
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  // Check if PIN is set
  Future<bool> isPinSet() async {
    return await _databaseService.isPinSet();
  }
  
  // Verify PIN
  Future<bool> verifyPin(String pin) async {
    return await _databaseService.verifyPin(pin);
  }
  
  // Set PIN
  Future<void> setPin(String pin) async {
    await _databaseService.setPin(pin);
  }
  
  // Reset PIN
  Future<void> resetPin() async {
    await _databaseService.deletePin();
  }
  
  // Hash PIN for secure storage
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      debugPrint('Error setting biometric preference: $e');
      // On web, secure storage might not be available
      if (kIsWeb) {
        // Fallback to local storage or other mechanism for web
      }
    }
  }
  
  // Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      debugPrint('Error reading biometric preference: $e');
      return false;
    }
  }
  
  // Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    // This would typically use local_auth package to check device capabilities
    // For now, return false as it's not implemented
    return false;
  }
}
