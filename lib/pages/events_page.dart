import 'package:flutter/material.dart';
import 'package:invite_scanner_qr/pages/scan_event_page.dart';
import 'package:invite_scanner_qr/pages/view_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<Map<String, dynamic>> events = [
  {
    "name": "Boda",
    "guests": [
      {"name": "Juan", "confirmed": true, "scanned": true, "scanTime": "10:30 AM"},
      {"name": "María", "confirmed": true, "scanned": false, "scanTime": null},
      {"name": "Carlos", "confirmed": false, "scanned": false, "scanTime": null},
      {"name": "Ana", "confirmed": true, "scanned": true, "scanTime": "11:00 AM"},
      {"name": "Luis", "confirmed": false, "scanned": false, "scanTime": null},
    ]
  },
  {
    "name": "XV años",
    "guests": [
      {"name": "Pedro", "confirmed": true, "scanned": false, "scanTime": null},
      {"name": "Laura", "confirmed": true, "scanned": true, "scanTime": "2:30 PM"},
      {"name": "Sofía", "confirmed": false, "scanned": false, "scanTime": null},
      {"name": "Fernando", "confirmed": true, "scanned": true, "scanTime": "3:00 PM"},
      {"name": "Valentina", "confirmed": false, "scanned": false, "scanTime": null},
    ]
  },
];

  int? selectedEventIndex;

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Ver Invitados'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewEventPage(event: events[selectedEventIndex!]),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Escanear Invitados'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanEventPage(event: events[selectedEventIndex!]),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar Evento'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  _confirmDelete(context, selectedEventIndex!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  events.removeAt(index);
                  selectedEventIndex = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Eventos'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index]['name']),
            selected: selectedEventIndex == index,
            onTap: () {
              setState(() {
                selectedEventIndex = index;
              });
              _showOptions(context);
            },
          );
        },
      ),
      floatingActionButton: selectedEventIndex != null
          ? FloatingActionButton(
              onPressed: () => _showOptions(context),
              child: const Icon(Icons.menu),
            )
          : null,
    );
  }
}