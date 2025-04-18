import 'package:flutter/material.dart';
import 'perfil_usuario.dart';  // Asegúrate de que la ruta sea correcta
import 'import_export.dart';
import 'login.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFF3C41),
      child: Column(
        children: [
          const SizedBox(height: 100),
          _buildDrawerButton("Perfil", Icons.person, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PerfilUsuarioScreen()), // Aquí ya es correcto
            );
          }, context),
          _buildDrawerButton("Importar/Exportar", Icons.import_export, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImportExportScreen()),
            );
          }, context),
          _buildDrawerButton("Cerrar Sesión", Icons.logout, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }, context),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(
      String text, IconData icon, VoidCallback onTap, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
        onTap: () {
          Navigator.of(context).pop(); // Cierra el Drawer
          onTap(); // Ejecuta la acción
        },
      ),
    );
  }
}
