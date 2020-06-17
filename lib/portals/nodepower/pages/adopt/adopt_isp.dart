import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class AdoptISP extends StatefulWidget {
  PageContext context;

  AdoptISP({this.context});

  @override
  _AdoptISPState createState() => _AdoptISPState();
}

class _AdoptISPState extends State<AdoptISP> {
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
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  child: Text('批准'),
                  onPressed: () {
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
    IIspRemote ispRemote = widget.context.site.getService('/remote/org/isp');
    await ispRemote.checkApplyRegisterByPlatform(inst.id, true);
    widget.context.backward(result: 'adopt');
  }

  void _returnApplyRegisterByPlatform(
      WorkInst inst, WorkEvent event, form) async {
    IIspRemote ispRemote = widget.context.site.getService('/remote/org/isp');
    await ispRemote.checkApplyRegisterByPlatform(inst.id, false);
    widget.context.backward(result: 'return');
  }
}
