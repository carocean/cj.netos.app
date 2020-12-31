import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class BuddyPush {
  static const MethodChannel _channel = const MethodChannel('buddy_push');

  static Future<Map<dynamic, dynamic>> get currentPushDriver async {
    final Map driver = await _channel.invokeMethod('currentPushDriver');
    return driver;
  }

  static Future<void> supportsDriver(
      Future<void> Function(String driver, bool isSupports) call) async {
    if (call == null) {
      return;
    }
    final Map map = await _channel.invokeMethod('supportsDriver');
    var driver = map['driver'];
    var isSupports = map['isSupports'];
    await call(driver, isSupports);
  }

  static void onEvent({
    Future<dynamic> Function(String driver, String regId) onToken,
    Future<dynamic> Function(String driver, String error) onError,
  }) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onToken':
          if (onToken == null) {
            break;
          }
          var driver = call.arguments['driver'];
          var regId = call.arguments['regId'];
          await onToken(driver, regId);
          break;
        case 'onError':
          if (onError == null) {
            break;
          }
          var driver = call.arguments['driver'];
          var error = call.arguments['error'];
          await onError(driver, error);
          break;
      }
    });
  }
}
