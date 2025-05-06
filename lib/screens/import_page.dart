import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// Navegación y componentes comunes
import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'tareas.dart';
import 'package:metrics/screens/global.dart';

// Web
import 'dart:typed_data';
import 'dart:html' as html;

// Móvil
import 'dart:io' as io;

class ImportExcelScreen extends StatefulWidget {
  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  String? fileName;
  Uint8List? fileBytes; // para web
  io.File? mobileFile;  // para móvil

  // Elegir archivo
  Future<void> pickExcelFile() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = '.xls,.xlsx';
      uploadInput.click();
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files.first;
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            setState(() {
              fileName = file.name;
              fileBytes = reader.result as Uint8List;
            });
          });
        }
      });
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          mobileFile = io.File(result.files.single.path!);
          fileName = result.files.single.name;
        });
      }
    }
  }

  // Subir archivo
  Future<void> uploadExcelFile() async {
    if ((kIsWeb && fileBytes == null) || (!kIsWeb && mobileFile == null)) {
      _showSnack('Primero selecciona un archivo Excel');
      return;
    }

    try {
      final uri = Uri.parse('http://10.100.0.9/importador_excel/import_excel.php');
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'excel_file',
          fileBytes!,
          filename: fileName ?? 'archivo.xlsx',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'excel_file',
          mobileFile!.path,
        ));
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
      _showSnack('Error inesperado: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3C41),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.file_present, color: Colors.white),
                label: Text(
                  fileName == null
                      ? 'Seleccionar archivo Excel'
                      : 'Seleccionado: $fileName',
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: pickExcelFile,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3C41),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text('Subir archivo'),
                onPressed: uploadExcelFile,
              ),
            ],
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
