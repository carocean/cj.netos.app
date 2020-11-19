import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/normal_slice.dart';
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

  @override
  void initState() {
    _qrcodeSliceOR = widget.context.parameters['slice'];
    _isShowAction = widget.context.partArgs['isShowAction'];
    if (_isShowAction == null) {
      _isShowAction = widget.context.parameters['isShowAction'];
    }
    _isShowAction = _isShowAction ?? false;
    _isAutoExport = widget.context.parameters['isAutoExport'];
    _isAutoExport = _isAutoExport ?? false;
    () async {
      await _loadTemplate();
      if (!_isAutoExport) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _exportSlice().then((value) {
          if(mounted) {
            widget.context.backward();
          }
        });
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
        _progressTips = '码片:${_qrcodeSliceOR.id}已导出';
        _isExporting = 2;
      });
    }
    return f;
  }

  @override
  Widget build(BuildContext context) {
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
            alignment: Alignment.center,
            child: RepaintBoundary(
              key: qrcodeKey,
              child: _renderSlice(),
            ),
          ),
          _rendPosition(),
        ],
      ),
    );
  }

  _renderSlice() {
    if (_qrcodeSliceOR == null || _templateOR == null) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    Widget slice;
    switch (_qrcodeSliceOR.template) {
      case 'normal':
        slice = widget.context.part('/robot/slice/image/normal', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'official':
        slice = widget.context
            .part('/robot/slice/image/official', context, arguments: {
          'slice': _qrcodeSliceOR,
          'template': _templateOR,
        });
        break;
      case 'happiness':
        slice = widget.context.part('/robot/slice/image/happiness', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'xibao':
        slice = widget.context.part('/robot/slice/image/xibao', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'caisheng':
        slice = widget.context.part('/robot/slice/image/caisheng', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'minxinpian':
        slice = widget.context.part('/robot/slice/image/minxinpian', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'chiji':
        slice = widget.context.part('/robot/slice/image/chiji', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'wangzherongyao':
        slice = widget.context.part(
            '/robot/slice/image/wangzherongyao', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      case 'love':
        slice = widget.context.part('/robot/slice/image/love', context,
            arguments: {'slice': _qrcodeSliceOR, 'template': _templateOR});
        break;
      default:
        slice = Container(
          child: Text('不支持的模板'),
        );
        break;
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        height: Adapt.screenH() - 60,
        width: Adapt.screenW(),
        child: slice,
      ),
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
