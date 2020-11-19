import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HappinessSliceImage extends StatefulWidget {
  PageContext context;

  HappinessSliceImage({this.context});

  @override
  _HappnissSliceState createState() => _HappnissSliceState();
}

class _HappnissSliceState extends State<HappinessSliceImage> {
  QrcodeSliceOR _qrcodeSliceOR;
  SliceTemplateOR _sliceTemplateOR;

  @override
  void initState() {
    super.initState();
    _qrcodeSliceOR = widget.context.partArgs['slice'];
    _sliceTemplateOR = widget.context.partArgs['template'];
  }

  @override
  void didUpdateWidget(HappinessSliceImage oldWidget) {
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
                fit: BoxFit.cover,
                image: NetworkImage(
                    '${_sliceTemplateOR.background}?accessToken=${widget.context.principal.accessToken}'),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 122,
                ),
                Center(
                  child:Padding(
                    padding: EdgeInsets.only(left: 20),
                    child:  _renderAvatar(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child:   Container(
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
