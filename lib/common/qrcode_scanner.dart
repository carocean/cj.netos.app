import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';

QrcodeScanner qrcodeScanner = QrcodeScanner(
  actions: {},
);
final scanner=_DefaultScanner();

mixin IScanner{
  Future<String> scan(PageContext context);
}
class _DefaultScanner implements IScanner{
  @override
  Future<String> scan(PageContext context)async{
    var result= await context.forward('/qrcode/scanner');
    if(result==null) {
      return null;
    }
    var s=result as RScanResult;
    return s.message;
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
  RScanCameraController _controller;
  bool isFirst = true;

  List<RScanCameraDescription> rScanCameras;

  void initCamera() async {
    if (rScanCameras == null || rScanCameras.length == 0) {
      final result = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.camera);
      if (result == PermissionStatus.granted) {
        rScanCameras = await availableRScanCameras();
        print('返回可用的相机：${rScanCameras.join('\n')}');
      } else {
        final resultMap = await PermissionHandler()
            .requestPermissions([PermissionGroup.camera]);
        if (resultMap[PermissionGroup.camera] == PermissionStatus.granted) {
          rScanCameras = await availableRScanCameras();
        } else {
          print('相机权限被拒绝，无法使用');
        }
      }
    }
    if (rScanCameras != null && rScanCameras.length > 0) {
      _controller = RScanCameraController(
          rScanCameras[0], RScanCameraResolutionPreset.high)
        ..addListener(() {
          final result = _controller.result;
          if (result != null) {
            if (isFirst) {
              Navigator.of(context).pop(result);
              isFirst = false;
            }
          }
        })
        ..initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  Future<void> _scanImage()async{
    var picker=ImagePicker();
   var image=await picker.getImage(source: ImageSource.gallery,imageQuality: 100,);
    if(image==null) {
      return;
    }
    final result = await RScan.scanImagePath(image.path);
    Navigator.of(context).pop(result);
  }
  @override
  Widget build(BuildContext context) {
    if (rScanCameras == null || rScanCameras.length == 0) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Text('not have available camera'),
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white,),
        actions: [
          IconButton(
            icon: Icon(
              Icons.image,
            ),
            onPressed: () {
              _scanImage();
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          ScanImageView(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: RScanCamera(_controller),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: FutureBuilder(
                future: getFlashMode(),
                builder: _buildFlashBtn,
              ))
        ],
      ),
    );
  }

  Future<bool> getFlashMode() async {
    bool isOpen = false;
    try {
      isOpen = await _controller.getFlashMode();
    } catch (_) {}
    return isOpen;
  }

  Widget _buildFlashBtn(BuildContext context, AsyncSnapshot<bool> snapshot) {
    return snapshot.hasData
        ? Padding(
      padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.of(context).padding.bottom),
      child: IconButton(
          icon: Icon(snapshot.data ? Icons.highlight : Icons.lightbulb_outline),
          color: Colors.white,
          iconSize: 46,
          onPressed: () {
            if (snapshot.data) {
              _controller.setFlashMode(false);
            } else {
              _controller.setFlashMode(true);
            }
            setState(() {});
          }),
    )
        : Container();
  }
}

class ScanImageView extends StatefulWidget {
  final Widget child;

  const ScanImageView({Key key, this.child}) : super(key: key);

  @override
  _ScanImageViewState createState() => _ScanImageViewState();
}

class _ScanImageViewState extends State<ScanImageView>
    with TickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) => CustomPaint(
          foregroundPainter:
          _ScanPainter(controller.value, Colors.white, Colors.green),
          child: widget.child,
          willChange: true,
        ));
  }
}

class _ScanPainter extends CustomPainter {
  final double value;
  final Color borderColor;
  final Color scanColor;

  _ScanPainter(this.value, this.borderColor, this.scanColor);

  Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paint == null) {
      initPaint();
    }
    double width = size.width;
    double height = size.height;

    double boxWidth = size.width * 2 / 3;
    double boxHeight = height / 4;

    double left = (width - boxWidth) / 2;
    double top = boxHeight;
    double bottom = boxHeight * 2;
    double right = left + boxWidth;
    _paint.color = borderColor;
    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    canvas.drawRect(rect, _paint);

    _paint.strokeWidth = 3;

    Path path1 = Path()
      ..moveTo(left, top + 10)
      ..lineTo(left, top)
      ..lineTo(left + 10, top);
    canvas.drawPath(path1, _paint);
    Path path2 = Path()
      ..moveTo(left, bottom - 10)
      ..lineTo(left, bottom)
      ..lineTo(left + 10, bottom);
    canvas.drawPath(path2, _paint);
    Path path3 = Path()
      ..moveTo(right, bottom - 10)
      ..lineTo(right, bottom)
      ..lineTo(right - 10, bottom);
    canvas.drawPath(path3, _paint);
    Path path4 = Path()
      ..moveTo(right, top + 10)
      ..lineTo(right, top)
      ..lineTo(right - 10, top);
    canvas.drawPath(path4, _paint);

    _paint.color = scanColor;

    final scanRect = Rect.fromLTWH(
        left + 10, top + 10 + (value * (boxHeight - 20)), boxWidth - 20, 3);

    _paint.shader = LinearGradient(colors: <Color>[
      Colors.white54,
      Colors.white,
      Colors.white54,
    ], stops: [
      0.0,
      0.5,
      1,
    ]).createShader(scanRect);
    canvas.drawRect(scanRect, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void initPaint() {
    _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }
}
