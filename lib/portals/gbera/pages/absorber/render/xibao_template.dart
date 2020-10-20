import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class XibaoSliceTemplate extends StatefulWidget {
  PageContext context;

  XibaoSliceTemplate({this.context});

  @override
  _XibaoSliceTemplateState createState() => _XibaoSliceTemplateState();
}

class _XibaoSliceTemplateState extends State<XibaoSliceTemplate> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.page.parameters['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(XibaoSliceTemplate oldWidget) {
    _sliceTemplate = widget.context.page.parameters['sliceTemplate'];
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var greetings = _sliceTemplate.props['greetings'];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    '${_sliceTemplate.background}?accessToken=${widget.context.principal.accessToken}'),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 0,
            left: 0,
            top: 0,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 60,
                    ),
                    height: 160,
                    width: 160,
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
                        // embeddedImage: StringUtil.isEmpty(avatar.value)
                        //     ? null
                        //     : NetworkImage(
                        //   '${avatar.value}?accessToken=${widget.context.principal.accessToken}',
                        // ),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(40, 40),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: Text(
                        '${greetings?.value ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
