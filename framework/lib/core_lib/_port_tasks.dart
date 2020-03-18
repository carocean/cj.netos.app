import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';

import '_principal.dart';

mixin IPortTaskManager {
  Future<void> start(IServiceProvider site);

  void close();

  listener(String path, Function(Frame) onmessage);

  unlistener(String path);

  void addPortGETTask(
    portsUrl,
    String restCommand, {
    String callbackUrl = '/',
    String tokenName = 'cjtoken',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
  }) {}

  void addPortPOSTTask(
    portsUrl,
    String restCommand, {
    String callbackUrl = '/',
    String tokenName = 'cjtoken',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
    data,
  }) {}

  void addUploadTask(
    String remoteDir,
    List<String> localFiles, {
    String callbackUrl = '/',
    String accessToken,
  });

  void addDownloadTask(
    String url,
    String localFile, {
    String callbackUrl = '/',
    Map<String, dynamic> queryParameters,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
  });

  void addDeleteFileTask(
    String file, {
    String callbackUrl = '/',
  });
}

class _PortTask {
  String name;
  String accessToken;
  String callbackUrl;
  Map<String, dynamic> headers;
  Map<String, dynamic> parameters;
  List<String> localFiles;
  String url;
  String localFile;
  dynamic data;
  bool deleteOnError;
  String lengthHeader;
  String remoteDir;
  String tokenName;
  String restCommand;

  _PortTask({
    this.name,
    this.accessToken,
    this.headers,
    this.parameters,
    this.callbackUrl,
    this.data,
    this.localFiles,
    this.url,
    this.localFile,
    this.lengthHeader,
    this.deleteOnError,
    this.remoteDir,
    this.tokenName,
    this.restCommand,
  });

  Map toMap() {
    return {
      'name': name,
      'accessToken': accessToken,
      'headers': headers,
      'parameters': parameters,
      'callbackUrl': callbackUrl,
      'data': data,
      'localFiles': localFiles,
      'url': url,
      'localFile': localFile,
      'lengthHeader': lengthHeader,
      'deleteOnError': deleteOnError,
      'remoteDir': remoteDir,
      'tokenName': tokenName,
      'restCommand': restCommand,
    };
  }

  static fromdMap(Map taskObj) {
    return _PortTask(
      name: taskObj['name'],
      accessToken: taskObj['accessToken'],
      headers: taskObj['headers'],
      parameters: taskObj['parameters'],
      callbackUrl: taskObj['callbackUrl'],
      data: taskObj['data'],
      localFiles: taskObj['localFiles'],
      url: taskObj['url'],
      localFile: taskObj['localFile'],
      lengthHeader: taskObj['lengthHeader'],
      deleteOnError: taskObj['deleteOnError'],
      remoteDir: taskObj['remoteDir'],
      tokenName: taskObj['tokenName'],
      restCommand: taskObj['restCommand'],
    );
  }
}

class _EntrypointArgument {
  SendPort bindPort;
  SendPort messagePort;
  String delFilePortsUrl;
  String readFilePortsUrl;
  String uploaderFilePortsUrl;
  String queuePath;

  _EntrypointArgument({
    this.bindPort,
    this.messagePort,
    this.delFilePortsUrl,
    this.readFilePortsUrl,
    this.uploaderFilePortsUrl,
    this.queuePath,
  });
}

mixin _IPortListener {
  String get path;

  void onmessage(Frame frame) {}
}

class _DefaultListener implements _IPortListener {
  String _path;
  Function(Frame) _onmessage;

  _DefaultListener({path, onmessage}) {
    this._onmessage = onmessage;
    this._path = path;
  }

  @override
  void onmessage(Frame frame) {
    if (_onmessage != null) {
      _onmessage(frame);
    }
  }

  @override
  // TODO: implement path
  String get path => _path;
}

class DefaultPortTaskManager implements IPortTaskManager {
  SendPort _output;
  IServiceProvider _site;
  SendPort _notifyPort;
  List<_IPortListener> _listeners = [];
  Isolate _isolate;

  @override
  UserPrincipal get principal => _site.getService('@.principal');

  @override
  listener(String path, Function(Frame) onmessage) {
    _listeners.add(_DefaultListener(path: path, onmessage: onmessage));
  }

  @override
  unlistener(String path) {
    for (var i = 0; i < _listeners.length; i++) {
      var listener = _listeners[0];
      if (listener.path.startsWith(path)) {
        _listeners.removeAt(i);
      }
    }
  }

  @override
  Future<void> start(IServiceProvider site) async {
    _site = site;
    var appHomeDir = await path_provider.getApplicationDocumentsDirectory();
    var appHomePath = appHomeDir.path;
    final systemPath =
        '${appHomePath.endsWith('/') ? appHomePath : '$appHomePath/'}system/';
    var systemDir = Directory(systemPath);
    if (!systemDir.existsSync()) {
      systemDir.createSync();
    }
    var path = '${systemPath}port';
    var queueDir = Directory(path);
    if (!queueDir.existsSync()) {
      queueDir.createSync();
    }
    ReceivePort bindPort = ReceivePort();
    ReceivePort messagePort = ReceivePort();
    _isolate = await Isolate.spawn(
      entrypoint,
      _EntrypointArgument(
        delFilePortsUrl: _site.getService('@.prop.fs.delfile'),
        readFilePortsUrl: _site.getService('@.prop.fs.reader'),
        uploaderFilePortsUrl: _site.getService('@.prop.fs.uploader'),
        bindPort: bindPort.sendPort,
        messagePort: messagePort.sendPort,
        queuePath: path,
      ),
    );
    messagePort.listen((data) {
      var frame = Frame.build(data);
      for (var listener in _listeners) {
        if (!frame.url.startsWith(listener.path)) {
          continue;
        }
        listener.onmessage(frame);
      }
    });
    List<SendPort> list = await bindPort.first;
    _output = list[0];
    _notifyPort = list[1];
    //启动后先通知检测下是否有库存任务
    _notifyPort.send({});
  }

  static void entrypoint(message) async {
    var args = message as _EntrypointArgument;
    var bindPort = args.bindPort;
    ReceivePort messageReceivePort = ReceivePort();
    ReceivePort notifyReceivePort = ReceivePort();
    bindPort.send([messageReceivePort.sendPort, notifyReceivePort.sendPort]);

    BaseOptions options = BaseOptions(headers: {
      'Content-Type': "text/html; charset=utf-8",
    });
    var _dio = Dio(options);

    var _db = ObjectDB('${args.queuePath}/tasks');
    _db.open();

    var controller = StreamController();
    controller.stream.listen((data) async {
      List<Map<dynamic, dynamic>> tasks = await _db.find({});
      for (Map<dynamic, dynamic> taskObj in tasks) {
        var task = _PortTask.fromdMap(taskObj);
        switch (task.name) {
          case 'addPortGETTask':
            _addPortGETTask(args, _dio, task);
            break;
          case 'addPortPOSTTask':
            _addPortPOSTTask(args, _dio, task);
            break;
          case 'addUploadTask':
            _addUploadTask(args, _dio, task);
            break;
          case 'addDownloadTask':
            _addDownloadTask(args, _dio, task);
            break;
          case 'addDeleteFileTask':
            _addDeleteFileTask(args, _dio, task);
            break;
        }
        await _db.remove({'_id': taskObj['_id']});
      }
    });
    notifyReceivePort.listen((data) {
      if ('close' == data) {
        controller.close();
        _db.close();
        return;
      }
      controller.add({});
    });
    messageReceivePort.listen((data) async {
      var task = data as _PortTask;
      await _db.insert(task.toMap());
      controller.add({});
    });
  }

  @override
  void close() {
    _notifyPort.send('close');
    _isolate.kill();
  }

  @override
  void addDeleteFileTask(
    String file, {
    String callbackUrl = '/',
  }) {
    _output.send(_PortTask(
      accessToken: principal.accessToken,
      url: file,
      callbackUrl: callbackUrl,
      name: 'addDeleteFileTask',
    ));
  }

  @override
  void addDownloadTask(String url, String localFile,
      {String callbackUrl = '/',
      Map<String, dynamic> queryParameters,
      bool deleteOnError = true,
      String lengthHeader = Headers.contentLengthHeader,
      data}) {
    _output.send(_PortTask(
      url: url,
      accessToken: principal.accessToken,
      callbackUrl: callbackUrl,
      localFile: localFile,
      parameters: queryParameters,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      name: 'addDownloadTask',
    ));
  }

  @override
  void addPortGETTask(
    portsUrl,
    String restCommand, {
    String tokenName = 'cjtoken',
    String callbackUrl = '/',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
  }) {
    _output.send(_PortTask(
      accessToken: principal.accessToken,
      headers: headers ?? <String, dynamic>{},
      parameters: parameters ?? <String, dynamic>{},
      callbackUrl: callbackUrl,
      url: portsUrl,
      restCommand: restCommand,
      tokenName: tokenName,
      name: 'addPortGETTask',
    ));
  }

  @override
  void addPortPOSTTask(portsUrl, String restCommand,
      {String tokenName = 'cjtoken',
      String callbackUrl = '/',
      Map<String, dynamic> headers,
      Map<String, dynamic> parameters,
      data}) {
    _output.send(_PortTask(
      accessToken: principal.accessToken,
      headers: headers ?? <String, dynamic>{},
      parameters: parameters ?? <String, dynamic>{},
      callbackUrl: callbackUrl,
      tokenName: tokenName,
      url: portsUrl,
      restCommand: restCommand,
      data: data,
      name: 'addPortPOSTTask',
    ));
  }

  @override
  void addUploadTask(
    String remoteDir,
    List<String> localFiles, {
    String accessToken,
    String callbackUrl = '/',
  }) {
    _output.send(_PortTask(
      accessToken: accessToken ?? principal.accessToken,
      callbackUrl: callbackUrl,
      localFiles: localFiles,
      remoteDir: remoteDir,
      name: 'addUploadTask',
    ));
  }
}

void _addDeleteFileTask(
    _EntrypointArgument args, Dio dio, _PortTask task) async {
  var status = '200';
  var message = 'ok';
  var frame = Frame('delete ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'begin');
  frame.setHead('path', task.url);
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());

  var response;
  try {
    response = await dio.get(
      args.delFilePortsUrl,
      options: Options(),
      queryParameters: {'path': task.url, 'type': 'f'},
    );
  } catch (e) {
    status = '500';
    message = '$e';
    var frame = Frame('delete ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setParameter('path', task.url);
    frame.setHead('status', status);
    frame.setHead('message', message);
    args.messagePort.send(frame.toMap());
    return;
  }
  if (response.statusCode > 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
    var frame = Frame('delete ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('path', task.url);
    frame.setHead('status', status);
    frame.setHead('message', message);
    args.messagePort.send(frame.toMap());
    return;
  }
  frame = Frame('delete ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'done');
  frame.setHead('path', task.url);
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());
}

void _addUploadTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  if (task.localFiles == null || task.localFiles.isEmpty) {
    return null;
  }
  var status = '200';
  var message = 'ok';
  var files = <MultipartFile>[];
  var remoteFiles = <String, String>{};
  for (var i = 0; i < task.localFiles.length; i++) {
    var f = task.localFiles[i];
    var ext = fileExt(f);
    String fn = "${Uuid().v1()}";
    if (!StringUtil.isEmpty(ext)) {
      fn = '$fn.$ext';
    }
    remoteFiles[f] = '${args.readFilePortsUrl}${task.remoteDir}/$fn';
    files.add(await MultipartFile.fromFile(
      f,
      filename: fn,
    ));
  }
  FormData data = FormData.fromMap({
    'files': files,
  });
  Frame frame = Frame('upload ${task.callbackUrl ?? '/'} port/1.0');
  frame.setHead('sub-command', 'begin');
  frame.setHead('status', status);
  frame.setHead('message', message);
  frame.addContent(jsonEncode(remoteFiles));
  args.messagePort.send(frame.toMap());

  var response;
  try {
    response = await dio.post(
      args.uploaderFilePortsUrl,
      data: data,
      options: Options(
        //上传的accessToken在header中，为了兼容在参数里也放
        headers: {
          "Cookie": 'accessToken=${task.accessToken}',
        },
      ),
      queryParameters: {
        'accessToken': task.accessToken,
        'dir': task.remoteDir,
      },
      onReceiveProgress: (i, j) {
        var frame = Frame('upload ${task.callbackUrl} port/1.0');
        frame.setHead('sub-command', 'receiveProgress');
        frame.setHead('count', '$i');
        frame.setHead('total', '$j');
        frame.setHead('status', status);
        frame.setHead('message', message);
        args.messagePort.send(frame.toMap());
      },
      onSendProgress: (i, j) {
        var frame = Frame('upload ${task.callbackUrl} port/1.0');
        frame.setHead('sub-command', 'sendProgress');
        frame.setHead('count', '$i');
        frame.setHead('total', '$j');
        frame.setHead('status', status);
        frame.setHead('message', message);
        args.messagePort.send(frame.toMap());
      },
    );
  } catch (e) {
    status = '500';
    message = '$e';
    Frame frame = Frame('upload ${task.callbackUrl ?? '/'} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.addContent(jsonEncode(remoteFiles));
    args.messagePort.send(frame.toMap());
    return;
  }
  //返回： remoteFiles;
  if (response.statusCode > 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
    Frame frame = Frame('upload ${task.callbackUrl ?? '/'} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.addContent(jsonEncode(remoteFiles));
    args.messagePort.send(frame.toMap());
    return;
  }
  frame = Frame('upload ${task.callbackUrl ?? '/'} port/1.0');
  frame.setHead('sub-command', 'done');
  frame.setHead('status', status);
  frame.setHead('message', message);
  frame.addContent(jsonEncode(remoteFiles));
  args.messagePort.send(frame.toMap());
}

void _addDownloadTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  var status = '200';
  var message = 'ok';
  var frame = Frame('download ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'begin');
  frame.setHead('localFile', task.localFile);
  frame.setHead('remoteUrl', task.url);
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());
  var response;
  try {
    response = await dio.download(
      task.url,
      task.localFile,
      onReceiveProgress: (i, j) {
        var frame = Frame('download ${task.callbackUrl} port/1.0');
        frame.setHead('sub-command', 'receiveProgress');
        frame.setHead('count', '$i');
        frame.setHead('total', '$j');
        frame.setHead('localFile', task.localFile);
        frame.setHead('remoteUrl', task.url);
        frame.setHead('status', status);
        frame.setHead('message', message);
        args.messagePort.send(frame.toMap());
      },
      queryParameters: task.parameters,
      data: task.data,
      deleteOnError: true,
      lengthHeader: task.lengthHeader,
    );
  } catch (e) {
    status = '500';
    message = '$e';
    var frame = Frame('download ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('localFile', task.localFile);
    frame.setHead('remoteUrl', task.url);
    frame.setHead('status', status);
    frame.setHead('message', message);
    args.messagePort.send(frame.toMap());
    return;
  }
  if (response.statusCode > 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
    var frame = Frame('download ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('localFile', task.localFile);
    frame.setHead('remoteUrl', task.url);
    frame.setHead('status', status);
    frame.setHead('message', message);
    args.messagePort.send(frame.toMap());
    return;
  }
  frame = Frame('download ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'done');
  frame.setHead('localFile', task.localFile);
  frame.setHead('remoteUrl', task.url);
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());
}

void _addPortPOSTTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  var status = '200';
  var message = 'ok';
  if (task.headers == null) {
    task.headers = <String, dynamic>{};
  }
  if (task.parameters == null) {
    task.parameters = <String, dynamic>{};
  }
  task.headers[task.tokenName] = task.accessToken;
  task.headers['Rest-Command'] = task.restCommand;

  var frame = Frame('portPost ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'begin');
  frame.setHead('restCommand', task.restCommand);
  frame.setHead('origin', task.url);
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());

  var response;
  try {
    response = await dio.post(
      task.url,
      options: Options(
        headers: task.headers,
      ),
      queryParameters: task.parameters,
      onReceiveProgress: (i, j) {
        var frame = Frame('portPost ${task.callbackUrl} port/1.0');
        frame.setHead('sub-command', 'receiveProgress');
        frame.setHead('count', '$i');
        frame.setHead('total', '$j');
        frame.setHead('restCommand', task.restCommand);
        frame.setHead('origin', task.url);
        frame.setHead('status', status);
        frame.setHead('message', message);
        args.messagePort.send(frame.toMap());
      },
      onSendProgress: (i, j) {
        var frame = Frame('portPost ${task.callbackUrl} port/1.0');
        frame.setHead('sub-command', 'sendProgress');
        frame.setHead('count', '$i');
        frame.setHead('total', '$j');
        frame.setHead('restCommand', task.restCommand);
        frame.setHead('origin', task.url);
        frame.setHead('status', status);
        frame.setHead('message', message);
        args.messagePort.send(frame.toMap());
      },
      data: task.data,
    );
  } catch (e) {
    status = '500';
    message = '$e';
    var frame = Frame('portPost ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('restCommand', task.restCommand);
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('origin', task.url);
    args.messagePort.send(frame.toMap());
    return;
  }
  if (response.statusCode >= 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
    var frame = Frame('portPost ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('restCommand', task.restCommand);
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('origin', task.url);
    args.messagePort.send(frame.toMap());
    return;
  }
  var _data = response.data;
  var content = jsonDecode(_data);
  if (content['status'] >= 400) {
    status = '${content['status']}';
    message = '${content['message']}';
    var frame = Frame('portPost ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('restCommand', task.restCommand);
    frame.setHead('origin', task.url);
    args.messagePort.send(frame.toMap());
    return;
  }
  var dataText = content['dataText'];
  if (StringUtil.isEmpty(dataText)) {
    status = '${content['status']}';
    message = '${content['message']}';
    var frame = Frame('portPost ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'done');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('restCommand', task.restCommand);
    frame.setHead('origin', task.url);
    args.messagePort.send(frame.toMap());
    return null;
  }
  frame = Frame('portPost ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'done');
  frame.setHead('restCommand', task.restCommand);
  frame.setHead('origin', task.url);
  frame.addContent(dataText);
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());
}

void _addPortGETTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  var status = '200';
  var message = 'ok';
  if (task.headers == null) {
    task.headers = <String, dynamic>{};
  }
  if (task.parameters == null) {
    task.parameters = <String, dynamic>{};
  }
  task.headers[task.tokenName] = task.accessToken;
  task.headers['Rest-Command'] = task.restCommand;
  var frame = Frame('portGet ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'begin');
  frame.setHead('status', status);
  frame.setHead('message', message);
  frame.setHead('origin', task.url);
  frame.setHead('restCommand', task.restCommand);
  args.messagePort.send(frame.toMap());
  var response;
  try {
    response = await dio.get(
      task.url,
      options: Options(
        headers: task.headers,
      ),
      queryParameters: task.parameters,
      onReceiveProgress: (i, j) {
        var frame = Frame('portGet ${task.callbackUrl} port/1.0');
        frame.setHead('sub-command', 'receiveProgress');
        frame.setHead('count', '$i');
        frame.setHead('total', '$j');
        frame.setHead('restCommand', task.restCommand);
        frame.setHead('origin', task.url);
        frame.setHead('status', status);
        frame.setHead('message', message);
        args.messagePort.send(frame.toMap());
      },
    );
  } catch (e) {
    status = '500';
    message = '$e';
    var frame = Frame('portGet ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('origin', task.url);
    frame.setHead('restCommand', task.restCommand);
    args.messagePort.send(frame.toMap());
    return;
  }
  if (response.statusCode >= 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
    var frame = Frame('portGet ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('origin', task.url);
    frame.setHead('restCommand', task.restCommand);
    args.messagePort.send(frame.toMap());
    return;
  }
  var _data = response.data;
  var content = jsonDecode(_data);
  if (content['status'] >= 400) {
    status = '${content['status']}';
    message = '${content['message']}';
    var frame = Frame('portGet ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'error');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('origin', task.url);
    frame.setHead('restCommand', task.restCommand);
    args.messagePort.send(frame.toMap());
    return;
  }
  var dataText = content['dataText'];
  if (StringUtil.isEmpty(dataText)) {
    var frame = Frame('portGet ${task.callbackUrl} port/1.0');
    frame.setHead('sub-command', 'done');
    frame.setHead('status', status);
    frame.setHead('message', message);
    frame.setHead('origin', task.url);
    frame.setHead('restCommand', task.restCommand);
    args.messagePort.send(frame.toMap());
    return null;
  }
  frame = Frame('portGet ${task.callbackUrl} port/1.0');
  frame.setHead('sub-command', 'done');
  frame.setHead('status', status);
  frame.setHead('message', message);
  frame.setHead('origin', task.url);
  frame.setHead('restCommand', task.restCommand);
  frame.addContent(dataText);
  args.messagePort.send(frame.toMap());
}
