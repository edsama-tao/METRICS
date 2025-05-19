import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> exportarArchivo(List<int> bytes, [dynamic context]) async {
  if (await Permission.storage.request().isGranted) {
    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/usuarios.xlsx');
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Archivo exportado correctamente')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permiso de almacenamiento denegado')),
    );
  }
}
