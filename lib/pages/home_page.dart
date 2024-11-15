import 'package:flutter/material.dart';
// import 'package:invite_scanner_qr/pages/add_event_page.dart';
import 'package:invite_scanner_qr/pages/events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Elige una opción',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventsPage()),
              );
            },
            child: const Text('Eventos'),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => AddEventPage()),
          //     );
          //   },
          //   child: const Text('Añadir Evento'),
          // ),
          ElevatedButton(
            onPressed: () {
              // Acción del botón "Opción 3"
            },
            child: const Text('Opción 3'),
          ),
        ],
      ),
    );
  }
}
