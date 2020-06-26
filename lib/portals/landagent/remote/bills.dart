import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class WenyStockBillOR {
  String sn;
  String title;
  String participant;
  String bankid;
  int order;
  double stock;
  double balance;
  String refsn;
  String ctime;
  String note;
  String workday;
  int day;
  int month;
  int weekday;
  int season;
  int year;

  WenyStockBillOR(
      {this.sn,
      this.title,
      this.participant,
      this.bankid,
      this.order,
      this.stock,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.workday,
      this.day,
      this.month,
      this.weekday,
      this.season,
      this.year});
}

class WenyFundBillOR {
  String sn;
  String title;
  String participant;
  String bankid;
  int order;
  int amount;
  int balance;
  String refsn;
  String ctime;
  String note;
  String workday;
  int day;
  int month;
  int weekday;
  int season;
  int year;

  WenyFundBillOR(
      {this.sn,
      this.title,
      this.participant,
      this.bankid,
      this.order,
      this.amount,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.workday,
      this.day,
      this.month,
      this.weekday,
      this.season,
      this.year});
}

mixin IWenyBillRemote {
  Future<List<WenyStockBillOR>> pageStockBillOfMonth(
      String bankid, DateTime dateTime, int order, int limit, int offset) {}

  Future<List<WenyStockBillOR>> getStockBillOfMonth(
      String bankid, DateTime dateTime, int limit, int offset) {}

  Future<double> totalInStockBillOfMonth(String id, DateTime selected) {}

  Future<double> totalOutStockBillOfMonth(String id, DateTime selected) {}

  Future<List<WenyFundBillOR>> pageFundBillOfMonth(
      String bankid, DateTime dateTime, int order, int limit, int offset) {}

  Future<List<WenyFundBillOR>> getFundBillOfMonth(
      String bankid, DateTime dateTime, int limit, int offset) {}

  Future<double> totalInFundBillOfMonth(String id, DateTime selected) {}

  Future<double> totalOutFundBillOfMonth(String id, DateTime selected) {}
}

class WenyBillRemote implements IWenyBillRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get stockPorts => site.getService('@.prop.ports.wybank.bill.stock');

  get fundPorts => site.getService('@.prop.ports.wybank.bill.fund');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<WenyStockBillOR>> pageStockBillOfMonth(String bankid,
      DateTime dateTime, int order, int limit, int offset) async {
    var list = await remotePorts.portGET(
      stockPorts,
      'pageBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'order': order,
        'year': dateTime.year,
        'month': dateTime.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <WenyStockBillOR>[];
    for (var obj in list) {
      items.add(WenyStockBillOR(
        stock: obj['stock'],
        note: obj['note'],
        bankid: obj['bankid'],
        sn: obj['sn'],
        ctime: obj['ctime'],
        title: obj['title'],
        balance: obj['balance'],
        day: obj['day'],
        month: obj['month'],
        order: obj['order'],
        participant: obj['participant'],
        refsn: obj['refsn'],
        season: obj['season'],
        weekday: obj['weekday'],
        workday: obj['workday'],
        year: obj['year'],
      ));
    }
    return items;
  }

  @override
  Future<List<WenyStockBillOR>> getStockBillOfMonth(
      String bankid, DateTime dateTime, int limit, int offset) async {
    var list = await remotePorts.portGET(
      stockPorts,
      'getBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': dateTime.year,
        'month': dateTime.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <WenyStockBillOR>[];
    for (var obj in list) {
      items.add(WenyStockBillOR(
        stock: obj['stock'],
        note: obj['note'],
        bankid: obj['bankid'],
        sn: obj['sn'],
        ctime: obj['ctime'],
        title: obj['title'],
        balance: obj['balance'],
        day: obj['day'],
        month: obj['month'],
        order: obj['order'],
        participant: obj['participant'],
        refsn: obj['refsn'],
        season: obj['season'],
        weekday: obj['weekday'],
        workday: obj['workday'],
        year: obj['year'],
      ));
    }
    return items;
  }

  @override
  Future<double> totalInStockBillOfMonth(
      String bankid, DateTime dateTime) async {
    var value = await remotePorts.portGET(
      stockPorts,
      'totalInBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': dateTime.year,
        'month': dateTime.month - 1,
      },
    );
    return double.parse('$value');
  }

  @override
  Future<double> totalOutStockBillOfMonth(
      String bankid, DateTime dateTime) async {
    var value = await remotePorts.portGET(
      stockPorts,
      'totalOutBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': dateTime.year,
        'month': dateTime.month - 1,
      },
    );
    return double.parse('$value');
  }

  @override
  Future<List<WenyFundBillOR>> pageFundBillOfMonth(String bankid,
      DateTime dateTime, int order, int limit, int offset) async {
    var list = await remotePorts.portGET(
      fundPorts,
      'pageBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'order': order,
        'year': dateTime.year,
        'month': dateTime.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <WenyFundBillOR>[];
    for (var obj in list) {
      items.add(WenyFundBillOR(
        amount: obj['amount'],
        note: obj['note'],
        bankid: obj['bankid'],
        sn: obj['sn'],
        ctime: obj['ctime'],
        title: obj['title'],
        balance: obj['balance'],
        day: obj['day'],
        month: obj['month'],
        order: obj['order'],
        participant: obj['participant'],
        refsn: obj['refsn'],
        season: obj['season'],
        weekday: obj['weekday'],
        workday: obj['workday'],
        year: obj['year'],
      ));
    }
    return items;
  }

  @override
  Future<List<WenyFundBillOR>> getFundBillOfMonth(
      String bankid, DateTime dateTime, int limit, int offset) async {
    var list = await remotePorts.portGET(
      fundPorts,
      'getBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': dateTime.year,
        'month': dateTime.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <WenyFundBillOR>[];
    for (var obj in list) {
      items.add(WenyFundBillOR(
        amount: obj['amount'],
        note: obj['note'],
        bankid: obj['bankid'],
        sn: obj['sn'],
        ctime: obj['ctime'],
        title: obj['title'],
        balance: obj['balance'],
        day: obj['day'],
        month: obj['month'],
        order: obj['order'],
        participant: obj['participant'],
        refsn: obj['refsn'],
        season: obj['season'],
        weekday: obj['weekday'],
        workday: obj['workday'],
        year: obj['year'],
      ));
    }
    return items;
  }

  @override
  Future<double> totalInFundBillOfMonth(
      String bankid, DateTime dateTime) async {
    var value = await remotePorts.portGET(
      fundPorts,
      'totalInBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': dateTime.year,
        'month': dateTime.month - 1,
      },
    );
    return double.parse('$value');
  }

  @override
  Future<double> totalOutFundBillOfMonth(
      String bankid, DateTime dateTime) async {
    var value = await remotePorts.portGET(
      fundPorts,
      'totalOutBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': dateTime.year,
        'month': dateTime.month - 1,
      },
    );
    return double.parse('$value');
  }
}
