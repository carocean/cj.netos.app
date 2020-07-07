import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class AbsorberOR {
  String id;
  String title;
  String bankid;
  String category;
  String proxy;
  LatLng location;
  int radius;
  int type;
  String creator;
  String ctime;
  int exitExpire;
  int exitAmount;
  int exitTimes;
  double weight;
  int maxRecipients;
  double currentAmount;
  int currentTimes;
  int state;
  String exitCause;

  AbsorberOR(
      {this.id,
      this.title,
      this.bankid,
      this.category,
      this.proxy,
      this.location,
      this.radius,
      this.type,
      this.creator,
      this.ctime,
      this.exitExpire,
      this.exitAmount,
      this.exitTimes,
      this.weight,
      this.maxRecipients,
      this.currentAmount,
      this.currentTimes,
      this.state,
      this.exitCause});

  void updateBy(AbsorberOR absorberOR) {
    this.id = absorberOR.id;
    this.title = absorberOR.title;
    this.bankid = absorberOR.bankid;
    this.category = absorberOR.category;
    this.proxy = absorberOR.proxy;
    this.location = absorberOR.location;
    this.radius = absorberOR.radius;
    this.type = absorberOR.type;
    this.creator = absorberOR.creator;
    this.ctime = absorberOR.ctime;
    this.exitExpire = absorberOR.exitExpire;
    this.exitAmount = absorberOR.exitAmount;
    this.exitTimes = absorberOR.exitTimes;
    this.weight = absorberOR.weight;
    this.maxRecipients = absorberOR.maxRecipients;
    this.currentAmount = absorberOR.currentAmount;
    this.currentTimes = absorberOR.currentTimes;
    this.state = absorberOR.state;
    this.exitCause = absorberOR.exitCause;
  }
}

class RecipientsOR {
  String id;
  String person;
  String absorber;
  String personName;
  String ctime;
  double weight;
  String encourageCode;
  String encourageCause;
  int desireAmount;

  RecipientsOR({
    this.id,
    this.person,
    this.absorber,
    this.personName,
    this.ctime,
    this.weight,
    this.encourageCode,
    this.encourageCause,
    this.desireAmount,
  });
}

mixin IRobotRemote {
  Future<double> getHubTails(String bankid) {}

  Future<List<AbsorberOR>> pageAbsorber(
      String bankid, int type, int limit, int offset) {}

  Future<List<RecipientsOR>> pageRecipients(String id, int limit, int offset) {}

  Future<void> startAbsorber(String absorberid) {}

  Future<void> stopAbsorber(String absorberid, String exitCause) {}

  Future<void> investAbsorber(
      int amount, int type, Map<String, dynamic> details, note);

  Future<AbsorberOR> getAbsorber(String absorberid) {}
}

class RobotRemote implements IRobotRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get robotPorts => site.getService('@.prop.ports.robot');

  get walletTradePorts => site.getService('@.prop.ports.wallet.trade.receipt');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<double> getHubTails(String bankid) async {
    var obj = await remotePorts.portGET(
      robotPorts,
      'getHubTails',
      parameters: {
        'bankid': bankid,
      },
    );
    if (obj == null) {
      return 0.00;
    }
    return obj['tailAdmount'];
  }

  @override
  Future<List<AbsorberOR>> pageAbsorber(
      String bankid, int type, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotPorts,
      'pageAbsorber',
      parameters: {
        'bankid': bankid,
        'type': type,
        'limit': limit,
        'offset': offset,
      },
    );
    var absorbers = <AbsorberOR>[];
    for (var obj in list) {
      absorbers.add(
        AbsorberOR(
          id: obj['id'],
          bankid: obj['bankid'],
          title: obj['title'],
          ctime: obj['ctime'],
          state: obj['state'],
          creator: obj['creator'],
          type: obj['type'],
          category: obj['category'],
          currentAmount: obj['currentAmount'],
          currentTimes: obj['currentTimes'],
          exitAmount: obj['exitAmount'],
          exitCause: obj['exitCause'],
          exitExpire: obj['exitExpire'],
          exitTimes: obj['exitTimes'],
          location: obj['type'] == 1
              ? LatLng.fromJson(jsonDecode(obj['location']))
              : null,
          maxRecipients: obj['maxRecipients'],
          proxy: obj['proxy'],
          radius: obj['radius'],
          weight: obj['weight'],
        ),
      );
    }
    return absorbers;
  }

  @override
  Future<List<RecipientsOR>> pageRecipients(
      String absorberid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotPorts,
      'pageRecipients',
      parameters: {
        'absorberid': absorberid,
        'limit': limit,
        'offset': offset,
      },
    );
    var recipients = <RecipientsOR>[];
    for (var obj in list) {
      recipients.add(
        RecipientsOR(
          weight: obj['weight'],
          ctime: obj['ctime'],
          id: obj['id'],
          personName: obj['personName'],
          absorber: obj['absorber'],
          desireAmount: obj['desireAmount'],
          encourageCause: obj['encourageCause'],
          encourageCode: obj['encourageCode'],
          person: obj['person'],
        ),
      );
    }
    return recipients;
  }

  @override
  Future<void> startAbsorber(String absorberid) async {
    await remotePorts.portGET(
      robotPorts,
      'startAbsorber',
      parameters: {
        'absorberid': absorberid,
      },
    );
  }

  @override
  Future<void> stopAbsorber(String absorberid, String exitCause) async {
    await remotePorts.portGET(
      robotPorts,
      'stopAbsorber',
      parameters: {
        'absorberid': absorberid,
        'exitCause': exitCause,
      },
    );
  }

  @override
  Future<void> investAbsorber(
      int amount, int type, Map<String, dynamic> details, note) async {
    await remotePorts.portPOST(
      walletTradePorts,
      'payTrade',
      parameters: {
        'amount': amount,
        'type': type,
        'note': note,
      },
      data: {
        'details': jsonEncode(details),
      },
    );
  }

  @override
  Future<AbsorberOR> getAbsorber(String absorberid) async {
    var obj = await remotePorts.portGET(
      robotPorts,
      'getAbsorber',
      parameters: {
        'absorberid': absorberid,
      },
    );
    return AbsorberOR(
      id: obj['id'],
      bankid: obj['bankid'],
      title: obj['title'],
      ctime: obj['ctime'],
      state: obj['state'],
      creator: obj['creator'],
      type: obj['type'],
      category: obj['category'],
      currentAmount: obj['currentAmount'],
      currentTimes: obj['currentTimes'],
      exitAmount: obj['exitAmount'],
      exitCause: obj['exitCause'],
      exitExpire: obj['exitExpire'],
      exitTimes: obj['exitTimes'],
      location: obj['type'] == 1
          ? LatLng.fromJson(jsonDecode(obj['location']))
          : null,
      maxRecipients: obj['maxRecipients'],
      proxy: obj['proxy'],
      radius: obj['radius'],
      weight: obj['weight'],
    );
  }
}
