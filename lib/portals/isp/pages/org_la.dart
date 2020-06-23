import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/org.dart';

class OrgLAPage extends StatefulWidget {
  PageContext context;

  OrgLAPage({this.context});

  @override
  _OrgLAPageState createState() => _OrgLAPageState();
}

class _OrgLAPageState extends State<OrgLAPage> {
  OrgLAOL _orgLAOL;
  OrgISPOL _orgISPOL;
  OrgLicenceOL _orgIspLicenceOL;
  OrgLicenceOL _orgLALicenceOL;

  @override
  void initState() {
    _orgLAOL = widget.context.parameters['la'];
    _onload().then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onload() async {
    IOrgLaRemote laRemote = widget.context.site.getService('/org/la2');
    _orgISPOL = await laRemote.getIsp(_orgLAOL.isp);
    _orgIspLicenceOL = await laRemote.getLicence(_orgLAOL.isp, 2);
    _orgLALicenceOL = await laRemote.getLicence(_orgLAOL.id, 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_orgLAOL == null || _orgISPOL == null) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          MediaQuery.removePadding(
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            context: context,
            child: AppBar(
              title: Text('地商'),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.white,
              toolbarOpacity: 1,
              actions: <Widget>[],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 20,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${_orgLAOL.corpLogo}?accessToken=${widget.context.principal.accessToken}',
                    width: 40,
                    height: 40,
                  ),
                ),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 5,
                  children: <Widget>[
                    Text(
                      '${_orgLAOL.corpName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_orgLAOL.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_orgLALicenceOL?.bussinessAreaTitle}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CardItem(
                    title: 'LA代表人',
                    subtitle: Text(
                      '${_orgLAOL.masterRealName}\n${_orgLAOL.masterPerson}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    tipsText: 'tel: ${_orgLAOL.masterPhone}',
                    paddingLeft: 20,
                    paddingRight: 20,
                    tail: SizedBox(
                      width: 0,
                      height: 0,
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                  ),
                  CardItem(
                    title: '申请日期',
                    paddingLeft: 20,
                    paddingRight: 20,
                    tipsText:
                        '${intl.DateFormat('yyyy年MM月dd日').format(parseStrTime(_orgLAOL.ctime, len: 17))}',
                    tail: SizedBox(
                      width: 0,
                      height: 0,
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                  ),
                  CardItem(
                    title: '认证材料',
                    paddingLeft: 20,
                    paddingRight: 20,
                    tail: SizedBox(
                      width: 30,
                      height: 30,
                      child: FadeInImage.assetNetwork(
                        placeholder:
                            'lib/portals/gbera/images/default_watting.gif',
                        image:
                            '${_orgLAOL.licenceSrc}?accessToken=${widget.context.principal.accessToken}',
                      ),
                    ),
                    onItemTap: () {
                      widget.context.forward(
                        '/images/viewer',
                        scene: 'gbera',
                        arguments: {
                          'media': MediaSrc(
                            text: '认证材料',
                            type: 'image',
                            src:
                                '${_orgLAOL.licenceSrc}?accessToken=${widget.context.principal.accessToken}',
                          ),
                          'others': <MediaSrc>[],
                        },
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CardItem(
                    title: 'LA营业执照',
                    paddingLeft: 20,
                    paddingRight: 20,
                    onItemTap: () {
                      widget.context.forward('/viewer/licence',
                          scene: 'gbera',
                          arguments: {
                            'organ': _orgLAOL.id,
                            'type': 0,
                          });
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                  ),
                  CardItem(
                    title: '纹银银行',
                    paddingLeft: 20,
                    paddingRight: 20,
                    onItemTap: () {
                      widget.context.forward('/wenybank', arguments: {
                        'bank': WenyBank(
                          bank: 'xxxxx',
                          stock: 2388382.3332238883,
                          freezen: 2303,
                          profit: 23983,
                          price: 0.00233248848484,
                          info: BankInfo(
                            title: '农业发展',
                            ctime: '20200603122816333',
                            id: 'xxxx',
                            state: 1,
                            icon: '',
                            creator: 'cj@gbera.netos',
                          ),
                        ),
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.white,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),
                        child: Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 10,
                          children: <Widget>[
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            Text(
                              '发消息',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
