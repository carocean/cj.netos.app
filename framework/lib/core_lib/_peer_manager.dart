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
import '_utimate.dart';

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

  Future<List<dynamic>> _getNameservers(
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
    return jsonDecode(json);
  }

  @override
  Future<void> start(ShareServiceContainer site) async {
    UserPrincipal principal = site.getService('@.principal');
    String accessToken = principal.accessToken;
    List<dynamic> nameservers = await _getNameservers(site, accessToken);
    if (nameservers.isEmpty) {
      throw new FlutterError('未发现网络节点服务!');
    }
    //在服务器数不变的情况下，让每个用户每次始终连向同一台机。
    //注：如果在完全均衡的情况下，用户的连接历史会在多台机上注册endport，每个endport都会存储发向他的同一份信息，所以下次再连向不同机时又会接收一份，造成重复接收。
    // 如果network下发时判断用户不在线就不存入endport的话，当用户在所有节点都不在线时，就丢失了发向他的信息，这肯定是不行的
    //该方式在扩展服务器数时也会造成多节点连接，不是撤低的解决办法。
    // 方案：一种方式是采用一致性哈希，保证在节点扩展或收缩时落在同一台机；一种是先遍历所有节点看是否有endport，如果有则与之连接，如果都没有连接过则用负载法选取一个。
    //第二种方案比较稳妥，但如果节点变成1000多个的时候，建立连接时的遍历会非常耗时，这也是美中不足的地方。
    //第三种方案可以让network报告person的登录点，然后通过名服务器来其历史登录点，如果有且可用则用之，有而不可用（节点不在了）则重新负载一个，没有则负载一个。这种方案是全解方案，没缺陷，上线前应实现该方案，否则上线后再实现的话数据迁移是个大工程。
    //目前临时采用person定向负载方式，为什么不采用person/device作为定向负载，因为不论用户用什么设备登录，其接收的信息都是他自己的，各设备都应接收一样信息。
    var nameserver = nameservers[
        MD5Util.MD5(principal.person).hashCode % nameservers.length];
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
    String nameServer,
    IPump pump,
    ILogicNetworkContainer logicNetworkContainer,
    AppCreator appCreator,
  }) async {
    await pump.start(networkQueuePath, errorQueuePath, systemQueuePath,
        appCreator.peerOnmessageCount);

    IPeer peer = await Peer.connect(
      nameServer,
      pingInterval: Duration(seconds: 5),
      reconnectDelayed: Duration(seconds: 10),
      onreconnect: (trytimes) {
        if (appCreator.peerOnreconnect != null)
          appCreator.peerOnreconnect(trytimes);
      },
      onopen: () async {
        pump.errorPumpWell.addTask({});
        pump.networkPumpWell.addTask({});
        pump.nofityPumpWell.addTask({});
        if (appCreator.peerOnopen != null) {
          appCreator.peerOnopen();
        }
      },
      onclose: () {
        if (appCreator.peerOnclose != null) appCreator.peerOnclose();
      },
      onerror: (frame) {
        pump.errorPumpWell.addFrame(frame);
      },
      onmessage: (frame) {
        pump.nofityPumpWell.addFrame(frame);
        if ('online' == frame.command) {
          if (appCreator.peerOnline != null) {
            appCreator.peerOnline();
          }
        }
      },
    );
    peer.authByAccessToken(accessToken);
    var network = peer.listen(appCreator.messageNetwork,
        EndOrientation.frontend, ListenMode.downstream);
    network.onmessage((frame) async {
      pump.networkPumpWell.addFrame(frame);
    });
    logicNetworkContainer.peer = peer;
    logicNetworkContainer.addNetwork(network);
  }
}
