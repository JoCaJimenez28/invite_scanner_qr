import 'package:flutter/material.dart';

class EditGuest extends StatefulWidget {
  const EditGuest({super.key});

  @override
  State<EditGuest> createState() => _EditGuestState();
}

class _EditGuestState extends State<EditGuest> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text("Alerta"),
      content: Text("No puedes editar"),
    );
  }
}

