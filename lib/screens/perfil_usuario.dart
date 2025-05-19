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
    if (globalUserId == 0) {
      setState(() {
        isLoading = false;
        usuarioData = null;
      });
      return;
    }

    final url = Uri.parse("http://10.100.0.9/flutter_api/get_usuario.php");

    try {
      final response = await http.post(
        url,
        body: {'id_user': globalUserId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('error')) {
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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFEDEDED),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : usuarioData == null
              ? const Center(child: Text("No se encontró el usuario."))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: Text(
                              "DATOS DEL USUARIO",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            buildInfoCard('NOMBRE DE USUARIO', usuarioData?['nombreUsuario'] ?? '', Icons.account_circle),
                            buildInfoCard('NOMBRE', usuarioData?['nombre'] ?? '', Icons.person),
                            buildInfoCard('APELLIDOS', usuarioData?['apellidos'] ?? '', Icons.person_outline),
                            buildInfoCard('DNI', usuarioData?['dni'] ?? '', Icons.badge),
                            buildInfoCard('CORREO', usuarioData?['correo'] ?? '', Icons.email),
                            buildInfoCard('TELÉFONO', usuarioData?['telefono'] ?? '', Icons.phone),
                            buildInfoCard('FECHA NACIMIENTO', usuarioData?['fechaNacimiento'] ?? '', Icons.calendar_today),
                            buildInfoCard('TIPO DE USUARIO', usuarioData?['tipoUser'] ?? '', Icons.verified_user),
                          ],
                        ),
                      ],
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

  Widget buildInfoCard(String label, String value, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 320 : double.infinity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(value, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
