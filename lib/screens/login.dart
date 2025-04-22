import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'registro.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> _login() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    print('Usuario: $user');
    print('Contraseña: $pass');

    final url = Uri.parse("http://10.100.0.51/flutter_api/login_usuario.php");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nombreUsuario': user,
          'contrasena': pass,
        },
      );

      final cleanedResponse = response.body.replaceAll('\uFEFF', '').trim();
      print("Respuesta del servidor: '$cleanedResponse'");

      final result = jsonDecode(cleanedResponse);

      if (result['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _mostrarError(result['message'] ?? 'Usuario o contraseña incorrectos.');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF3C41),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/imagelogo.png',
                  width: 500,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  TextField(
                    controller: _userController,
                    decoration: _buildInputDecoration(
                      icon: Icons.person,
                      hintText: 'USUARIO',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: _buildInputDecoration(
                      icon: Icons.lock,
                      hintText: 'CONTRASEÑA',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.check_box_outline_blank, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "RECORDAR USUARIO",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      ),
                      Text(
                        "NO RECUERDAS TU CONTRASEÑA?",
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3C41),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text(
                      'LOGIN',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("NO TIENES CUENTA DE USUARIO? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'CREAR CUENTA DE USUARIO',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required IconData icon,
    required String hintText,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hintText,
      filled: true,
      fillColor: Colors.white70,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
