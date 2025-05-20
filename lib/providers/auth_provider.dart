import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isAuthenticated = false;
  bool _isPinSet = false;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isPinSet => _isPinSet;
  
  Future<void> checkPinStatus() async {
    _isPinSet = await _databaseService.isPinSet();
    notifyListeners();
  }
  
  Future<bool> verifyPin(String pin) async {
    final isValid = await _databaseService.verifyPin(pin);
    
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    
    return isValid;
  }
  
  Future<void> setPin(String pin) async {
    await _databaseService.setPin(pin);
    _isPinSet = true;
    _isAuthenticated = true;
    notifyListeners();
  }
  
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
