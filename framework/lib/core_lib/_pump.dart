import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:framework/core_lib/_connection.dart';
import 'package:framework/core_lib/_event_queue.dart';
import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';

mixin IPump {
  IPumpWell get networkPumpWell;

  IPumpWell get errorPumpWell;

  IPumpWell get nofityPumpWell;

  Future<void> start(String networkQueuePath, String errorQueuePath,
      String nofityQueuePath, OnQueueCount onMessageCount) {}

  void close();
}

class _EntrypointArgument {
  SendPort bindSwicher;
  SendPort outputMessage;
  SendPort outputQueueCount;
  String queuePath;
  PumpWellType pumpWellType;

  bool isOutputQueueCount;

  _EntrypointArgument({
    this.bindSwicher,
    this.outputMessage,
    this.outputQueueCount,
    this.queuePath,
    this.isOutputQueueCount = false,
    this.pumpWellType = PumpWellType.network,
  });
}

enum PumpWellType {
  network,
  error,
  notify,
}
mixin IPumpWell {
  Future<void> start(String queuePath,
      [PumpWellType pumpWellType = PumpWellType.network,
      OnQueueCount onQueueCount]);

  void close();

  void listen(UserPrincipal principal, String url, onmessage);

  void unlisten(UserPrincipal principal, String url);

  void addTask(task);

  void addFrame(Frame frame) {}

  bool isListening(UserPrincipal principal, String path) {}
}

class DefaultPumpWell implements IPumpWell {
  Isolate _isolate;
  SendPort _outputTask;
  SendPort _outputListenItemChange;
  SendPort _outputMessage;
  Map<String, Onmessage> _listenItems = {};

  @override
  Future<void> start(String queuePath,
      [PumpWellType pumpWellType = PumpWellType.network,
      OnQueueCount onQueueCount]) async {
    ReceivePort bindReceivePort = ReceivePort();
    ReceivePort messageReceivePort = ReceivePort();
    ReceivePort onQueueCountReceivePort = ReceivePort();
    //虽然_entryPoint是静态函数，但每调用一次spawn则在内核中分配为新实例，即不会多个进程执行同一个实体，因为进程的空间是独立的。这类似于各个进程各自拷贝了一份该函数的代码指令集
    _isolate = await Isolate.spawn(
      _entryPoint,
      _EntrypointArgument(
        bindSwicher: bindReceivePort.sendPort,
        outputMessage: messageReceivePort.sendPort,
        outputQueueCount: onQueueCountReceivePort.sendPort,
        queuePath: queuePath,
        pumpWellType: pumpWellType,
        isOutputQueueCount: onQueueCount != null,
      ),
      debugName: 'isolate@${pumpWellType?.toString()}',
    );
    var outputPorts = await bindReceivePort.first as List<SendPort>;
    _outputTask = outputPorts[0];
    _outputListenItemChange = outputPorts[1];
    _outputMessage = outputPorts[2];

    messageReceivePort.listen((frameMap) {
      var itemKey = frameMap['itemKey'];
      var onmessage = _listenItems[itemKey];
      if (onmessage != null) {
        onmessage(Frame.build(frameMap));
      }
    });
    if (onQueueCount != null) {
      onQueueCountReceivePort.listen((count) {
        onQueueCount(count);
      });
    }
  }

  @override
  void close() {
    _isolate.kill();
  }

  @override
  bool isListening(UserPrincipal principal, String path) {
    return _listenItems.containsKey('${principal.person}:/$path');
  }

  @override
  void listen(UserPrincipal principal, String url, onmessage) {
    if (onmessage == null) {
      return;
    }
    unlisten(principal, url);

    var path = getPath(url);
    _listenItems['${principal.person}:/$path'] = onmessage;
    _outputListenItemChange?.send(
        _ListenItem(person: principal.person, path: path, action: 'listen'));
    //有侦听则通知拉取一次
    _outputTask.send({});
  }

  @override
  void unlisten(UserPrincipal principal, String url) {
    var path = getPath(url);
    _outputListenItemChange?.send(
        _ListenItem(person: principal.person, path: path, action: 'unlisten'));
    String itemKey = '${principal.person}:/$path';
    _listenItems?.remove(itemKey);
  }

  static _entryPoint(message) async {
//    print('----${Isolate.current.debugName}');
    var args = message as _EntrypointArgument;
    SendPort bindSwicher = args.bindSwicher;
    ReceivePort receiveTask = ReceivePort();
    ReceivePort receiveMessage = ReceivePort();
    ReceivePort receiveListenItemsChange = ReceivePort();
    bindSwicher.send([
      receiveTask.sendPort,
      receiveListenItemsChange.sendPort,
      receiveMessage.sendPort
    ]);

    IEventQueue queue = new DefaultEventQueue();
    if (args.isOutputQueueCount) {
      await queue.open(args.queuePath, (count) {
        //输出变化
        args.outputQueueCount.send(count);
      });
    } else {
      await queue.open(args.queuePath);
    }
    List<_ListenItem> _listenItems = [];

    _unlisten(String person, String path) {
      var count = _listenItems.length;
      for (var i = 0; i < count; i++) {
        var item = _listenItems[i];
        if (item == null) {
          continue;
        }
        if (item.path == path && item.person == person) {
          _listenItems.removeAt(i);
        }
      }
    }

    _listen(_item) {
      _unlisten(_item.person, _item.path);
      _listenItems.add(_item);
    }

    //以上是声明全局变量
    receiveListenItemsChange.listen((_item) {
      switch (_item.action) {
        case 'listen':
          _listen(_item);
          break;
        case 'unlisten':
          _unlisten(_item.person, _item.path);
          break;
      }
    });
    receiveMessage.listen((frameMap) async {
      await queue.add(frameMap);
    });
    SendPort outputMessage = args.outputMessage;
    receiveTask.listen((task) async {
      var count = _listenItems.length;
      for (var i = 0; i < count; i++) {
        var item = _listenItems[i];
        if (item == null) {
          continue;
        }
        List<Map<dynamic, dynamic>> frameList;
        switch (args.pumpWellType) {
          case PumpWellType.network:
            frameList = await queue.find(item.person, item.path);
            break;
          case PumpWellType.error:
            frameList = await queue.findAll();
            break;
          case PumpWellType.notify:
            frameList = await queue.findAll();
            break;
        }
        for (var map in frameList) {
//          Map<dynamic, dynamic> map = frame.toMap();
          map['itemKey'] = '${item.person}:/${item.path}';
          outputMessage.send(map);
          await queue.remove(map);
        }
      }
    });
  }

  @override
  void addTask(task) {
    _outputTask?.send(task);
  }

  @override
  void addFrame(Frame frame) {
    _outputMessage?.send(frame.toMap());
    addTask({});
  }
}

class DefaultPump implements IPump {
  IPumpWell _networkPumpWell;
  IPumpWell _errorPumpWell;
  IPumpWell _notifyPumpWell;

  @override
  Future<void> start(String networkQueuePath, String errorQueuePath,
      String nofityQueuePath, OnQueueCount onMessageCount) async {
    _networkPumpWell = DefaultPumpWell();
    _notifyPumpWell = DefaultPumpWell();
    _errorPumpWell = DefaultPumpWell();
    await _networkPumpWell.start(
        networkQueuePath, PumpWellType.network, onMessageCount);
    await _errorPumpWell.start(errorQueuePath, PumpWellType.error);
    await _notifyPumpWell.start(nofityQueuePath, PumpWellType.notify);
  }

  @override
  void close() {
    _networkPumpWell.close();
    _errorPumpWell.close();
    _notifyPumpWell.close();
  }

  @override
  IPumpWell get errorPumpWell => _errorPumpWell;

  @override
  IPumpWell get networkPumpWell => _networkPumpWell;

  @override
  IPumpWell get nofityPumpWell => _notifyPumpWell;
}

class _ListenItem {
  String action;
  String person;
  String path;

  _ListenItem({
    this.person,
    this.path,
    this.action,
  });
}
