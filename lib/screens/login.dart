import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'home.dart';
import 'package:metrics/screens/global.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool recordarUsuario = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioGuardado();
  }

  Future<void> _cargarUsuarioGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString('usuarioRecordado') ?? '';
    if (guardado.isNotEmpty) {
      _userController.text = guardado;
      setState(() {
        recordarUsuario = true;
      });
    }
  }

  Future<void> _login() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    final url = Uri.parse("http://10.100.0.9/flutter_api/login_usuario.php");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'nombreUsuario': user, 'contrasena': pass},
      );

      final cleanedResponse = response.body.replaceAll('\uFEFF', '').trim();
      final result = jsonDecode(cleanedResponse);

      if (result['status'] == 'success') {
        globalUserId =
            result['id_user'] is int
                ? result['id_user']
                : int.parse(result['id_user'].toString());
        globalTipoUser = result['tipoUser'].toString();

        final prefs = await SharedPreferences.getInstance();
        if (recordarUsuario) {
          await prefs.setString('usuarioRecordado', user);
        } else {
          await prefs.remove('usuarioRecordado');
        }
        await prefs.setString('tipoUser', globalTipoUser);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      builder:
          (context) => AlertDialog(
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
            const SizedBox(height: 20), // antes 60 → ahora subimos todo
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
            const SizedBox(
              height: 20,
            ), // antes 40 → ahora más arriba el container
            Center(
              child: Card(
                elevation: 10,
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDEDEE),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: recordarUsuario,
                                    onChanged: (value) {
                                      setState(() {
                                        recordarUsuario = value ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "RECORDAR USUARIO",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Text(
                                  "NO RECUERDAS TU CONTRASEÑA?",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
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
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
