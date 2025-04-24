import 'package:flutter/material.dart';
import 'package:metrics/screens/global.dart';
import 'home.dart';
import 'avisos.dart';
import 'custom_drawer.dart';
import 'tareas.dart'; 

class PerfilUsuarioScreen extends StatelessWidget {
  final Map<String, String> usuario = {
    'NOMBRE DE USUARIO': 'unaipareja',
    'NOMBRE': 'Unai',
    'APELLIDOS': 'Pareja Oncala',
    'DNI': '12345678A',
    'CORREO': 'unaipareja@bemenfp.cat',
    'TELÉFONO': '+34 612 345 678',
    'EMPRESA': 'Procon Systems SA',
    'TUTOR/A CENTRO EDUCATIVO': 'Isabel Latorre',
    'TUTOR EMPRESA': 'David Rodriguez',
  };

  PerfilUsuarioScreen({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: usuario.entries.map((entry) {
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
                    '${entry.key}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41), // Barra inferior igual a Home
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
                  MaterialPageRoute(builder: (_) => const HomeScreen()), // Va a Home
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AvisosScreen()), // Va a la pantalla de avisos
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
