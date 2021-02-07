import 'dart:convert';

import 'package:framework/framework.dart';
import 'package:uuid/uuid.dart';

class CashierBalanceOR {
  String person;
  int balance;

  CashierBalanceOR({this.person, this.balance});

  CashierBalanceOR.parse(obj) {
    this.person = obj['person'];
    this.balance = obj['balance'];
  }
}

class CashierOR {
  String person;
  int state;
  int type;
  int dayAmount;
  int cacAverage;
  double amplitudeFactor;
  String closedCause;

  CashierOR({
    this.person,
    this.state,
    this.type,
    this.dayAmount,
    this.cacAverage,
    this.amplitudeFactor,
    this.closedCause,
  });

  CashierOR.parse(obj) {
    this.person = obj['person'];
    this.state = obj['state'];
    this.type = obj['type'];
    this.dayAmount = obj['dayAmount'];
    this.cacAverage = obj['cacAverage'];
    this.amplitudeFactor = obj['amplitudeFactor'];
    this.closedCause = obj['closedCause'];
  }
}

mixin IFissionMFCashierRemote {
  Future<void> recharge(int amount);

  Future<CashierBalanceOR> getCashierBalance();

  Future<CashierOR> getCashier() {}

  Future<int> assessCacCount() {}

  Future<void> withdraw(int amount) {}

  Future<void> startCashier() {}
  Future<void> stopCashier(String closedCause){}
}

class FissionMFCashierRemote
    implements IFissionMFCashierRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletTradePorts => site.getService('@.prop.ports.wallet.trade.receipt');

  get fissionMfCashierPorts =>
      site.getService('@.prop.ports.fission.mf.cashier');

  get fissionMfReceiptPorts =>
      site.getService('@.prop.ports.fission.mf.receipt');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<void> recharge(int amount) async {
    var details = <String, dynamic>{
      "payeeCode": "${principal.person}",
      "payeeName": "${principal.nickName}",
      "payeeType": "fission-mf",
      "orderno": "${MD5Util.MD5(Uuid().v1())}",
      "orderTitle": "付款到${principal.nickName}的裂变游戏·交个朋友出纳柜台",
      "serviceid": "fission/mf",
      "serviceName": "裂变游戏·交个朋友",
      "note": "推广费"
    };
    await remotePorts.portPOST(
      walletTradePorts,
      'payTrade',
      parameters: {
        'amount': amount,
        'type': 1,
        'note': '付款给裂变游戏·交个朋友',
      },
      data: {
        'details': jsonEncode(details),
      },
    );
  }

  @override
  Future<CashierBalanceOR> getCashierBalance() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getCashierBalance',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return CashierBalanceOR.parse(obj);
  }

  @override
  Future<CashierOR> getCashier() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getCashier',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return CashierOR.parse(obj);
  }

  @override
  Future<int> assessCacCount() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'assessCacCount',
      parameters: {},
    );
    return obj;
  }

  @override
  Future<void> withdraw(int amount) async {
    await remotePorts.portPOST(
      fissionMfReceiptPorts,
      'withdraw',
      parameters: {
        'amount': amount,
      },
    );
  }

  @override
  Future<void> stopCashier(String closedCause)async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'stopCashier',
      parameters: {
        'closedCause':closedCause,
      },
    );
  }
  @override
  Future<void> startCashier()async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'startCashier',
      parameters: {},
    );
  }
}
