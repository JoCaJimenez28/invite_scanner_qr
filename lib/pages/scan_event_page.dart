// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class ScanEventPage extends StatefulWidget {
//   final Map<String, dynamic> event;

//   const ScanEventPage({super.key, required this.event});

//   @override
//   _ScanEventPageState createState() => _ScanEventPageState();
// }

// class _ScanEventPageState extends State<ScanEventPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   String? qrText;

//   @override
//   void reassemble() {
//     super.reassemble();
//     if (controller != null) {
//       controller!.pauseCamera();
//       controller!.resumeCamera();
//     }
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         qrText = scanData.code;
//       });
//       _showScanResult(scanData.code);
//     });
//   }

//   void _showScanResult(String? result) {
//     if (result != null) {
//       controller?.pauseCamera();
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Código escaneado'),
//             content: Text('Contenido: $result'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   controller?.resumeCamera();
//                 },
//                 child: const Text('Aceptar'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Escanear Código QR'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             flex: 4,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: (qrText != null)
//                   ? Text('Resultado: $qrText')
//                   : const Text('Escanea un código QR'),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:intl/intl.dart';

class ScanEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const ScanEventPage({super.key, required this.event});

  @override
  _ScanEventPageState createState() => _ScanEventPageState();
}

class _ScanEventPageState extends State<ScanEventPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool _isProcessing = false; // Variable para evitar múltiples escaneos

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing) {
        setState(() {
          qrText = scanData.code;
          _isProcessing = true; // Marcamos que estamos procesando
        });
        controller.pauseCamera(); // Pausa el escáner
        _processScanResult(scanData.code);
      }
    });
  }

  Future<void> _processScanResult(String? guestId) async {
    if (guestId != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event['id'])
            .collection('guests')
            .where('guestId', isEqualTo: guestId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final guestDoc = querySnapshot.docs.first;
          String timeScanned = DateFormat('HH:mm').format(DateTime.now());

          await guestDoc.reference.update({
            'scanned': true,
            'timeScanned': timeScanned,
          });

          _showScanResultDialog(
            title: 'Invitado encontrado',
            content:
                'Nombre: ${guestDoc['name']}\nHora de escaneo: $timeScanned\nEstado: Escaneado',
          );
        } else {
          _showScanResultDialog(
            title: 'Invitado no encontrado',
            content: 'El código QR pertenece a otro evento o es inválido.',
          );
        }
      } catch (e) {
        print("Error al procesar el resultado del escaneo: $e");
      } finally {
        _isProcessing = false; // Restablecemos el estado después de procesar
      }
    }
  }

  void _showScanResultDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller?.resumeCamera(); // Reanuda el escáner al cerrar el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrText != null)
                  ? Text('Resultado: $qrText')
                  : const Text('Escanea un código QR'),
            ),
          ),
        ],
      ),
    );
  }
}

