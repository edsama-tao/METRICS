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
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(
      String text, IconData icon, VoidCallback onTap, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
      ),
    );
  }
}
