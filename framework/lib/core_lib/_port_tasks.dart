import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:uuid/uuid.dart';

import '_principal.dart';
import '_remote_ports.dart';

mixin IPortTaskManager {
  Future<void> start(IServiceProvider site);

  void close();

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
}

class _EntrypointArgument {
  SendPort bindPort;
  SendPort messagePort;
  String delFilePortsUrl;
  String readFilePortsUrl;
  String uploaderFilePortsUrl;

  _EntrypointArgument(
      {this.bindPort,
      this.messagePort,
      this.delFilePortsUrl,
      this.readFilePortsUrl,
      this.uploaderFilePortsUrl});
}

class DefaultPortTaskManager implements IPortTaskManager {
  SendPort _output;
  IServiceProvider _site;

  @override
  UserPrincipal get principal => _site.getService('@.principal');

  @override
  Future<void> start(IServiceProvider site) async {
    _site = site;
    ReceivePort bindPort = ReceivePort();
    ReceivePort messagePort = ReceivePort();
    var isolate = await Isolate.spawn(
      entrypoint,
      _EntrypointArgument(
        delFilePortsUrl: _site.getService('@.prop.fs.delfile'),
        readFilePortsUrl: _site.getService('@.prop.fs.reader'),
        uploaderFilePortsUrl: _site.getService('@.prop.fs.uploader'),
        bindPort: bindPort.sendPort,
        messagePort: messagePort.sendPort,
      ),
    );
    _output = await bindPort.first;
  }

  @override
  void close() {
    // TODO: implement close
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

void entrypoint(message) {
  var args = message as _EntrypointArgument;
  var bindPort = args.bindPort;
  ReceivePort receivePort = ReceivePort();
  bindPort.send(receivePort.sendPort);

  BaseOptions options = BaseOptions(headers: {
    'Content-Type': "text/html; charset=utf-8",
  });
  var _dio = Dio(options); //

  receivePort.listen((data) {
    var task = data as _PortTask;
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
  });
}

void _addDeleteFileTask(
    _EntrypointArgument args, Dio dio, _PortTask task) async {
  var response = await dio.get(
    args.delFilePortsUrl,
    options: Options(
        //上传的accessToken在header中，为了兼容在参数里也放
//        headers: {
//          "Cookie": 'accessToken=$accessToken',
//        },
        ),
    queryParameters: {'path': task.url, 'type': 'f'},
  );
  var status = '200';
  var message = 'ok';
  if (response.statusCode > 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
  }
  Frame frame = Frame('deleteFile ${task.callbackUrl ?? '/'} flutter/1.0');
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());
}

void _addUploadTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  if (task.localFiles == null || task.localFiles.isEmpty) {
    return null;
  }

  var files = <MultipartFile>[];
  var remoteFiles = <String, String>{};
  for (var i = 0; i < task.localFiles.length; i++) {
    var f = task.localFiles[i];
    int pos = f.lastIndexOf('.');
    var ext = '';
    var prev = '';
    if (pos > -1) {
      ext = f.substring(pos + 1, f.length);
      prev = f.substring(0, pos);
    } else {
      prev = f;
    }
    prev = prev.substring(prev.lastIndexOf('/') + 1, prev.length);
    String fn = "${Uuid().v1()}_$prev.$ext";
    remoteFiles[f] = '${args.readFilePortsUrl}${task.remoteDir}/$fn';
    print(remoteFiles[f]);
    files.add(await MultipartFile.fromFile(
      f,
      filename: fn,
    ));
  }
  FormData data = FormData.fromMap({
    'files': files,
  });
  var token = StringUtil.isEmpty(task.accessToken);
  var response = await dio.post(
    args.uploaderFilePortsUrl,
    data: data,
    options: Options(
      //上传的accessToken在header中，为了兼容在参数里也放
      headers: {
        "Cookie": 'accessToken=$token',
      },
    ),
    queryParameters: {
      'accessToken': token,
      'dir': task.remoteDir,
    },
    onReceiveProgress: (i, j) {},
    onSendProgress: (i, j) {},
  );
  if (response.statusCode > 400) {
    throw FlutterError('上传失败：${response.statusCode} ${response.statusMessage}');
  }
  //返回： remoteFiles;
  var status = '200';
  var message = 'ok';
  if (response.statusCode > 400) {
    status = '${response.statusCode}';
    message = '${response.statusMessage}';
  }
  Frame frame = Frame('uploadFiles ${task.callbackUrl ?? '/'} flutter/1.0');
  frame.setHead('status', status);
  frame.setHead('message', message);
  args.messagePort.send(frame.toMap());
}

void _addDownloadTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  await dio.download(
    task.url,
    task.localFile,
    onReceiveProgress: (i, j) {},
    queryParameters: task.parameters,
    data: task.data,
    deleteOnError: true,
    lengthHeader: task.lengthHeader,
  );
}

void _addPortPOSTTask(_EntrypointArgument args, Dio dio, _PortTask task) async {
  if (task.headers == null) {
    task.headers = <String, dynamic>{};
  }
  if (task.parameters == null) {
    task.parameters = <String, dynamic>{};
  }
  task.headers[task.tokenName] = task.accessToken;
  task.headers['Rest-Command'] = task.restCommand;
  var response = await dio.post(
    task.url,
    options: Options(
      headers: task.headers,
    ),
    queryParameters: task.parameters,
    onReceiveProgress: (i, j) {},
    onSendProgress: (i, j) {},
    data: task.data,
  );
  if (response.statusCode >= 400) {
    throw FlutterError('${response.statusCode} ${response.statusMessage}');
  }
  var _data = response.data;
  var content = jsonDecode(_data);
  if (content['status'] >= 400) {
    throw FlutterError('${content['status']} ${content['message']}');
  }
  var dataText = content['dataText'];
  if (StringUtil.isEmpty(dataText)) {
    return null;
  }
  var obj = jsonDecode(dataText);
}

void _addPortGETTask(_EntrypointArgument args, Dio dio, _PortTask task) async{
  if (task.headers == null) {
    task. headers = <String, dynamic>{};
  }
  if (task.parameters == null) {
    task.parameters = <String, dynamic>{};
  }
  task. headers[task.tokenName] = task.accessToken;
  task.headers['Rest-Command'] = task.restCommand;
  var response = await dio.get(
    task.url,
    options: Options(
      headers: task.headers,
    ),
    queryParameters:task. parameters,
    onReceiveProgress: (i,j){},
  );
  if (response.statusCode >= 400) {
    throw FlutterError('${response.statusCode} ${response.statusMessage}');
  }
  var _data = response.data;
  var content = jsonDecode(_data);
  if (content['status'] >= 400) {
    throw FlutterError('${content['status']} ${content['message']}');
  }
  var dataText = content['dataText'];
  if (StringUtil.isEmpty(dataText)) {
    return null;
  }
  var obj = jsonDecode(dataText);
}
