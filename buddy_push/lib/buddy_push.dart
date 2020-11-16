
import 'dart:async';

import 'package:flutter/services.dart';

class BuddyPush {
  static const MethodChannel _channel =
      const MethodChannel('buddy_push');

  static Future<Map<dynamic,dynamic>> get currentPushDriver async {
    final Map driver = await _channel.invokeMethod('currentPushDriver');
    return driver;
  }
}
