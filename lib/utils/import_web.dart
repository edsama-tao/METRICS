import 'dart:html' as html;
import 'dart:typed_data';

Future<void> seleccionarArchivoExcelWeb(Function(List<int> bytes) onSelected) async {
  final uploadInput = html.FileUploadInputElement()..accept = '.xls,.xlsx';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final file = uploadInput.files!.first;
    final reader = html.FileReader();

    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      final result = reader.result;
      if (result is List<int>) {
        onSelected(result);
      } else if (result is ByteBuffer) {
        onSelected(result.asUint8List());
      }
    });
  });
}
