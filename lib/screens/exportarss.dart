import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/exporter.dart';
import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'tareas.dart';
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
    'Fecha Nacimiento': false,
    'Número SS': false,
    'Teléfono': false,
    'Contrato': false,
  };
  bool _selectAllFields = false;
  List<Map<String, dynamic>> usuarios = [];
  Map<int, bool> selectedUsers = {};
  bool _loading = true;
  String _busqueda = '';
  bool _selectAllUsers = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    final url = Uri.parse('http://10.100.101.46/flutter_api/listar_usuarios.php');
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
  final selectedFields =
      _fields.entries.where((e) => e.value).map((e) => e.key).toList();
  final selectedIds =
      selectedUsers.entries.where((e) => e.value).map((e) => e.key).toList();

  if (selectedIds.isEmpty || selectedFields.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SELECCIONE AL MENOS UN USUARIO Y UN CAMPO'),
      ),
    );
    return;
  }

  try {
    final uri = Uri.parse(
      'http://10.100.101.46/flutter_api/exportar_usuarios.php',
    );
    final response = await http.post(
      uri,
      body: {
        'ids': selectedIds.join(','),
        'fields': selectedFields.join(','),
      },
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await exportarArchivo(bytes, context); // ✅ USO UNIFICADO
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 85,
          child: Image.asset('assets/imagelogo.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_download,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'EXPORTAR USUARIOS A EXCEL',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selecciona los campos y los usuarios que deseas exportar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'CAMPOS A INCLUIR:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 20,
                            runSpacing: 8,
                            children:
                                _fields.entries.map((entry) {
                                  return SizedBox(
                                    width: 300,
                                    child: CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(entry.key),
                                      value: entry.value,
                                      onChanged:
                                          (val) => _toggleField(entry.key, val),
                                    ),
                                  );
                                }).toList(),
                          ),
                          CheckboxListTile(
                            title: const Text('Seleccionar todos los campos'),
                            value: _selectAllFields,
                            onChanged: _toggleSelectAllFields,
                          ),
                          const Divider(height: 40, thickness: 1),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'BUSCAR USUARIO:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Escribe un nombre de usuario',
                              prefixIcon: const Icon(Icons.search),
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() => _busqueda = value.toLowerCase());
                            },
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'USUARIOS DISPONIBLES:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CheckboxListTile(
                            title: const Text('Seleccionar todos los usuarios'),
                            value: _selectAllUsers,
                            onChanged: (val) {
                              setState(() {
                                _selectAllUsers = val ?? false;
                                selectedUsers.updateAll(
                                  (key, _) => _selectAllUsers,
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              child: ListView(
                                controller: _scrollController,
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                children:
                                    usuarios
                                        .where(
                                          (usuario) => usuario['nombreUsuario']
                                              .toLowerCase()
                                              .contains(_busqueda),
                                        )
                                        .map((usuario) {
                                          final id = int.parse(
                                            usuario['id_user'],
                                          );
                                          final name = usuario['nombreUsuario'];
                                          return CheckboxListTile(
                                            title: Text(name),
                                            value: selectedUsers[id],
                                            onChanged: (val) {
                                              setState(() {
                                                selectedUsers[id] =
                                                    val ?? false;
                                              });
                                            },
                                          );
                                        })
                                        .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: exportarUsuariosSeleccionados,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text(
                              'EXPORTAR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD83535),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black38,
                            ),
                          ),
                        ],
                      ),
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
}
