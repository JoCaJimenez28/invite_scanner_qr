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

class ViewEventPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const ViewEventPage({super.key, required this.event});

  void _showGuestDetails(BuildContext context, Map<String, dynamic> guest) {
    // Aquí puedes agregar una acción al seleccionar un invitado, como mostrar detalles.
    // Este método está solo como un ejemplo, puedes eliminarlo o implementarlo.
  }

  @override
  Widget build(BuildContext context) {
    final guests = event['guests'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invitados de ${event['name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GuestSearchDelegate(guests, _showGuestDetails),
              );
            },
          ),
        ],
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
              'Hora de escaneo: ${guest['timeScanned'] ?? "N/A"}',
            ),
            onTap: () => _showGuestDetails(context, guest),
          );
        },
      ),
    );
  }
}

class GuestSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> guests;
  final Function(BuildContext, Map<String, dynamic>) onGuestSelected;

  GuestSearchDelegate(this.guests, this.onGuestSelected);

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
    final results = guests
        .where((guest) => guest['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final guest = results[index];
        return ListTile(
          title: Text(guest['name']),
          subtitle: Text(
            'Confirmado: ${guest['confirmed'] ? "Sí" : "No"}\n'
            'Escaneado: ${guest['scanned'] ? "Sí" : "No"}\n'
            'Hora de escaneo: ${guest['timeScanned'] ?? "N/A"}',
          ),
          onTap: () {
            close(context, null);
            onGuestSelected(context, guest);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = guests
        .where((guest) => guest['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final guest = suggestions[index];
        return ListTile(
          title: Text(guest['name']),
          subtitle: Text(
            'Confirmado: ${guest['confirmed'] ? "Sí" : "No"}\n'
            'Escaneado: ${guest['scanned'] ? "Sí" : "No"}\n'
            'Hora de escaneo: ${guest['timeScanned'] ?? "N/A"}',
          ),
          onTap: () {
            query = guest['name'];
            showResults(context);
          },
        );
      },
    );
  }
}

