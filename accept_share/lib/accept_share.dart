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

  static Future<void> forwardEasyTalk({Map<String, String> arguments}) async{
    await _channel.invokeMethod('forwardEasyTalk',arguments);
  }

  static Future<void> forwardNetflow({Map<String, String> arguments}) async{
    await _channel.invokeMethod('forwardNetflow',arguments);
  }

  static Future<void> forwardGeosphere({Map<String, String> arguments}) async{
    await _channel.invokeMethod('forwardGeosphere',arguments);
  }

  static void forwardTiptool({Map<String, String> arguments}) async{
    await _channel.invokeMethod('forwardTiptool',arguments);
  }

}
