import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Official2Template extends StatefulWidget {
  PageContext context;

  Official2Template({this.context});

  @override
  _Official2TemplateState createState() => _Official2TemplateState();
}

class _Official2TemplateState extends State<Official2Template> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.partArgs['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(Official2Template oldWidget) {
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
                    '${_sliceTemplate.background}?accessToken=${widget.context.principal.accessToken}'),
              ),
            ),
          ),
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       SizedBox(
          //         height: 124,
          //       ),
          //       Center(
          //         child:Padding(
          //           padding: EdgeInsets.only(left: 20),
          //           child:  _renderAvatar(),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
                    data: '只是模板，此时无效',
                    version: QrVersions.auto,
                    gapless: false,
                    padding: EdgeInsets.all(0),
                    // embeddedImage: StringUtil.isEmpty(avatar.value)
                    //     ? null
                    //     : NetworkImage(
                    //   '${avatar.value}?accessToken=${widget.context.principal.accessToken}',
                    // ),
                    // embeddedImageStyle: QrEmbeddedImageStyle(
                    //   size: Size(40, 40),
                    // ),
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
