import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/registro.dart'; // importa si tienes el archivo RegisterScreen separado

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), // opcional si tienes navegación al registro
      },
    );
  }
}
