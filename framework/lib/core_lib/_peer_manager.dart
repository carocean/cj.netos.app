import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/core_lib/_app_surface.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';
import '_event_queue.dart';
import '_frame.dart';
import '_network_container.dart';
import '_peer.dart';
import '_principal.dart';
import '_pump.dart';
import '_service_containers.dart';

mixin IPeerManager {
  Future<void> start(ShareServiceContainer site) {}
}

class DefaultPeerManager implements IPeerManager {
  _getQueuePath() async {
    var appHomeDir = await path_provider.getApplicationDocumentsDirectory();
    var appHomePath = appHomeDir.path;
    final systemPath =
        '${appHomePath.endsWith('/') ? appHomePath : '$appHomePath/'}system/';
    var systemDir = Directory(systemPath);
    if (!systemDir.existsSync()) {
      systemDir.createSync();
    }
    var queuePath = '${systemPath}queues/';
    var queueDir = Directory(queuePath);
    if (!queueDir.existsSync()) {
      queueDir.createSync();
    }
    return queuePath;
  }

  Future<List<_NameServer>> _getNameservers(
      ShareServiceContainer site, String accessToken) async {
    Dio dio = site.getService('@.http');
    var path = site.getService('@.prop.ports.nameserver');
    var response = await dio.get(
      path,
      options: Options(
        headers: {
          'Rest-Command': 'workablePortList',
          'cjtoken': accessToken,
        },
      ),
    );
    if (response.statusCode >= 400) {
      throw new FlutterError(
          '${response.statusCode} ${response.statusMessage}');
    }
    var data = response.data;
    Map map = jsonDecode(data);
    if ((map['status'] as int) != 200) {
      throw new FlutterError('${map['status']} ${map['message']}');
    }
    var json = map['dataText'];
    List items = jsonDecode(json);
    List<_NameServer> names = [];
    items.forEach((v) {
      _NameServer name = new _NameServer(
        nodeName: v['nodeName'],
        openports: v['openports'],
      );
      names.add(name);
    });
    return names;
  }

  @override
  Future<void> start(ShareServiceContainer site) async {
    UserPrincipal principal = site.getService('@.principal');
    String accessToken = principal.accessToken;

    List<_NameServer> nameservers = await _getNameservers(site, accessToken);
    if (nameservers.isEmpty) {
      throw new FlutterError('未发现网络节点服务!');
    }
    var nameserver = nameservers[Uuid().v1().hashCode % nameservers.length];
    IPump pump = site.getService('@.pump');
    ILogicNetworkContainer logicNetworkContainer =
        site.getService('@.logic.network.container');
    AppCreator appCreator = site.getService('@.app.creator');

    var queuePath = await _getQueuePath();
    var errorQueuePath = '$queuePath/errorQueuePath.db';
    var networkQueuePath = '$queuePath/networkQueuePath.db';
    var systemQueuePath = '$queuePath/systemQueuePath.db';

    await _entryPoint(
      errorQueuePath: errorQueuePath,
      networkQueuePath: networkQueuePath,
      systemQueuePath: systemQueuePath,
      accessToken: accessToken,
      nameServer: nameserver,
      pump: pump,
      logicNetworkContainer: logicNetworkContainer,
      appCreator: appCreator,
    );
  }

  Future<void> _entryPoint({
    errorQueuePath,
    networkQueuePath,
    systemQueuePath,
    String accessToken,
    _NameServer nameServer,
    IPump pump,
    ILogicNetworkContainer logicNetworkContainer,
    AppCreator appCreator,
  }) async {
    IEventQueue errorQueue = DefaultEventQueue();
    IEventQueue networkQueue = DefaultEventQueue();
    IEventQueue systemQueue = DefaultEventQueue();

    if (appCreator.peerOnmessageCount != null) {
      networkQueue.onQueueCount = (count) {
        appCreator.peerOnmessageCount(count);
      };
    }

    await errorQueue.open(errorQueuePath);
    await networkQueue.open(networkQueuePath);
    await systemQueue.open(systemQueuePath);
    await pump.start(networkQueue, errorQueue, systemQueue);



    IPeer peer = await Peer.connect(
      nameServer.openports,
      pingInterval: Duration(seconds: 5),
      reconnectDelayed: Duration(seconds: 15),
      reconnectTimes: 10,
      onreconnect: (trytimes) {
        if (appCreator.peerOnreconnect != null)
          appCreator.peerOnreconnect(trytimes);
      },
      onopen: () async {
        pump.addNetworkTask({});
        pump.addErrorTask({});
        pump.addNotifyTask({});
        if (appCreator.peerOnopen != null) {
          appCreator.peerOnopen();
        }
      },
      onclose: () {
        if (appCreator.peerOnclose != null) appCreator.peerOnclose();
      },
      onerror: (frame) {
        errorQueue.add(frame);
        pump.addErrorTask({});
      },
      onmessage: (frame) {
        systemQueue.add(frame);
        pump.addNotifyTask({});
      },
    );
    peer.authByAccessToken(accessToken);
    var network = peer.listen(appCreator.messageNetwork,
        EndOrientation.frontend, ListenMode.downstream);
    network.onmessage((frame) async {
      networkQueue.add(frame);
      pump.addNetworkTask({});
    });
    logicNetworkContainer.peer = peer;
    logicNetworkContainer.addNetwork(network);
  }
}

class _NameServer {
  String nodeName;
  String openports;

  _NameServer({this.nodeName, this.openports});
}
