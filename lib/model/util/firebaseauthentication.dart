import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clase AuthService que gestiona la autenticación del usuario mediante Firebase Authentication
/// y el almacenamiento seguro de las credenciales (email y contraseña) utilizando Flutter Secure Storage.
/// Proporciona métodos para guardar, verificar, iniciar sesión automáticamente con credenciales guardadas,
/// eliminar credenciales y cerrar sesión.
class AuthService {
  static final AuthService _instance = AuthService._internal(); //crear instancia singleton
  final FirebaseAuth _auth = FirebaseAuth.instance; //instanciar FirebaseAuth
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); //instanciar almacenamiento seguro
  
  //claves para almacenamiento seguro
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';

  factory AuthService() {
    return _instance; //retornar instancia singleton
  }

  AuthService._internal(); //constructor privado para singleton

  //guardar credenciales de forma segura
  Future<void> saveCredentials(String email, String password, bool unused) async {
    await _secureStorage.write(key: _emailKey, value: email); //guardar email
    await _secureStorage.write(key: _passwordKey, value: password); //guardar contraseña
  }

  //comprobar si hay credenciales guardadas
  Future<bool> hasSavedCredentials() async {
    final email = await _secureStorage.read(key: _emailKey); //leer email guardado
    final password = await _secureStorage.read(key: _passwordKey); //leer contraseña guardada
    
    return email != null && password != null; //retornar true si ambas existen
  }

  //iniciar sesión automáticamente con credenciales guardadas
  Future<User?> autoLogin() async {
    if (!await hasSavedCredentials()) {
      return null; //retornar null si no hay credenciales
    }
    
    final email = await _secureStorage.read(key: _emailKey); //leer email guardado
    final password = await _secureStorage.read(key: _passwordKey); //leer contraseña guardada
    
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email!, //usar email guardado
        password: password!, //usar contraseña guardada
      );
      return userCredential.user; //retornar usuario autenticado
    } catch (e) {
      return null; //retornar null si error de autenticación
    }
  }

  //eliminar credenciales guardadas
  Future<void> clearSavedCredentials() async {
    await _secureStorage.delete(key: _emailKey); //borrar email guardado
    await _secureStorage.delete(key: _passwordKey); //borrar contraseña guardada
  }

  //cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut(); //cerrar sesión en Firebase
  }
}