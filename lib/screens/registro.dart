import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metrics/screens/global.dart';
import 'dart:convert';
import 'tareas.dart';
import 'custom_drawer.dart';
 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final dniController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registrarUsuario() async {
    final url = Uri.parse("http://10.100.0.9/flutter_api/registrar_usuario.php");

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombreController.text,
          'apellidos': apellidosController.text,
          'dni': dniController.text,
          'correo': correoController.text,
          'telefono': telefonoController.text,
          'nombreUsuario': usuarioController.text,
          'contrasena': passwordController.text,
        }),
      );

      print('Código HTTP: ${respuesta.statusCode}');
      print('Respuesta del servidor: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final resultado = jsonDecode(respuesta.body);
        if (resultado['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${resultado['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en la petición (${respuesta.statusCode})')),
        );
      }
    } catch (e) {
      print('Error en conexión HTTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF3C41),
      endDrawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: false,
        title: Center(
          child: Transform.scale(
            scale: 1.4,
            child: Image.asset(
              'assets/imagelogo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
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
                buildTextFormField(nombreController, Icons.person, 'NOMBRE', false),
                buildTextFormField(apellidosController, Icons.person_outline, 'APELLIDOS', false),
                buildTextFormField(dniController, Icons.badge, 'DNI', false),
                buildTextFormField(correoController, Icons.email, 'CORREO', false),
                buildTextFormField(telefonoController, Icons.phone, 'TELÉFONO', false),
                buildTextFormField(usuarioController, Icons.account_circle, 'USUARIO', false),
                buildTextFormField(passwordController, Icons.lock, 'CONTRASEÑA', true),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD83535),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registrarUsuario();
                    }
                  },
                  child: const Text(
                    'REGISTRAR USUARIO',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActividadDiariaScreen(userId: globalUserId),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                // Acción icono de Home
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                // Acción icono de Avisos
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(
      TextEditingController controller, IconData icon, String hint, bool obscure) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Completa este campo' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          filled: true,
          fillColor: Colors.white70,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}