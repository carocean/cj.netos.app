import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class CashierBillOR {
  String sn;
  String title;
  String person;
  String nickName;
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

  CashierBillOR({
    this.sn,
    this.title,
    this.person,
    this.nickName,
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

  CashierBillOR.parse(obj) {
    this.sn = obj['sn'];
    this.title = obj['title'];
    this.person = obj['person'];
    this.nickName = obj['nickName'];
    this.amount = obj['amount'];
    this.balance = obj['balance'];
    this.order = obj['order'];
    this.refsn = obj['refsn'];
    this.ctime = obj['ctime'];
    this.workday = obj['workday'];
    this.day = obj['day'];
    this.month = obj['month'];
    this.season = obj['season'];
    this.year = obj['year'];
    this.note = obj['note'];
  }
}

mixin IFissionMFCashierBillRemote {
  Future<int> totalBillOfMonthByOrder(int order, int year, int month) {}

  Future<List<CashierBillOR>> pageBillByOrder(
      int order, int limit, int offset) {}

  Future<List<CashierBillOR>> pageBillOfMonth(
      int order, int year, int month, int limit, int offset) {}

  Future<List<CashierBillOR>> getBillOfMonth(
      int year, int month, int limit, int offset) {}

  Future<int>totalBillOfDayByOrder(int order, int year, int month, int day) {}

}

class FissionMFCashierBillRemote
    implements IFissionMFCashierBillRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get fissionMfCashierPorts =>
      site.getService('@.prop.ports.fission.mf.cashier');

  get fissionMfReceiptPorts =>
      site.getService('@.prop.ports.fission.mf.receipt');

  get fissionMfBillPorts =>
      site.getService('@.prop.ports.fission.mf.cashier.bill');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<int> totalBillOfMonthByOrder(int order, int year, int month) async {
    return await remotePorts.portPOST(
      fissionMfBillPorts,
      'totalBillOfMonthByOrder',
      parameters: {
        'order': order,
        'year': year,
        'month': month,
      },
    );
  }

  @override
  Future<List<CashierBillOR>> pageBillByOrder(
      int order, int limit, int offset) async {
    var list = await remotePorts.portPOST(
      fissionMfBillPorts,
      'pageBillByOrder',
      parameters: {
        'order': order,
        'limit': limit,
        'offset': offset,
      },
    );
    List<CashierBillOR> bills = [];
    for (var obj in list) {
      bills.add(CashierBillOR.parse(obj));
    }
    return bills;
  }

  @override
  Future<List<CashierBillOR>> pageBillOfMonth(
      int order, int year, int month, int limit, int offset) async {
    var list = await remotePorts.portPOST(
      fissionMfBillPorts,
      'pageBillOfMonth',
      parameters: {
        'order': order,
        'year': year,
        'month': month,
        'limit': limit,
        'offset': offset,
      },
    );
    List<CashierBillOR> bills = [];
    for (var obj in list) {
      bills.add(CashierBillOR.parse(obj));
    }
    return bills;
  }

  @override
  Future<List<CashierBillOR>> getBillOfMonth(
      int year, int month, int limit, int offset) async {
    var list = await remotePorts.portPOST(
      fissionMfBillPorts,
      'getBillOfMonth',
      parameters: {
        'year': year,
        'month': month,
        'limit': limit,
        'offset': offset,
      },
    );
    List<CashierBillOR> bills = [];
    for (var obj in list) {
      bills.add(CashierBillOR.parse(obj));
    }
    return bills;
  }

  @override
  Future<int> totalBillOfDayByOrder(int order, int year, int month, int day) async{
    return await remotePorts.portPOST(
      fissionMfBillPorts,
      'totalBillOfDayByOrder',
      parameters: {
        'order':order,
        'year':year,
        'month':month,
        'day':day,
      },
    );
  }
}
