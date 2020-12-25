import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

QrcodeScanner qrcodeScanner = QrcodeScanner(
  actions: {},
);
final scanner = _DefaultScanner();

mixin IScanner {
  Future<String> scan(PageContext context);
}

class _DefaultScanner implements IScanner {
  @override
  Future<String> scan(PageContext context) async {
    var result = await context.forward('/qrcode/scanner');
    if (result == null) {
      return null;
    }
    var s = result as Barcode;
    return s.code;
  }
}

class QrcodeScanner {
  final Map<String, QrcodeAction> actions;

  const QrcodeScanner({this.actions});

  void close() {
    actions.clear();
  }

  Future<String> scan(
      BuildContext buildContext, PageContext pageContext) async {
    String cameraScanResult = await scanner.scan(pageContext);
    if (StringUtil.isEmpty(cameraScanResult)) {
      return 'no';
    }
    String itis;
    String data;
    if (cameraScanResult.startsWith('{')) {
      var map = jsonDecode(cameraScanResult);
      itis = map['itis'];
      data = map['data'];
    } else {
      data = cameraScanResult;
      itis = 'unknown';
    }
    QrcodeAction action = actions[itis];
    if (action == null) {
      print('未处理的二维码扫描策略:$itis');
      return 'no';
    }
    QrcodeInfo info = await action.parse(itis, data);
    var v = await showDialog(
      context: buildContext,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        var actions = <Widget>[];
        if (!info.isHidenYesButton) {
          actions.add(
            FlatButton(
              child: Text(
                '是',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(['yes', action]);
              },
            ),
          );
        }
        if (!info.isHidenNoButton) {
          actions.add(
            FlatButton(
              child: Text(
                '否',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(['no', action]);
              },
            ),
          );
        }
        return AlertDialog(
          title: Text(info.title),
          content: info.tips,
          actions: actions,
          elevation: 20,
          semanticLabel: '',
          // 设置成 圆角
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
    if (v == null) {
      return null;
    }
    var selected = v[0];
    QrcodeAction qraction = v[1];
    switch (selected) {
      case 'yes':
        if (qraction.doit != null) {
          await qraction.doit(info);
        }
        break;
      case 'no':
        break;
    }
    return selected;
  }
}

class QrcodeAction {
  Future<QrcodeInfo> Function(String itis, String data) parse;
  Future<void> Function(QrcodeInfo info) doit;

  QrcodeAction({this.parse, this.doit});
}

class QrcodeInfo {
  String title;
  String itis;
  Widget tips;
  bool isHidenYesButton;

  bool isHidenNoButton;

  Map<String, dynamic> props;

  QrcodeInfo(
      {this.itis,
      this.title,
      this.tips,
      this.props,
      this.isHidenNoButton = false,
      this.isHidenYesButton = false});
}

class QrScannerDialog extends StatefulWidget {
  PageContext context;

  QrScannerDialog({this.context});

  @override
  _QrScannerDialogState createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController _controller;
  bool isFirst = true;
  var _flashState = false;

// In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller.pauseCamera();
    } else if (Platform.isIOS) {
      _controller.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 300.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (notification) {
              Future.microtask(() =>
                  _controller?.updateDimensions(_qrKey, scanArea: scanArea));
              return false;
            },
            child: SizeChangedLayoutNotifier(
              key: const Key('qr-size-notifier'),
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: scanArea,
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 15,
            right: 15,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    widget.context.backward();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFlashBtn(
                  context,
                  _flashState,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _controller.dispose();
      if (mounted) {
        Navigator.of(context).pop(scanData);
      }
    });
  }

  Widget _buildFlashBtn(BuildContext context, bool flashOn) {
    return flashOn != null
        ? Padding(
            padding: EdgeInsets.only(
                bottom: 24 + MediaQuery.of(context).padding.bottom),
            child: IconButton(
              icon: Icon(flashOn ? Icons.highlight : Icons.lightbulb_outline),
              color: Colors.white,
              iconSize: 46,
              onPressed: () {
                _controller.toggleFlash();
                _flashState = !_flashState;
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          )
        : Container();
  }
}
