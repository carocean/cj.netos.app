import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Official2SliceImage extends StatefulWidget {
  PageContext context;

  Official2SliceImage({this.context});

  @override
  _HappnissSliceState createState() => _HappnissSliceState();
}

class _HappnissSliceState extends State<Official2SliceImage> {
  QrcodeSliceOR _qrcodeSliceOR;
  SliceTemplateOR _sliceTemplateOR;

  @override
  void initState() {
    super.initState();
    _qrcodeSliceOR = widget.context.partArgs['slice'];
    _sliceTemplateOR = widget.context.partArgs['template'];
  }

  @override
  void didUpdateWidget(Official2SliceImage oldWidget) {
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
            right: 90,
            top: 5,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 76,
                height: 76,
                color: Colors.white,
                padding: EdgeInsets.all(5),
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
