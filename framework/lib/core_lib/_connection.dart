import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '_frame.dart';
import '_utimate.dart';

typedef Onmessage = void Function(Frame frame);
typedef Onopen = void Function();
typedef Onclose = void Function();
typedef Onerror = void Function(dynamic e);
typedef Onreconnect = void Function(int tryTimes);
typedef Online = void Function();

mixin IConnection {
  String get host;

  String get protocol;

  String get path;

  int get port;

  void close();

  void send(Frame frame);
}

class Connection implements IConnection {
  WebSocket _webSocket;
  bool _isConnected = false;
  Timer _timer;
  bool _isDone = false;
  String _url;
  Onreconnect _onreconnect;
  Duration _pingInterval;
  Onopen _onopen;
  Onclose _onclose;
  Onmessage _onmessage;
  Onerror _onerror;
  Duration _reconnectDelayed;
  int _conntimes = 0;

  Connection._();

  _doReconnect(Timer timer) async {
    if (_isConnected || _isDone) {
      timer.cancel();
      return;
    }
    if (_onreconnect != null) {
      _onreconnect(_conntimes);
    }
    _conntimes++;
    try {
      _webSocket = await WebSocket.connect(_url);
      _isConnected = true;
      if(_timer!=null&&_timer.isActive) {
        _timer.cancel();
        _timer=null;
      }
      print('连接成功。$_url');
      _afterInit();
    } catch (e) {
      _isConnected = false;
      print('连接失败。$e');
    }
  }

  Future<void> _init(
    String url,
    Duration pingInterval,
    Onopen onopen,
    Onclose onclose,
    Onmessage onmessage,
    Onerror onerror,
    Onreconnect onreconnect,
    Duration reconnectDelayed,
  ) async {
    _url = url;
    _isDone = false;
    _onreconnect = onreconnect;
    _pingInterval = pingInterval;
    _onopen = onopen;
    _onclose = onclose;
    _onmessage = onmessage;
    _onerror = onerror;
    _reconnectDelayed = reconnectDelayed;

    try {
      _webSocket = await WebSocket.connect(url);
      _isConnected = true;
      if(_timer!=null&&_timer.isActive) {
        _timer.cancel();
        _timer=null;
      }
      print('连接成功。$url');
      _afterInit();
    } catch (e) {
      _isConnected = false;
      print('连接失败。$e');
      if (_timer != null && _timer.isActive) {
        return;
      }
      _timer = Timer.periodic(reconnectDelayed, _doReconnect);
      return;
    }
  }

  _afterInit() {
    if (_pingInterval != null) {
      _webSocket.pingInterval = _pingInterval;
    }
    _parseUrl(_url, this);
    _webSocket.listen(
      (frameRaw) {
        if (_onmessage != null) {
//          print(utf8.decode(frameRaw));
          _onmessage(Frame.load(frameRaw));
        }
      },
      onError: (e) {
        if (_onerror != null) {
          _onerror(e);
        }
      },
      cancelOnError: false,
      onDone: () async {
        _isConnected = false;
        if (!_isDone && (_timer == null || !_timer.isActive)) {
          _timer = Timer.periodic(_reconnectDelayed, _doReconnect);
        }
        if (_onclose != null) {
          _onclose();
        }
      },
    );
    if (_onopen != null) {
      _onopen();
    }
  }

  /// 连接
  static Future<IConnection> connect(
    String url, {
    Duration pingInterval,
    Onopen onopen,
    Onclose onclose,
    Onmessage onmessage,
    Onerror onerror,
    Onreconnect onreconnect,
    Duration reconnectDelayed,
  }) async {
    Connection conn = Connection._();
    await conn._init(url, pingInterval, onopen, onclose, onmessage, onerror,
        onreconnect, reconnectDelayed);
    return conn;
  }

  String _path;
  String _protocol;
  String _host;
  int _port;

  @override
  String get path => _path;

  @override
  String get host => _host;

  @override
  int get port => _port;

  @override
  String get protocol => _protocol;

  @override
  void close() {
    _webSocket.close();
    _isDone = true;
  }

  static void _parseUrl(String url, Connection conn) {
    String path = "";
    int pos = url.indexOf("?");
    if (pos < 0) {
      path = url;
    } else {
      path = url.substring(0, pos);
    }
    pos = path.indexOf('://');
    String protocol = path.substring(0, pos);
    String remain = path.substring(pos + '://'.length + 1);
    pos = remain.indexOf(':');
    String host = '';
    var wspath = '';
    int port = 0;
    if (pos < 0) {
      host = remain;
      port = 80;
    } else {
      host = remain.substring(0, pos);
      remain = remain.substring(pos + 1);
      pos = remain.indexOf("/");
      if (pos < 0) {
        port = int.parse(remain);
      } else {
        String _port = remain.substring(0, pos);
        port = int.parse(_port);
        wspath = remain.substring(pos + 1);
      }
    }
    conn._path = StringUtil.isEmpty(wspath) ? '/websocket' : wspath;
    conn._port = port;
    conn._protocol = protocol;
    conn._host = host;
  }

  @override
  void send(Frame frame) {
    _webSocket.add(frame.toBytes());
  }
}
