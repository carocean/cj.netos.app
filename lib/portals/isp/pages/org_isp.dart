import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/landagent/remote/org.dart';

class OrgISPPage extends StatefulWidget {
  PageContext context;

  OrgISPPage({this.context});

  @override
  _OrgISPPageState createState() => _OrgISPPageState();
}

class _OrgISPPageState extends State<OrgISPPage> {
  OrgISPOL _orgISPOL;
  OrgLicenceOL _orgLicenceOL;
  @override
  void initState() {
    _orgISPOL = widget.context.parameters['isp'];
    _onload().then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onload() async {
    ILicenceRemote licenceRemote = widget.context.site.getService('/org/licence');
    _orgLicenceOL=await licenceRemote.getLicence(_orgISPOL.id, 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_orgISPOL == null) {
      return Container();
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
              backgroundColor: Colors.transparent,
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
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${_orgISPOL.corpLogo}?accessToken=${widget.context.principal.accessToken}',
                    width: 40,
                    height: 40,
                  ),
                ),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 5,
                  children: <Widget>[
                    Text(
                      '${_orgISPOL.corpName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_orgISPOL.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CardItem(
                    title: 'ISP代表人',
                    subtitle: Text(
                      '${_orgISPOL.masterRealName}\n${_orgISPOL.masterPerson}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    tipsText: 'tel: ${_orgISPOL.masterPhone}',
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
                    '${intl.DateFormat('yyyy年MM月dd日').format(parseStrTime(_orgISPOL.ctime, len: 17))}',
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
                        '${_orgISPOL.licenceSrc}?accessToken=${widget.context.principal.accessToken}',
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
                            '${_orgISPOL.licenceSrc}?accessToken=${widget.context.principal.accessToken}',
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
          SizedBox(height: 10,),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CardItem(
                    title: 'ISP营业执照',
                    paddingLeft: 20,
                    paddingRight: 20,
                    onItemTap: () {
                      widget.context.forward('/viewer/licence',
                          scene: 'gbera',
                          arguments: {
                            'organ': _orgISPOL.id,
                            'type': 2,
                          });
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
        ],
      ),
    );
  }
}
