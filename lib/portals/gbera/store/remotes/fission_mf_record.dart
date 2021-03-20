import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class FissionMFRechargeRecordOR {
  String sn;
  String recharger;
  String nickName;
  String currency;
  int amount;
  double shuntRatio;
  int shuntAmount;
  int remnantAmount;
  String salesman;
  int rechargeStrategy;
  int dayLimitAmount;
  int state;
  String ctime;
  String refOrderSn;
  String refOrderTitle;
  String refPaySn;
  int status;
  String message;
  String note;

  FissionMFRechargeRecordOR({
    this.sn,
    this.recharger,
    this.nickName,
    this.currency,
    this.amount,
    this.shuntRatio,
    this.shuntAmount,
    this.remnantAmount,
    this.salesman,
    this.rechargeStrategy,
    this.dayLimitAmount,
    this.state,
    this.ctime,
    this.refOrderSn,
    this.refOrderTitle,
    this.refPaySn,
    this.status,
    this.message,
    this.note,
  });

  FissionMFRechargeRecordOR.parse(obj) {
    this.sn = obj['sn'];
    this.recharger = obj['recharger'];
    this.nickName = obj['nickName'];
    this.currency = obj['currency'];
    this.amount = obj['amount'];
    this.rechargeStrategy = obj['rechargeStrategy'];
    this.dayLimitAmount = obj['dayLimitAmount'];
    this.state = obj['state'];
    this.ctime = obj['ctime'];
    this.refOrderSn = obj['refOrderSn'];
    this.refOrderTitle = obj['refOrderTitle'];
    this.refPaySn = obj['refPaySn'];
    this.status = obj['status'];
    this.message = obj['message'];
    this.note = obj['note'];
    this.shuntRatio = obj['shuntRatio'];
    this.shuntAmount = obj['shuntAmount'];
    this.remnantAmount = obj['remnantAmount'];
    this.salesman = obj['salesman'];
  }
}

class FissionMFWithdrawRecordOR {
  String sn;
  String withdrawer;
  String nickName;
  String currency;
  int amount;
  double incomeRatio;
  double commissionRatio;
  double absorbRatio;
  double shuntRatio;
  int incomeAmount;
  int absorbAmount;
  int commissionAmount;
  int gainAmount;
  int state;
  String ctime;
  int status;
  String message;
  String referrer;
  String referrerName;
  String note;

  FissionMFWithdrawRecordOR({
    this.sn,
    this.withdrawer,
    this.nickName,
    this.currency,
    this.amount,
    this.incomeRatio,
    this.commissionRatio,
    this.absorbRatio,
    this.shuntRatio,
    this.incomeAmount,
    this.absorbAmount,
    this.commissionAmount,
    this.gainAmount,
    this.state,
    this.ctime,
    this.status,
    this.message,
    this.referrer,
    this.referrerName,
    this.note,
  });

  FissionMFWithdrawRecordOR.parse(obj) {
    this.sn = obj['sn'];
    this.withdrawer = obj['withdrawer'];
    this.nickName = obj['nickName'];
    this.currency = obj['currency'];
    this.amount = obj['amount'];
    this.incomeRatio = obj['incomeRatio'];
    this.commissionRatio = obj['commissionRatio'];
    this.absorbRatio = obj['absorbRatio'];
    this.shuntRatio = obj['shuntRatio'];
    this.incomeAmount = obj['incomeAmount'];
    this.absorbAmount = obj['absorbAmount'];
    this.commissionAmount = obj['commissionAmount'];
    this.gainAmount = obj['gainAmount'];
    this.state = obj['state'];
    this.ctime = obj['ctime'];
    this.status = obj['status'];
    this.message = obj['message'];
    this.referrer = obj['referrer'];
    this.referrerName = obj['referrerName'];
    this.note = obj['note'];
  }
}

class FissionMFPerson {
  String id;

  String nickName;

  String avatarUrl;

  int gender;

  String country;

  String province;
  String city;
  String district;
  String town;
  LatLng location;
  String language;

  String ctime;
  String openid;

  FissionMFPerson({
    this.id,
    this.nickName,
    this.avatarUrl,
    this.gender,
    this.country,
    this.province,
    this.city,
    this.district,
    this.town,
    this.location,
    this.language,
    this.ctime,
    this.openid,
  });

  FissionMFPerson.parse(obj) {
    this.id = obj['id'];
    this.nickName = obj['nickName'];
    this.avatarUrl = obj['avatarUrl'];
    this.gender = obj['gender'];
    this.country = obj['country'];
    this.province = obj['province'];
    this.city = obj['city'];
    this.district = obj['district'];
    this.town = obj['town'];
    this.location =
        obj['location'] == null ? null : LatLng.fromJson(obj['location']);
    this.language = obj['language'];
    this.ctime = obj['ctime'];
    this.openid = obj['openid'];
  }
}

class FissionMFPayRecordOR {
  String sn;
  String payer;
  String payerName;
  String payee;
  String payeeName;
  String currency;
  int amount;
  int state;
  String ctime;
  int status;
  String message;
  String note;

  FissionMFPayRecordOR({
    this.sn,
    this.payer,
    this.payerName,
    this.payee,
    this.payeeName,
    this.currency,
    this.amount,
    this.state,
    this.ctime,
    this.status,
    this.message,
    this.note,
  });

  FissionMFPayRecordOR.parse(obj) {
    this.sn = obj['sn'];
    this.payer = obj['payer'];
    this.payerName = obj['payerName'];
    this.payee = obj['payee'];
    this.payeeName = obj['payeeName'];
    this.currency = obj['currency'];
    this.amount = obj['amount'];
    this.state = obj['state'];
    this.ctime = obj['ctime'];
    this.status = obj['status'];
    this.message = obj['message'];
    this.note = obj['note'];
  }
}

class FissionMFCommissionRecordOR {
  String sn;
  String person;
  String nickName;
  String currency;
  int amount;
  int state;
  String ctime;
  int status;
  String message;
  String refsn;
  String note;

  FissionMFCommissionRecordOR({
    this.sn,
    this.person,
    this.nickName,
    this.currency,
    this.amount,
    this.state,
    this.ctime,
    this.status,
    this.message,
    this.refsn,
    this.note,
  });

  FissionMFCommissionRecordOR.parse(obj) {
    this.sn = obj['sn'];
    this.person = obj['person'];
    this.nickName = obj['nickName'];
    this.currency = obj['currency'];
    this.amount = obj['amount'];
    this.state = obj['state'];
    this.ctime = obj['ctime'];
    this.status = obj['status'];
    this.message = obj['message'];
    this.refsn = obj['refsn'];
    this.note = obj['note'];
  }
}

class PayPersonOR extends FissionMFPayRecordOR {
  FissionMFPerson person;

  PayPersonOR({this.person});

  PayPersonOR.parse(obj) : super.parse(obj) {
    this.person = FissionMFPerson.parse(obj['person']);
  }
}

class StaffOR {
  FissionMFPerson person;
  String ctime;
  int amount;
  int count;
  StaffOR({this.person, this.ctime, this.amount,this.count});

  StaffOR.parse(obj) {
    var p = obj['person'];
    this.person = FissionMFPerson.parse(p);
    this.amount = obj['amount'];
    this.count = obj['count'];
    this.ctime = obj['ctime'];
  }
}

mixin IFissionMFCashierRecordRemote {
  Future<int> totalPersonAmount() {}

  Future<int> totalPayeeAmount() {}

  Future<int> totalStaffAmount() {}
  Future<int>  totalAllStaffAmount() {}
  Future<int> totalAllStaff() {}

  Future<int> totalPayee() {}

  Future<int> totalPerson() {}

  Future<int> totalPayer() {}

  Future<int> totalPayeeOfDay(String format) {}

  Future<int> totalPayerOnDay(String timeStr) {}

  Future<int> totalPersonOnDay(String timeStr) {}

  Future<int> totalCommissionOnDay(String timeStr) {}

  Future<List<PayPersonOR>> pagePayeeDetails(int limit, int offset) {}

  Future<List<PayPersonOR>> pagePersonDetails(int limit, int offset) {}

  Future<List<StaffOR>> pageStaffDetails(int limit, int offset) {}

  Future<List<StaffOR>> pageAllStaffDetails(int limit, int offset) {}

  Future<List<PayPersonOR>> pagePayerDetails(int limit, int offset) {}

  Future<List<FissionMFPerson>> pagePayeeInfo(int limit, int offset) {}

  Future<List<FissionMFPerson>> pagePersonInfo(int limit, int offset) {}

  Future<List<FissionMFPerson>> pagePayerInfo(int limit, int offset) {}

  Future<FissionMFRechargeRecordOR> getRechargeRecord(String sn);

  Future<FissionMFWithdrawRecordOR> getWithdrawRecord(String sn);

  Future<FissionMFPayRecordOR> getPayRecord(String sn);

  Future<FissionMFCommissionRecordOR> getDepositCommissionRecord(String sn);






}

class FissionMFCashierRecordRemote
    implements IFissionMFCashierRecordRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get fissionMfCashierPorts =>
      site.getService('@.prop.ports.fission.mf.cashier');

  get fissionMfReceiptPorts =>
      site.getService('@.prop.ports.fission.mf.receipt');

  get fissionMfRecordPorts =>
      site.getService('@.prop.ports.fission.mf.cashier.record');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<int> totalPayeeAmount() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayeeAmount',
      parameters: {},
    );
  }

  @override
  Future<int> totalStaffAmount() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalStaffAmount',
      parameters: {},
    );
  }

  @override
  Future<int> totalAllStaffAmount()async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalAllStaffAmount',
      parameters: {},
    );
  }

  @override
  Future<int> totalAllStaff()async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalAllStaff',
      parameters: {},
    );
  }

  @override
  Future<int> totalPersonAmount() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPersonAmount',
      parameters: {},
    );
  }

  @override
  Future<int> totalPayee() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayee2',
      parameters: {},
    );
  }

  @override
  Future<int> totalPerson() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPerson',
      parameters: {},
    );
  }

  @override
  Future<int> totalPayer() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayer2',
      parameters: {},
    );
  }

  @override
  Future<int> totalPayeeOfDay(String day) async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayeeOfDay2',
      parameters: {'dayTime': day},
    );
  }

  @override
  Future<int> totalPersonOnDay(String timeStr) async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPersonOfDay',
      parameters: {'dayTime': timeStr},
    );
  }

  @override
  Future<int> totalPayerOnDay(String timeStr) async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayerOnDay2',
      parameters: {'dayTime': timeStr},
    );
  }

  @override
  Future<int> totalCommissionOnDay(String timeStr) async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalCommissionOnDay',
      parameters: {'dayTime': timeStr},
    );
  }

  @override
  Future<List<PayPersonOR>> pagePayeeDetails(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayeeDetails2',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<PayPersonOR> persons = [];
    for (var obj in list) {
      persons.add(PayPersonOR.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<StaffOR>> pageStaffDetails(int limit, int offset)async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pageStaffDetails',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<StaffOR> persons = [];
    for (var obj in list) {
      persons.add(StaffOR.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<StaffOR>> pageAllStaffDetails(int limit, int offset)async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pageAllStaffDetails',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<StaffOR> persons = [];
    for (var obj in list) {
      persons.add(StaffOR.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<PayPersonOR>> pagePersonDetails(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePersonDetails',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<PayPersonOR> persons = [];
    for (var obj in list) {
      persons.add(PayPersonOR.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<PayPersonOR>> pagePayerDetails(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayerDetails2',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<PayPersonOR> persons = [];
    for (var obj in list) {
      persons.add(PayPersonOR.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<FissionMFPerson>> pagePayerInfo(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayerInfo2',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<FissionMFPerson> persons = [];
    for (var obj in list) {
      persons.add(FissionMFPerson.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<FissionMFPerson>> pagePayeeInfo(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayeeInfo2',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<FissionMFPerson> persons = [];
    for (var obj in list) {
      persons.add(FissionMFPerson.parse(obj));
    }
    return persons;
  }

  @override
  Future<List<FissionMFPerson>> pagePersonInfo(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePersonInfo',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<FissionMFPerson> persons = [];
    for (var obj in list) {
      persons.add(FissionMFPerson.parse(obj));
    }
    return persons;
  }

  @override
  Future<FissionMFCommissionRecordOR> getDepositCommissionRecord(
      String sn) async {
    var obj = await remotePorts.portGET(
      fissionMfRecordPorts,
      'getDepositCommissionRecord',
      parameters: {
        'sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return FissionMFCommissionRecordOR.parse(obj);
  }

  @override
  Future<FissionMFPayRecordOR> getPayRecord(String sn) async {
    var obj = await remotePorts.portGET(
      fissionMfRecordPorts,
      'getPayRecord',
      parameters: {
        'sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return FissionMFPayRecordOR.parse(obj);
  }

  @override
  Future<FissionMFRechargeRecordOR> getRechargeRecord(String sn) async {
    var obj = await remotePorts.portGET(
      fissionMfRecordPorts,
      'getRechargeRecord',
      parameters: {
        'sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return FissionMFRechargeRecordOR.parse(obj);
  }

  @override
  Future<FissionMFWithdrawRecordOR> getWithdrawRecord(String sn) async {
    var obj = await remotePorts.portGET(
      fissionMfRecordPorts,
      'getWithdrawRecord',
      parameters: {
        'sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return FissionMFWithdrawRecordOR.parse(obj);
  }
}
