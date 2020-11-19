import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class NormalSliceImage extends StatefulWidget {
  PageContext context;

  NormalSliceImage({this.context});

  @override
  _NormalSliceImageState createState() => _NormalSliceImageState();
}

class _NormalSliceImageState extends State<NormalSliceImage> {
  QrcodeSliceOR _qrcodeSliceOR;
  SliceTemplateOR _templateOR;

  @override
  void initState() {
    super.initState();
    _qrcodeSliceOR = widget.context.partArgs['slice'];
    _templateOR = widget.context.partArgs['template'];
  }

  @override
  void didUpdateWidget(NormalSliceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var welcome = _qrcodeSliceOR.props['welcome'];
    var avatar = _qrcodeSliceOR == null ? null : _qrcodeSliceOR.props['avatar'];
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration:_templateOR==null?null: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
                '${_templateOR.background}?accessToken=${widget.context.principal.accessToken}'),
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
                    '${welcome?.value ?? ''}',
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
                          data:
                              '${_qrcodeSliceOR.href}?id=${_qrcodeSliceOR.id}',
                          version: QrVersions.auto,
                          gapless: false,
                          padding: EdgeInsets.all(0),
                          embeddedImage: StringUtil.isEmpty(avatar.value)
                              ? null
                              : NetworkImage(
                            '${avatar.value}?accessToken=${widget.context.principal.accessToken}',
                          ),
                          embeddedImageStyle: QrEmbeddedImageStyle(
                            size: Size(20, 20),
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
        ),
      ),
    );
  }
}
