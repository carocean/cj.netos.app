
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '_utimate.dart';


class AppKeyPair {
  String appid;
  String appKey;
  String appSecret;
  String device;

  AppKeyPair({this.appid, this.appKey, this.appSecret, this.device});

  String appSign(String nonce) {
    return MD5Util.MD5('$appKey$nonce$appSecret').toUpperCase();
  }

  ///以当前的key获取指定app的key
  Future<AppKeyPair> getAppKeyPair(String appid, IServiceProvider site) async {
    Dio dio = site.getService('@.http');
    var nonce = MD5Util.MD5(
        '${Uuid().v1()}${DateTime.now().millisecondsSinceEpoch}');
    var url = site.getService('@.prop.ports.uc.platform');
    var response = await dio.get(
      url,
      options: Options(
        headers: {
          'Rest-Command': 'getAppKeyStore',
          'app-id': this.appid,
          'app-key': this.appKey,
          'app-nonce': nonce,
          'app-sign': this.appSign(nonce),
        },
      ),
      queryParameters: {
        'appid': appid,
      },
    );
    if (response.statusCode != 200) {
      throw FlutterError('${response.statusCode} ${response.statusMessage}');
    }
    var data = response.data;
    var map = jsonDecode(data);
    if (map['status'] as int != 200) {
      throw FlutterError('${map['status']} ${map['message']}');
    }
    var json = map['dataText'];
    var obj = jsonDecode(json);
    var kp = AppKeyPair(
        device: this.device,
        appid: obj['appid'],
        appSecret: obj['appSecret'],
        appKey: obj['appKey']);
    return kp;
  }
}
