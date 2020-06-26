import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:intl/intl.dart' as intl;

class PurchaseOR {
  String sn;
  String purchaser;
  String personName;
  String currency;
  int amount;
  double stock;
  double price;
  double ttm;
  String ptime;
  int state;
  String note;
  int serviceFee;
  int principalAmount;
  double feeRatio;
  double principalRatio;
  int tailAmount;
  double freeRatio;
  double reserveRatio;
  int freeAmount;
  int reserveAmount;
  String bankid;
  String device;
  String status;
  String message;
  String outTradeSn;
  String dtime;

  PurchaseOR({
    this.sn,
    this.purchaser,
    this.personName,
    this.currency,
    this.amount,
    this.stock,
    this.price,
    this.ttm,
    this.ptime,
    this.state,
    this.note,
    this.serviceFee,
    this.principalAmount,
    this.feeRatio,
    this.principalRatio,
    this.tailAmount,
    this.freeRatio,
    this.reserveRatio,
    this.freeAmount,
    this.reserveAmount,
    this.bankid,
    this.device,
    this.status,
    this.message,
    this.outTradeSn,
    this.dtime,
  });
}

class PurchaseActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  PurchaseActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class ExchangeOR {
  String sn;
  String exchanger;
  String personName;
  String currency;
  int amount;
  double stock;
  double price;
  double ttm;
  String refPurchase;
  int profit;
  int purchaseAmount;
  int principalAmount;
  int serviceFeeAmount;
  double purchasePrice;
  String dtime;
  String ctime;
  int state;
  String note;
  String bankid;
  String status;
  String message;
  String outTradeSn;

  ExchangeOR({
    this.sn,
    this.exchanger,
    this.personName,
    this.currency,
    this.amount,
    this.stock,
    this.price,
    this.ttm,
    this.refPurchase,
    this.profit,
    this.purchaseAmount,
    this.principalAmount,
    this.serviceFeeAmount,
    this.purchasePrice,
    this.dtime,
    this.ctime,
    this.state,
    this.note,
    this.bankid,
    this.status,
    this.message,
    this.outTradeSn,
  });
}

mixin IWyBankRecordRemote {
  Future<List<PurchaseOR>> pagePurchase(
      String bankid, DateTime dateTime, int state, int limit, int offset) {}

  Future<List<ExchangeOR>> pageExchange(String id, DateTime selectedDateTime,
      int tabFilter, int limit, int offset) {}

  Future<PurchaseOR> getPurchaseRecord(String sn) {}
}

class WybankRecordRemote implements IWyBankRecordRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get recordsPorts => site.getService('@.prop.ports.wybank.records');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<PurchaseOR>> pagePurchase(String bankid, DateTime dateTime,
      int state, int limit, int offset) async {
    var list = await remotePorts.portGET(
      recordsPorts,
      'pagePurchaseRecordInMonth',
      parameters: {
        'wenyBankID': bankid,
        'monthText': intl.DateFormat('yyyyMM').format(dateTime),
        'state': state,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <PurchaseOR>[];
    for (var obj in list) {
      items.add(PurchaseOR(
        stock: obj['stock'],
        price: obj['price'],
        freeAmount: obj['freeAmount'],
        note: obj['note'],
        freeRatio: obj['freeRatio'],
        reserveRatio: obj['reserveRatio'],
        principalRatio: obj['principalRatio'],
        ttm: obj['ttm'],
        state: obj['state'],
        amount: obj['amount'],
        bankid: obj['bankid'],
        currency: obj['currency'],
        device: obj['device'],
        dtime: obj['dtime'],
        feeRatio: obj['feeRatio'],
        message: obj['message'],
        outTradeSn: obj['outTradeSn'],
        personName: obj['personName'],
        principalAmount: obj['principalAmount'],
        ptime: obj['ptime'],
        purchaser: obj['purchaser'],
        reserveAmount: obj['reserveAmount'],
        serviceFee: obj['serviceFee'],
        sn: obj['sn'],
        status: obj['status'],
        tailAmount: obj['tailAmount'],
      ));
    }
    return items;
  }

  @override
  Future<List<ExchangeOR>> pageExchange(String bankid, DateTime dateTime,
      int state, int limit, int offset) async {
    var list = await remotePorts.portGET(
      recordsPorts,
      'pageExchangeRecordInMonth',
      parameters: {
        'wenyBankID': bankid,
        'monthText': intl.DateFormat('yyyyMM').format(dateTime),
        'state': state,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <ExchangeOR>[];
    for (var obj in list) {
      items.add(ExchangeOR(
        stock: obj['stock'],
        price: obj['price'],
        note: obj['note'],
        ttm: obj['ttm'],
        state: obj['state'],
        amount: obj['amount'],
        bankid: obj['bankid'],
        currency: obj['currency'],
        dtime: obj['dtime'],
        message: obj['message'],
        outTradeSn: obj['outTradeSn'],
        personName: obj['personName'],
        principalAmount: obj['principalAmount'],
        sn: obj['sn'],
        status: obj['status'],
        ctime: obj['ctime'],
        exchanger: obj['exchanger'],
        profit: obj['profit'],
        purchaseAmount: obj['purchaseAmount'],
        purchasePrice: obj['purchasePrice'],
        refPurchase: obj['refPurchase'],
        serviceFeeAmount: obj['serviceFeeAmount'],
      ));
    }
    return items;
  }

  @override
  Future<PurchaseOR> getPurchaseRecord(String sn) async {
    var obj = await remotePorts.portGET(
      recordsPorts,
      'getPurchaseRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    return PurchaseOR(
      stock: obj['stock'],
      price: obj['price'],
      freeAmount: obj['freeAmount'],
      note: obj['note'],
      freeRatio: obj['freeRatio'],
      reserveRatio: obj['reserveRatio'],
      principalRatio: obj['principalRatio'],
      ttm: obj['ttm'],
      state: obj['state'],
      amount: obj['amount'],
      bankid: obj['bankid'],
      currency: obj['currency'],
      device: obj['device'],
      dtime: obj['dtime'],
      feeRatio: obj['feeRatio'],
      message: obj['message'],
      outTradeSn: obj['outTradeSn'],
      personName: obj['personName'],
      principalAmount: obj['principalAmount'],
      ptime: obj['ptime'],
      purchaser: obj['purchaser'],
      reserveAmount: obj['reserveAmount'],
      serviceFee: obj['serviceFee'],
      sn: obj['sn'],
      status: obj['status'],
      tailAmount: obj['tailAmount'],
    );
  }
}
