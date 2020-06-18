import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class AdoptLA extends StatefulWidget {
  PageContext context;

  AdoptLA({this.context});

  @override
  _AdoptLAState createState() => _AdoptLAState();
}

class _AdoptLAState extends State<AdoptLA> {
  String _selectedISP;
  List<OrgISPLicenceOL> _ispList = [];

  @override
  void initState() {
    _loadIsp();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WorkItem workitem = widget.context.page.parameters['workitem'];
    var inst = workitem.workInst;
    var event = workitem.workEvent;
    var form = jsonDecode(event.data);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: Image.network(
            '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
          ),
        ),
        titleSpacing: 0,
        title: Column(
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  '选择运营商: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      underline: Container(
                        height: 1,
                        color: Colors.grey[400],
                      ),
                      isExpanded: false,
                      elevation: 1,
                      value: _selectedISP,
                      onChanged: (v) {
                        _selectedISP = v;
                        setState(() {});
                      },
                      isDense: true,
                      items: _ispList.map((ispLicence) {
                        var isp = ispLicence.ispOL;
                        var licence = ispLicence.licenceOL;
                        return DropdownMenuItem(
                          value: isp.id,
                          child: Container(
                            child: Text(
                              '${isp.corpName}-${licence.bussinessAreaTitle}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: Adapt.screenH() / 2 - 100,
                  maxWidth: 250,
                ),
                color: Colors.white,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
//                      FadeInImage.assetNetwork(
//                        placeholder:
//                            'lib/portals/gbera/images/default_watting.gif',
//                        image:
//                            '${form['payEvidence']}?accessToken=${widget.context.principal.accessToken}',
//                        fit: BoxFit.cover,
//                      ),

                        MediaWidget([
                          MediaSrc(
                            id: '',
                            text: '交易单',
                            src: '${form['payEvidence']}',
                            type: 'image',
                          )
                        ], widget.context),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Text('交易单'),
                        ),
                      ],
                    ),
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
                  child: Text('批准'),
                  onPressed: StringUtil.isEmpty(_selectedISP)
                      ? null
                      : () {
                          _adoptApplyRegisterByPlatform(inst, event, form);
                        },
                ),
                FlatButton(
                  child: Text('退回'),
                  onPressed: () {
                    _returnApplyRegisterByPlatform(inst, event, form);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _adoptApplyRegisterByPlatform(
      WorkInst inst, WorkEvent event, form) async {
    ILaRemote laRemote = widget.context.site.getService('/remote/org/la');
    await laRemote.checkApplyRegisterByPlatform(inst.id, true,_selectedISP);
    widget.context.backward(result: 'adopt');
  }

  void _returnApplyRegisterByPlatform(
      WorkInst inst, WorkEvent event, form) async {
    ILaRemote laRemote = widget.context.site.getService('/remote/org/la');
    await laRemote.checkApplyRegisterByPlatform(inst.id, false,_selectedISP);
    widget.context.backward(result: 'return');
  }

  void _loadIsp() async {
    IIspRemote ispRemote = widget.context.site.getService('/remote/org/isp');
    List<OrgISPLicenceOL> list = await ispRemote.pageIsp(10000, 0);
    if (list.isNotEmpty) {
      _ispList.addAll(list);
    }
    if (mounted) {
      setState(() {});
    }
  }
}
