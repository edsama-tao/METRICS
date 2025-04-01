import 'package:flutter/material.dart';

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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF3C41), // Fondo rojo
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/imagelogo.png',
                  width: 500, // Aumentado para que se vea más grande
                  fit: BoxFit.contain, // Mantiene proporción sin deformar
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
                  _buildTextField(
                    icon: Icons.person,
                    hintText: 'USUARIO',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    icon: Icons.lock,
                    hintText: 'CONTRASEÑA',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.check_box_outline_blank, size: 16),
                          SizedBox(width: 4),
                          Text("RECORDAR USUARIO",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.blue)),
                        ],
                      ),
                      Text("NO RECUERDAS TU CONTRASEÑA?",
                          style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD83535),
                      minimumSize: Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'LOGIN',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("NO TIENES CUENTA DE USUARIO? "),
                  TextButton(
                    onPressed: () {},
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

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required bool obscureText,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white70,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
