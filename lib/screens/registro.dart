import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metrics/screens/global.dart';
import 'dart:convert';
import 'tareas.dart';
import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final fechaNacimientoController = TextEditingController(); // Nuevo
  final dniController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registrarUsuario() async {
    final url = Uri.parse("http://10.100.101.46/flutter_api/registrar_usuario.php");

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombreController.text.trim(),
          'apellidos': apellidosController.text.trim(),
          'fechaNacimiento': fechaNacimientoController.text.trim(),
          'dni': dniController.text.trim(),
          'correo': correoController.text.trim(),
          'telefono': telefonoController.text.trim(),
          'nombreUsuario': usuarioController.text.trim(),
          'contrasena': passwordController.text.trim(),
        }),
      );

      if (respuesta.statusCode == 200) {
        final resultado = jsonDecode(respuesta.body);
        if (resultado['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (resultado['status'] == 'exists') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: El nombre de usuario ya existe')),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        fechaNacimientoController.text =
            "${fechaSeleccionada.day.toString().padLeft(2, '0')}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 85,
          child: Image.asset(
            'assets/imagelogo.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
            child: Form(
              key: _formKey,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    buildTextFormField(nombreController, Icons.person, 'NOMBRE', false),
                    buildTextFormField(apellidosController, Icons.person_outline, 'APELLIDOS', false),
                    buildDatePickerField(fechaNacimientoController, Icons.calendar_today, 'FECHA DE NACIMIENTO'),
                    buildTextFormField(dniController, Icons.badge, 'DNI', false),
                    buildTextFormField(correoController, Icons.email, 'CORREO', false, isGmail: true),
                    buildTextFormField(telefonoController, Icons.phone, 'TELÉFONO', false),
                    buildTextFormField(usuarioController, Icons.account_circle, 'USUARIO', false),
                    buildTextFormField(passwordController, Icons.lock, 'CONTRASEÑA', true),
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
                        if (_formKey.currentState!.validate()) {
                          registrarUsuario();
                        }
                      },
                      child: const Text(
                        'REGISTRAR USUARIO',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
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
                    builder: (_) => ActividadDiariaScreen(
                      userId: globalUserId,
                      fechaSeleccionada: DateTime.now(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AvisosScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(
    TextEditingController controller,
    IconData icon,
    String hint,
    bool obscure, {
    bool isGmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Completa este campo';
          }
          if (isGmail && !RegExp(r'^[\w\.-]+@gmail\.com$').hasMatch(value.trim())) {
            return 'Introduce un correo Gmail válido';
          }
          return null;
        },
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

  Widget buildDatePickerField(
    TextEditingController controller,
    IconData icon,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _seleccionarFecha,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Completa este campo';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              hintText: hint,
              filled: true,
              fillColor: Colors.white70,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ),
    );
  }
}
