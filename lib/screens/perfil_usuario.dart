import 'package:flutter/material.dart';
import 'package:metrics/screens/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home.dart';
import 'avisos.dart';
import 'custom_drawer.dart';
import 'tareas.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  Map<String, dynamic>? usuarioData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    // 🛠️ Validación y depuración
    print('📡 Enviando ID: $globalUserId');

    if (globalUserId == 0) {
      print('❌ ID inválido. No se puede cargar el usuario.');
      setState(() {
        isLoading = false;
        usuarioData = null;
      });
      return;
    }

    final url = Uri.parse("http://10.100.0.9/flutter_api/get_usuario.php");

    try {
      final response = await http.post(url, body: {'id_user': globalUserId.toString()});
      print('✅ Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Si viene un error desde el backend
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          print('⚠️ Error desde PHP: ${data['error']}');
          setState(() {
            usuarioData = null;
            isLoading = false;
          });
        } else {
          setState(() {
            usuarioData = data;
            isLoading = false;
          });
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Excepción: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : usuarioData == null
              ? const Center(child: Text("No se encontró el usuario."))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    buildInfoTile('NOMBRE DE USUARIO', usuarioData?['nombreUsuario'] ?? ''),
                    buildInfoTile('NOMBRE', usuarioData?['nombre'] ?? ''),
                    buildInfoTile('APELLIDOS', usuarioData?['apellidos'] ?? ''),
                    buildInfoTile('DNI', usuarioData?['dni'] ?? ''),
                    buildInfoTile('CORREO', usuarioData?['correo'] ?? ''),
                    buildInfoTile('TELÉFONO', usuarioData?['telefono'] ?? ''),
                    buildInfoTile('FECHA NACIMIENTO', usuarioData?['fechaNacimiento'] ?? ''),
                    buildInfoTile('TIPO DE USUARIO', usuarioData?['tipoUser'] ?? ''),
                  ],
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

  Widget buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}