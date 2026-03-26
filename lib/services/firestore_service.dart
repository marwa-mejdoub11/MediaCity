import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/media_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Duration _firestoreProfileTimeout = Duration(seconds: 12);

  /// Save user profile to Firestore
  Future<void> _saveUserProfile(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set(
        {
          'email': user.email,
          'role': 'user',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).timeout(_firestoreProfileTimeout);
    } on TimeoutException {
      debugPrint('Firestore: timeout saving user ${user.uid}');
    } catch (e) {
      debugPrint('Firestore error: $e');
    }
  }

  /// Register user
  Future<User?> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Registration failed");

      await _saveUserProfile(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      throw Exception("Registration error: $e");
    }
  }

  /// Login user
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      throw Exception("Login error: $e");
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Map Firebase auth errors to readable messages
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Invalid email address";
      case 'user-not-found':
        return "No account found for this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'email-already-in-use':
        return "This email is already in use";
      case 'weak-password':
        return "Password is too weak (min 6 characters)";
      case 'network-request-failed':
        return "Network error. Check your connection";
      default:
        return e.message ?? "Authentication error (${e.code})";
    }
  }
}

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  /// Add media with auto-save to Firestore
  Future<String> addMedia(Media media) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) throw Exception("User not authenticated");

      final docRef = await _db.collection('users').doc(userId).collection('media').add({
        'title': media.title,
        'type': media.type,
        'available': media.available,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Media added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding media: $e');
      rethrow;
    }
  }

  /// Create or update media (auto-save friendly)
  Future<String> upsertMedia(Media media) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) throw Exception("User not authenticated");

      if (media.id.isEmpty) {
        return await addMedia(media);
      }

      await _db
          .collection('users')
          .doc(userId)
          .collection('media')
          .doc(media.id)
          .set({
        'title': media.title,
        'type': media.type,
        'available': media.available,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': media.createdAt != null
            ? Timestamp.fromDate(media.createdAt!)
            : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Media upserted successfully: ${media.id}');
      return media.id;
    } catch (e) {
      debugPrint('Error upserting media: $e');
      rethrow;
    }
  }

  /// Update media with auto-save
  Future<void> updateMedia(Media media) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) throw Exception("User not authenticated");

      await _db
          .collection('users')
          .doc(userId)
          .collection('media')
          .doc(media.id)
          .update({
        'title': media.title,
        'type': media.type,
        'available': media.available,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Media updated successfully: ${media.id}');
    } catch (e) {
      debugPrint('Error updating media: $e');
      rethrow;
    }
  }

  /// Delete media
  Future<void> deleteMedia(String mediaId) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) throw Exception("User not authenticated");

      await _db
          .collection('users')
          .doc(userId)
          .collection('media')
          .doc(mediaId)
          .delete();

      debugPrint('Media deleted successfully: $mediaId');
    } catch (e) {
      debugPrint('Error deleting media: $e');
      rethrow;
    }
  }

  /// Get media stream for real-time updates
  Stream<List<Media>> getMedia() {
    final userId = _userId;
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('media')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Media.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get single media
  Future<Media?> getMediaById(String mediaId) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) throw Exception("User not authenticated");

      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('media')
          .doc(mediaId)
          .get();

      if (doc.exists) {
        return Media.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting media: $e');
      return null;
    }
  }
}
