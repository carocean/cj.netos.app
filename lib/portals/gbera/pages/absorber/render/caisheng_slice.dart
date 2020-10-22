import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CaishengSliceImage extends StatefulWidget {
  PageContext context;

  CaishengSliceImage({this.context});

  @override
  _CaishengSliceImageState createState() => _CaishengSliceImageState();
}

class _CaishengSliceImageState extends State<CaishengSliceImage> {
  QrcodeSliceOR _qrcodeSliceOR;
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    super.initState();
    _qrcodeSliceOR = widget.context.page.parameters['slice'];
    _sliceTemplate = widget.context.page.parameters['template'];
  }

  @override
  void didUpdateWidget(CaishengSliceImage oldWidget) {
    _qrcodeSliceOR = widget.context.page.parameters['slice'];
    _sliceTemplate = widget.context.page.parameters['template'];
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
                  data: '${_qrcodeSliceOR.href}?id=${_qrcodeSliceOR.id}',
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
}