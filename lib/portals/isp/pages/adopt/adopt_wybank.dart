import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/wybank_form.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class AdoptWybank extends StatefulWidget {
  PageContext context;

  AdoptWybank({this.context});

  @override
  _AdoptWybankState createState() => _AdoptWybankState();
}

class _AdoptWybankState extends State<AdoptWybank> {
  WorkItem _workitem;
  OrgLicenceOL _orgLicenceOL;
  Map<String, dynamic> _form;

  @override
  void initState() {
    _workitem = widget.context.page.parameters['workitem'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    _form = jsonDecode(_workitem.workInst.data);
    ILicenceRemote licenceRemote =
        widget.context.site.getService('/org/licence');
    _orgLicenceOL = await licenceRemote.getLicenceByID(_form['licence']);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _doAdopt() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/org/workflow');
    await workflowRemote.doMyWorkItem(
      _workitem.workInst.id,
      'reviewed',
      true,
      '已阅',
    );
    widget.context
        .backward(result: {'action': 'doAdopt', 'workitem': _workitem});
  }

  @override
  Widget build(BuildContext context) {
    if (_workitem == null || _orgLicenceOL == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Center(
          child: Text(
            '加载中...',
          ),
        ),
      );
    }
    var inst = _workitem.workInst;
    var event = _workitem.workEvent;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: 5,
              ),
              child: Image.network(
                '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
                width: 30,
                height: 30,
                fit: BoxFit.fill,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${inst.name}'),
                  Text(
                    '件号:${event.id}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${_form['icon']}?accessToken=${widget.context.principal.accessToken}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 5,
                    children: <Widget>[
                      Text(
                        '${_form['title']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text.rich(TextSpan(
                        text: '申请人:',
                        children: [
                          TextSpan(
                            text: '${_form['creator']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      )),
                      Text.rich(TextSpan(
                        text: '行政区:',
                        children: [
                          TextSpan(
                            text: '${_form['districtTitle']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      )),
                      Text.rich(
                        TextSpan(
                          text: '区代码:',
                          children: [
                            TextSpan(
                              text: '${_form['districtCode']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            child: CardItem(
              title: 'LA运营资质认证',
              onItemTap: () {
                widget.context.forward(
                  '/viewer/licence',
                  scene: 'gbera',
                  arguments: {
                    'organ': _orgLicenceOL.organ,
                    'type': _orgLicenceOL.privilegeLevel,
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
                bottom: 20,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              color: Colors.white,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                    top: 10,
                                    left: 10,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 5,
                                    children: <Widget>[
                                      Text.rich(
                                        TextSpan(
                                          text: '投单金额(1.0000)=',
                                          children: [
                                            TextSpan(
                                              text:
                                                  '本金率(${(_form['principalRatio'] as double).toStringAsFixed(4)})+',
                                            ),
                                            TextSpan(
                                              text:
                                                  '费率(${(_form['serviceFeeRatio'] as double).toStringAsFixed(4)})',
                                            ),
                                          ],
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          text:
                                              '费率(${(_form['serviceFeeRatio'] as double).toStringAsFixed(4)})=',
                                          children: [
                                            TextSpan(
                                              text:
                                                  '准备率(${(_form['reserveRatio'] as double).toStringAsFixed(4)})+',
                                            ),
                                            TextSpan(
                                              text:
                                                  '自由金率(${((_form['serviceFeeRatio'] as double) - (_form['reserveRatio'] as double)).toStringAsFixed(4)})]',
                                            ),
                                          ],
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2,
                            left: 18,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                '费率',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (_form['ttmConfig'] as List<dynamic>)
                                  .map((ttm) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                      ),
                                      child: Text(
                                          '${ttm['ttm']} \n              ${ttm['minAmount']}/${ttm['maxAmount']}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      child: Divider(
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          Positioned(
                            top: 2,
                            left: 18,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                '市盈率',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                              ),
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          '平        台 ${(_form['platformRatio'] as double).toStringAsFixed(4)}'),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text('运  营  商 ${(_form['ispRatio'] as double).toStringAsFixed(4)}'),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text('地        商 ${(_form['laRatio'] as double).toStringAsFixed(4)}'),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child:
                                          Text('网络洇金 ${(_form['absorbRatio'] as double).toStringAsFixed(4)}'),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                    top: 5,
                                    left: 10,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(
                                    TextSpan(
                                      text: '地商账金提现人:',
                                      children: [
                                        TextSpan(
                                          text: ' ${inst.creator}',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2,
                            left: 18,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                '账比设置',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  child: Text('已阅'),
                  onPressed: (inst.isDone == 1 ||event.isDone==1||
                          _workitem.workEvent.recipient !=
                              widget.context.principal.person)
                      ? null
                      : () {
                          _doAdopt();
                        },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
