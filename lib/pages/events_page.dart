// import 'package:flutter/material.dart';
// import 'package:invite_scanner_qr/pages/view_event_page.dart';
// import 'add_event_page.dart';

// class EventsPage extends StatefulWidget {
//   const EventsPage({super.key});

//   @override
//   _EventsPageState createState() => _EventsPageState();
// }

// class _EventsPageState extends State<EventsPage> {
//   List<Map<String, dynamic>> events = [];

//   void _addNewEvent(Map<String, dynamic> newEvent) {
//     setState(() {
//       events.add(newEvent);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Listado de Eventos')),
//       body: ListView.builder(
//         itemCount: events.length,
//         itemBuilder: (context, index) {
//           final event = events[index];
//           return ListTile(
//             title: Text(event['name']),
//             subtitle: Text('Fecha: ${event['date']}'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ViewEventPage(event: event),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddEventPage(onAddEvent: _addNewEvent),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';
// import 'dart:io';

// class EventsPage extends StatefulWidget {
//   const EventsPage({super.key});

//   @override
//   _EventsPageState createState() => _EventsPageState();
// }

// class _EventsPageState extends State<EventsPage> {
//   final List<Map<String, dynamic>> events = [];
//   int? selectedEventIndex;

//   Future<void> _addEventFromExcel() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx'],
//     );

//     if (result != null) {
//       final fileBytes = result.files.single.bytes!;
//       final excel = Excel.decodeBytes(fileBytes);

//       String eventName = result.files.single.name.split('.').first;
//       List<Map<String, dynamic>> guests = [];

//       for (var table in excel.tables.keys) {
//         var rows = excel.tables[table]?.rows;
//         if (rows != null && rows.isNotEmpty) {
//           for (int i = 1; i < rows.length; i++) {
//             var row = rows[i];
//             guests.add({
//               "name": row[0]?.value ?? '',
//               "mesa": row[1]?.value ?? 0,
//               "personas": row[2]?.value ?? 0,
//               "invitado_por": row[3]?.value ?? '',
//               "confirmo_asistencia": row[4]?.value ?? 'No',
//               "asistencia": row[5]?.value ?? 'No',
//             });
//           }
//         }
//       }

//       setState(() {
//         events.add({"name": eventName, "guests": guests});
//       });
//     }
//   }

//   void _showOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.visibility),
//                 title: const Text('Ver Invitados'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ViewEventPage(
//                         event: events[selectedEventIndex!],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.qr_code_scanner),
//                 title: const Text('Escanear Invitados'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ScanEventPage(
//                         event: events[selectedEventIndex!],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.delete),
//                 title: const Text('Eliminar Evento'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _confirmDelete(context, selectedEventIndex!);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _confirmDelete(BuildContext context, int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirmar eliminación'),
//           content: const Text('¿Estás seguro de que quieres eliminar este evento?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancelar'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   events.removeAt(index);
//                   selectedEventIndex = null;
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Eliminar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Listado de Eventos'),
//       ),
//       body: events.isNotEmpty
//           ? ListView.builder(
//               itemCount: events.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(events[index]['name']),
//                   selected: selectedEventIndex == index,
//                   onTap: () {
//                     setState(() {
//                       selectedEventIndex = index;
//                     });
//                     _showOptions(context);
//                   },
//                 );
//               },
//             )
//           : const Center(
//               child: Text('No hay eventos disponibles.'),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addEventFromExcel,
//         child: const Icon(Icons.add),
//         tooltip: 'Añadir Evento desde Excel',
//       ),
//     );
//   }
// }

// class ViewEventPage extends StatelessWidget {
//   final Map<String, dynamic> event;
//   const ViewEventPage({Key? key, required this.event}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final guests = event['guests'] as List<Map<String, dynamic>>;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Invitados - ${event['name']}"),
//       ),
//       body: ListView.builder(
//         itemCount: guests.length,
//         itemBuilder: (context, index) {
//           final guest = guests[index];
//           return ListTile(
//             title: Text(guest['name']),
//             subtitle: Text("Mesa: ${guest['mesa']} - Confirmado: ${guest['confirmo_asistencia']}"),
//           );
//         },
//       ),
//     );
//   }
// }

// class ScanEventPage extends StatelessWidget {
//   final Map<String, dynamic> event;
//   const ScanEventPage({Key? key, required this.event}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Aquí iría la lógica de escaneo para los invitados del evento
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Escanear Invitados - ${event['name']}"),
//       ),
//       body: const Center(
//         child: Text("Escanear QR para invitados"),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:invite_scanner_qr/pages/scan_event_page.dart';
import 'package:invite_scanner_qr/pages/view_event_page.dart';
import 'add_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredEvents = events;
  }

  void _addNewEvent(Map<String, dynamic> newEvent) {
    setState(() {
      events.add(newEvent);
      _filterEvents();
    });
  }

  void _filterEvents() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredEvents = events;
      } else {
        filteredEvents = events
            .where((event) =>
                event['name'].toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  void _showOptions(BuildContext context, Map<String, dynamic> event) {
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewEventPage(event: event),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Escanear Invitados'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanEventPage(event: event),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar Evento'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, event);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> event) {
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
                  events.remove(event);
                  _filterEvents();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EventSearchDelegate(events, _showOptions),
              );
            },
          ),
        ],
      ),
      body: filteredEvents.isNotEmpty
          ? ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text('Fecha: ${event['date']}'),
                  onTap: () {
                    _showOptions(context, event);
                  },
                );
              },
            )
          : const Center(
              child: Text('No hay eventos disponibles.'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventPage(onAddEvent: _addNewEvent),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EventSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> events;
  final Function(BuildContext, Map<String, dynamic>) onEventSelected;

  EventSearchDelegate(this.events, this.onEventSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = events
        .where((event) => event['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        return ListTile(
          title: Text(event['name']),
          subtitle: Text('Fecha: ${event['date']}'),
          onTap: () {
            close(context, null);
            onEventSelected(context, event);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = events
        .where((event) => event['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final event = suggestions[index];
        return ListTile(
          title: Text(event['name']),
          subtitle: Text('Fecha: ${event['date']}'),
          onTap: () {
            query = event['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
