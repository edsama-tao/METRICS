import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

Future<void> exportarArchivo(List<int> bytes, BuildContext context) async {
  PermissionStatus status;

  // Pedir el permiso adecuado según la versión de Android
  if (Platform.isAndroid && (await Permission.manageExternalStorage.status.isDenied || await Permission.manageExternalStorage.status.isRestricted)) {
    status = await Permission.manageExternalStorage.request();
  } else {
    status = await Permission.storage.request();
  }

  if (status.isGranted) {
    try {
      final directory = await getExternalStorageDirectory();

      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo acceder al almacenamiento')),
        );
        return;
      }

      final path = '${directory.path}/usuarios.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo guardado en: $path')),
      );

      // Abrir el archivo automáticamente (opcional)
      await OpenFile.open(path);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar archivo: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permiso de almacenamiento denegado')),
    );
  }
}
