import 'package:flutter/material.dart';
import 'package:metrics/screens/avisos.dart';
import 'package:metrics/screens/global.dart';
import 'package:metrics/screens/import_page.dart';
import 'custom_drawer.dart';
import 'home.dart';
import 'exportarss.dart';
import 'tareas.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFEDEDED),
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
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          _buildRoundedButton(
            context,
            label: 'IMPORT',
            destination: ImportExcelScreen(),
          ),
          const SizedBox(height: 30),
          _buildRoundedButton(
            context,
            label: 'EXPORT',
            destination: const ExportDataScreen(),
          ),
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
                    builder:
                        (_) => ActividadDiariaScreen(
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

  static Widget _buildRoundedButton(
    BuildContext context, {
    required String label,
    required Widget destination,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3C41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
