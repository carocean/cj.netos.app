import 'dart:io';
import 'dart:ui';

import 'package:city_pickers/meta/_province.dart';
import 'package:city_pickers/meta/province.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

//屏自适应
class Adapt {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static double _width = mediaQuery.size.width;
  static double _height = mediaQuery.size.height;
  static double _topbarH = mediaQuery.padding.top;
  static double _botbarH = mediaQuery.padding.bottom;
  static double _pixelRatio = mediaQuery.devicePixelRatio;
  static var _ratio;

  static init(int number) {
    int uiwidth = number is int ? number : 750;
    _ratio = _width / uiwidth;
  }

  static px(number) {
    if (!(_ratio is double || _ratio is int)) {
      Adapt.init(750);
    }
    return number * _ratio;
  }

  static onepx() {
    return 1 / _pixelRatio;
  }

  static screenW() {
    return _width;
  }

  static screenH() {
    return _height;
  }

  static padTopH() {
    return _topbarH;
  }

  static padBotH() {
    return _botbarH;
  }
}

String formatNum(num, {point: 2}) {
  if (num != null) {
    String str = double.parse(num.toString()).toString();
    // 分开截取
    List<String> sub = str.split('.');
    // 处理值
    List val = List.from(sub[0].split(''));
    // 处理点
    List<String> points = List.from(sub[1].split(''));
    //处理分割符
    for (int index = 0, i = val.length - 1; i >= 0; index++, i--) {
      // 除以三没有余数、不等于零并且不等于1 就加个逗号
      if (index % 3 == 0 && index != 0 && i != 1) val[i] = val[i] + ',';
    }
    // 处理小数点
    for (int i = 0; i <= point - points.length; i++) {
      points.add('0');
    }
    //如果大于长度就截取
    if (points.length > point) {
      // 截取数组
      points = points.sublist(0, point);
    }
    // 判断是否有长度
    if (points.length > 0) {
      return '${val.join('')}.${points.join('')}';
    } else {
      return val.join('');
    }
  } else {
    return "0.0";
  }
}

Future<String> downloadPersonAvatar({Dio dio, String avatarUrl}) async {
  var home = await getApplicationDocumentsDirectory();
  var dir = Directory('${home.path}/pictures/share/persons');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  var avatarPath = '${dir.path}/${MD5Util.MD5(avatarUrl)}';
  var ext = fileExt(avatarUrl);
  if (!StringUtil.isEmpty(ext)) {
    avatarPath = '$avatarPath.$ext';
  }
  await dio.download(avatarUrl, avatarPath);
  return avatarPath;
}

Future<String> downloadChannelAvatar({Dio dio, String avatarUrl}) async {
  var home = await getApplicationDocumentsDirectory();
  var dir = Directory('${home.path}/pictures/share/channels');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  var avatarPath = '${dir.path}/${Uuid().v1()}';
  var ext = fileExt(avatarUrl);
  if (!StringUtil.isEmpty(ext)) {
    avatarPath = '$avatarPath.$ext';
  }
  await dio.download(avatarUrl, avatarPath);
  return avatarPath;
}

Future<Map<String, String>> uploadFile(String fsReaderUrl, String fsWriterUrl,
    String remoteDir, List<String> localFiles,
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
    var ext = fileExt(f);
    String fn = "${Uuid().v1()}";
    if (!StringUtil.isEmpty(ext)) {
      fn = '$fn.$ext';
    }
    remoteFiles[f] = '$fsReaderUrl$remoteDir/$fn';
    files.add(await MultipartFile.fromFile(
      f,
      filename: fn,
    ));
  }
  FormData data = FormData.fromMap({
    'files': files,
  });
  BaseOptions options = BaseOptions(headers: {
    'Content-Type': "text/html; charset=utf-8",
  });
  var _dio = Dio(options); //使用base配置可以通
  var response = await _dio.post(
    fsWriterUrl,
    data: data,
    options: Options(
      //上传的accessToken在header中，为了兼容在参数里也放
      headers: {
        "Cookie": 'accessToken=$accessToken',
      },
    ),
    queryParameters: {
      'accessToken': accessToken,
      'dir': remoteDir,
    },
    onReceiveProgress: onReceiveProgress,
    onSendProgress: onSendProgress,
  );
  if (response.statusCode > 400) {
    _dio.close();
    throw FlutterError('上传失败：${response.statusCode} ${response.statusMessage}');
  }
  _dio.close();
  return remoteFiles;
}

///年、月、日、时、分、秒、毫秒，共17位
DateTime parseStrTime(String strTime, {int len = 17}) {
  int year = int.parse(strTime.substring(0, 4));
  int month = int.parse(strTime.substring(4, 6));
  int day = int.parse(strTime.substring(6, 8));
  int hour = int.parse(strTime.substring(8, 10));
  int minut = int.parse(strTime.substring(10, 12));
  int sec = int.parse(strTime.substring(12, 14));
  if (len < 17) {
    return DateTime(
      year, //year
      month, //month
      day, //day
      hour, //hour
      minut, //minits
      sec, //sec
    );
  }

  int microsec = int.parse(strTime.substring(14, 17));

  return DateTime(
    year,
    //year
    month,
    //month
    day,
    //day
    hour,
    //hour
    minut,
    //minits
    sec,
    //sec
    microsec, //mic
  );
}

///转换数字为友好表示，如大于999表示为k,大于999k表示为m，大于999m表示为g
String parseInt(int count, int fractionDigits) {
  if (fractionDigits == null) {
    fractionDigits = 2;
  }
  if (count <= 999) {
    return '$count';
  }
  if (count <= 999 * 1024) {
    return '${(count / 1024.00).toStringAsFixed(fractionDigits)}k';
  }
  if (count <= 999 * 1024 * 1024) {
    return '${(count / 1024.00 / 1024.00).toStringAsFixed(fractionDigits)}m';
  }
  return '${(count / 1024.00 / 1024.00 / 1024.00).toStringAsFixed(fractionDigits)}g';
}

Map<String, String> parseUrlParams(String paramStr) {
  Map<String, String> map = {};
  List<String> list = paramStr.split('&');
  for (var pv in list) {
    if (StringUtil.isEmpty(pv)) {
      continue;
    }
    List<String> keyPair = pv.split('=');
    String k = keyPair[0];
    String v = '';
    if (keyPair.length > 1) {
      v = keyPair[1];
    }
    map[k] = v;
  }
  return map;
}

Widget getAvatarWidget(String avatar, PageContext context,[defaultAssetAvatar='lib/portals/gbera/images/default_avatar.png',Color color]) {
  if (StringUtil.isEmpty(avatar)) {
    return Image.asset(defaultAssetAvatar??'lib/portals/gbera/images/default_avatar.png',color: color,);
  }
  if (avatar.startsWith('/')) {
    return Image.file(File(avatar),color: color,);
  }
  return FadeInImage.assetNetwork(
      placeholder: 'lib/portals/gbera/images/default_watting.gif',
      image: '$avatar?accessToken=${context.principal.accessToken}',);
}

Future<String> checkUrlAndDownload(PageContext pageContext, String src) async {
  var home = await getApplicationDocumentsDirectory();
  var dir = '${home.path}/videos';
  var dirFile = Directory(dir);
  if (!dirFile.existsSync()) {
    dirFile.createSync();
  }
  var localFile = '$dir/${MD5Util.MD5(src)}.${fileExt(src)}';
  var file = File(localFile);
  if (file.existsSync()) {
    return file.path;
  }
  await pageContext.ports.download('${src}?accessToken=${pageContext.principal.accessToken}', localFile, onReceiveProgress: (i, j) {
    print('---downloadVideo--$i  $j');
  });
  return localFile;
}
///VideoCompress文件名含有空格，导致frame在解析地址时截断，从而使对方收到的文件名是空
Future<String> copyVideoCompressFile(File srcFile)async{
  var src=srcFile.path;
  if(src.indexOf(' ')<0){
    return src;
  }
  var home = await getApplicationDocumentsDirectory();
  var dir = '${home.path}/videos';
  var dirFile = Directory(dir);
  if (!dirFile.existsSync()) {
    dirFile.createSync();
  }
  var localFile = '$dir/${MD5Util.MD5(src)}.${fileExt(src)}';
  srcFile.copySync(localFile);
  return localFile;
}

String getUrlWithAccessToken(String url,String accessToken){
  int pos=url.indexOf('?');
  if(pos>-1) {
    return '$url&accessToken=$accessToken';
  }
  return '$url?accessToken=$accessToken';
}


String findProvinceCode(String provinceName) {
  var provinces = provincesData;
  for (var code in provinces.keys) {
    var name = provinces[code];
    if (name == provinceName) {
      return code;
    }
  }
  return null;
}

String findCityCode(String provinceCode,String cityName) {
  var cities = citysData[provinceCode];
  for (var code in cities.keys) {
    var name = cities[code];
    if (name == cityName) {
      return code;
    }
  }
  return null;
}

///取小数点后几位
///num 数据
///location 几位
String formatNum2(double num) {
 var text=num.toStringAsFixed(2);
 int pos=text.indexOf('.');
 if(pos>-1) {
   return text.substring(pos+1);
 }
 return '00';
}