import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(SignLanguageApp());
}

class SignLanguageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
