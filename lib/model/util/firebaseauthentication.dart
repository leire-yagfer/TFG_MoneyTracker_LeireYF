import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Keys for secure storage
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Save credentials securely
  Future<void> saveCredentials(String email, String password, bool unused) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  // Check if user has saved credentials
  Future<bool> hasSavedCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    
    return email != null && password != null;
  }

  // Automatically login using saved credentials
  Future<User?> autoLogin() async {
    if (!await hasSavedCredentials()) {
      return null;
    }
    
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
} 