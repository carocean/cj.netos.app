import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class TaskBar extends StatefulWidget {
  IServiceProvider site;

  TaskBar(this.site);

  @override
  _TaskBarState createState() => _TaskBarState();
}

class _TaskBarState extends State<TaskBar> {
  int state = 0; //0是初始态；1是正在处理
  double percent = 0.0;

  reset() {
    state = 0;
    percent = 0;
  }

  @override
  void initState() {
    IRemotePorts ports = widget.site.getService('@.remote.ports');
    _listenChannelTask(ports);
    super.initState();
  }

  @override
  void dispose() {
    IRemotePorts ports = widget.site.getService('@.remote.ports');
    ports.portTask.unlistener('/network/channel/doc');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (state < 1) {
      return Container(
        width: 0,
        height: 0,
      );
    }
    return LinearProgressIndicator(
      value: percent,
    );
  }

  void _listenChannelTask(IRemotePorts ports) {
    ports.portTask.listener('/network/channel/doc', (frame) {
      switch (frame.command) {
        case "portPost":
          switch (frame.head('sub-command')) {
            case 'begin':
              reset();
              break;
            case 'done':
              reset();
              //推文任务
              var flowChannelPortsUrl =
              widget.site.getService('@.prop.ports.flow.channel');
              ports.portTask.addPortPOSTTask(
                flowChannelPortsUrl,
                'pushChannelDocument',
                parameters: {
                  'channel': frame.parameter('channel'),
                  'docid': frame.parameter('docid'),
                  'interval': 100,
                },
              );
              break;
          }
          break;
        case "upload":
          switch (frame.head('sub-command')) {
            case 'begin':
              reset();
              break;
            case 'done':
              reset();
              var json=frame.contentText;
              var files=jsonDecode(json);
              var map = {
                'type': frame.parameter('type'),
                'docid':frame.parameter('docid'),
                'src': files[frame.parameter('localFile')],
              };
              var portsUrl =
              widget.site.getService('@.prop.ports.network.channel');
              ports.portTask.addPortPOSTTask(
                portsUrl,
                'addDocumentMedia',
                callbackUrl: '/network/channel/media',
                data: {
                  'media': jsonEncode(map),
                },
              );
              setState(() {});
              break;
            case 'sendProgress':
              state = 1;
              var count = frame.head('count');
              var total = frame.head('total');
              percent = double.parse(count) / double.parse(total);
              setState(() {});
              break;
          }
          break;
      }
    });
  }

}
