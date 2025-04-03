import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() {
  runApp(const MetricsApp());
}

class MetricsApp extends StatelessWidget {
  const MetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metrics Login',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
