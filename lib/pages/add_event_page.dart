import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddEventPage extends StatelessWidget {
  const AddEventPage({super.key});

  Future<void> _pickExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      var bytes = result.files.single.bytes;
      var excel = Excel.decodeBytes(bytes!);

      List<Map<String, dynamic>> guests = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row[0] != null && row[1] != null) {
            guests.add({
              'name': row[0]!.value.toString(),
              'confirmed': row[1]!.value.toString().toLowerCase() == 'sí',
              'scanned': false,
              'scanTime': null,
            });
          }
        }
      }

      Navigator.pop(context, {'guests': guests});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Evento desde Excel'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _pickExcelFile(context);
          },
          child: const Text('Seleccionar archivo de Excel'),
        ),
      ),
    );
  }
}
