// lib/test_firebase_config.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = "Vérification en cours...";
  Color _statusColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _testFirebaseConfig();
  }

  Future<void> _testFirebaseConfig() async {
    try {
      // 1. Vérifier Firebase Core
      await Firebase.initializeApp();
      
      // 2. Vérifier Firebase Auth
      final auth = FirebaseAuth.instance;
      await auth.signOut(); // Test simple
      
      // 3. Vérifier Firestore (écriture test)
      final testDoc = FirebaseFirestore.instance
          .collection('test_config')
          .doc('test_connection');
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'ok'
      });
      
      // Lire le document pour vérifier
      final docSnapshot = await testDoc.get();
      
      // 4. Vérifier Storage
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('test/test.txt');
      
      // Upload d'un petit fichier test
      final testData = 'Test Firebase Storage';
      await storageRef.putString(testData);
      
      // Vérifier que le fichier existe
      await storageRef.getDownloadURL();
      
      // Nettoyer : supprimer le fichier test
      await storageRef.delete();
      
      // 5. Vérifier Firebase Messaging
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      
      if (token != null) {
        print('✅ FCM Token: $token');
      }
      
      // Nettoyer le document test
      await testDoc.delete();
      
      setState(() {
        _status = "✅ TOUS LES SERVICES FIREBASE FONCTIONNENT !\n\n"
                  "✓ Firebase Core: OK\n"
                  "✓ Firebase Auth: OK\n"
                  "✓ Cloud Firestore: OK\n"
                  "✓ Firebase Storage: OK\n"
                  "✓ Firebase Messaging: OK\n\n"
                  "FCM Token: $token";
        _statusColor = Colors.green;
      });
      
    } catch (e) {
      setState(() {
        _status = "❌ ERREUR DE CONFIGURATION :\n\n$e\n\n"
                  "Vérifie :\n"
                  "1. Le fichier google-services.json (Android)\n"
                  "2. Le fichier GoogleService-Info.plist (iOS)\n"
                  "3. Que Firebase est bien initialisé dans main.dart";
        _statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Configuration Firebase'),
        backgroundColor: _statusColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _statusColor == Colors.green ? Icons.check_circle : 
              _statusColor == Colors.orange ? Icons.hourglass_empty : 
              Icons.error,
              size: 80,
              color: _statusColor,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: _statusColor == Colors.green ? Colors.black87 : _statusColor,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testFirebaseConfig,
              child: Text('Relancer le test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}