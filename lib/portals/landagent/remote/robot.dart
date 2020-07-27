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
  double distance;

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
    this.distance,
  });
}

class RecipientsSummaryOR {
  String person;
  String absorber;
  String personName;
  String ctime;
  double weights;
  String encourageCauses;

  RecipientsSummaryOR({
    this.person,
    this.absorber,
    this.personName,
    this.ctime,
    this.weights,
    this.encourageCauses,
  });
}

class RecipientsRecordOR {
  String sn;
  String recipient;
  double amount;
  String ctime;
  String refsn;
  String absorber;
  String encourageCode;
  String encourageCause;
  String recipientsId;

  RecipientsRecordOR(
      {this.sn,
      this.recipient,
      this.amount,
      this.ctime,
      this.refsn,
      this.absorber,
      this.encourageCode,
      this.encourageCause,
      this.recipientsId});
}

class InvestRecordOR {
  String sn;
  String absorber;
  int amount;
  String invester;
  String ctime;
  String personName;
  String outTradeSn;
  String investOrderNo;
  String investOrderTitle;
  String note;

  InvestRecordOR({
    this.sn,
    this.absorber,
    this.amount,
    this.invester,
    this.ctime,
    this.personName,
    this.outTradeSn,
    this.investOrderNo,
    this.investOrderTitle,
    this.note,
  });
}

class WithdrawRecordOR {
  String sn;
  String bankid;
  String shunter;
  String alias;
  String withdrawer;
  String personName;
  int reqAmount;
  int realAmount;
  String ctime;
  String cBtime;
  int state;
  String refsn;
  String status;
  String message;

  WithdrawRecordOR(
      {this.sn,
      this.bankid,
      this.shunter,
      this.alias,
      this.withdrawer,
      this.personName,
      this.reqAmount,
      this.realAmount,
      this.ctime,
      this.cBtime,
      this.state,
      this.refsn,
      this.status,
      this.message});
}

class HubTailsBillOR {
  String sn;
  String person;
  String refsn;
  double amount;
  int order;
  String bankid;
  double balance;
  String ctime;
  String note;
  String workday;
  int day;
  int month;
  int season;
  int year;

  HubTailsBillOR(
      {this.sn,
      this.person,
      this.refsn,
      this.amount,
      this.order,
      this.bankid,
      this.balance,
      this.ctime,
      this.note,
      this.workday,
      this.day,
      this.month,
      this.season,
      this.year});
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

  Future<double> totalRecipientsRecord(String absorber, String person) {}

  Future<List<RecipientsSummaryOR>> pageSimpleRecipients(
      String absorber, int limit, int offset) {}

  Future<double> totalRecipientsRecordById(String recipientsId) {}

  Future<List<RecipientsRecordOR>> pageRecipientsRecordByPerson(
      String absorberid, String recipients, int limit, int offset) {}

  Future<List<RecipientsRecordOR>> pageRecipientsRecordById(
      String recipientsId, int limit, int offset) {}

  Future<List<InvestRecordOR>> pageInvestRecord(
      String absorber, int limit, int offset);

  Future<int> totalAmountInvests(String absorber);

  Future<List<WithdrawRecordOR>> pageWithdrawRecord(
      String bankid, int limit, int offset);

  Future<int> totalAmountWithdraws(String bankid);

  Future<double> totalInBillOfMonth(String bankid, DateTime selected) {}

  Future<double> totalOutBillOfMonth(String bankid, DateTime selected) {}

  Future<List<HubTailsBillOR>> pageBillOfMonth(
      String bankid, DateTime selected, int order, int limit, int offset) {}

  Future<List<HubTailsBillOR>> getBillOfMonth(
      String bankid, DateTime selected, int limit, int offset) {}

  withdrawHubTails(String bankid) {}
}

class RobotRemote implements IRobotRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get robotHubPorts => site.getService('@.prop.ports.robot.hub');

  get robotRecordPorts => site.getService('@.prop.ports.robot.record');

  get walletTradePorts => site.getService('@.prop.ports.wallet.trade.receipt');

  get robotHubTailsPorts => site.getService('@.prop.ports.robot.hubTails');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<double> getHubTails(String bankid) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
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
      robotHubPorts,
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
      robotHubPorts,
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
          distance: obj['distance'] == null
              ? null
              : double.parse('${obj['distance']}'),
        ),
      );
    }
    return recipients;
  }

  @override
  Future<void> startAbsorber(String absorberid) async {
    await remotePorts.portGET(
      robotHubPorts,
      'startAbsorber',
      parameters: {
        'absorberid': absorberid,
      },
    );
  }

  @override
  Future<void> stopAbsorber(String absorberid, String exitCause) async {
    await remotePorts.portGET(
      robotHubPorts,
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
      robotHubPorts,
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

  @override
  Future<double> totalRecipientsRecord(String absorber, String person) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecord',
      parameters: {
        'absorber': absorber,
        'recipients': person,
      },
    );
  }

  @override
  Future<double> totalRecipientsRecordById(String recipientsId) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecordById',
      parameters: {
        'recipientsId': recipientsId,
      },
    );
  }

  @override
  Future<List<RecipientsSummaryOR>> pageSimpleRecipients(
      String absorber, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageSimpleRecipients',
      parameters: {
        'absorberid': absorber,
        'limit': limit,
        'offset': offset,
      },
    );
    var recipients = <RecipientsSummaryOR>[];
    for (var obj in list) {
      recipients.add(
        RecipientsSummaryOR(
          weights: obj['weights'],
          ctime: obj['ctime'],
          personName: obj['personName'],
          absorber: obj['absorber'],
          encourageCauses: obj['encourageCauses'],
          person: obj['person'],
        ),
      );
    }
    return recipients;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordByPerson(
      String absorberid, String recipients, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordByPerson',
      parameters: {
        'absorberid': absorberid,
        'recipients': recipients,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR(
          encourageCode: obj['encourageCode'],
          encourageCause: obj['encourageCause'],
          absorber: obj['absorber'],
          ctime: obj['ctime'],
          amount: obj['amount'],
          refsn: obj['refsn'],
          sn: obj['sn'],
          recipient: obj['recipient'],
          recipientsId: obj['recipientsId'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordById(
      String recipientsId, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordById',
      parameters: {
        'recipientsId': recipientsId,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR(
          encourageCode: obj['encourageCode'],
          encourageCause: obj['encourageCause'],
          absorber: obj['absorber'],
          ctime: obj['ctime'],
          amount: obj['amount'],
          refsn: obj['refsn'],
          sn: obj['sn'],
          recipient: obj['recipient'],
          recipientsId: obj['recipientsId'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<List<InvestRecordOR>> pageInvestRecord(
      String absorber, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageInvestRecord',
      parameters: {
        'absorber': absorber,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <InvestRecordOR>[];
    for (var obj in list) {
      recordList.add(
        InvestRecordOR(
          sn: obj['sn'],
          amount: obj['amount'],
          ctime: obj['ctime'],
          absorber: obj['absorber'],
          personName: obj['personName'],
          outTradeSn: obj['outTradeSn'],
          note: obj['note'],
          invester: obj['invester'],
          investOrderNo: obj['investOrderNo'],
          investOrderTitle: obj['investOrderTitle'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<int> totalAmountInvests(String absorber) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalAmountInvests',
      parameters: {
        'absorber': absorber,
      },
    );
  }

  @override
  Future<List<WithdrawRecordOR>> pageWithdrawRecord(
      String bankid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageWithdrawRecord',
      parameters: {
        'bankid': bankid,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <WithdrawRecordOR>[];
    for (var obj in list) {
      recordList.add(
        WithdrawRecordOR(
          personName: obj['personName'],
          ctime: obj['ctime'],
          sn: obj['sn'],
          refsn: obj['refsn'],
          state: obj['state'],
          bankid: obj['bankid'],
          shunter: obj['shunter'],
          alias: obj['alias'],
          reqAmount: obj['reqAmount'],
          realAmount: obj['realAmount'],
          status: obj['status'],
          message: obj['message'],
          cBtime: obj['cBtime'],
          withdrawer: obj['withdrawer'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<int> totalAmountWithdraws(String bankid) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalAmountWithdraws',
      parameters: {
        'bankid': bankid,
      },
    );
  }

  @override
  Future<double> totalInBillOfMonth(String bankid, DateTime selected) async {
    var v = await remotePorts.portGET(
      robotHubTailsPorts,
      'totalInBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': selected.year,
        'month': selected.month - 1,
      },
    );
    if (v == null) {
      return 0.00;
    }
    return double.parse(v);
  }

  @override
  Future<double> totalOutBillOfMonth(String bankid, DateTime selected) async {
    var v = await remotePorts.portGET(
      robotHubTailsPorts,
      'totalOutBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': selected.year,
        'month': selected.month - 1,
      },
    );
    if (v == null) {
      return 0.00;
    }
    return double.parse(v);
  }

  @override
  Future<List<HubTailsBillOR>> getBillOfMonth(
      String bankid, DateTime selected, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubTailsPorts,
      'getBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': selected.year,
        'month': selected.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <HubTailsBillOR>[];
    for (var obj in list) {
      recordList.add(
        HubTailsBillOR(
          bankid: obj['bankid'],
          refsn: obj['refsn'],
          sn: obj['sn'],
          ctime: obj['ctime'],
          note: obj['note'],
          amount: obj['amount'],
          person: obj['person'],
          year: obj['year'],
          workday: obj['workday'],
          season: obj['season'],
          order: obj['order'],
          month: obj['month'],
          day: obj['day'],
          balance: obj['balance'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<List<HubTailsBillOR>> pageBillOfMonth(String bankid, DateTime selected,
      int order, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubTailsPorts,
      'pageBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'order': order,
        'year': selected.year,
        'month': selected.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <HubTailsBillOR>[];
    for (var obj in list) {
      recordList.add(
        HubTailsBillOR(
          bankid: obj['bankid'],
          refsn: obj['refsn'],
          sn: obj['sn'],
          ctime: obj['ctime'],
          note: obj['note'],
          amount: obj['amount'],
          person: obj['person'],
          year: obj['year'],
          workday: obj['workday'],
          season: obj['season'],
          order: obj['order'],
          month: obj['month'],
          day: obj['day'],
          balance: obj['balance'],
        ),
      );
    }
    return recordList;
  }

  @override
  withdrawHubTails(String bankid) async {
    await remotePorts.portGET(
      robotHubPorts,
      'withdrawHubTails',
      parameters: {
        'bankid': bankid,
      },
    );
  }
}