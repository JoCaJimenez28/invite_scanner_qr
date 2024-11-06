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
      setState(() {
        qrText = scanData.code;
      });
      _processScanResult(scanData.code);
    });
  }

  void _processScanResult(String? result) {
    if (result != null) {
      final Map<String, dynamic>? scannedGuest = _findGuestInEvent(result);
      String timeScanned = DateFormat('HH:mm').format(DateTime.now()).toString();
      controller?.pauseCamera();
      

      if (scannedGuest != null) {
        setState(() {
          scannedGuest['scanned'] = true;
          scannedGuest['timeScanned'] = timeScanned;
        });
        _showScanResultDialog(
          title: 'Invitado encontrado',
          content: 'Nombre: ${scannedGuest['name']}\nHora de escaneo: $timeScanned\nEstado: Escaneado',
        );
      } else {
        _showScanResultDialog(
          title: 'Invitado no encontrado',
          content: 'El código QR pertenece a otro evento o es inválido.',
        );
      }
    }
  }

  Map<String, dynamic>? _findGuestInEvent(String guestId) {
    // Busca el invitado en el evento actual usando el ID del QR
    print("event " + widget.event.toString());
    var guest = widget.event['guests']?.firstWhere(
      (guest) => guest['name'] == guestId,
      orElse: () => <String, dynamic>{},
    );

    return guest.isNotEmpty ? guest : null;
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
                controller?.resumeCamera();
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
                  ? Text('Resultado: $qrText["name"]')
                  : const Text('Escanea un código QR'),
            ),
          ),
        ],
      ),
    );
  }
}