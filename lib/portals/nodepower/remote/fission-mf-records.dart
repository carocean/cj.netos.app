import 'package:framework/framework.dart';

class BusinessInRecord {
  String sn;

  String person;

  String nickName;

  String currency;

  int amount;

  int state;

  int shuntState;

  String refsn;

  String salesman;

  double shuntRatio;

  String ctime;

  int status;

  String message;

  String note;

  BusinessInRecord({
    this.sn,
    this.person,
    this.nickName,
    this.currency,
    this.amount,
    this.state,
    this.shuntState,
    this.refsn,
    this.salesman,
    this.shuntRatio,
    this.ctime,
    this.status,
    this.message,
    this.note,
  });

  BusinessInRecord.parse(obj) {
    this.sn = obj['sn'];
    this.person = obj['person'];
    this.nickName = obj['nickName'];
    this.currency = obj['currency'];
    this.amount = obj['amount'];
    this.state = obj['state'];
    this.shuntState = obj['shuntState'];
    this.refsn = obj['refsn'];
    this.salesman = obj['salesman'];
    this.shuntRatio = obj['shuntRatio'];
    this.ctime = obj['ctime'];
    this.status = obj['status'];
    this.message = obj['message'];
    this.note = obj['note'];
  }
}

mixin IFissionMFRecordRemote {
  Future<List<BusinessInRecord>> pageBusinessInRecord(
      int shuntState, int limit, int offset);
}

class FissionMFRecordRemote implements IFissionMFRecordRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get recordsPorts =>
      site.getService('@.prop.ports.fission.mf.account.records');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<BusinessInRecord>> pageBusinessInRecord(
      int shuntState, int limit, int offset) async {
    var list = await remotePorts.portGET(
      recordsPorts,
      'pageBusinessInRecord',
      parameters: {
        'shuntState': shuntState,
        'limit': limit,
        'offset': offset,
      },
    );
    List<BusinessInRecord> records = [];
    for (var obj in list) {
      records.add(BusinessInRecord.parse(obj));
    }
    return records;
  }
}
