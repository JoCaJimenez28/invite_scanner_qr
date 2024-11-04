import 'package:flutter/material.dart';

class ViewEventPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const ViewEventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final guests = event['guests'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invitados de ${event['name']}'),
      ),
      body: ListView.builder(
        itemCount: guests.length,
        itemBuilder: (context, index) {
          final guest = guests[index];
          return ListTile(
            title: Text(guest['name']),
            subtitle: Text(
                'Confirmado: ${guest['confirmed'] ? "Sí" : "No"}\n'
                'Escaneado: ${guest['scanned'] ? "Sí" : "No"}\n'
                'Hora de escaneo: ${guest['scanTime'] ?? "N/A"}'
            ),
          );
        },
      ),
    );
  }
}
