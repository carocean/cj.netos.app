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

class TransAbsorbOR {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int realAmount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;

  TransAbsorbOR(
      {this.sn,
      this.person,
      this.personName,
      this.currency,
      this.demandAmount,
      this.realAmount,
      this.state,
      this.ctime,
      this.lutime,
      this.status,
      this.message,
      this.note});
}

class DepositAbsorbOR {
  String sn;
  String person;
  String personName;
  String currency;
  double demandAmount;
  double realAmount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;
  String sourceCode;
  String sourceTitle;

  DepositAbsorbOR({
    this.sn,
    this.person,
    this.personName,
    this.currency,
    this.demandAmount,
    this.realAmount,
    this.state,
    this.ctime,
    this.lutime,
    this.status,
    this.message,
    this.note,
    this.sourceCode,
    this.sourceTitle,
  });
}

class TransProfitOR {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int realAmount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;
  String bankid;

  TransProfitOR({
    this.sn,
    this.person,
    this.personName,
    this.currency,
    this.demandAmount,
    this.realAmount,
    this.state,
    this.ctime,
    this.lutime,
    this.status,
    this.message,
    this.note,
    this.bankid,
  });
}

class TransAbsorbActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  TransAbsorbActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class TransProfitActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  TransProfitActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class DepositProfitActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  DepositProfitActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class TransShunterOR {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int realAmount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;
  String bankid;
  String shunter;

  TransShunterOR(
      {this.sn,
      this.person,
      this.personName,
      this.currency,
      this.demandAmount,
      this.realAmount,
      this.state,
      this.ctime,
      this.lutime,
      this.status,
      this.message,
      this.note,
      this.bankid,
      this.shunter});
}

class TransShunterActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  TransShunterActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class DepositHubTailsOR {
  String sn;
  String person;
  String personName;
  String currency;
  int amount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;
  String bankid;

  DepositHubTailsOR({
    this.sn,
    this.person,
    this.personName,
    this.currency,
    this.amount,
    this.state,
    this.ctime,
    this.lutime,
    this.status,
    this.message,
    this.note,
    this.bankid,
  });
}

class DepositHubTailsActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  DepositHubTailsActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class PayOR {
  String sn;
  String person;
  String personName;
  String currency;
  int amount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  String note;
  PayDetailsOR details;

  PayOR({
    this.sn,
    this.person,
    this.personName,
    this.currency,
    this.amount,
    this.state,
    this.ctime,
    this.lutime,
    this.status,
    this.message,
    this.note,
    this.details,
  });
}

class PayDetailsOR {
  String id;
  String payeeCode;
  String payeeName;
  String payeeType;
  String orderNo;
  String orderTitle;
  String serviceId;
  String serviceName;
  String note;
  String paySn;

  PayDetailsOR(
      {this.id,
      this.payeeCode,
      this.payeeName,
      this.payeeType,
      this.orderNo,
      this.orderTitle,
      this.serviceId,
      this.serviceName,
      this.note,
      this.paySn});
}

class PayActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  PayActivityOR(
      {this.activityNo,
      this.activityName,
      this.record_sn,
      this.status,
      this.message,
      this.ctime,
      this.id});
}

class P2PRecordOR {
  String sn;
  String payer;
  String payerName;
  String payee;
  String payeeName;
  String currency;
  int amount;
  int state;
  String ctime;
  String lutime;
  int status;
  String message;
  int type;
  String direct;

  P2PRecordOR({
    this.sn,
    this.payer,
    this.payerName,
    this.payee,
    this.payeeName,
    this.currency,
    this.amount,
    this.state,
    this.ctime,
    this.lutime,
    this.status,
    this.message,
    this.type,
    this.direct,
  });
}

class P2PActivityOR {
  int activityNo;
  String activityName;
  String record_sn;
  int status;
  String message;
  String ctime;
  String id;

  P2PActivityOR(
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

  Future<TransAbsorbOR> getTransAbsorb(String sn) {}

  Future<TransProfitOR> getTransProfit(sn) {}

  Future<List<TransAbsorbActivityOR>> getTransAbsorbActivies(String sn) {}

  Future<List<TransProfitActivityOR>> getTransProfitActivies(String sn) {}

  Future<List<DepositProfitActivityOR>> getDepositAbsorbActivies(sn) {}

  Future<DepositAbsorbOR> getDepositAbsorb(String refsn) {}

  Future<TransShunterOR> getTransShunter(String sn) {}

  Future<List<TransShunterActivityOR>> getTransShunterActivies(sn) {}

  Future<DepositHubTailsOR> getDepositHubTails(String sn) {}

  Future<List<DepositHubTailsActivityOR>> getDepositHubTailsActivies(sn) {}

  Future<PayOR> getPayTrade(String sn) {}

  Future<PayDetailsOR> getPayDetails(String sn) {}

  Future<List<PayActivityOR>> getPayActivies(sn) {}

  Future<P2PRecordOR> getP2PRecord(String sn) {}

  Future<List<P2PActivityOR>> getP2PActivities(sn) {}
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
    if (obj == null) {
      return null;
    }
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
    if (obj == null) {
      return null;
    }
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
      demandAmount: obj['demandAmount'],
      realAmount: obj['realAmount'],
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
    if (obj == null) {
      return null;
    }
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
      demandAmount: obj['demandAmount'],
      realAmount: obj['realAmount'],
      fromChannel: obj['fromChannel'],
    );
  }

  @override
  Future<List<WithdrawActivityOR>> getWithdrawActivies(String sn) async {
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
  Future<List<RechargeActivityOR>> getRechargeActivies(String sn) async {
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

  @override
  Future<TransAbsorbOR> getTransAbsorb(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getTransAbsorbRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return TransAbsorbOR(
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
      demandAmount: obj['demandAmount'],
      realAmount: obj['realAmount'],
    );
  }

  @override
  Future<TransProfitOR> getTransProfit(sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getTransProfitRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return TransProfitOR(
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
      demandAmount: obj['demandAmount'],
      realAmount: obj['realAmount'],
      bankid: obj['bankid'],
    );
  }

  @override
  Future<List<TransAbsorbActivityOR>> getTransAbsorbActivies(String sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getTransAbsorbActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<TransAbsorbActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        TransAbsorbActivityOR(
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
  Future<List<TransProfitActivityOR>> getTransProfitActivies(String sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getTransProfitActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<TransProfitActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        TransProfitActivityOR(
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
  Future<List<DepositProfitActivityOR>> getDepositAbsorbActivies(sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getDepositAbsorbActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<DepositProfitActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        DepositProfitActivityOR(
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
  Future<DepositAbsorbOR> getDepositAbsorb(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getDepositAbsorbRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return DepositAbsorbOR(
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
      demandAmount: obj['demandAmount'],
      realAmount: obj['realAmount'],
      sourceCode: obj['sourceCode'],
      sourceTitle: obj['sourceTitle'],
    );
  }

  @override
  Future<TransShunterOR> getTransShunter(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getTransShunterRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return TransShunterOR(
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
      demandAmount: obj['demandAmount'],
      realAmount: obj['realAmount'],
      shunter: obj['shunter'],
      bankid: obj['bankid'],
    );
  }

  @override
  Future<List<TransShunterActivityOR>> getTransShunterActivies(sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getTransShunterActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<TransShunterActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        TransShunterActivityOR(
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
  Future<DepositHubTailsOR> getDepositHubTails(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getDepositHubTailsRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return DepositHubTailsOR(
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
      amount: obj['amount'],
      bankid: obj['bankid'],
    );
  }

  @override
  Future<List<DepositHubTailsActivityOR>> getDepositHubTailsActivies(sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getDepositHubTailsActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<DepositHubTailsActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        DepositHubTailsActivityOR(
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
  Future<List<PayActivityOR>> getPayActivies(sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getPayActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<PayActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        PayActivityOR(
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
  Future<PayDetailsOR> getPayDetails(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getPayDetails',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return PayDetailsOR(
      note: obj['note'],
      id: obj['id'],
      orderNo: obj['orderNo'],
      orderTitle: obj['orderTitle'],
      payeeCode: obj['payeeCode'],
      payeeName: obj['payeeName'],
      payeeType: obj['payeeType'],
      paySn: obj['paySn'],
      serviceId: obj['serviceId'],
      serviceName: obj['serviceName'],
    );
  }

  @override
  Future<PayOR> getPayTrade(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getPayRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    var detailsMap = obj['details'];
    var details;
    if (detailsMap != null) {
      details = PayDetailsOR(
        note: detailsMap['note'],
        id: detailsMap['id'],
        orderNo: detailsMap['orderNo'],
        orderTitle: detailsMap['orderTitle'],
        payeeCode: detailsMap['payeeCode'],
        payeeName: detailsMap['payeeName'],
        payeeType: detailsMap['payeeType'],
        paySn: detailsMap['paySn'],
        serviceId: detailsMap['serviceId'],
        serviceName: detailsMap['serviceName'],
      );
    }
    return PayOR(
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
      amount: obj['amount'],
      details: details,
    );
  }

  @override
  Future<List<P2PActivityOR>> getP2PActivities(sn) async {
    var list = await remotePorts.portGET(
      walletRecordPorts,
      'getP2PActivities',
      parameters: {
        'record_sn': sn,
      },
    );
    List<P2PActivityOR> activities = [];
    for (var obj in list) {
      activities.add(
        P2PActivityOR(
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
  Future<P2PRecordOR> getP2PRecord(String sn) async {
    var obj = await remotePorts.portGET(
      walletRecordPorts,
      'getP2PRecord',
      parameters: {
        'record_sn': sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return P2PRecordOR(
      payeeName: obj['payeeName'],
      amount: obj['amount'],
      ctime: obj['ctime'],
      sn: obj['sn'],
      message: obj['message'],
      status: obj['status'],
      state: obj['state'],
      type: obj['type'],
      currency: obj['currency'],
      direct: obj['direct'],
      lutime: obj['lutime'],
      payee: obj['payee'],
      payer: obj['payer'],
      payerName: obj['payerName'],
    );
  }
}
