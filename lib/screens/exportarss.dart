import 'package:flutter/material.dart';
import 'package:metrics/screens/custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'tareas.dart'; // Importa TareasScreen
import 'package:metrics/screens/global.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final Map<String, bool> _fields = {
    'Nombre y Apellidos': false,
    'DNI': false,
    'FECHA NACIMIENTO': false,
    'Numero SS': false,
    'Telefono': false,
  };

  bool _selectAll = false;

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      _fields.updateAll((key, _) => _selectAll);
    });
  }

  void _toggleField(String key, bool? value) {
    setState(() {
      _fields[key] = value ?? false;
      _selectAll = _fields.values.every((selected) => selected);
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Exportar Datos de\nSeguridad Social',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Seleccione los datos a exportar',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ..._fields.entries.map((entry) {
              return CheckboxListTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                value: entry.value,
                onChanged: (value) => _toggleField(entry.key, value),
              );
            }),
            CheckboxListTile(
              title: const Text(
                'Seleccionar todo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _selectAll,
              onChanged: _toggleSelectAll,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD83535),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  final selected =
                      _fields.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList();
                  if (selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seleccione al menos un dato'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exportando: ${selected.join(', ')}'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'EXPORTAR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
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
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ), // Va a Home
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvisosScreen(),
                  ), // Va a la pantalla de avisos
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
