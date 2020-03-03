import 'dart:async';
import 'dart:collection';

import 'package:framework/core_lib/_connection.dart';
import 'package:framework/core_lib/_event_queue.dart';
import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';

mixin IPump {
  void listenNetwork(UserPrincipal principal, String url,String matchPath, onmessage) {}

  void unlistenNetwork(UserPrincipal principal, String url) {}

  void start(IEventQueue networkQueue, IEventQueue errorQueue, IEventQueue nofityQueue) {}

  void addNetworkTask(dynamic task);

  void addErrorTask(task);

  void addNotifyTask(task);

  void close();

  void listenError(UserPrincipal principal, String url, Onerror onerror) {}

  void listenNotify(UserPrincipal principal, String url, Onmessage onmessage) {}

  void unlistenError(UserPrincipal principal, String url);

  void unlistenNotify(UserPrincipal principal, String url);
}

class DefaultPump implements IPump {
  List<_ListenItem> _listenItemsNetwork = [];
  StreamController _streamControllerNetwork;
  List<_ListenItem> _listenItemsError = [];
  StreamController _streamControllerError;
  List<_ListenItem> _listenItemsNotify = [];
  StreamController _streamControllerNotify;

  @override
  void addNetworkTask(task) {
    _streamControllerNetwork.add(task);
  }

  @override
  void addErrorTask(task) {
    _streamControllerError.add(task);
  }

  @override
  void addNotifyTask(task) {
    _streamControllerNotify.add(task);
  }

  @override
  void start(IEventQueue networkQueue, IEventQueue errorQueue, IEventQueue nofityQueue) async {
    _startNetwork(networkQueue);
    _startError(errorQueue);
    _startNofity(nofityQueue);
//    Stream.periodic(
//        Duration(
//          seconds: 15, //每隔15秒发一次任务
//        ), (count) {
//      return {};
//    }).listen((task) async {
////      if (await _streamControllerNotify.stream.isEmpty) {
//        addNotifyTask(task);
////      }
////      if (await _streamControllerError.stream.isEmpty) {
//        addErrorTask(task);
////      }
////      if (await _streamControllerNetwork.stream.isEmpty) {
//        addNetworkTask(task);
////      }
//    });
  }

  void _startNofity(IEventQueue queue) {
    if (_streamControllerNotify != null) {
      _streamControllerNotify.close();
    }
    _streamControllerNotify = StreamController();
    _streamControllerNotify.stream.listen((task) async {
      for (var i = 0; i < _listenItemsNotify.length; i++) {
        var item = _listenItemsNotify[i];
        if (item == null) {
          continue;
        }
        List<Frame> frameList = await queue.findAll();
        for (var frame in frameList) {
          item.handler(frame);
          await queue.removeWhere(frame);
        }
      }
    });
  }

  void _startError(IEventQueue queue) {
    if (_streamControllerError != null) {
      _streamControllerError.close();
    }
    _streamControllerError = StreamController();
    _streamControllerError.stream.listen((task) async {
      for (var i = 0; i < _listenItemsError.length; i++) {
        var item = _listenItemsError[i];
        if (item == null) {
          continue;
        }
        List<Frame> frameList = await queue.findAll();
        for (var frame in frameList) {
          item.handler(frame);
          await queue.removeWhere(frame);
        }
      }
    });
  }

  void _startNetwork(IEventQueue queue) {
    if (_streamControllerNetwork != null) {
      _streamControllerNetwork.close();
    }
    _streamControllerNetwork = StreamController();
    _streamControllerNetwork.stream.listen((task) async {
      for (var i = 0; i < _listenItemsNetwork.length; i++) {
        var item = _listenItemsNetwork[i];
        if (item == null) {
          continue;
        }
        List<Frame> frameList = await queue.find(item.person, item.path);
        for (var frame in frameList) {
          item.handler(frame);
          await queue.remove(frame);
        }
      }
    });
  }

  @override
  void listenNetwork(UserPrincipal principal, String url,String matchPath, onmessage) async {
    if (onmessage == null) {
      return;
    }
    unlistenNetwork(principal, url);

    var path;
    if(!StringUtil.isEmpty(matchPath)) {
      path=matchPath;
    }else{
      path = _getPath(url);
    }
    _listenItemsNetwork.add(
      _ListenItem(
        person: principal.person,
        path: path,
        handler: onmessage,
      ),
    );
    addNetworkTask({});
  }

  @override
  void unlistenNetwork(UserPrincipal principal, String url) {
    var path = _getPath(url);
    var count = _listenItemsNetwork.length;
    for (var i = 0; i < count; i++) {
      var item = _listenItemsNetwork[i];
      if (item == null) {
        continue;
      }
      if (item.path == path && item.person == principal.person) {
        _listenItemsNetwork.removeAt(i);
      }
    }
  }

  @override
  void listenError(UserPrincipal principal, String url, Onerror onerror) {
    if (onerror == null) {
      return;
    }
    unlistenError(principal, url);
    var path = _getPath(url);
    _listenItemsError.add(
      _ListenItem(
        person: principal.person,
        path: path,
        handler: onerror,
      ),
    );
    addErrorTask({});
  }

  @override
  void listenNotify(UserPrincipal principal, String url, onmessage) {
    if (onmessage == null) {
      return;
    }
    unlistenNotify(principal, url);
    var path = _getPath(url);
    _listenItemsNotify.add(
      _ListenItem(
        person: principal.person,
        path: path,
        handler: onmessage,
      ),
    );
    addNotifyTask({});
  }

  @override
  void unlistenError(UserPrincipal principal, String url) {
    var path = _getPath(url);
    var count = _listenItemsError.length;
    for (var i = 0; i < count; i++) {
      var item = _listenItemsError[i];
      if (item == null) {
        continue;
      }
      if (item.path == path && item.person == principal.person) {
        _listenItemsError.removeAt(i);
      }
    }
  }

  @override
  void unlistenNotify(UserPrincipal principal, String url) {
    var path = _getPath(url);
    var count = _listenItemsNotify.length;
    for (var i = 0; i < count; i++) {
      var item = _listenItemsNotify[i];
      if (item == null) {
        continue;
      }
      if (item.path == path && item.person == principal.person) {
        _listenItemsNotify.removeAt(i);
      }
    }
  }

  _getPath(String url) {
    var path = '';
    int pos = url.indexOf("?");
    if (pos < 0) {
      path = url;
    } else {
      path = url.substring(0, pos);
    }
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }

  @override
  void close() {
    _streamControllerNetwork.close();
    _streamControllerNotify.close();
    _streamControllerError.close();
  }
}

class _ListenItem {
  String person;
  String path;
  dynamic handler;

  _ListenItem({this.person, this.path, this.handler});
}
