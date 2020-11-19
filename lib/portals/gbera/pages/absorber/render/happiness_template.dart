import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HappinessTemplate extends StatefulWidget {
  PageContext context;

  HappinessTemplate({this.context});

  @override
  _HappinessTemplateState createState() => _HappinessTemplateState();
}

class _HappinessTemplateState extends State<HappinessTemplate> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.partArgs['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(HappinessTemplate oldWidget) {
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
                    '${_sliceTemplate.background}?accessToken=${widget.context.principal.accessToken}'),
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
                  height: 124,
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
            child:  Container(
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
      width: 120,
      height: 100,
      fit: BoxFit.cover,
    );
  }
}
