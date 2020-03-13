import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:framework/core_lib/_app_keypair.dart';
import 'package:framework/framework.dart';
import 'package:uuid/uuid.dart';

import '../../portals/gbera/store/services.dart';
import 'dao/database.dart';
import 'entities.dart';

mixin IPlatformLocalPrincipalManager implements ILocalPrincipalVisitor {
  //在IPrincipalService的构造中初始化
  IPrincipal get(String person);

  Future<void> remove(String person);

  List<String> list();

  String current();

  Future<void> setCurrent(String person) {}

  bool isEmpty();

  //请求远程刷新token并存储
  Future<void> doRefreshToken([error, susseed]);

  //刷入信息到本地
  Future<void> add(
    final String person, {
    final String uid,
    final String accountCode,
    final String nickName,
    final String appid,
    final String portal,
    final List<String> roles,
    final String accessToken,
    final String refreshToken,
    final String remoteAvatar,
    final String localAvatar,
    final String signature,
    final int ltime,
    final int pubtime,
    final int expiretime,
    final String device,
  }) {}

  Future<void> emptyRefreshToken();

  Future<void> updateAvatar(String person, localAvatar, String remoteAvatar) {}

  Future<void> updateNickName(String person, String nickName) {}

  Future<void> updateSignature(String person, String text) {}
}

class DefaultLocalPrincipalManager
    implements IPlatformLocalPrincipalManager, IServiceBuilder {
  IPrincipalService _principalService;
  Map<String, Principal> _cached = {};
  List<String> _indexed = [];
  String _current;
  IServiceProvider _site;

  UserPrincipal get principal => _site.getService('@.principal');

  @override
  builder(IServiceProvider site) async {
    _site = site;
    AppDatabase db = site.getService('@.db');
    _principalService = site.getService('/principals');
    ILocalPrincipal localPrincipal = _site.getService('@.principal.local');
    if (localPrincipal != null) {
      localPrincipal.setVisitor(this);
    }
    await load();
  }

  load() async {
    List<Principal> list = await _principalService.getAll();
    for (var p in list) {
      _cached[p.person] = p;
      _indexed.add(p.person);
    }
  }

  @override
  String current() {
    return _current;
  }

  @override
  Future<void> emptyRefreshToken() async {
    await _principalService.emptyRefreshToken(_current);
    _cached[_current] = await _principalService.get(_current);
  }

  @override
  Future<Function> updateAvatar(
      String person, localAvatar, String remoteAvatar) async {
    Principal principal = get(person);
    if (principal == null) {
      return null;
    }
    await _principalService.updateAvatar(person, localAvatar, remoteAvatar);
    principal.lavatar = localAvatar;
    principal.ravatar = remoteAvatar;
  }

  @override
  Future<Function> updateSignature(String person, String signature) async {
    Principal principal = get(person);
    if (principal == null) {
      return null;
    }
    await _principalService.updateSignature(person, signature);
    principal.signature = signature;
  }

  @override
  Future<Function> updateNickName(String person, String nickName) async {
    Principal principal = get(person);
    if (principal == null) {
      return null;
    }
    await _principalService.updateNickName(person, nickName);
    principal.nickName = nickName;
  }

  @override
  Future<void> doRefreshToken([error, susseed]) async {
    String person = _current;
    Principal principal = await _principalService.get(person);
    //如果令牌还能用半个小时就不刷新，半个小时会导致用户在使用中间令牌失效
    //非常操蛋，entrypoint会一次性调用两次doRefreshToken，而且第二次传入的是旧的refreshToken，因此第二次会验证失败，故计是一次进入该方法两个处理，都拿的是旧的。之后再找原因
    if (principal?.pubtime + principal?.expiretime >
        DateTime.now().millisecondsSinceEpoch - 1800000) {
      if (susseed != null) {
        susseed(principal);
      }
      return;
    }
    Dio dio = _site.getService('@.http');
    AppKeyPair appKeyPair = _site.getService('@.appKeyPair');
    //强制刷新所有账户的访问令牌
    var appNonce = MD5Util.generateMd5(Uuid().v1()).toUpperCase();
    var response = await dio
        .post(
      _site.getService('@.prop.ports.uc.auth'),
      queryParameters: {
        'refreshToken': principal.refreshToken,
      },
      options: Options(
        headers: {
          'rest-command': 'refreshToken',
          'app-id': appKeyPair.appid,
          'app-key': appKeyPair.appKey,
          'app-nonce': appNonce,
          'app-sign': appKeyPair.appSign(appNonce),
        },
      ),
    )
        .catchError((e) {
      print(e);
    });
    if (response.statusCode >= 400) {
      print('刷新失败：${response.statusCode} ${response.statusMessage}');
      return;
    }
    var data = response.data;
    var map = jsonDecode(data);
    if (map['status'] as int >= 400) {
      print('刷新失败：${map['status']} ${map['message']}');
      if (error != null) {
        error(map);
      }
      return;
    }
    var json = map['dataText'];
    var result = jsonDecode(json);
    String accessToken = result['accessToken'];
    String refreshToken = result['refreshToken'];
    await _principalService.updateToken(refreshToken, accessToken, person);
    //更新缓冲
    Principal one = await _principalService.get(person);
    _cached[person] = one;
    if (susseed != null) {
      susseed(one);
    }
  }

  @override
  IPrincipal get(String person) {
    return _cached[person];
  }

  @override
  Future<void> add(String person,
      {String uid,
      String accountCode,
      String nickName,
      String appid,
      String portal,
      List<String> roles,
      String accessToken,
      String refreshToken,
      String remoteAvatar,
      String localAvatar,
      String signature,
      int ltime,
      int pubtime,
      int expiretime,
      String device}) async {
    var p = Principal(
        person,
        uid,
        accountCode,
        nickName,
        appid,
        portal,
        jsonEncode(roles ?? []),
        accessToken,
        refreshToken,
        remoteAvatar,
        localAvatar,
        signature,
        ltime,
        pubtime,
        expiretime,
        device);

    _cached[p.person] = p;
    if (!_indexed.contains(p.person)) {
      _indexed.add(p.person);
    }
    await _flushOne(p);
  }

  @override
  bool isEmpty() {
    return _cached.isEmpty;
  }

  @override
  List<String> list() {
    return _indexed.toList();
  }

  @override
  Future<void> remove(String person) async {
    _cached.remove(person);
    _indexed.remove(person);
    if (_current == person) {
      _current = null;
    }
    await _principalService.remove(person);
  }

  @override
  Future<void> setCurrent(String person) async {
    _current = person;
    IPeerManager peerManager = _site.getService('@.peer.manager');
    if (peerManager != null) {
      await peerManager.start(_site);
    }
  }

  Future<void> _flushOne(Principal p) async {
    Principal exists = await _principalService.get(p.person);
    if (exists != null) {
      await _principalService.remove(p.person);
    }
    await _principalService.add(p);
  }
}
