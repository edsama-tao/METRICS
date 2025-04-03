import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                  const SizedBox(height: 20),
                  buildTextField(icon: Icons.person, hintText: 'NOMBRE', obscureText: false),
                  const SizedBox(height: 10),
                  buildTextField(icon: Icons.person_outline, hintText: 'APELLIDOS', obscureText: false),
                  const SizedBox(height: 10),
                  buildTextField(icon: Icons.badge, hintText: 'DNI', obscureText: false),
                  const SizedBox(height: 10),
                  buildTextField(icon: Icons.email, hintText: 'CORREO', obscureText: false),
                  const SizedBox(height: 10),
                  buildTextField(icon: Icons.phone, hintText: 'TELÉFONO', obscureText: false),
                  const SizedBox(height: 10),
                  buildTextField(icon: Icons.account_circle, hintText: 'TIPO DE USUARIO', obscureText: false),
                  const SizedBox(height: 10),
                  buildTextField(icon: Icons.lock, hintText: 'CONTRASEÑA', obscureText: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD83535),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Acción de registro
                    },
                    child: const Text(
                      'REGISTRARSE',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '¿YA TIENES CUENTA? INICIAR SESIÓN',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildTextField({
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
