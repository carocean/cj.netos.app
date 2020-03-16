import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

mixin StringUtil {
  static bool isEmpty(String qs) {
    return qs == null || '' == qs;
  }
}
mixin MD5Util {
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }
}
mixin Sha1Util {
  static String generateSha1(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = sha1.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }
}
mixin PersonUtil {
  static String official(accountName, appid, tenantid) {
    return '$accountName@$appid.$tenantid';
  }

  static String officialBy(var person) {
    if (!StringUtil.isEmpty(person.official)) {
      return person.official;
    }
    return '${person.accountCode}@${person.appid}.${person.tenantid}';
  }
}

typedef BuildServices = Future<Map<String, dynamic>> Function(
    IServiceProvider site);

mixin IServiceProvider {
  getService(String name);
}
mixin IDisposable {
  void dispose();
}


mixin IServiceBuilder {
  Future<void> builder(IServiceProvider site);
}
String getPath(String url) {
  var path = '';
  int pos = url.indexOf("?");
  if (pos < 0) {
    path = url;
  } else {
    path = url.substring(0, pos);
  }
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path;
}

String fileExt(String path) {
  String remain = path;
  int pos = remain.indexOf("?");
  if (pos > -1) {
    remain = remain.substring(0, pos);
  }
  pos = remain.lastIndexOf('/');
  if (pos > -1) {
    remain = remain.substring(pos + 1);
  }
  pos = remain.lastIndexOf('.');
  if (pos < 0) {
    return '';
  }
  return remain.substring(pos + 1);
}