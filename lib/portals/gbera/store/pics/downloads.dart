import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Downloads {
  static Future<String> downloadPersonAvatar(
      {Dio dio, String avatarUrl}) async {
    var home = await getApplicationDocumentsDirectory();
    var dir = Directory('${home.path}/pictures/share/persons');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    var avatarPath = '${dir.path}/${Uuid().v1()}';
    await dio.download(avatarUrl, avatarPath);
    return avatarPath;
  }
  static Future<String> downloadChannelAvatar(
      {Dio dio, String avatarUrl}) async {
    var home = await getApplicationDocumentsDirectory();
    var dir = Directory('${home.path}/pictures/share/channels');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    var avatarPath = '${dir.path}/${Uuid().v1()}';
    await dio.download(avatarUrl, avatarPath);
    return avatarPath;
  }
}
