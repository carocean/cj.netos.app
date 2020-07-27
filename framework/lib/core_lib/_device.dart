import '_connection.dart';
import '_frame.dart';

typedef Online = void Function();
typedef Offline = void Function();
mixin IDevice {
  bool get isOnline => null;

  void on(String accessToken);

  void leave();

  void pause();

  void resume();

  void close();

  void ls();
}

class Device implements IDevice {
  IConnection _connection;

  @override
  bool get isOnline => _connection?.isOnline;

  Device._();

  /// 连接
  static Future<IDevice> connect(
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
    Device device = Device._();
    device._connection = await Connection.connect(
      url,
      reconnectDelayed: reconnectDelayed,
      onreconnect: onreconnect,
      onopen: onopen,
      onmessage: onmessage,
      onclose: onclose,
      onerror: onerror,
      pingInterval: pingInterval,
      onevent: onevent,
    );
    return device;
  }

  @override
  void close() {
    _connection.close();
  }

  @override
  void leave() {
    var frame = Frame("logout / NET/1.0");
    _connection.send(frame);
  }

  @override
  void ls() {
    var frame = Frame("ls / NET/1.0");
    _connection.send(frame);
  }

  @override
  void on(String accessToken) {
    var frame = Frame("login / NET/1.0");
    frame.setHead('accessToken', accessToken);
    _connection.send(frame);
  }

  @override
  void pause() {
    var frame = Frame("pause / NET/1.0");
    _connection.send(frame);
  }

  @override
  void resume() {
    var frame = Frame("resume / NET/1.0");
    _connection.send(frame);
  }
}
