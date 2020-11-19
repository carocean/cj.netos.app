import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CaishengTemplate extends StatefulWidget {
  PageContext context;

  CaishengTemplate({this.context});

  @override
  _CaishengTemplateState createState() => _CaishengTemplateState();
}

class _CaishengTemplateState extends State<CaishengTemplate> {
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    _sliceTemplate = widget.context.partArgs['sliceTemplate'];
    super.initState();
  }

  @override
  void didUpdateWidget(CaishengTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var advices = _sliceTemplate.props['advices'];
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
            left: 30,
            bottom: 20,
            child: SizedBox(
              width: 170,
              child: Text(
                '${advices.value ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
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
}
