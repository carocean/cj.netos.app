import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_port_tasks.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:uuid/uuid.dart';

import '_exceptions.dart';

typedef OnReceiveProgress = void Function(int, int);
typedef OnSendProgress = void Function(int, int);
mixin IRemotePorts {
  UserPrincipal get principal;

  IPortTaskManager get portTask;

  Future<dynamic> portGET(
    portsUrl,
    String restCommand, {
    String tokenName = 'cjtoken',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
    OnReceiveProgress onReceiveProgress,
  }) {}

  Future<dynamic> portPOST(
    portsUrl,
    String restCommand, {
    String tokenName = 'cjtoken',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
    OnReceiveProgress onReceiveProgress,
    OnSendProgress onSendProgress,
    data,
  }) {}

  Future<void> callback(
    ///请求头，格式，如：get http://localhost:8080/uc/p1.service?name=cj&age=33 http/1.1
    String headline, {

    ///远程服务的方法名
    String restCommand,
    Map<String, String> headers,
    Map<String, String> parameters,
    Map<String, Object> content,
    void Function({dynamic rc, Response response}) onsucceed,
    void Function({dynamic e, dynamic stack}) onerror,
    void Function(int, int) onReceiveProgress,
    void Function(int, int) onSendProgress,
  });

  Future<Map<String, String>> upload(String remoteDir, List<String> localFiles,
      {String accessToken,
      void Function(int, int) onReceiveProgress,
      void Function(int, int) onSendProgress});

  Future<void> download(
    String url,
    String localFile, {
    void Function(int, int) onReceiveProgress,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options options,
  });

  Future<void> deleteFile(
    String file,
  );
}

class DefaultRemotePorts implements IRemotePorts {
  Dio _dio;
  IServiceProvider _site;
  IPortTaskManager _portTaskManager;

  @override
  UserPrincipal get principal => _site.getService('@.principal');

  @override
  IPortTaskManager get portTask => _portTaskManager;

  DefaultRemotePorts(IServiceProvider site, Dio dio) {
    _dio = dio;
    _site = site;
    _portTaskManager = DefaultPortTaskManager();
    _portTaskManager.start(site);
  }

  @override
  Future<dynamic> portGET(
    portsUrl,
    String restCommand, {
    String tokenName = 'cjtoken',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
    OnReceiveProgress onReceiveProgress,
  }) async {
    if (headers == null) {
      headers = <String, dynamic>{};
    }
    if (parameters == null) {
      parameters = <String, dynamic>{};
    }
    headers[tokenName] = principal.accessToken;
    headers['Rest-Command'] = restCommand;
    var response = await _dio.get(
      portsUrl,
      options: Options(
        headers: headers,
      ),
      queryParameters: parameters,
      onReceiveProgress: onReceiveProgress,
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
    return obj;
  }

  @override
  Future<dynamic> portPOST(
    portsUrl,
    String restCommand, {
    String tokenName = 'cjtoken',
    Map<String, dynamic> headers,
    Map<String, dynamic> parameters,
    OnReceiveProgress onReceiveProgress,
    OnSendProgress onSendProgress,
    data,
  }) async {
    if (headers == null) {
      headers = <String, dynamic>{};
    }
    if (parameters == null) {
      parameters = <String, dynamic>{};
    }
    headers[tokenName] = principal.accessToken;
    headers['Rest-Command'] = restCommand;
    var response = await _dio.post(
      portsUrl,
      options: Options(
        headers: headers,
      ),
      queryParameters: parameters,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      data: data,
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
    return obj;
  }

  Future<Map<String, String>> upload(String remoteDir, List<String> localFiles,
      {String accessToken,
      void Function(int, int) onReceiveProgress,
      void Function(int, int) onSendProgress}) async {
    if (localFiles == null || localFiles.isEmpty) {
      return null;
    }

    var files = <MultipartFile>[];
    var remoteFiles = <String, String>{};
    for (var i = 0; i < localFiles.length; i++) {
      var f = localFiles[i];
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
      remoteFiles[f] = '${_site.getService('@.prop.fs.reader')}$remoteDir/$fn';
      print(remoteFiles[f]);
      files.add(await MultipartFile.fromFile(
        f,
        filename: fn,
      ));
    }
    FormData data = FormData.fromMap({
      'files': files,
    });
    var token =
        StringUtil.isEmpty(accessToken) ? principal.accessToken : accessToken;
    var response = await _dio.post(
      _site.getService('@.prop.fs.uploader'),
      data: data,
      options: Options(
        //上传的accessToken在header中，为了兼容在参数里也放
        headers: {
          "Cookie": 'accessToken=$token',
        },
      ),
      queryParameters: {
        'accessToken': token,
        'dir': remoteDir,
      },
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
    if (response.statusCode > 400) {
      throw FlutterError(
          '上传失败：${response.statusCode} ${response.statusMessage}');
    }
    return remoteFiles;
  }

  ///下载文件
  Future<void> download(
    String url,
    String localFile, {
    void Function(int, int) onReceiveProgress,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options options,
  }) async {
    return await _dio.download(
      url,
      localFile,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      data: data,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  Future<void> deleteFile(
    String file,
  ) async {
    var response = await _dio.get(
      _site.getService('@.prop.fs.delfile'),
      options: Options(
          //上传的accessToken在header中，为了兼容在参数里也放
//        headers: {
//          "Cookie": 'accessToken=$accessToken',
//        },
          ),
      queryParameters: {'path': file, 'type': 'f'},
    );
    if (response.statusCode > 400) {
      throw FlutterError(
          '删除失败：${response.statusCode} ${response.statusMessage}');
    }
  }

  Future<void> callback(
    ///请求头，格式，如：get http://localhost:8080/uc/p1.service?name=cj&age=33 http/1.1
    String headline, {

    ///远程服务的方法名
    String restCommand,
    Map<String, String> headers,
    Map<String, String> parameters,
    Map<String, Object> content,
    void Function({dynamic rc, Response response}) onsucceed,
    void Function({dynamic e, dynamic stack}) onerror,
    void Function(int, int) onReceiveProgress,
    void Function(int, int) onSendProgress,
  }) async {
    String cmd = '';
    String uri = '';
    String protocol = '';
    String hl = headline;
    while (hl.startsWith(" ")) {
      hl = hl.substring(1, hl.length);
    }
    int pos = hl.indexOf(" ");
    if (pos < 0) {
      throw FlutterError(
          '请求行格式错误，缺少uri和protocol，错误请求行为：$hl,合法格式应为：get|post uri http/1.1');
    }
    cmd = hl.substring(0, pos);
    hl = hl.substring(pos + 1, hl.length);
    while (hl.startsWith(" ")) {
      hl = hl.substring(1, hl.length);
    }
    pos = hl.indexOf(" ");
    if (pos < 0) {
      throw FlutterError(
          '请求行格式错误，缺少protocol，错误请求行为：$hl,合法格式应为：get|post uri http/1.1');
    }
    uri = hl.substring(0, pos);
    if (uri.indexOf("://") < 0) {
      throw FlutterError('不是正确的请求地址：${hl},合法格式应为：https://sss/ss/ss?ss=ss');
    }
    hl = hl.substring(pos + 1, hl.length);
    while (hl.startsWith(" ")) {
      hl = hl.substring(1, hl.length);
    }
    while (hl.endsWith(" ")) {
      hl = hl.substring(0, hl.length - 1);
    }
    if (StringUtil.isEmpty(hl)) {
      throw FlutterError('请求行缺少协议:$hl');
    }
    protocol = hl;

    Dio _dio = _site.getService("@.http");
    //dio会自动将头转换为小写
    Options options = Options(
      headers: headers,
    );
    options.headers['Rest-Command'] = restCommand;
    cmd = cmd.toUpperCase();
    switch (cmd) {
      case 'GET':
        try {
          var response = await _dio.get(
            uri,
            queryParameters: parameters,
            onReceiveProgress: onReceiveProgress,
            options: options,
          );
          var data = response.data;
          Map<String, Object> rc = jsonDecode(data);
          int status = rc['status'];
          if ((status >= 200 && status < 300) || status == 304) {
            if (onsucceed != null) {
              onsucceed(rc: rc, response: response);
            }
          } else {
            if (onerror != null) {
              onerror(
                  e: OpenportsException(
                    state: status,
                    message: rc['message'],
                    cause: rc['dataText'],
                  ),
                  stack: null);
            }
          }
        } on DioError catch (e, stack) {
          if (e.response != null) {
            // Something happened in setting up or sending the request that triggered an Error
            if (onerror != null) {
              onerror(e: e, stack: stack);
              return;
            }
            FlutterErrorDetails details =
                FlutterErrorDetails(exception: e, stack: stack);
            FlutterError.reportError(details);
            return;
          }
          throw FlutterError(e.error);
        }
        break;
      case 'POST':
        options.headers['Content-Type'] =
            'application/x-www-form-urlencoded; charset=UTF-8';
        try {
          var response = await _dio.post(
            uri,
            data: content ?? json.encode(content),
            queryParameters: parameters,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            options: options,
          );
          var data = response.data;
          Map<String, Object> rc = jsonDecode(data);
          int status = rc['status'];
          if ((status >= 200 && status < 300) || status == 304) {
            if (onsucceed != null) {
              var dataText = jsonDecode(rc['dataText']);
              onsucceed(rc: rc, response: response);
            }
          } else {
            if (onerror != null) {
              onerror(
                  e: OpenportsException(
                    state: status,
                    message: rc['message'],
                    cause: rc['dataText'],
                  ),
                  stack: null);
            }
          }
        } on DioError catch (e, stack) {
          if (e.response != null) {
            // Something happened in setting up or sending the request that triggered an Error
            if (onerror != null) {
              onerror(e: e, stack: stack);
              return;
            }
            FlutterErrorDetails details =
                FlutterErrorDetails(exception: e, stack: stack);
            FlutterError.reportError(details);
            return;
          }
          throw FlutterError(e.error);
        }
        break;
      default:
        throw FlutterErrorDetails(exception: Exception('不支持的命令:$cmd'));
    }
  }
}
