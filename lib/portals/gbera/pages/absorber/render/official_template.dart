import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OfficialTemplate extends StatefulWidget {
  PageContext context;

  OfficialTemplate({this.context});

  @override
  _OfficialTemplateState createState() => _OfficialTemplateState();
}

class _OfficialTemplateState extends State<OfficialTemplate> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.page.parameters['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(OfficialTemplate oldWidget) {
    _sliceTemplate = widget.context.page.parameters['sliceTemplate'];
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
      width: 120,
      height: 100,
      fit: BoxFit.cover,
    );
  }
}
