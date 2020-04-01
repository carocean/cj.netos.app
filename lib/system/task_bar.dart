import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/main.dart';

class TaskBar extends StatefulWidget {
  IServiceProvider site;
  ProgressTaskBar progressTaskbar;

  TaskBar(this.site, this.progressTaskbar);

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
    widget.progressTaskbar.target = (percent) {
      this.percent = percent;
      state = percent > 0.99 ? 0 : 1;
      setState(() {});
    };
    IRemotePorts ports = widget.site.getService('@.remote.ports');
    _listenChannelTask(ports);
    _listenGeosphereSettingsTask(ports);
    _listenGeosphereDocTask(ports);
    _listenGeosphereDocUploadMediaTask(ports);
    super.initState();
  }

  @override
  void dispose() {
    widget.progressTaskbar.target = null;
    IRemotePorts ports = widget.site.getService('@.remote.ports');
    ports.portTask.unlistener('/network/channel/doc');
    ports.portTask.unlistener('/geosphere/receptor/settings');
    ports.portTask.unlistener('/geosphere/receptor/docs/publishMessage');
    ports.portTask.unlistener('/geosphere/receptor/docs/uploadMedia');
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

  void _listenGeosphereDocUploadMediaTask(ports) {
    //成功上传图片则提交多媒体信息
    ports.portTask.listener('/geosphere/receptor/docs/uploadMedia',
        (Frame frame) {
      switch (frame.command) {
        case "upload":
          switch (frame.head('sub-command')) {
            case 'begin':
              reset();
              break;
            case 'done':
              reset();
              var json = frame.contentText;
              var files = jsonDecode(json);
              var remoteFile = files[frame.parameter('src')];
              var _receptorPortsUrl =
                  widget.site.getService('@.prop.ports.document.geo.receptor');
              ports.portTask.addPortGETTask(
                _receptorPortsUrl,
                'addMedia',
                parameters: {
                  'receptor': frame.parameter('receptor'),
                  'category': frame.parameter('category'),
                  'docid': frame.parameter('msgid'),
                  'id': frame.parameter('id'),
                  'type': frame.parameter('type') ?? '',
                  'src': remoteFile,
                  'text': frame.parameter('text') ?? '',
                  'leading': frame.parameter('leading') ?? '',
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

  void _listenGeosphereDocTask(ports) {
    //文档成功上传完则推送
    ports.portTask.listener('/geosphere/receptor/docs/publishMessage', (frame) {
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
                  widget.site.getService('@.prop.ports.flow.geosphere');
              ports.portTask.addPortPOSTTask(
                flowChannelPortsUrl,
                'pushGeoDocument',
                parameters: {
                  'category': frame.parameter('category'),
                  'receptor': frame.parameter('receptor'),
                  'docid': frame.parameter('msgid'),
                  'interval': 100,
                },
              );
              break;
          }
          break;
      }
    });
  }

  void _listenGeosphereSettingsTask(IRemotePorts ports) {
    ports.portTask.listener('/geosphere/receptor/settings', (frame) {
      switch (frame.command) {
        case "upload":
          switch (frame.head('sub-command')) {
            case 'begin':
              reset();
              break;
            case 'done':
              reset();
              //调用更新背景api
              var json = frame.contentText;
              var files = jsonDecode(json);
              var remoteFile = files[frame.parameter('background')];
              var _receptorPortsUrl =
                  widget.site.getService('@.prop.ports.document.geo.receptor');
              ports.portTask.addPortGETTask(
                _receptorPortsUrl,
                'updateBackground',
                parameters: {
                  'id': frame.parameter('receptor'),
                  'category': frame.parameter('category'),
                  'mode': frame.parameter('mode'),
                  'background': remoteFile,
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
              var json = frame.contentText;
              var files = jsonDecode(json);
              var map = {
                'type': frame.parameter('type'),
                'docid': frame.parameter('docid'),
                'src': files[frame.parameter('localFile')],
                'channel': frame.parameter('channel'),
                'text': frame.parameter('text'),
                'leading': frame.parameter('leading'),
                'id': frame.parameter('mediaid'),
              };
              var docNetworkportsUrl = widget.site
                  .getService('@.prop.ports.document.network.channel');
              ports.portTask.addPortPOSTTask(
                docNetworkportsUrl,
                'addDocumentMedia',
                callbackUrl: '/network/channel/media',
                data: {
                  'media': jsonEncode(map),
                },
              );
              //推送媒体文件
              var flowChannelPortsUrl =
                  widget.site.getService('@.prop.ports.flow.channel');
              ports.portTask.addPortPOSTTask(
                flowChannelPortsUrl,
                'pushChannelDocumentMedia',
                callbackUrl: '/network/channel/media',
                parameters: {
                  'interval': 10,
                },
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
