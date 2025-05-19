import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'tareas.dart';
import 'package:metrics/screens/global.dart';

import '../utils/importer.dart'; // Importación condicional

import 'dart:io';

class ImportExcelScreen extends StatefulWidget {
  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  String? fileName;
  Uint8List? fileBytes;
  File? mobileFile;

  Future<void> pickExcelFile() async {
    if (kIsWeb) {
      await seleccionarArchivoExcelWeb((bytes) {
        setState(() {
          fileBytes = bytes as Uint8List?;
          fileName = 'archivo_subido.xlsx';
        });
      });
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          mobileFile = File(result.files.single.path!);
          fileName = result.files.single.name;
        });
      }
    }
  }

  Future<void> uploadExcelFile() async {
    if ((kIsWeb && fileBytes == null) || (!kIsWeb && mobileFile == null)) {
      _showSnack('Primero selecciona un archivo Excel');
      return;
    }

    try {
      final uri = Uri.parse('http://10.100.101.46/importador_excel/import_excel.php');
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'excel_file',
            fileBytes!,
            filename: fileName ?? 'archivo.xlsx',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('excel_file', mobileFile!.path),
        );
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnack('Archivo importado correctamente.');
        print(responseBody.body);
      } else {
        _showSnack('Error al subir el archivo.');
        print(responseBody.body);
      }
    } catch (e) {
      _showSnack('Error inesperado: \$e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 85,
          child: Image.asset(
            'assets/imagelogo.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_file, size: 70, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'SUBE TU ARCHIVO EXCEL PARA IMPORTARLO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3C41),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black26,
                  ),
                  icon: const Icon(Icons.file_present, color: Colors.white),
                  label: Text(
                    fileName == null
                        ? 'SELECCIONAR ARCHIVO EXCEL'
                        : 'Seleccionado: \$fileName',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: pickExcelFile,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3C41),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black26,
                  ),
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: const Text(
                    'SUBIR ARCHIVO',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: uploadExcelFile,
                ),
              ],
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
                    builder: (_) => ActividadDiariaScreen(
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
