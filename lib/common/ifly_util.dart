import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:framework/core_lib/_utimate.dart';

final _appId = '5ffda5e0';
final _apiKey = '97a99830db0c5e25d2bc674a8e2191e5';

String _ws_url() {
  var ts = '${(DateTime.now().millisecondsSinceEpoch) ~/ 1000}';
  var sign = '$_appId$ts';
  // sign = md5.convert(utf8.encode(sign)).toString();
  sign=MD5Util.MD5(sign);
  var key = utf8.encode(_apiKey);
  var mac = Hmac(sha1, key);
  var data = utf8.encode(sign);
  var signaDig = mac.convert(data);
  var signa = base64Encode(signaDig.bytes);
  return 'ws://rtasr.xfyun.cn/v1/ws?appid=$_appId&ts=$ts&signa=$signa';
}
class Ifly {
  static Future<WebSocket> _open(void Function(TranslateResult result) callback) async {
    var url = _ws_url();
    callback(TranslateResult(cmd: 'open',term: '开始联系第三方服务...'));
    var _ws = await WebSocket.connect(
      url,
    );
    if (_ws.readyState != WebSocket.open) {
      print('----连接出错');
      callback(TranslateResult(cmd: 'connError',term: '联系统第三方服务失败,稍后可重试。'));
      return null;
    }
    _ws.listen((event) {
      if (callback == null || event == null) {
        return;
      }
      var result = jsonDecode(event);
      var action=result['action'];
      switch(action){
        case 'started':
          print('即时译握手成功:${result['sid']}');
          callback(TranslateResult(cmd: 'started',term: '成功连接到第三方服务，准备翻译...'));
          break;
        case 'result':
          var data = result['data'];
          var obj = jsonDecode(data);
          var text = _getContent(obj);
          callback(TranslateResult(cmd: 'result',term:text));
          break;
        case 'error':
          print('-----即时译出错:$result');
          callback(TranslateResult(cmd: 'transError',term:'翻译失败，请稍后重试。'));
          break;
      }
    });
    return _ws;
  }

  static Future<void> sendFile(String path,
      {void Function(TranslateResult result) callback}) async {
    var _ws = await _open(callback);
    if (_ws == null) {
      return;
    }
    var file = File(path);
    int readPos = 0;
    int limitLen = 1280;
    int fileLen = file.lengthSync();
    var stream = Stream.periodic(Duration(milliseconds: 50), (count) async {
      if (readPos < fileLen) {
        int end = readPos + limitLen;
        var stream = file.openRead(readPos, end);
        List<int> dataList = <int>[];
        await for (var data in stream) {
          dataList.addAll(data);
          readPos += data.length;
        }
        return dataList;
      }
      return null;
    });
    await for (var data in stream) {
      var arr = await data;
      if (arr == null) {
        break;
      }
      _ws.add(arr);
    }
    var end = jsonEncode({"end": true});
    var arr = utf8.encode(end);
    _ws?.add(arr);
    _ws.close();
    callback(TranslateResult(cmd: 'stoped',term:'翻译完毕。'));
  }

  static String _getContent(Map messageObj) {
    var text = '';
    try {
      var cn = messageObj["cn"];
      var st = cn["st"];
      var rtArr = st["rt"];
      for (int i = 0; i < rtArr.length; i++) {
        var rtArrObj = rtArr[i];
        var wsArr = rtArrObj["ws"];
        for (int j = 0; j < wsArr.length; j++) {
          var wsArrObj = wsArr[j];
          var cwArr = wsArrObj["cw"];
          for (int k = 0; k < cwArr.length; k++) {
            var cwArrObj = cwArr[k];
            String wStr = cwArrObj["w"];
            text += wStr;
          }
        }
      }
    } catch (e) {
      return '$e';
    }
    return text;
  }
}
class TranslateResult{
  String cmd;
  String term;

  TranslateResult({this.cmd, this.term});
}