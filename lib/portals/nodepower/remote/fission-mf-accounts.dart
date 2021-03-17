import 'package:framework/framework.dart';

class FissionMFAccountOR {
  int balance;
  String account;

  FissionMFAccountOR({this.balance, this.account});

  FissionMFAccountOR.parse(obj) {
    this.balance = obj['balance'];
    this.account = obj['account'];
  }
}

class BusinessBillOR {
  String sn;
  String title;
  String person;
  String nickName;
  String account;
  int amount;
  int balance;
  int order;
  String refsn;
  String ctime;
  String workday;
  int day;
  int month;
  int season;
  int year;
  String note;

  BusinessBillOR({
    this.sn,
    this.title,
    this.person,
    this.nickName,
    this.account,
    this.amount,
    this.balance,
    this.order,
    this.refsn,
    this.ctime,
    this.workday,
    this.day,
    this.month,
    this.season,
    this.year,
    this.note,
  });

  BusinessBillOR.parse(obj){
    this.sn=obj['sn'];
    this.title=obj['title'];
    this.person=obj['person'];
    this.nickName=obj['nickName'];
    this.account=obj['account'];
    this.amount=obj['amount'];
    this.balance=obj['balance'];
    this.order=obj['order'];
    this.refsn=obj['refsn'];
    this.ctime=obj['ctime'];
    this.workday=obj['workday'];
    this.day=obj['day'];
    this.month=obj['month'];
    this.season=obj['season'];
    this.year=obj['year'];
    this.note=obj['note'];
  }
}

mixin IFissionMFAccountRemote {
  Future<FissionMFAccountOR> getAbsorbAccount();

  Future<FissionMFAccountOR> getBusinessAccount();

  Future<FissionMFAccountOR> getIncomeAccount();

  Future<List<FissionMFAccountOR>> listAccount();

  Future<List<BusinessBillOR>> pageBusinessBill(
      int order, int limit, int offset);
}

class FissionMFAccountRemote
    implements IFissionMFAccountRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get accountPorts => site.getService('@.prop.ports.fission.mf.account');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<FissionMFAccountOR> getAbsorbAccount() async {
    var obj = await remotePorts.portGET(
      accountPorts,
      'getAbsorbAccount',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return FissionMFAccountOR.parse(obj);
  }

  @override
  Future<FissionMFAccountOR> getBusinessAccount() async {
    var obj = await remotePorts.portGET(
      accountPorts,
      'getBusinessAccount',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return FissionMFAccountOR.parse(obj);
  }

  @override
  Future<FissionMFAccountOR> getIncomeAccount() async {
    var obj = await remotePorts.portGET(
      accountPorts,
      'getIncomeAccount',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return FissionMFAccountOR.parse(obj);
  }

  @override
  Future<List<FissionMFAccountOR>> listAccount() async {
    var list = await remotePorts.portGET(
      accountPorts,
      'listAccount',
      parameters: {},
    );
    List<FissionMFAccountOR> accounts = [];
    for (var obj in list) {
      accounts.add(FissionMFAccountOR.parse(obj));
    }
    return accounts;
  }

  @override
  Future<List<BusinessBillOR>> pageBusinessBill(
      int order, int limit, int offset) async {
    var list = await remotePorts.portGET(
      accountPorts,
      'pageBusinessBill',
      parameters: {
        'order': order,
        'limit': limit,
        'offset': offset,
      },
    );
    List<BusinessBillOR> bills = [];
    for (var obj in list) {
      bills.add(BusinessBillOR.parse(obj));
    }
    return bills;
  }
}
