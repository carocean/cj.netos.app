import 'dart:async';

import 'package:flutter/services.dart';

class AcceptShare {
  static const MethodChannel _channel = const MethodChannel('accept_share');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void setCallback(Future<dynamic> Function(MethodCall call) cb) {
    _channel.setMethodCallHandler(cb);
  }
}
