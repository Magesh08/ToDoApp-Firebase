import 'package:flutter/material.dart';
import 'package:new_project/firebase_options.dart';
// Corrected capitalization
import 'package:firebase_core/firebase_core.dart';
import 'package:new_project/pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Practice(),
  ));
}

class Practice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomePage(),
    );
  }
}
