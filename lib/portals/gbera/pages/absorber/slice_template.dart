import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SliceTemplatePage extends StatefulWidget {
  PageContext context;

  SliceTemplatePage({this.context});

  @override
  _SliceTemplatePageState createState() => _SliceTemplatePageState();
}

class _SliceTemplatePageState extends State<SliceTemplatePage> {
  SliceTemplateOR _selectSliceTemplate;
  bool _fitted = false;

  @override
  void initState() {
    _selectSliceTemplate =
        widget.context.page.parameters['selectedSliceTemplate'];
    _fitted = widget.context.page.parameters['fitted'];
    _fitted = _fitted ?? false;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(SliceTemplatePage oldWidget) {
    _selectSliceTemplate =
        widget.context.page.parameters['selectedSliceTemplate'];
    _fitted = widget.context.page.parameters['fitted'];
    _fitted = _fitted ?? false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    dynamic body;
    if (_fitted) {
      body = FittedBox(
        fit: BoxFit.contain,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Adapt.screenW(),
            maxHeight: Adapt.screenH() - 60,
          ),
          child: _renderNormalSlice(),
        ),
      );
    } else {
      body = _renderNormalSlice();
    }
    return Scaffold(
      body: body,
    );
  }

  Widget _renderNormalSlice() {
    var prop = _selectSliceTemplate == null
        ? null
        : _selectSliceTemplate.props['welcome'];
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
              'http://47.105.165.186:7100/app/qrcodeslice/normal.jpg?accessToken=${widget.context.principal.accessToken}'),
        ),
      ),
      child: Column(
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
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: RepaintBoundary(
                      child: QrImage(
                        ///二维码数据
                        data: '只是模板，此时无效',
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
                '${_selectSliceTemplate?.copyright ?? ''}',
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
      ),
    );
  }
}
