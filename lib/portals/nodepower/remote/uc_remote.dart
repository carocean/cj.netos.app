import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:intl/intl.dart' as intl;

class AppAcountOL {
  String accountId;
  String accountCode;
  String appId;
  String nickName;
  String avatar;
  int nameKind;
  String userId;
  DateTime createTime;
  String signature;

  AppAcountOL({
    this.accountId,
    this.accountCode,
    this.appId,
    this.nickName,
    this.avatar,
    this.nameKind,
    this.userId,
    this.createTime,
    this.signature,
  });
}

mixin IAppRemote {
  Future<List<AppAcountOL>> pageAccount(int limit, int offset);
}

class AppRemote implements IAppRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get appPorts => site.getService('@.prop.ports.uc.app');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<AppAcountOL>> pageAccount(int limit, int offset) async {
    var list = await remotePorts.portGET(
      appPorts,
      'pageAccount',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var accounts = <AppAcountOL>[];
    for (var obj in list) {
      var dateISO = obj['createTime'] as String;
      var time = intl.DateFormat('MMM dd, yyyy HH:mm:ss').parse(dateISO);
      accounts.add(
        AppAcountOL(
          accountCode: obj['accountCode'],
          accountId: obj['accountId'],
          appId: obj['appId'],
          avatar: obj['avatar'],
          createTime: time,
          nameKind: obj['nameKind'],
          nickName: obj['nickName'],
          userId: obj['userId'],
          signature: obj['signature'],
        ),
      );
    }
    return accounts;
  }
}
