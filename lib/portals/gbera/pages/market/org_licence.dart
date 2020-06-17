import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class OrgLicenceCard extends StatefulWidget {
  PageContext context;
  String ispid;
  int type; //0为isp；1为la
  OrgLicenceCard({this.context, this.ispid, this.type});

  @override
  _OrgLicenceCardState createState() => _OrgLicenceCardState();
}

class _OrgLicenceCardState extends State<OrgLicenceCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);
    return Stack(
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
                  'ISP营业执照',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                children: <Widget>[
                  Text(
                    '统一商家信用代码',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '939299392399293',
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
                              'http://47.105.165.186:7100/app/org/isp/licence/0e0ad670-af05-11ea-de3e-d5b24b50094e.jpg?accessToken=${widget.context.principal.accessToken}',
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
                                    text: '动力信息',
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
                                    text: '9388383839929292',
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: 'ISP  代  表  人   ',
                          children: [
                            TextSpan(
                              text: '陆飞',
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
                          '授权运营区域  ',
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
                                      text: '河南省',
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
                                      text: '883838',
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
                      Text.rich(
                        TextSpan(
                          text: '经   营   范  围   ',
                          children: [
                            TextSpan(
                              text: '信息技术、计算机等',
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
                    height: 30,
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: '付  费   金   额   ',
                          children: [
                            TextSpan(
                              text: '¥60.00万元',
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
                          text: '成  立   日   期   ',
                          children: [
                            TextSpan(
                              text: '2020年4月8日',
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
                              text: '12个月',
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
                          'http://47.105.165.186:7100/app/org/isp/licence/0e0ad670-af05-11ea-de3e-d5b24b50094e.jpg?accessToken=${widget.context.principal.accessToken}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '签名: 8823823828283',
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
            onTap: () {},
            child: Icon(
              Icons.content_cut,
              size: 14,
            ),
          ),
        )
      ],
    );
  }
}
