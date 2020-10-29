
import 'dart:async';

import 'package:flutter/services.dart';

class OpenFile {
  static const MethodChannel _channel =
      const MethodChannel('open_file');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future<bool>  installApk(String path) async {
    final bool result = await _channel.invokeMethod('installApk',path);
    return result;
  }
}
