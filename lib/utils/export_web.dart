import 'dart:html' as html;

Future<void> exportarArchivo(List<int> bytes, [dynamic _]) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'usuarios.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}

