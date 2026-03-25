import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIGN UP
  Future<User?> register(String email, String password) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return user.user;
    } catch (e) {
      print("Erreur register: $e");
      return null;
    }
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return user.user;
    } catch (e) {
      print("Erreur login: $e");
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}