import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart';
import 'custom_drawer.dart';
import 'home.dart';
import 'tareas.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  List<Map<String, dynamic>> avisos = [];

  @override
  void initState() {
    super.initState();
    _cargarAvisos();
  }

  Future<void> _cargarAvisos() async {
    final url = Uri.parse('http://10.100.0.9/flutter_api/get_avisos_usuario.php');
    try {
      final response = await http.post(url, body: {
        'id_user': globalUserId.toString(),
      });

      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        final tipoUser = result['tipoUser'];
        final horasAcuerdo = result['horasAcuerdo'];

        List<Map<String, dynamic>> listaAvisos = [];

        if (tipoUser == "estudiante") {
          if (horasAcuerdo != null) {
            if (horasAcuerdo >= 383) {
              listaAvisos.add({
                "icono": const Icon(Icons.warning, color: Colors.red),
                "mensaje": "Has assolit les 383 hores. Finalitza l’acord.",
              });
            } else {
              final restantes = 383 - horasAcuerdo;
              listaAvisos.add({
                "icono": const Icon(Icons.info, color: Colors.orange),
                "mensaje": "Et falten $restantes hores per completar l’acord.",
              });
            }
          } else {
            listaAvisos.add({
              "icono": const Icon(Icons.warning_amber, color: Colors.amber),
              "mensaje": "No hi ha dades d’hores informades al teu acord.",
            });
          }
        } else if (tipoUser == "admin") {
          listaAvisos.add({
            "icono": const Icon(Icons.admin_panel_settings, color: Colors.blue),
            "mensaje": "Revisa els acords actius dels estudiants.",
          });
        }

        setState(() {
          avisos = listaAvisos;
        });
      } else {
        _mostrarError("No es van poder carregar els avisos.");
      }
    } catch (e) {
      _mostrarError("Error de connexió: $e");
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
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
        centerTitle: true, // ✅ Asegura que el título esté centrado
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('NOTIFICACIONS:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: avisos.isEmpty
                      ? const Center(child: Text("No hi ha avisos."))
                      : ListView.separated(
                          itemCount: avisos.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final aviso = avisos[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  aviso['icono'],
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(aviso['mensaje'])),
                                ],
                              ),
                            );
                          },
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
}
