import 'package:flutter/cupertino.dart';

import '_connection.dart';
import '_frame.dart';

enum ListenMode {
  upstream,
  downstream,
  both,
}
enum EndOrientation {
  frontend,
  backend,
}
mixin ILogicNetwork {
  String get networkName ;

  void leave();

  void ls(String memberIn);

  void send(Frame frame);

  void onmessage(Onmessage onmessage);
}
mixin IPeer {
  void authByPassword(String peer, String person, String password);

  void authByAccessToken(String accessToken);

  ILogicNetwork listen(
      String networkName, EndOrientation endOrientation, ListenMode mode);

  void close();

  bool get isAuthed;

  bool get isSupportsReconnect;
}

class Peer implements IPeer {
  IConnection _connection;
  bool _isAuthed;
  Map<String, ILogicNetwork> _networks = {};

  List<Function()> _commands = [];

  bool _isSupportsReconnect = false;

  Peer._(this._isSupportsReconnect);

  @override
  bool get isAuthed {
    return _isAuthed;
  }

  @override
  bool get isSupportsReconnect {
    return _isSupportsReconnect;
  }

  /// 连接
  static Future<IPeer> connect(
    String url, {
    Duration pingInterval,
    Onopen onopen,
    Onclose onclose,
    Onmessage onmessage,
    Onerror onerror,
    Onreconnect onreconnect,
        ///如果为0表示断开不重连,超出此设定值则会报连接异常退出
    int reconnectTimes=0,
    Duration reconnectDelayed,
  }) async {
    Peer peer = Peer._(reconnectTimes > 0);
    peer._connection = await Connection.connect(
      url,
      reconnectDelayed: reconnectDelayed,
      reconnectTimes: reconnectTimes,
      onreconnect: onreconnect,
      onopen: peer._isSupportsReconnect
          ? peer._createOnopenEventHandler(onopen)
          : onopen,
      onmessage: peer._createOnmessageEventHandler(onmessage, onerror),
      onclose: onclose,
      onerror: onerror,
      pingInterval: pingInterval,
    );
    return peer;
  }

  @override
  void authByAccessToken(String accessToken) {
    if (_isSupportsReconnect) {
      _commands.add(() {
        _authByAccessToken(accessToken);
      });
    }
    _authByAccessToken(accessToken);
  }

  _authByAccessToken(String accessToken) {
    var frame = new Frame("auth / network/1.0");
    frame.setHead("auth-mode", "accessToken");
    frame.setParameter("accessToken", accessToken);
    _connection.send(frame);
    _isAuthed = true;
  }

  @override
  void authByPassword(String peer, String person, String password) {
    if (_isSupportsReconnect) {
      _commands.add(() {
        _authByPassword(peer, person, password);
      });
    }
    _authByPassword(peer, person, password);
  }

  void _authByPassword(String peer, String person, String password) {
    var frame = new Frame("auth / network/1.0");
    frame.setHead("auth-mode", "password");
    frame.setParameter("peer", peer);
    frame.setParameter("person", person);
    frame.setParameter("password", password);
    _connection.send(frame);
    _isAuthed = true;
  }

  void _checkAuthed() {
    if (_isAuthed) {
      return;
    }
    throw new FlutterError("未认证");
  }

  @override
  ILogicNetwork listen(String networkName, EndOrientation endOrientation,
      ListenMode listenMode) {
    _checkAuthed();
    if (_isSupportsReconnect) {
      _commands.add(() {
        _listen(networkName, endOrientation, listenMode);
      });
    }
    return _listen(networkName, endOrientation, listenMode);
  }

  ILogicNetwork _listen(String networkName, EndOrientation endOrientation,
      ListenMode listenMode) {
    var frame = new Frame("listenNetwork /$networkName network/1.0");
    var isJoinToFrontend = '';
    switch (endOrientation ?? EndOrientation.frontend) {
      case EndOrientation.frontend:
        isJoinToFrontend = 'true';
        break;
      case EndOrientation.backend:
        isJoinToFrontend = 'false';
        break;
    }
    frame.setParameter("isJoinToFrontend", isJoinToFrontend);
    var mode = '';
    switch (listenMode ?? ListenMode.both) {
      case ListenMode.upstream:
        mode = 'upstream';
        break;
      case ListenMode.downstream:
        mode = 'downstream';
        break;
      case ListenMode.both:
        mode = 'both';
        break;
    }
    frame.setParameter("listenMode", mode);
    if (_networks.containsKey(networkName)) {
      var nw = _networks[networkName];
      nw.send(frame);
      return nw;
    }
    var lnetwork =
        new DefaultLogicNetwork(networkName, _connection, this._networks);
    _connection.send(frame);
    _networks[networkName] = lnetwork;
    return lnetwork;
  }

  @override
  void close() {
    _connection.close();
    _networks.clear();
    _commands.clear();
  }

  Onopen _createOnopenEventHandler(onopen) {
    return () {
      for (var cmd in _commands) {
        cmd();
      }
      //已成功打开了，此处清除掉命令集
//      _commands.clear();
      if (onopen != null) {
        onopen();
      }
    };
  }

  Onmessage _createOnmessageEventHandler(Onmessage onmessage, Onerror onerror) {
    void _flowSystem(Frame frame) {
      switch (frame.command) {
        case "error":
          if (onerror != null) {
            onerror(frame);
          }
          break;
        default:
          if (onmessage != null) {
            onmessage(frame);
          }
          break;
      }
    }

    void _flowCustom(Frame frame) {
      String network = frame.rootName;
      var nw = _networks[network] as DefaultLogicNetwork;
      if (nw != null) {
        nw._fireOnmessage(frame);
        return;
      }
      if (onmessage != null) {
        onmessage(frame);
      }
    }

    return (frame) {
      if ("NETWORK/1.0" == frame.protocol) {
        _flowSystem(frame);
        return;
      }
      _flowCustom(frame);
    };
  }
}

class DefaultLogicNetwork implements ILogicNetwork {
  IConnection _connection;
  String _networkName;
  Map<String, ILogicNetwork> _networks;
  Onmessage _onmessage;

  DefaultLogicNetwork(this._networkName, this._connection, this._networks);

  @override
  String get networkName {
    return _networkName;
  }

  @override
  void leave() {
    var frame = new Frame("leaveNetwork /$_networkName network/1.0");
    _connection.send(frame);
    _networks.remove(_networkName);
    _connection = null;
  }

  @override
  void ls(String memberIn) {
    var frame = new Frame("viewNetwork /$_networkName network/1.0");
    frame.setParameter("viewMember", memberIn);
    _connection.send(frame);
  }

  @override
  void onmessage(Onmessage onmessage) {
    _onmessage = onmessage;
  }

  @override
  void send(Frame frame) {
    String old = frame.url;
    String url = "/$_networkName$old";
    frame.url = url;
    _connection.send(frame);
    frame.url = old;
  }

  void _fireOnmessage(Frame frame) {
    if (_onmessage == null) {
      return;
    }
    var url=frame.relativeUrl;
    frame.url=url;
    _onmessage(frame);
  }
}
