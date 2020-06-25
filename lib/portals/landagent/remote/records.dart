import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

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

mixin IWyBankRecordRemote {
  Future<List<PurchaseOR>> pagePurchase(
      String bankid, int state, int limit, int offset) {}
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
  Future<List<PurchaseOR>> pagePurchase(
      String bankid, int state, int limit, int offset) async {
    var list = await remotePorts.portGET(
      recordsPorts,
      'pagePurchaseRecordByState',
      parameters: {
        'wenyBankID': bankid,
        'state': state,
        'limit': limit,
        'offset': offset,
      },
    );
    var items=<PurchaseOR>[];
    for(var obj in list) {
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
}
