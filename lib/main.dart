import 'package:flutter/material.dart';
import 'package:invite_scanner_qr/pages/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Invite App'),
        ),
        body: const HomePage(), // Carga HomePage en el cuerpo de Scaffold
      ),
    );
  }
}
