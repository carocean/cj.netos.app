import 'package:framework/framework.dart';

class PurchaseOR {
  String sn;
  int purchAmount;
  double stock;
  double price;
  int serviceFee;
  double feeRatio;
  int state;
  String ctime;
  String note;
  String bankid;
  int status;
  String message;
  int principalAmount;
  double principalRatio;
  String bankPurchSn;
  int exchangeState;

  PurchaseOR({
    this.sn,
    this.purchAmount,
    this.stock,
    this.price,
    this.serviceFee,
    this.feeRatio,
    this.state,
    this.ctime,
    this.note,
    this.bankid,
    this.status,
    this.message,
    this.principalAmount,
    this.principalRatio,
    this.bankPurchSn,
    this.exchangeState,
  });
}

class ExchangeOR {
  String sn;
  int amount;
  double stock;
  double price;
  String refPurchase;
  int profit;
  String ctime;
  String dtime;
  int purchAmount;
  String note;
  String bankid;
  int state;
  int status;
  String message;
  String bankPurchNo;

  ExchangeOR({
    this.sn,
    this.amount,
    this.stock,
    this.price,
    this.refPurchase,
    this.profit,
    this.ctime,
    this.dtime,
    this.purchAmount,
    this.note,
    this.bankid,
    this.state,
    this.status,
    this.message,
    this.bankPurchNo,
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

class ExchangeActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  ExchangeActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class RechargeOR {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int realAmount;
  String fromChannel;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;

  RechargeOR(
      {this.sn,
      this.person,
      this.personName,
      this.currency,
      this.demandAmount,
      this.realAmount,
      this.fromChannel,
      this.state,
      this.ctime,
      this.lutime,
      this.status,
      this.message,
      this.note});
}
class RechargeActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  RechargeActivityOR(
      {this.activityNo,
        this.activityName,
        this.record_sn,
        this.status,
        this.message,
        this.ctime,
        this.id});
}

class WithdrawOR {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int realAmount;
  String toChannel;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;

  WithdrawOR(
      {this.sn,
      this.person,
      this.personName,
      this.currency,
      this.demandAmount,
      this.realAmount,
      this.toChannel,
      this.state,
      this.ctime,
      this.lutime,
      this.status,
      this.message,
      this.note});
}
class WithdrawActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  WithdrawActivityOR(
      {this.activityNo,
        this.activityName,
        this.record_sn,
        this.status,
        this.message,
        this.ctime,
        this.id});
}
mixin IWalletRecordRemote {
  Future<List<PurchaseOR>> pagePurchase(String bankid, int limit, int offset) {}

  Future<List<ExchangeOR>> pageExchange(String bankid, int limit, int offset) {}

  Future<List<PurchaseActivityOR>> getPurchaseActivies(String sn) {}

  Future<ExchangeOR> getExchangeRecord(String sn) {}

  Future<List<PurchaseOR>> pagePurchaseUnExchange(
      String bankid, int limit, int offset) {}

  Future<List<PurchaseOR>> pagePurchaseExchanged(
      String bankid, int limit, int offset) {}

  Future<List<ExchangeActivityOR>> getExchangeActivies(String sn) {}

  Future<PurchaseOR> getPurchaseRecord(String refPurchase) {}

  Future<RechargeOR> getRechargeRecord(String refsn) {}

  Future<List<RechargeActivityOR>> getRechargeActivies(String sn) {}

  Future<WithdrawOR> getWithdrawRecord(String refsn) {}

  Future<List<WithdrawActivityOR>> getWithdrawActivies(String sn) {}
}

class WalletRecordRemote implements IWalletRecordRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletRecordPorts => site.getService('@.prop.ports.wallet.record');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<PurchaseActivityOR>> getPurchaseActivies(String sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getPurchaseActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<PurchaseActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        PurchaseActivityOR(
          id: obj['id'],
          ctime: obj['ctime'],
          status: obj['status'],
          message: obj['message'],
          activityName: obj['activityName'],
          activityNo: obj['activityNo'],
          record_sn: obj['recordSn'],
        ),
      );
    }
    return activities;
  }

  @override
  Future<List<ExchangeActivityOR>> getExchangeActivies(String sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getExchangeActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<ExchangeActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        ExchangeActivityOR(
          id: obj['id'],
          ctime: obj['ctime'],
          status: obj['status'],
          message: obj['message'],
          activityName: obj['activityName'],
          activityNo: obj['activityNo'],
          record_sn: obj['recordSn'],
        ),
      );
    }
    return activities;
  }

  @override
  Future<List<PurchaseOR>> pagePurchase(
      String bankid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'pagePurchaseRecord',
      parameters: {
        'wenyBankID': bankid,
        'limit': limit,
        'offset': offset,
      },
    );
    var purchases = <PurchaseOR>[];
    for (var obj in list) {
      purchases.add(
        PurchaseOR(
          ctime: obj['ctime'],
          state: obj['state'],
          stock: obj['stock'],
          message: obj['message'],
          bankid: obj['bankid'],
          bankPurchSn: obj['bankPurchSn'],
          exchangeState: obj['exchangeState'],
          feeRatio: obj['feeRatio'],
          note: obj['note'],
          price: obj['price'],
          principalAmount: obj['principalAmount'],
          principalRatio: obj['principalRatio'],
          purchAmount: obj['purchAmount'],
          serviceFee: obj['serviceFee'],
          sn: obj['sn'],
          status: obj['status'],
        ),
      );
    }
    return purchases;
  }

  @override
  Future<List<PurchaseOR>> pagePurchaseExchanged(
      String bankid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'pagePurchaseRecordOfExchanged',
      parameters: {
        'wenyBankID': bankid,
        'limit': limit,
        'offset': offset,
      },
    );
    var purchases = <PurchaseOR>[];
    for (var obj in list) {
      purchases.add(
        PurchaseOR(
          ctime: obj['ctime'],
          state: obj['state'],
          stock: obj['stock'],
          message: obj['message'],
          bankid: obj['bankid'],
          bankPurchSn: obj['bankPurchSn'],
          exchangeState: obj['exchangeState'],
          feeRatio: obj['feeRatio'],
          note: obj['note'],
          price: obj['price'],
          principalAmount: obj['principalAmount'],
          principalRatio: obj['principalRatio'],
          purchAmount: obj['purchAmount'],
          serviceFee: obj['serviceFee'],
          sn: obj['sn'],
          status: obj['status'],
        ),
      );
    }
    return purchases;
  }

  @override
  Future<List<PurchaseOR>> pagePurchaseUnExchange(
      String bankid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'pagePurchaseRecordOfUnexchanged',
      parameters: {
        'wenyBankID': bankid,
        'limit': limit,
        'offset': offset,
      },
    );
    var purchases = <PurchaseOR>[];
    for (var obj in list) {
      purchases.add(
        PurchaseOR(
          ctime: obj['ctime'],
          state: obj['state'],
          stock: obj['stock'],
          message: obj['message'],
          bankid: obj['bankid'],
          bankPurchSn: obj['bankPurchSn'],
          exchangeState: obj['exchangeState'],
          feeRatio: obj['feeRatio'],
          note: obj['note'],
          price: obj['price'],
          principalAmount: obj['principalAmount'],
          principalRatio: obj['principalRatio'],
          purchAmount: obj['purchAmount'],
          serviceFee: obj['serviceFee'],
          sn: obj['sn'],
          status: obj['status'],
        ),
      );
    }
    return purchases;
  }

  @override
  Future<List<ExchangeOR>> pageExchange(
      String bankid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'pageExchangeRecord',
      parameters: {
        'wenyBankID': bankid,
        'limit': limit,
        'offset': offset,
      },
    );
    var exchanges = <ExchangeOR>[];
    for (var obj in list) {
      exchanges.add(
        ExchangeOR(
          ctime: obj['ctime'],
          dtime: obj['lutime'],
          state: obj['state'],
          stock: obj['stock'],
          message: obj['message'],
          bankid: obj['bankid'],
          bankPurchNo: obj['bankPurchNo'],
          note: obj['note'],
          price: obj['price'],
          purchAmount: obj['purchAmount'],
          sn: obj['sn'],
          status: obj['status'],
          profit: obj['profit'],
          amount: obj['amount'],
          refPurchase: obj['refsn'],
        ),
      );
    }
    return exchanges;
  }

  @override
  Future<PurchaseOR> getPurchaseRecord(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getPurchaseRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    return PurchaseOR(
      ctime: obj['ctime'],
      state: obj['state'],
      stock: obj['stock'],
      message: obj['message'],
      bankid: obj['bankid'],
      bankPurchSn: obj['bankPurchSn'],
      exchangeState: obj['exchangeState'],
      feeRatio: obj['feeRatio'],
      note: obj['note'],
      price: obj['price'],
      principalAmount: obj['principalAmount'],
      principalRatio: obj['principalRatio'],
      purchAmount: obj['purchAmount'],
      serviceFee: obj['serviceFee'],
      sn: obj['sn'],
      status: obj['status'],
    );
  }

  @override
  Future<ExchangeOR> getExchangeRecord(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getExchangeRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    return ExchangeOR(
      ctime: obj['ctime'],
      dtime: obj['lutime'],
      state: obj['state'],
      stock: obj['stock'],
      message: obj['message'],
      bankid: obj['bankid'],
      bankPurchNo: obj['bankPurchNo'],
      note: obj['note'],
      price: obj['price'],
      purchAmount: obj['purchAmount'],
      sn: obj['sn'],
      status: obj['status'],
      profit: obj['profit'],
      amount: obj['amount'],
      refPurchase: obj['refsn'],
    );
  }

  @override
  Future<WithdrawOR> getWithdrawRecord(String refsn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getWithdrawRecord',
      parameters: {
        'record_sn': refsn,
      },
    );
    return WithdrawOR(
      ctime: obj['ctime'],
      lutime: obj['lutime'],
      state: obj['state'],
      message: obj['message'],
      note: obj['note'],
      sn: obj['sn'],
      status: obj['status'],
      personName: obj['personName'],
      currency: obj['currency'],
      person: obj['person'],
      demandAmount: obj['demandAmount'] ,
      realAmount: obj['realAmount'] ,
      toChannel: obj['toChannel'],
    );
  }

  @override
  Future<RechargeOR> getRechargeRecord(String refsn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getRechargeRecord',
      parameters: {
        'record_sn': refsn,
      },
    );
    return RechargeOR(
      ctime: obj['ctime'],
      lutime: obj['lutime'],
      state: obj['state'],
      message: obj['message'],
      note: obj['note'],
      sn: obj['sn'],
      status: obj['status'],
      personName: obj['personName'],
      currency: obj['currency'],
      person: obj['person'],
      demandAmount: obj['demandAmount'] ,
      realAmount: obj['realAmount'],
      fromChannel: obj['fromChannel'],
    );
  }

  @override
  Future<List<WithdrawActivityOR>> getWithdrawActivies(String sn) async{
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getWithdrawActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<WithdrawActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        WithdrawActivityOR(
          id: obj['id'],
          ctime: obj['ctime'],
          status: obj['status'],
          message: obj['message'],
          activityName: obj['activityName'],
          activityNo: obj['activityNo'],
          record_sn: obj['recordSn'],
        ),
      );
    }
    return activities;
  }

  @override
  Future<List<RechargeActivityOR>> getRechargeActivies(String sn) async{
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getRechargeActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<RechargeActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        RechargeActivityOR(
          id: obj['id'],
          ctime: obj['ctime'],
          status: obj['status'],
          message: obj['message'],
          activityName: obj['activityName'],
          activityNo: obj['activityNo'],
          record_sn: obj['recordSn'],
        ),
      );
    }
    return activities;
  }
}
