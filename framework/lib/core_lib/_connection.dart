import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:framework/core_lib/_device.dart';

import '_frame.dart';
import '_utimate.dart';

typedef Onmessage = void Function(Frame frame);
typedef Onopen = void Function(IConnection connection);
typedef Onclose = void Function();
typedef Onerror = void Function(dynamic e);
typedef Onevent = void Function(Frame frame);
typedef Onreconnect = void Function(int tryTimes);

mixin IConnection {
  String get host;

  String get protocol;

  String get path;

  int get port;

  bool get isActived;

  get isOnline => null;

  void close();

  void send(Frame frame);
}

IConnection _currentConnection;

class Connection implements IConnection {
  WebSocket _webSocket;
  Timer _timer;
  bool _isDone = false;
  String _url;
  bool _isOnline = false;
  Duration _pingInterval;
  Onopen _onopen;
  Onclose _onclose;
  Onevent _onevent;
  Onerror _onerror;
  Onmessage _onmessage;
  Onreconnect _onreconnect;

  Duration _reconnectDelayed;
  int _conntimes = 0;

  @override
  bool get isActived => _webSocket.readyState == WebSocket.open;

  @override
  get isOnline => _isOnline;

  Connection._();

  _doReconnect(Timer timer) async {
    if (isActived || _isDone) {
      timer.cancel();
      timer = null;
      return;
    }
    if (_onreconnect != null) {
      _onreconnect(_conntimes);
    }
    _conntimes++;
    try {
      _webSocket = await WebSocket.connect(_url);
      if (_isDone || (_timer != null && _timer.isActive)) {
        _timer.cancel();
        _timer = null;
      }
      print('连接成功。$_url');
      _afterInit();
    } catch (e) {
      print('连接失败。$e');
    }
  }

  Future<void> _init({
    String url,
    Duration pingInterval,
    Onopen onopen,
    Onclose onclose,
    Onmessage onmessage,
    Onerror onerror,
    Onevent onevent,
    Onreconnect onreconnect,
    Duration reconnectDelayed,
  }) async {
    _url = url;
    _isDone = false;
    _onevent = onevent;
    _pingInterval = pingInterval;
    _onopen = onopen;
    _onclose = onclose;
    _onmessage = onmessage;
    _onerror = onerror;
    _onreconnect = onreconnect;
    _reconnectDelayed = reconnectDelayed;

    try {
      _webSocket = await WebSocket.connect(url);
      if (_timer != null && _timer.isActive) {
        _timer.cancel();
        _timer = null;
      }
      print('连接成功。$url');
      _afterInit();
    } catch (e) {
      print('连接失败。$e');
      if (_isDone || (_timer != null && _timer.isActive)) {
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
          var frame = Frame.load(frameRaw);
          if ('NET/1.0' == frame.protocol.toUpperCase()) {
            var status = frame.head("status");
            if (StringUtil.isEmpty(status)) {
              status = "200";
            }
            var statusInt = double.parse(status).floor();
            if (statusInt >= 400) {
              if (_onerror != null) {
                String message = frame.head("message");
                _onerror(Exception('$statusInt $message'));
              }
              return;
            }
            if (_onevent != null) {
              if ('online' == frame.command) {
                _isOnline = true;
              }
              if ('offline' == frame.command) {
                _isOnline = false;
              }
              _onevent(frame);
            }
            return;
          }

          _onmessage(frame);
        }
      },
      onError: (e) {
        if (_onerror != null) {
          _onerror(e);
        }
      },
      cancelOnError: false,
      onDone: () async {
        _isOnline = false;
        print('连接完成状态:${_webSocket.readyState}');
        if (_webSocket.readyState == WebSocket.closed) {
          if (_onclose != null) {
            _onclose();
          }
          if (!_isDone && (_timer == null || !_timer.isActive)) {
            _timer = Timer.periodic(_reconnectDelayed, _doReconnect);
          }
        }
      },
    );
    if (_onopen != null) {
      _onopen(this);
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
    Onevent onevent,
    Onreconnect onreconnect,
    Duration reconnectDelayed,
  }) async {
    if (_currentConnection != null) {
      _currentConnection.close();
    }
    Connection conn = Connection._();
    await conn._init(
      url: url,
      onclose: onclose,
      onerror: onerror,
      onevent: onevent,
      onmessage: onmessage,
      onopen: onopen,
      onreconnect: onreconnect,
      pingInterval: pingInterval,
      reconnectDelayed: reconnectDelayed,
    );
    _currentConnection = conn;
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
    _isDone = true;
    _webSocket.close();
    _currentConnection = null;
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
