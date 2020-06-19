import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/landagent/remote/org.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class ApplyWyBank extends StatefulWidget {
  PageContext context;

  ApplyWyBank({this.context});

  @override
  _ApplyWyBankState createState() => _ApplyWyBankState();
}

class _ApplyWyBankState extends State<ApplyWyBank> {
  bool _showDistrict = false;
  List<OrgLAOL> _laList = [];
  OrgLicenceOL _orgLicenceOL;
  OrgLAOL _orgLAOL;
  String _wybankLogo_local;
  bool _logo_uploading = false;
  int _upload_logo_i = 0;
  int _upload_logo_j = 1;
  String _wybankLogo;

  @override
  void initState() {
    _onload().then((value) {
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

  bool _checkButoonEnabled() {
    return _orgLicenceOL != null && !StringUtil.isEmpty(_wybankLogo);
  }

  Future<void> _onload() async {
    IOrgLaRemote laRemote = widget.context.site.getService('/org/la');
    List<OrgLAOL> laList = await laRemote.listMyOrgLA();
    _laList.addAll(laList);
  }

  Future<void> _selectedLa(OrgLAOL la) async {
    IOrgLaRemote laRemote = widget.context.site.getService('/org/la');
    _orgLicenceOL = await laRemote.getLicence(la.id, 0);
    _orgLAOL = la;
    _showDistrict = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _uploadIcon(avatar) async {
    _wybankLogo_local = avatar;
    _logo_uploading = true;
    setState(() {});
    var map = await widget.context.ports
        .upload('/app/org/wybank/logo/', [avatar], onSendProgress: (i, j) {
      _upload_logo_i = i;
      _upload_logo_j = j;
      if (i == j) {
        _logo_uploading = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
    _wybankLogo = map[avatar];
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _doWorkflow() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/org/workflow');
    var data = jsonEncode({
      'title': _orgLAOL.corpSimple,
      'icon': _wybankLogo,
      'licence': _orgLicenceOL.id,
      'districtTitle': _orgLicenceOL.bussinessAreaTitle,
      'districtCode': _orgLicenceOL.bussinessAreaCode,
      'creator': widget.context.principal.person,
    });
    var workitem =
        await workflowRemote.createWorkInstance('workflow.wybank.apply', data);
    widget.context.backward(result: workitem);
  }

  @override
  Widget build(BuildContext context) {
    var dialogItems = <Widget>[];
    for (int i = 0; i < _laList.length; i++) {
      var la = _laList[i];
      dialogItems.add(
        CupertinoActionSheetAction(
          onPressed: () {
            widget.context.backward(
              result: la,
            );
          },
          child: Wrap(
            direction: Axis.horizontal,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: 'lib/portals/gbera/images/default_watting.gif',
                image:
                    '${la.corpLogo}?accessToken=${widget.context.principal.accessToken}',
                width: 30,
                height: 30,
                fit: BoxFit.fill,
              ),
              Text(
                '${la.corpSimple}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('申请纹银银行'),
            elevation: 0,
            pinned: true,
            actions: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: 14,
                  bottom: 14,
                  right: 10,
                ),
                width: 70,
                child: FlatButton(
                  child: Text(
                    '完成',
                    style: TextStyle(
                      color: !_checkButoonEnabled()
                          ? Colors.grey[400]
                          : Colors.white,
                    ),
                  ),
                  color: !_checkButoonEnabled() ? null : Color(0xFF0288d1),
                  onPressed: !_checkButoonEnabled()
                      ? null
                      : () {
                          _doWorkflow();
                        },
                ),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      CardItem(
                        title: '业主',
                        tipsText: '选择LA',
                        paddingRight: 20,
                        paddingLeft: 20,
                        onItemTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (ctx) {
                              return CupertinoActionSheet(
                                title: Text('从我的地商中选择'),
                                actions: dialogItems,
                                cancelButton: FlatButton(
                                  child: Text('取消'),
                                  onPressed: () {
                                    widget.context.backward();
                                  },
                                ),
                              );
                            },
                          ).then((value) {
                            if (value == null) {
                              return;
                            }
                            _selectedLa(value);
                          });
                        },
                      ),
                      !_showDistrict
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : CardItem(
                              title: '营业区域',
                              subtitle: Text(
                                '${_orgLicenceOL.title}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              paddingRight: 20,
                              paddingLeft: 50,
                              tipsText:
                                  '${_orgLicenceOL.bussinessAreaTitle}\n${_orgLicenceOL.bussinessAreaCode}',
                              onItemTap: () {
                                widget.context.forward('/viewer/licence',
                                    scene: 'gbera',
                                    arguments: {
                                      'organ': _orgLicenceOL.organ,
                                      'type': _orgLicenceOL.privilegeLevel,
                                    });
                              },
                            ),
                      Divider(
                        height: 1,
                        indent: 20,
                      ),
                      CardItem(
                        title: '徽标',
                        paddingRight: 20,
                        paddingLeft: 20,
                        tail: StringUtil.isEmpty(_wybankLogo_local)
                            ? null
                            : Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 5,
                                children: <Widget>[
                                  Wrap(
                                    direction: Axis.vertical,
                                    spacing: 2,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Image.file(
                                        File(
                                          '$_wybankLogo_local',
                                        ),
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.fill,
                                      ),
                                      !_logo_uploading
                                          ? SizedBox(
                                              width: 0,
                                              height: 0,
                                            )
                                          : Text(
                                              '${((_upload_logo_i / _upload_logo_j) * 100.00).toStringAsFixed(0)}%')
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                        onItemTap: () {
                          widget.context.forward('/widgets/avatar', scene: '/',
                              onFinishedSwitchScene: (avatar) {
                            if (StringUtil.isEmpty(avatar)) {
                              return;
                            }
                            _uploadIcon(avatar);
                          });
                        },
                      ),
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
