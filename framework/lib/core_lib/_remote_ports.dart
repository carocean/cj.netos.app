import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';

typedef OnReceiveProgress = void Function(int, int);
typedef OnSendProgress = void Function(int, int);
mixin IRemotePorts {
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
}

class DefaultRemotePorts implements IRemotePorts {
  Dio _dio;
  IServiceProvider _site;

  UserPrincipal get principal => _site.getService('@.principal');

  DefaultRemotePorts(IServiceProvider site, Dio dio) {
    _dio = dio;
    _site = site;
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
}
