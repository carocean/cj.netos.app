import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:intl/intl.dart' as intl;

class OrgLicenceCard extends StatefulWidget {
  PageContext context;
  String organ;
  int type; //0为la；2为isp
  OrgLicenceCard({this.context, this.organ, this.type});

  @override
  _OrgLicenceCardState createState() => _OrgLicenceCardState();
}

class _OrgLicenceCardState extends State<OrgLicenceCard> {
  OrgISPOL _orgISPOL;
  OrgLAOL _orgLAOL;
  OrgLicenceOL _orgLicenceOL;
  GlobalKey comGlobalKey = GlobalKey();

  @override
  void initState() {
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    switch (widget.type) {
      case 0: //la
        ILaRemote laRemote = widget.context.site.getService('/remote/org/la');
        _orgLAOL = await laRemote.getLa(widget.organ);
        ILicenceRemote licenceRemote =
            widget.context.site.getService('/remote/org/licence');
        _orgLicenceOL = await licenceRemote.getLicence(widget.organ, 0);
        var isp = _orgLAOL.isp;
        if (!StringUtil.isEmpty(isp)) {
          IspRemote ispRemote =
              widget.context.site.getService('/remote/org/isp');
          _orgISPOL = await ispRemote.getIsp(isp);
        }
        break;
      case 2: //isp
        IIspRemote ispRemote =
            widget.context.site.getService('/remote/org/isp');
        _orgISPOL = await ispRemote.getIsp(widget.organ);
        ILicenceRemote licenceRemote =
            widget.context.site.getService('/remote/org/licence');
        _orgLicenceOL = await licenceRemote.getLicence(widget.organ, 2);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orgLicenceOL == null) {
      return Column(
        children: <Widget>[
          Center(
            child: Text('正在加载...'),
          ),
        ],
      );
    }
    var type = widget.type;
//    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);

    return RepaintBoundary(
      key: comGlobalKey,
      child: Card(
        color: Color(0xFFFBE9E7),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 30,
                bottom: 2,
              ),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'lib/portals/gbera/images/gbera_op.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      widget.type == 2
                          ? 'ISP营业执照'
                          : widget.type == 0 ? 'LA营业执照' : '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: <Widget>[
                      Text(
                        '统一商家信用代码',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_orgLicenceOL.id}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'lib/portals/gbera/images/default_watting.gif',
                              image:
                                  '${type == 2 ? _orgISPOL.corpLogo : (type == 0 ? _orgLAOL.corpLogo : '')}?accessToken=${widget.context.principal.accessToken}',
                              width: 35,
                              height: 35,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '企    业   ',
                                    children: [
                                      TextSpan(
                                        text:
                                            '${type == 2 ? _orgISPOL.corpName : (type == 0 ? _orgLAOL.corpName : '')}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '认证号   ',
                                    children: [
                                      TextSpan(
                                        text:
                                            '${type == 2 ? _orgISPOL.corpCode : (type == 0 ? _orgLAOL.corpCode : '')}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: type == 0
                                  ? 'LA  代  表   人   '
                                  : type == 2 ? 'ISP  代  表  人   ' : '',
                              children: [
                                TextSpan(
                                  text:
                                      '${type == 2 ? _orgISPOL.masterRealName : (type == 0 ? _orgLAOL.masterRealName : '')}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        constraints: BoxConstraints.tightForFinite(
                          width: double.maxFinite,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '授权营业区域  ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 42,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      text: '行政区   ',
                                      children: [
                                        TextSpan(
                                          text:
                                              '${_orgLicenceOL.bussinessAreaTitle}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      text: '代    码   ',
                                      children: [
                                        TextSpan(
                                          text:
                                              '${_orgLicenceOL.bussinessAreaCode}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '经   营   范  围   ',
                                    children: [],
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 42,
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      text: '${_orgLicenceOL.bussinessScop}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                        child: Divider(
                          height: 1,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: '成  立   日   期   ',
                              children: [
                                TextSpan(
                                  text: '${_getPubTime()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: '授权营业期限   ',
                              children: [
                                TextSpan(
                                  text: '${_orgLicenceOL.operatePeriod}个月',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: '付  费   金   额   ',
                              children: [
                                TextSpan(
                                  text:
                                      '¥${((_orgLicenceOL.fee) / 1000000.00).toStringAsFixed(2)}万元',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      type != 0
                          ? SizedBox(
                              height: 0,
                              width: 0,
                            )
                          : SizedBox(
                              height: 3,
                            ),
                      type != 0
                          ? SizedBox(
                              height: 0,
                              width: 0,
                            )
                          : Row(
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '归 属 运 营 商   ',
                                    children: [
                                      TextSpan(
                                        text:
                                            '${_orgISPOL == null ? '' : _orgISPOL.corpName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.network(
                              '${_orgLicenceOL.payEvidence}?accessToken=${widget.context.principal.accessToken}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '签名: ${_orgLicenceOL.signText}',
                              softWrap: false,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  if (await _saveToPng()) {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return SimpleDialog(
                            title: Text('结果'),
                            children: <Widget>[
                              SimpleDialogOption(
                                onPressed: () {},
                                child: Text('保存成功!，请在相册中查看。'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  widget.context.backward();
                                },
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  }
                },
                child: Icon(
                  Icons.content_cut,
                  size: 14,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// 获取Uint8List数据
  Future<bool> _saveToPng() async {
    try {
      RenderRepaintBoundary boundary =
          comGlobalKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      await ImageGallerySaver.saveImage(pngBytes);
      return true; //这个对象就是图片数据
    } catch (e) {
      print('org_licence:$e');
      return false;
    }
  }

  _getPubTime() {
    var pubtime = _orgLicenceOL.pubTime;
    DateTime dateTime = parseStrTime(pubtime, len: 17);
    return intl.DateFormat("yyyy-MM-dd").format(dateTime);
  }
}
