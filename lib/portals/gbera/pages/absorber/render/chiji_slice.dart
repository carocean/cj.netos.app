import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChijiSliceImage extends StatefulWidget {
  PageContext context;

  ChijiSliceImage({this.context});

  @override
  _ChijiSliceImageState createState() => _ChijiSliceImageState();
}

class _ChijiSliceImageState extends State<ChijiSliceImage> {
  QrcodeSliceOR _qrcodeSliceOR;
  SliceTemplateOR _sliceTemplate;

  @override
  void initState() {
    super.initState();
    _qrcodeSliceOR = widget.context.page.parameters['slice'];
    _sliceTemplate = widget.context.page.parameters['template'];
  }

  @override
  void didUpdateWidget(ChijiSliceImage oldWidget) {
    _qrcodeSliceOR = widget.context.page.parameters['slice'];
    _sliceTemplate = widget.context.page.parameters['template'];
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    var note = _qrcodeSliceOR.props['note'];
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
            top: 120,
            right: 20,
            left: 20,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      alignment: Alignment.center,
                      child: Text(
                        '${note.value ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
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
