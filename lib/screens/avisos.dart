import 'package:flutter/material.dart';
import 'home.dart';
import 'custom_drawer.dart';

class AvisosScreen extends StatelessWidget {
  const AvisosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Icon> avisos = [
      const Icon(Icons.warning, color: Colors.amber, size: 32),
      const Icon(Icons.warning, color: Colors.amber, size: 32),
      const Icon(Icons.warning, color: Colors.amber, size: 32),
      const Icon(Icons.warning, color: Colors.amber, size: 32),
      const Icon(Icons.warning, color: Colors.amber, size: 32),
      const Icon(Icons.warning_amber_outlined, color: Colors.red, size: 32),
      const Icon(Icons.warning, color: Colors.amber, size: 32),
    ];

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: avisos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        avisos[index],
                        const SizedBox(width: 12),
                        const Text(
                          'Aviso importante recibido',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(Icons.calendar_month, color: Colors.white),
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
                // Ir a esta misma pantalla (para efecto desde otra)
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
