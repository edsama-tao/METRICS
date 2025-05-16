import 'package:flutter/material.dart';
import 'perfil_usuario.dart';
import 'import_export.dart';
import 'login.dart';
import 'registro.dart';
import 'package:metrics/screens/global.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFF3C41),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                _buildDrawerButton("Perfil", Icons.person, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PerfilUsuarioScreen()),
                  );
                }, context),
                _buildDrawerButton("Importar/Exportar", Icons.import_export, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ImportExportScreen()),
                  );
                }, context),
                if (globalTipoUser == 'admin')
                  _buildDrawerButton("Registrar Usuario", Icons.person_add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/imagelogo.png',
                height: 110, // 🔼 Aumentado el tamaño del logo
              ),
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
      ),
    );
  }
}
