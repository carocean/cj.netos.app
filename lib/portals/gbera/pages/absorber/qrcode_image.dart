import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrcodeSliceImagePage extends StatefulWidget {
  PageContext context;

  QrcodeSliceImagePage({this.context});

  @override
  _QrcodeSliceImagePageState createState() => _QrcodeSliceImagePageState();
}

class _QrcodeSliceImagePageState extends State<QrcodeSliceImagePage> {
  QrcodeSliceOR _qrcodeSliceOR;
  var qrcodeKey = GlobalKey();
  int _isExporting = 0; //0为重新开始，1为正在导；2为已完成
  bool _isShowAction = false;
  bool _isAutoExport = false;
  String _progressTips = '';
  SliceTemplateOR _templateOR;
  List<QrcodeSliceOR> _slices = [];

  @override
  void initState() {
    _qrcodeSliceOR = widget.context.page.parameters['slice'];
    _isShowAction = widget.context.page.parameters['isShowAction'];
    if (_qrcodeSliceOR == null) {
      _qrcodeSliceOR = widget.context.parameters['slice'];
    }
    if (_isShowAction == null) {
      _isShowAction = widget.context.parameters['isShowAction'];
    }
    _isShowAction = _isShowAction ?? false;
    _slices = widget.context.parameters['slices'];
    _isAutoExport = widget.context.parameters['isAutoExport'];
    _isAutoExport = _isAutoExport ?? false;
    if (_isAutoExport && _slices != null && _slices.isNotEmpty) {
      _qrcodeSliceOR = _slices[0];
    }
    () async {
      await _loadTemplate();
      if (!_isAutoExport) {
        return;
      }
      if (mounted) {
        setState(() {
          _progressTips = '开始导出码片到相册...';
        });
      }
      int i = 0;
      do {
        if (mounted) {
          setState(() {
            _progressTips = '准备导出第${i + 1}张...';
          });
        }
        await _exportSlice();
        if (mounted) {
          setState(() {
            _progressTips = '第${i + 1}张已导出，图片名:${_qrcodeSliceOR.id}.png';
          });
        }
        _qrcodeSliceOR = _slices[i];
        i++;
      } while (i < _slices.length);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.context.backward();
      });
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(QrcodeSliceImagePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadTemplate() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    _templateOR =
        await robotRemote.getQrcodeSliceTemplate(_qrcodeSliceOR.template);
    if (mounted) {
      setState(() {});
    }
  }

  Future<String> _exportSlice() async {
    setState(() {
      _isExporting = 1;
    });
    RenderRepaintBoundary boundary =
        qrcodeKey.currentContext.findRenderObject();
    var image = await boundary.toImage(
      pixelRatio: 8,
    );
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    ///本来应该保存到相册，但相册是手机的共享目录，得找第三方插件才能实现,下面先保存到应用目录，用户是看不到的。
    Directory dir = await getApplicationDocumentsDirectory();
    await File('${dir.path}/${_qrcodeSliceOR.id}.png').writeAsBytes(pngBytes);
    var f = '${dir.path}/${_qrcodeSliceOR.id}.png';
    await ImageGallerySaver.saveFile(f);
    if (mounted) {
      setState(() {
        _isExporting = 2;
      });
    }
    return f;
  }

  @override
  Widget build(BuildContext context) {
    Widget slice;
    switch (_qrcodeSliceOR.template) {
      case 'normal':
        slice = _renderNormalSlice();
        break;
      default:
        slice = Container(
          child: Text('不支持的模板'),
        );
        break;
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: !_isShowAction ? 10 : 40,
              bottom: 10,
            ),
            child: RepaintBoundary(
              key: qrcodeKey,
              child: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        'http://47.105.165.186:7100/app/qrcodeslice/normal.jpg?accessToken=${widget.context.principal.accessToken}'),
                  ),
                ),
                child: slice,
              ),
            ),
          ),
          _rendPosition(),
        ],
      ),
    );
  }

  Widget _renderNormalSlice() {
    var prop = _qrcodeSliceOR.props['welcome'];
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${prop?.name ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              bottom: 20,
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 60,
                  ),
                  height: 120,
                  width: 120,
                  color: Colors.white,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: RepaintBoundary(
                    child: QrImage(
                      ///二维码数据
                      data: '${_qrcodeSliceOR.href}?id=${_qrcodeSliceOR.id}',
                      version: QrVersions.auto,
                      gapless: false,
                      padding: EdgeInsets.all(0),
                      // embeddedImage:
                      // FileImage(File(widget.context.principal.avatarOnLocal)),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_templateOR?.copyright ?? ''}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }

  _rendPosition() {
    if (_isAutoExport) {
      return Positioned(
        top: 50,
        left: 0,
        right: 0,
        bottom: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '$_progressTips',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    }
    if (!_isShowAction) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    return Positioned(
      top: 50,
      left: 25,
      right: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.backward();
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _exportSlice();
            },
            child: Text(
              '${_isExporting == 0 ? '导出到相册' : _isExporting == 1 ? '正在导出...' : '已保存'}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
