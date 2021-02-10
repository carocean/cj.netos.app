import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

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
  String location;
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
    this.location = obj['location'];
    this.language = obj['language'];
    this.ctime = obj['ctime'];
    this.openid = obj['openid'];
  }
}

class PayRecordOR {
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

  PayRecordOR({
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

  PayRecordOR.parse(obj){
    this.sn=obj['sn'];
    this.payer=obj['payer'];
    this.payerName=obj['payerName'];
    this.payee=obj['payee'];
    this.payeeName=obj['payeeName'];
    this.currency=obj['currency'];
    this.amount=obj['amount'];
    this.state=obj['state'];
    this.ctime=obj['ctime'];
    this.status=obj['status'];
    this.message=obj['message'];
    this.note=obj['note'];
  }
}
class PayPersonOR extends PayRecordOR{
  FissionMFPerson person;

  PayPersonOR({this.person});

  PayPersonOR.parse(obj):super.parse(obj){
    this.person=FissionMFPerson.parse(obj['person']);
  }
}
mixin IFissionMFCashierRecordRemote {
  Future<int> totalPayee() {}

  Future<int> totalPayer() {}

  Future<int> totalPayeeOfDay(String format) {}

  Future<int> totalPayerOnDay(String timeStr) {}

  Future<List<PayPersonOR>> pagePayeeDetails(int limit, int offset) {}

  Future<List<PayPersonOR>> pagePayerDetails(int limit, int offset) {}

  Future<List<FissionMFPerson>> pagePayeeInfo(int limit, int offset) {}

  Future<List<FissionMFPerson>> pagePayerInfo(int limit, int offset) {}
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
  Future<int> totalPayee() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayee',
      parameters: {},
    );
  }

  @override
  Future<int> totalPayer() async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayer',
      parameters: {},
    );
  }

  @override
  Future<int> totalPayeeOfDay(String day) async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayeeOfDay',
      parameters: {'dayTime': day},
    );
  }

  @override
  Future<int> totalPayerOnDay(String timeStr) async {
    return await remotePorts.portGET(
      fissionMfRecordPorts,
      'totalPayerOnDay',
      parameters: {'dayTime': timeStr},
    );
  }

  @override
  Future<List<PayPersonOR>> pagePayeeDetails(int limit, int offset) async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayeeDetails',
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
      'pagePayerDetails',
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
  Future<List<FissionMFPerson>> pagePayerInfo(int limit, int offset)async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayerInfo',
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
  Future<List<FissionMFPerson>> pagePayeeInfo(int limit, int offset)async {
    var list = await remotePorts.portGET(
      fissionMfRecordPorts,
      'pagePayeeInfo',
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
}
