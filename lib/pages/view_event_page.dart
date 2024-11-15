// import 'package:flutter/material.dart';

// class ViewEventPage extends StatelessWidget {
//   final Map<String, dynamic> event;

//   const ViewEventPage({super.key, required this.event});

//   @override
//   Widget build(BuildContext context) {
//     final guests = event['guests'] as List<Map<String, dynamic>>;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Invitados de ${event['name']}'),
//       ),
//       body: ListView.builder(
//         itemCount: guests.length,
//         itemBuilder: (context, index) {
//           final guest = guests[index];
//           return ListTile(
//             title: Text(guest['name']),
//             subtitle: Text(
//                 'Confirmado: ${guest['confirmed'] ? "si" : "no"}\n'
//                 'Escaneado: ${guest['scanned'] ? "Sí" : "No"}\n'
//                 'Hora de escaneo: ${guest['timeScanned'] ?? "N/A"}'
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:invite_scanner_qr/pages/edit_guest.dart';

class ViewEventPage extends StatelessWidget {
  final String eventId;

  const ViewEventPage({super.key, required this.eventId});

  void _showOptionsGuest(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.check_box),
                title: const Text('Confirmar asistencia'),
                onTap: () {
                  _confirmAsistence(event);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  //Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Alerta"),
                        content: const Text("No puedes editar"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAsistence(Map<String, dynamic> event) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .where('guestId', isEqualTo: event['guestId'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final guestDoc = querySnapshot.docs.first;
      String timeScanned = DateFormat('HH:mm').format(DateTime.now());

      await guestDoc.reference.update({
        'scanned': true,
        'timeScanned': timeScanned,
      });

      // _showScanResultDialog(
      //   title: 'Invitado encontrado',
      //   content:
      //       'Nombre: ${guestDoc['name']}\nHora de escaneo: $timeScanned\nEstado: Escaneado',
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference guests = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('guests');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitados'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: guests.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No hay invitados para este evento.'));
          }
          final guestDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: guestDocs.length,
            itemBuilder: (context, index) {
              final guest = guestDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(guest['name']),
                subtitle: Text(
                  'Confirmado: ${guest['confirmed'] ? "Sí" : "No"}\n'
                  'Escaneado: ${guest['scanned'] ? "Sí" : "No"}\n'
                  'Hora de escaneo: ${guest['timeScanned'] ?? "N/A"}',
                ),
                onTap: () {
                  _showOptionsGuest(context, guest);
                },
              );
            },
          );
        },
      ),
    );
  }
}
