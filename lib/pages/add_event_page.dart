// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';

// class AddEventPage extends StatefulWidget {
//   final Function(Map<String, dynamic>) onAddEvent;

//   const AddEventPage({super.key, required this.onAddEvent});

//   @override
//   _AddEventPageState createState() => _AddEventPageState();
// }

// class _AddEventPageState extends State<AddEventPage> {
//   final TextEditingController _eventDateController = TextEditingController();
//   final TextEditingController _guestCountController = TextEditingController();
//   final TextEditingController _startTimeController = TextEditingController();
//   List<Map<String, dynamic>> guests = [];
//   File? excelFile;

//   void _pickExcelFile() async {
//     final result = await FilePicker.platform
//         .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
//     if (result != null) {
//       setState(() {
//         excelFile = File(result.files.single.path!);
//       });
//       _loadGuestsFromExcel(excelFile!);
//     }
//   }

//   void _loadGuestsFromExcel(File file) async {
//     final bytes = file.readAsBytesSync();
//     final excel = Excel.decodeBytes(bytes);

//     // Ajustar la función para leer las columnas de tu archivo
//     for (var table in excel.tables.keys) {
//       final sheet = excel.tables[table];
//       if (sheet != null) {
//         for (var row in sheet.rows.skip(1)) {
//           setState(() {
//             guests.add({
//               "name": row[0]?.value.toString(), // Nombre
//               "table": row[1]?.value.toString(), // Mesa
//               "peopleCount": row[2]?.value.toString(), // Personas
//               "invitedBy": row[3]?.value.toString(), // Invitado por
//               "confirmed": row[4]?.value.toString().toLowerCase() == "si", // Confirmó asistencia
//               "scanned": row[5]?.value.toString().toLowerCase() == "si", // Asistencia
//               "timeScanned": row[6]?.value.toString()
//             });
//           });
//         }
//         print(guests);
//       }
//     }
//   }

//   void _addEvent() {
//     if (_eventDateController.text.isNotEmpty && excelFile != null) {
//       widget.onAddEvent({
//         "name": excelFile!.path.split('/').last.split('.').first,
//         "date": _eventDateController.text,
//         "guestCount": _guestCountController.text,
//         "startTime": _startTimeController.text,
//         "guests": guests,
//       });
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Por favor completa todos los campos')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Agregar Evento')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _eventDateController,
//               decoration: const InputDecoration(labelText: 'Fecha del Evento'),
//             ),
//             TextField(
//               controller: _guestCountController,
//               decoration:
//                   const InputDecoration(labelText: 'Cantidad de Personas'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: _startTimeController,
//               decoration:
//                   const InputDecoration(labelText: 'Hora de Inicio del Evento'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickExcelFile,
//               child: const Text('Añadir desde archivo Excel'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addEvent,
//               child: const Text('Agregar Evento'),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: guests.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(guests[index]['name']),
//                     subtitle: Text(guests[index]['confirmed']
//                         ? 'si'
//                         : 'no'),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  String? _selectedType;
  String? _eventId;
  List<Map<String, dynamic>> guests = [];
  File? excelFile;

  final Map<String, String> eventTypes = {
    'BODA': 'Boda',
    'XV': 'XV años',
    'CUMPLE': 'Cumpleaños',
    'CUMPL': 'Aniversario',
    'OTRO': 'Otro'
  };

  // Función para seleccionar el archivo de Excel
  void _pickExcelFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result != null) {
      setState(() {
        excelFile = File(result.files.single.path!);
      });
      _loadGuestsFromExcel(excelFile!);
    }
  }

  // Cargar invitados desde el archivo de Excel
  void _loadGuestsFromExcel(File file) async {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet != null) {
        for (var row in sheet.rows.skip(1)) {
          setState(() {
            guests.add({
              "name": row[0]?.value.toString(),
              "table": row[1]?.value.toString(),
              "peopleCount": row[2]?.value.toString(),
              "invitedBy": row[3]?.value.toString(),
              "confirmed": row[4]?.value.toString().toLowerCase() == "si",
              "scanned": row[5]?.value.toString().toLowerCase() == "si",
              "timeScanned": row[6]?.value.toString()
            });
          });
        }
      }
    }
  }

  // Generar un ID único para el evento
  Future<void> _generateEventId() async {
    if (_selectedType == null) return;

    // Obtener el tipo seleccionado en formato corto
    String typePrefix = _selectedType!;

    // Obtener los eventos que empiezan con el tipo seleccionado
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('type', isEqualTo: typePrefix)
        .orderBy('eventId', descending: true)
        .limit(1)
        .get();

    // Calcular el siguiente ID
    String nextId;
    if (querySnapshot.docs.isEmpty) {
      nextId = '$typePrefix-0001';
    } else {
      // Obtener el último ID y calcular el siguiente
      String lastId = querySnapshot.docs.first['eventId'];
      int lastNumber = int.parse(lastId.split('-').last);
      nextId = '$typePrefix-${(lastNumber + 1).toString().padLeft(4, '0')}';
    }

    setState(() {
      _eventId = nextId;
    });
  }

  // Función para agregar el evento y los invitados a Firestore
  void _addEvent() async {
    if (_eventDateController.text.isNotEmpty && excelFile != null) {
      await _generateEventId();

      // Añade el evento a Firestore
      final eventDoc = await FirebaseFirestore.instance.collection('events').add({
        "name": excelFile!.path.split('/').last.split('.').first,
        "date": _eventDateController.text,
        "guestCount": _guestCountController.text,
        "startTime": _startTimeController.text,
        "type": _selectedType,
        "eventId": _eventId,
      });

      // Añade cada invitado al evento en Firestore
      for (var guest in guests) {
        // Generar un guestId único basado en el índice
        String guestId = '$_eventId-${guests.indexOf(guest) + 1}';

        await eventDoc.collection('guests').add({
          ...guest,
          'eventId': _eventId,
          'guestId': guestId,
        });
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  // Función para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _eventDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Función para seleccionar la hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTimeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Evento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventDateController,
              decoration: const InputDecoration(
                labelText: 'Fecha del Evento',
                hintText: 'Selecciona la fecha',
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            TextField(
              controller: _guestCountController,
              decoration: const InputDecoration(labelText: 'Cantidad de Personas'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: 'Hora de Inicio del Evento',
                hintText: 'Selecciona la hora',
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: eventTypes.entries
                  .map((entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Tipo de evento'),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione un tipo' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickExcelFile,
              child: const Text('Añadir desde archivo Excel'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEvent,
              child: const Text('Agregar Evento'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: guests.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(guests[index]['name']),
                    subtitle: Text(guests[index]['confirmed'] ? 'sí' : 'no'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

