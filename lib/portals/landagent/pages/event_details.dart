import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';

class LandagentEventDetails extends StatefulWidget {
  PageContext context;

  LandagentEventDetails({this.context});

  @override
  _LandagentEventDetailsState createState() => _LandagentEventDetailsState();
}

class _LandagentEventDetailsState extends State<LandagentEventDetails> {
  @override
  Widget build(BuildContext context) {
    WorkItem workitem = widget.context.page.parameters['workitem'];

    return Scaffold(
      appBar: AppBar(
        title: _getTitle(widget.context, workitem),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(
                  left: 50,
                  right: 50,
                  bottom: 10,
                ),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  child: _rendWorkitem(widget.context, workitem),
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            alignment: Alignment.center,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            color: Colors.white,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              alignment: WrapAlignment.spaceAround,
              children: _getButtons(widget.context, workitem),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _getTitle(PageContext context, WorkItem workitem) {
  var inst = workitem.workInst;
  return Wrap(
    direction: Axis.horizontal,
    spacing: 10,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: <Widget>[
      FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image: '${inst.icon}?accessToken=${context.principal.accessToken}',
        width: 25,
        height: 25,
        fit: BoxFit.fill,
      ),
      Text('${inst.name}'),
    ],
  );
}

List<Widget> _getButtons(PageContext context, WorkItem workitem) {
  var buttons = <Widget>[];
  switch (workitem.workInst.workflow) {
    case 'workflow.wybank.apply':
      buttons.add(
        FlatButton(
          onPressed: () {
            context.backward();
          },
          child: Text(
            '返回',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
      break;
    default:
      break;
  }
  return buttons;
}

Widget _rendWorkitem(PageContext context, WorkItem workitem) {
  var inst = workitem.workInst;
  var event = workitem.workEvent;
  var form = jsonDecode(workitem.workEvent.data);
  switch (workitem.workInst.workflow) {
    case 'workflow.wybank.apply':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${form['icon']}?accessToken=${context.principal.accessToken}',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  direction: Axis.vertical,
                  spacing: 5,
                  children: <Widget>[
                    Text(
                      '${form['title']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${form['districtTitle']} ${form['districtCode']}'),
                    Text('${inst.isDone == 1 ? '流程结束' : '流转中'}'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.white,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            padding: EdgeInsets.only(
              left: 20,
              top: 10,
              bottom: 10
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('当前步骤:${event.title}'),
                SizedBox(
                  height: 5,
                ),
                Text('处理人:${event.recipient ?? '-'}'),
                SizedBox(
                  height: 5,
                ),
                Text('状态:${event.isDone == 1 ? '完成' : '正在处理'}'),
                SizedBox(
                  height: 5,
                ),
                Text('说明:${event.note ?? '-'}'),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    default:
      return Container(
        child: Text('不支持显示该流程的工作项'),
      );
  }
}
