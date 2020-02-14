import 'dart:convert';

import 'package:framework/core_lib/_utimate.dart';

mixin IPrincipal {
  String get person;

  String get uid;

  String get accountCode;

  String get nickName;

  String get appid;

  String get portal;

  String get roles;

  String get accessToken;

  String get refreshToken;

  String get ravatar;

  String get lavatar;

  String get signature;

  int get ltime;

  int get pubtime;

  int get expiretime;

  String get device;
}
mixin ILocalPrincipalVisitor {
  //在IPrincipalService的构造中初始化
  IPrincipal get(String person);

  String current();
}
mixin ILocalPrincipal implements ILocalPrincipalVisitor {
  void setVisitor(ILocalPrincipalVisitor visitor);
}

class UserPrincipal {
  final ILocalPrincipal manager;

  UserPrincipal({
    this.manager,
  });

  String get person => manager.get(manager.current())?.person;

  String get device => manager.get(manager.current())?.device;

  String get portal => manager.get(manager.current())?.portal;

  String get uid => manager.get(manager.current())?.uid;

  String get accountCode => manager.get(manager.current())?.accountCode;

  String get nickName => manager.get(manager.current())?.nickName;

  String get appid => manager.get(manager.current())?.appid;

  List<dynamic> get roles =>
      jsonDecode(manager.get(manager.current())?.roles ?? <dynamic>[]);

  String get accessToken => manager.get(manager.current())?.accessToken;

  String get refreshToken => manager.get(manager.current())?.refreshToken;

  String get avatarOnRemote => manager.get(manager.current())?.ravatar;

  String get avatarOnLocal => manager.get(manager.current())?.lavatar;

  String get avatarOnRemoteWithAccessToken =>
      '${manager.get(manager.current())?.ravatar}?accessToken=${manager.get(manager.current())?.accessToken}';

  String get signature => manager.get(manager.current())?.signature;

  int get tokenPubTime => manager.get(manager.current())?.pubtime;

  int get tokenExpireTime => manager.get(manager.current())?.expiretime;
}
