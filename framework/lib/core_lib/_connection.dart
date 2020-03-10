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
typedef Online=void Function();

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

  Connection._();

  /// 连接
  static Future<IConnection> connect(
    String url, {
    Duration pingInterval,
    Onopen onopen,
    Onclose onclose,
    Onmessage onmessage,
    Onerror onerror,
    Onreconnect onreconnect,
    int reconnectTimes,
    Duration reconnectDelayed,
  }) async {
    return _connect(
      url,
      onopen: onopen,
      onreconnect: onreconnect,
      onmessage: onmessage,
      pingInterval: pingInterval,
      onerror: onerror,
      onclose: onclose,
      reconnectTimes: reconnectTimes,
      reconnectDelayed: reconnectDelayed,
      preconn: null,
    );
  }

  static Future<IConnection> _connect(
    String url, {
    Duration pingInterval,
    Onopen onopen,
    Onclose onclose,
    Onmessage onmessage,
    Onerror onerror,
    Onreconnect onreconnect,
    int reconnectTimes,
    Duration reconnectDelayed,
    Connection preconn,
  }) async {
    var websocket = await _waitConnectComplated(
      url: url,
      reconnectTimes: reconnectTimes,
      currentTryTimes: 0,
      onreconnect: onreconnect,
      delayed: reconnectDelayed ?? Duration(seconds: 15),
      onopen: onopen,
    );

    Connection conn = preconn == null ? Connection._() : preconn;
    conn._webSocket = websocket;
    if (pingInterval != null) {
      conn._webSocket.pingInterval = pingInterval;
    }
    conn._isConnected = true;
    _parseUrl(url, conn);
    conn._webSocket.listen(
      (frameRaw) {
        if (onmessage != null) {
          onmessage(Frame.load(frameRaw));
        }
      },
      onError: (e) {
        if (onerror != null) {
          onerror(e);
        }
      },
      cancelOnError: false,
      onDone: () async {
        conn._isConnected = false;
        if (reconnectTimes > 0) {
          await _connect(
            url,
            onopen: onopen,
            onreconnect: onreconnect,
            onmessage: onmessage,
            pingInterval: pingInterval,
            onerror: onerror,
            onclose: onclose,
            reconnectTimes: reconnectTimes,
            reconnectDelayed: reconnectDelayed,
            preconn: conn,
          );
          return;
        }
        if (onclose != null) {
          onclose();
        }
      },
    );
    if (onopen != null) {
      onopen();
    }
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

  static Future<WebSocket> _waitConnectComplated({
    String url,
    int reconnectTimes = 0,
    Duration delayed,
    int currentTryTimes = 0,
    Onreconnect onreconnect,
    Onopen onopen,
  }) async {
    if (reconnectTimes < 1) {
      var ws = await WebSocket.connect(url);
      print('连接成功。$url');
      return ws;
    }
    var ws = await _delayedGet(
        delayed, currentTryTimes, reconnectTimes, url, onreconnect);
    print('连接成功。$url');
    return ws;
  }

  static Future<WebSocket> _delayedGet(Duration delayed, int currentTryTimes,
      int reconnectTimes, String url, Onreconnect onreconnect) async {
    try {
      return await WebSocket.connect(url);
    } catch (e) {
      if (currentTryTimes >= reconnectTimes) {
        throw e;
      }
      ++currentTryTimes;
      return await Future.delayed(delayed, () async {
        print('连接失败，原因:$e。重连第$currentTryTimes次');
        if (onreconnect != null) {
          onreconnect(currentTryTimes);
        }
        return await _delayedGet(
            delayed, currentTryTimes, reconnectTimes, url, onreconnect);
      });
    }
  }
}
