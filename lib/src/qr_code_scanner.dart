import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef QRViewCreatedCallback = void Function(QRViewController);

class QRView extends StatefulWidget {
  const QRView({
    @required Key key,
    @required this.onQRViewCreated,
    this.overlay,
    this.title = '',
    this.subtitle = '',
  })  : assert(key != null),
        assert(onQRViewCreated != null),
        super(key: key);

  final QRViewCreatedCallback onQRViewCreated;

  final ShapeBorder overlay;
  final title;
  final subtitle;

  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _getPlatformQrView(),
        if (widget.overlay != null)
          Container(
            decoration: ShapeDecoration(
              shape: widget.overlay,
            ),
          )
        else
          Container(),
        Align(
          alignment: Alignment(0, -0.8),
          child: Container(
              child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'SofiaPro',
              fontWeight: FontWeight.bold,
              package: 'qr_code_scanner',
            ),
          )),
        ),
        Align(
          alignment: Alignment(0, -0.65),
          child: Container(
              child: Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'SofiaPro',
              package: 'qr_code_scanner',
            ),
          )),
        ),
      ],
    );
  }

  Widget _getPlatformQrView() {
    Widget _platformQrView;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _platformQrView = AndroidView(
          viewType: 'net.touchcapture.qr.flutterqr/qrview',
          onPlatformViewCreated: _onPlatformViewCreated,
        );
        break;
      case TargetPlatform.iOS:
        _platformQrView = UiKitView(
          viewType: 'net.touchcapture.qr.flutterqr/qrview',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _CreationParams.fromWidget(0, 0).toMap(),
          creationParamsCodec: StandardMessageCodec(),
        );
        break;
      default:
        throw UnsupportedError(
            "Trying to use the default webview implementation for $defaultTargetPlatform but there isn't a default one");
    }
    return _platformQrView;
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onQRViewCreated == null) {
      return;
    }
    widget.onQRViewCreated(QRViewController._(id, widget.key));
  }
}

class _CreationParams {
  _CreationParams({this.width, this.height});

  static _CreationParams fromWidget(double width, double height) {
    return _CreationParams(
      width: width,
      height: height,
    );
  }

  final double width;
  final double height;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}

class QRViewController {
  QRViewController._(int id, GlobalKey qrKey)
      : _channel = MethodChannel('net.touchcapture.qr.flutterqr/qrview_$id') {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final RenderBox renderBox = qrKey.currentContext.findRenderObject();
      _channel.invokeMethod('setDimensions',
          {'width': renderBox.size.width, 'height': renderBox.size.height});
    }
    _channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case scanMethodCall:
            if (call.arguments != null) {
              _scanUpdateController.sink.add(call.arguments.toString());
            }
        }
      },
    );
  }

  static const scanMethodCall = 'onRecognizeQR';

  final MethodChannel _channel;

  final StreamController<String> _scanUpdateController =
      StreamController<String>();

  Stream<String> get scannedDataStream => _scanUpdateController.stream;

  void flipCamera() {
    _channel.invokeMethod('flipCamera');
  }

  void toggleFlash() {
    _channel.invokeMethod('toggleFlash');
  }

  void pauseCamera() {
    _channel.invokeMethod('pauseCamera');
  }

  void resumeCamera() {
    _channel.invokeMethod('resumeCamera');
  }

  void dispose() {
    _scanUpdateController.close();
  }
}
