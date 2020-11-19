import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class NormalSliceTemplate extends StatefulWidget {
  PageContext context;

  NormalSliceTemplate({this.context});

  @override
  _NormalSliceTemplateState createState() => _NormalSliceTemplateState();
}

class _NormalSliceTemplateState extends State<NormalSliceTemplate> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.partArgs['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(NormalSliceTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var welcome =
        _sliceTemplate == null ? null : _sliceTemplate.props['welcome'];
    var avatar = _sliceTemplate == null ? null : _sliceTemplate.props['avatar'];
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
                '${_sliceTemplate.background}?accessToken=${widget.context.principal.accessToken}'),
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
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: RepaintBoundary(
                        child: QrImage(
                          ///二维码数据
                          data: '只是模板，此时无效',
                          version: QrVersions.auto,
                          gapless: false,
                          padding: EdgeInsets.all(0),
                          embeddedImage: StringUtil.isEmpty(avatar.value)
                              ? null
                              : NetworkImage(
                                  '${avatar.value}?accessToken=${widget.context.principal.accessToken}',
                                ),
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
                  '${_sliceTemplate?.copyright ?? ''}',
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
