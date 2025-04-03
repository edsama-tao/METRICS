import 'package:flutter/material.dart';
import 'custom_drawer.dart'; // Asegúrate de que el archivo exista

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(), // ✅ Drawer real
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        centerTitle: true,
        title: const Text('Import/export'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          _buildRoundedButton(context, 'IMPORT'),
          const SizedBox(height: 30),
          _buildRoundedButton(context, 'EXPORT'),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.calendar_month, color: Colors.white),
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.mail, color: Colors.white),
          ],
        ),
      ),
    );
  }

  static Widget _buildRoundedButton(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 70, // ⬅️ Botón más alto
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label presionado')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD83535),
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
