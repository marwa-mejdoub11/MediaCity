import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthController {
  final FirebaseService _service = FirebaseService();

  Future<User?> register(String email, String password) {
    return _service.register(email, password);
  }

  Future<User?> login(String email, String password) {
    return _service.login(email, password);
  }

  Future<void> logout() {
    return _service.logout();
  }

  User? currentUser() {
    return _service.getCurrentUser();
  }
}