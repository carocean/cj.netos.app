import 'dart:convert';
import 'dart:io';

import 'package:sprintf/sprintf.dart';

import '_utimate.dart';

class Frame {
  static final _QUERY_STRING_REG = "(^|\\?|&)\\s*%s\\s*=\\s*([^&]*)(&|\$)";
  Map<String, String> _headers;
  Map<String, String> _parameters;
  BytesBuilder _content;

  Frame(String headline) {
    _headers = <String, String>{};
    _parameters = <String, String>{};
    _content = BytesBuilder();
    _parseHeadline(headline);
  }

  Frame.load(List<int> frameRaw) {
    _headers = <String, String>{};
    _parameters = <String, String>{};
    _content = BytesBuilder();

    int up = 0;
    int down = 0;
    int field = 0; // 0=heads;1=params;2=content
    int frameRawLength = frameRaw.length;
    while (down < frameRawLength) {
      if (field < 2) {
        // 修改了当内容的头几行是连续空行的情况的bug因此使用了field<2
        if (frameRaw[up] == '\r'.codeUnitAt(0) &&
            (up + 1 < frameRawLength &&
                frameRaw[up + 1] == '\n'.codeUnitAt(0))) {
          // 跳域
          field++;
          up += 2;
          down += 2;
          continue;
        }
      } else {
        down = frameRawLength; // 非常变态，bytebuf数组总是在结尾入多一个0，因此其长度总是比写入的长度多1个字节
        List<int> b = List(down - up);
        b.setRange(0, b.length, frameRaw, up);
        _content.add(b);
        break;
      }
      if (frameRaw[down] == '\r'.codeUnitAt(0) &&
          (down + 1 < frameRawLength &&
              frameRaw[down + 1] == '\n'.codeUnitAt(0))) {
        // 跳行
        List<int> b = List(down - up);
        b.setRange(0, b.length, frameRaw, up);
        switch (field) {
          case 0:
            String kv = String.fromCharCodes(b);
            int at = kv.indexOf("=");
            String k = kv.substring(0, at);
            String v = kv.substring(at + 1, kv.length);
            if ("protocol" == k) {
              if (v != null) v = v.toUpperCase();
            }
            _headers[k] = v;
            break;
          case 1:
            String kv = String.fromCharCodes(b);
            int at = kv.indexOf("=");
            String k = kv.substring(0, at);
            String v = kv.substring(at + 1, kv.length);
            _parameters[k] = StringUtil.isEmpty(v) ? '' : v;
            break;
        }
        down += 2;
        up = down;
        continue;
      }
      down++;
    }
  }

  Frame.build(Map obj) {
    _headers = obj['headers'].cast<String,String>();
    if (_headers == null) {
      _headers = <String, String>{};
    }
    _parameters = obj['parameters'].cast<String,String>();
    if (_parameters == null) {
      _parameters = <String, String>{};
    }
    if (_content == null) {
      _content = BytesBuilder();
    }
    var cnt = obj['content'];
    if (cnt != null) {
      _content.add(cnt.cast<int>());
    }
  }

  String head(String name) {
    if (!_headers.containsKey(name)) {
      return null;
    }
    return _headers[name];
  }

  String get contentType {
    return _headers["Content-Type"];
  }

  set contentType(String type) {
    _headers["Content-Type"] = type;
  }

  List<String> enumHeadName() {
    return _headers.keys.toList();
  }

  bool containsHead(String name) {
    return _headers.containsKey(name);
  }

  void setHead(String key, String value) {
    _headers[key] = value;
  }

  void setParameter(String key, String value) {
    _parameters[key] = value;
  }

  String parameter(String name) {
    if (_parameters.containsKey(name)) return _parameters[name];
    var rule = sprintf(_QUERY_STRING_REG, [name]);
    RegExpMatch m = RegExp(rule).firstMatch(url);
    if (m != null) {
      return m.group(2).trim();
    }
    return null;
  }

  void addContent(String content) {
    var list = utf8.encode(content);
    _content.add(list);
  }

  int get contentLength {
    return _content.length;
  }

  String get contentText {
    return utf8.decode(_content.takeBytes());
  }

  List<int> get contentBytes {
    return _content.takeBytes();
  }

  Map<dynamic, dynamic> toMap() {
    Map<dynamic, dynamic> map = {};
    map['headers'] = _headers;
    map['parameters'] = _parameters;
    map['content'] = _content.toBytes();
    var path = this.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    map['path']=path;
    return map;
  }

  List<int> toBytes() {
    var b = BytesBuilder();
    var crcf = "\r\n".codeUnits;
    if (!_headers.containsKey("Content-Length")) {
      var len = _content.length;
      _headers["Content-Length"] = '$len';
    }
    for (var key in _headers.keys) {
      String v = _headers[key];
      if (StringUtil.isEmpty(v)) {
        continue;
      }
      String tow = '$key=${StringUtil.isEmpty(v) ? '' : v}\r\n';
      b.add(tow.codeUnits);
    }
    b.add(crcf);
    for (var key in _parameters.keys) {
      var v = _parameters[key];
      if (/* StringUtil.isEmpty(v) || */ _containedQueryStrParam(key)) {
        continue;
      }
      String tow = '$key=${StringUtil.isEmpty(v) ? '' : v}\r\n';
      b.add(tow.codeUnits);
    }
    b.add(crcf);
    if (this._content.length > 0) {
      var data = _content.toBytes();
      b.add(data);
    }
    return b.toBytes();
  }

  String get url {
    return _headers["url"];
  }

  set url(String url) {
    _headers['url'] = url;
  }

  String get command {
    return _headers['command'];
  }

  set command(String command) {
    _headers['command'] = command.trim();
  }

  bool containsQueryString() {
    return _headers["url"].indexOf("?") >= 0;
  }

  bool containsParameter(String key) {
    if (_parameters.containsKey(key)) return true;
    return _containedQueryStrParam(key);
  }

  String get path {
    String p;
    String _url = url;

    if (_url.contains("?")) {
      p = _url.substring(0, _url.indexOf("?"));
    } else {
      p = _url;
    }
    return p;
  }

  bool get isInvalid {
    return StringUtil.isEmpty(protocol) ||
        StringUtil.isEmpty(command) ||
        StringUtil.isEmpty(url);
  }

  String get rootName {
    String root = rootPath;
    if (root == "/") {
      return "";
    } else {
      return root.substring(1, root.length);
    }
  }

  String get rootPath {
    String _path = path;
    if ("/" == _path) return _path;
    _path = _path.startsWith("/") ? _path : '/$_path';

    int nextSp = _path.indexOf("/", 1);
    if (nextSp < 0) {
      if (_path.indexOf(".") >= 0) {
        return "/";
      } else {
        return _path;
      }
    }
    _path = _path.substring(0, nextSp);
    return _path;
  }

  String get relativePath {
    String _path = path;
    _path = _path.substring(rootPath.length, _path.length);
    if (!_path.startsWith("/")) {
      _path = '/$_path';
    }
    return _path;
  }

  String get relativeUrl {
    String rurl = url;
    rurl = rurl.substring(rootPath.length, rurl.length);
    if (!rurl.startsWith("/")) {
      rurl = '/$rurl';
    }
    return rurl;
  }

  void removeHead(String key) {
    _headers.remove(key);
  }

  List<String> enumParameterName() {
    if (_headers["url"].indexOf("?") < 0) {
      return _parameters.keys.toList();
    }
    List<String> keys = [];
    var arr = queryString.split("&");
    for (String pair in arr) {
      if (StringUtil.isEmpty(pair)) {
        continue;
      }
      var e = pair.split("=");
      keys.add(e[0]);
    }
    for (String key in _parameters.keys) {
      keys.add(key);
    }
    return keys;
  }

  void removeParameter(String key) {
    _parameters.remove(key);
  }

  String get protocol {
    return _headers["protocol"];
  }

  set protocol(String protocol) {
    _headers["protocol"] = protocol.toUpperCase();
  }

  bool _containedQueryStrParam(String key) {
    String q = queryString;
    if (StringUtil.isEmpty(q)) return false;

    if (RegExp(_QUERY_STRING_REG).hasMatch(url)) {
      return true;
    }
    return false;
  }

  String get queryString {
    String q = "";
    String url = this.url;
    if (url.contains("?")) {
      q = url.substring(url.indexOf("?") + 1, url.length);
    }
    return q;
  }

  void _parseHeadline(String headline) {
    var line = headline.trim();
    int pos = line.indexOf(" ");
    var command = line.substring(0, pos);
    var remain = line.substring(pos + 1);
    while (remain.startsWith(' ')) {
      remain = remain.substring(1);
    }
    pos = remain.indexOf(' ');
    var url = remain.substring(0, pos);
    remain = remain.substring(pos + 1);
    while (remain.startsWith(' ')) {
      remain = remain.substring(1);
    }
    var protocol = remain;
    _headers['command'] = command;
    _headers['url'] = url;
    _headers['protocol'] = protocol;
  }

  ///即：将所有参数拼到原查询串后面
  String get retrieveUrl {
    String q = retrieveQueryString;
    if (StringUtil.isEmpty(q)) {
      return url;
    }
    String _url = "$path?$q";
    return _url;
  }

  //
  String get retrieveQueryString {
    String q = queryString;
    if (!StringUtil.isEmpty(q) && q.endsWith("&")) {
      q = q.substring(0, q.length - 1);
    }
    var set = _parameters.keys;
    for (String key in set) {
      String v = _parameters[key];
      q = "$q&$key=$v";
    }
    if (q.startsWith("&")) {
      q = q.substring(1, q.length);
    }
    return q;
  }

  @override
  String toString() {
    return '${_headers['command']} ${_headers['url']} ${_headers['protocol']}';
  }
}
