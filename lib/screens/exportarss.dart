import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metrics/screens/custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'tareas.dart';
import 'package:metrics/screens/global.dart';

// Solo para móvil
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

// Solo para web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
  bool _selectAllFields = false;

  List<Map<String, dynamic>> usuarios = [];
  Map<int, bool> selectedUsers = {};
  bool _loading = true;
  String _busqueda = '';
  bool _selectAllUsers = false;

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    final url = Uri.parse('http://10.100.0.9/flutter_api/listar_usuarios.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        usuarios = data.cast<Map<String, dynamic>>();
        for (var usuario in usuarios) {
          selectedUsers[int.parse(usuario['id_user'])] = false;
        }
        _loading = false;
      });
    }
  }

  void _toggleSelectAllFields(bool? value) {
    setState(() {
      _selectAllFields = value ?? false;
      _fields.updateAll((key, _) => _selectAllFields);
    });
  }

  void _toggleField(String key, bool? value) {
    setState(() {
      _fields[key] = value ?? false;
      _selectAllFields = _fields.values.every((v) => v);
    });
  }

  Future<void> exportarUsuariosSeleccionados() async {
    final selectedFields = _fields.entries.where((e) => e.value).map((e) => e.key).toList();
    final selectedIds = selectedUsers.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedIds.isEmpty || selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un usuario y un campo')),
      );
      return;
    }

    try {
      final uri = Uri.parse('http://10.100.0.9/flutter_api/exportar_usuarios.php');
      final response = await http.post(uri, body: {
        'ids': selectedIds.join(','),
        'fields': selectedFields.join(','),
      });

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (kIsWeb) {
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..target = 'blank'
            ..download = 'usuarios_exportados.xlsx';

          html.document.body!.append(anchor);
          anchor.click();
          anchor.remove();
          html.Url.revokeObjectUrl(url);
        } else {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de almacenamiento denegado')),
            );
            return;
          }

          final directory = await getExternalStorageDirectory();
          final filePath = '${directory!.path}/usuarios_exportados.xlsx';
          final file = io.File(filePath);
          await file.writeAsBytes(bytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Archivo guardado en: $filePath')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
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
            child: Image.asset('assets/imagelogo.png', height: 40),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seleccione los campos a exportar', style: TextStyle(fontSize: 16)),
                  ..._fields.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      value: entry.value,
                      onChanged: (val) => _toggleField(entry.key, val),
                    );
                  }),
                  CheckboxListTile(
                    title: const Text('Seleccionar todos los campos', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: _selectAllFields,
                    onChanged: _toggleSelectAllFields,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Buscar usuario:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar por nombre de usuario',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _busqueda = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Seleccione los usuarios a exportar', style: TextStyle(fontSize: 16)),
                  CheckboxListTile(
                    title: const Text('Seleccionar todos los usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: _selectAllUsers,
                    onChanged: (val) {
                      setState(() {
                        _selectAllUsers = val ?? false;
                        selectedUsers.updateAll((key, _) => _selectAllUsers);
                      });
                    },
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 350),
                    child: ListView(
                      shrinkWrap: true,
                      children: usuarios.where((usuario) {
                        final nombre = usuario['nombreUsuario'].toLowerCase();
                        return nombre.contains(_busqueda);
                      }).map((usuario) {
                        final id = int.parse(usuario['id_user']);
                        final name = usuario['nombreUsuario'];
                        return CheckboxListTile(
                          title: Text(name),
                          value: selectedUsers[id],
                          onChanged: (val) {
                            setState(() {
                              selectedUsers[id] = val ?? false;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: exportarUsuariosSeleccionados,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD83535),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
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
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ActividadDiariaScreen(userId: globalUserId),
                ));
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AvisosScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
