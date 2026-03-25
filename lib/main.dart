import 'package:flutter/material.dart';
import 'views/login_page.dart'; // Assure-toi que le chemin est correct
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Généré par FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediacite',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}