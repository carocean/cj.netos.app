import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MinXinPianTemplate extends StatefulWidget {
  PageContext context;

  MinXinPianTemplate({this.context});

  @override
  _MinXinPianTemplateState createState() => _MinXinPianTemplateState();
}

class _MinXinPianTemplateState extends State<MinXinPianTemplate> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.partArgs['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(MinXinPianTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var content = _sliceTemplate.props['content'];
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
            left: 10,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Padding(
                 padding: EdgeInsets.only(bottom: 240,),
                 child:  SizedBox(
                   width: 120,
                   height: 120,
                   child: CircleAvatar(
                     backgroundImage: NetworkImage(
                       '${widget.context.principal.avatarOnRemote}?accessToken=${widget.context.principal.accessToken}',
                     ),
                   ),
                 ),
               ),
              ],
            ),
          ),
          Positioned(
            top: 160,
            right: 20,
            left: 20,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 60),
                child: Column(
                  children: [
                    Container(
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
                      height: 40,
                    ),
                    Container(
                      width: 150,
                      padding: EdgeInsets.only(
                        left: 20,
                      ),
                      child: Text(
                        '${content.value ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        strutStyle: StrutStyle(
                            forceStrutHeight: true, height: 1.9, leading: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
