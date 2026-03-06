import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'test_firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialisé avec succès');
    runApp(MyApp());
  } catch (e) {
    print('❌ Erreur initialisation Firebase: $e');
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediacite',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FirebaseTestScreen(), // Temporaire pour le test
    );
  }
}