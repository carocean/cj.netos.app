import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:path_provider/path_provider.dart';

class QrcodeSliceView extends StatefulWidget {
  PageContext context;

  QrcodeSliceView({this.context});

  @override
  _QrcodeSliceViewState createState() => _QrcodeSliceViewState();
}

class _QrcodeSliceViewState extends State<QrcodeSliceView> {
  QrcodeSliceOR _qrcodeSliceOR;
  TemplatePropOR _templatePropOR;
  @override
  void initState() {
    _qrcodeSliceOR = widget.context.parameters['slice'];
    _templatePropOR = widget.context.parameters['template'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: widget.context.part('/robot/slice/image', context,
                  arguments: {'slice': _qrcodeSliceOR,}),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/robot/slice/webview',arguments: {'slice':_qrcodeSliceOR,});
                  },
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '查看码片信息',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                _qrcodeSliceOR.state==1?SizedBox(width: 0,height: 0,):
                SizedBox(
                  height: 10,
                  child: Divider(height: 1,),
                ),
                _qrcodeSliceOR.state==1?SizedBox(width: 0,height: 0,):
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/robot/slice/image',arguments: {'slice':_qrcodeSliceOR,'isShowAction':true,});
                  },
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '导出码片',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                _qrcodeSliceOR.state==1?SizedBox(width: 0,height: 0,):
                SizedBox(
                  height: 10,
                  child: Divider(height: 1,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
