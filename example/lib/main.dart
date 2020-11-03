import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(MaterialApp(home: QRViewExample()));

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  var qrText = '';
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            title: 'Scan QR Code',
            subtitle:
                "Find the store's QR code \n (Usually located at the entrance)",
            overlay: QrScannerOverlayShape(
              overlayColor: Color.fromRGBO(24, 212, 149, 0.85),
              borderColor: Color.fromRGBO(25, 86, 125, 1),
              borderRadius: 5,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          Align(
            alignment: Alignment(-0.15, 0.68),
            child: IconButton(
              icon: Icon(Icons.flash_on),
              color: Colors.white,
              iconSize: 55,
              onPressed: () {
                if (controller != null) {
                  controller.toggleFlash();
                  if (_isFlashOn(flashState)) {
                    setState(() {
                      flashState = flashOff;
                    });
                  } else {
                    setState(() {
                      flashState = flashOn;
                    });
                  }
                }
              },
            ),
          ),
          Align(
            alignment: Alignment(0.25, 0.68),
            child: IconButton(
              icon: Icon(Icons.flip_camera_android),
              color: Colors.white,
              iconSize: 55,
              onPressed: () {
                if (controller != null) {
                  controller.flipCamera();
                  if (_isBackCamera(cameraState)) {
                    setState(() {
                      cameraState = frontCamera;
                    });
                  } else {
                    setState(() {
                      cameraState = backCamera;
                    });
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
