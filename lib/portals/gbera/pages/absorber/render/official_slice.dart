import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OfficialSliceImage extends StatefulWidget {
  PageContext context;

  OfficialSliceImage({this.context});

  @override
  _HappnissSliceState createState() => _HappnissSliceState();
}

class _HappnissSliceState extends State<OfficialSliceImage> {
  QrcodeSliceOR _qrcodeSliceOR;
  SliceTemplateOR _sliceTemplateOR;

  @override
  void initState() {
    super.initState();
    _qrcodeSliceOR = widget.context.partArgs['slice'];
    _sliceTemplateOR = widget.context.partArgs['template'];
  }

  @override
  void didUpdateWidget(OfficialSliceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: NetworkImage(
                    '${_sliceTemplateOR.background}?accessToken=${widget.context.principal.accessToken}'),
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
                  Container(
                    margin: EdgeInsets.only(
                      top: 30,
                      right: 30,
                    ),
                    height: 120,
                    width: 120,
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: RepaintBoundary(
                      child: QrImage(
                        ///二维码数据
                        data: '${_qrcodeSliceOR.href}?id=${_qrcodeSliceOR.id}',
                        version: QrVersions.auto,
                        gapless: false,
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderAvatar() {
    var avatarUrl = widget.context.principal.avatarOnRemote;
    return FadeInImage.assetNetwork(
      placeholder: 'lib/portals/gbera/images/default_watting.gif',
      image: '$avatarUrl?accessToken=${widget.context.principal.accessToken}',
      width: 110,
      height: 105,
      fit: BoxFit.cover,
    );
  }
}
