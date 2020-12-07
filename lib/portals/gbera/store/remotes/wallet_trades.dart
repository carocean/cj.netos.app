import 'dart:convert';

import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class ExchangeResult {
  String sn;
  String personName;
  String currency;
  int amount;
  double stock;
  int profit;
  int purchaseAmount;
  int principalAmount;
  int serviceFeeamount;
  String ctime;
  int state;
  String bankid;

  ExchangeResult(
      {this.sn,
      this.personName,
      this.currency,
      this.amount,
      this.stock,
      this.profit,
      this.purchaseAmount,
      this.principalAmount,
      this.serviceFeeamount,
      this.ctime,
      this.state,
      this.bankid});
}

class TransAbsorbResult {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int state;
  String ctime;
  int status;
  String message;
  String note;

  TransAbsorbResult(
      {this.sn,
      this.person,
      this.personName,
      this.currency,
      this.demandAmount,
      this.state,
      this.ctime,
      this.status,
      this.message,
      this.note});
}

class TransProfitResult {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int state;
  String ctime;
  int status;
  String message;
  String note;
  String bankid;

  TransProfitResult({
    this.sn,
    this.person,
    this.personName,
    this.currency,
    this.demandAmount,
    this.state,
    this.ctime,
    this.status,
    this.message,
    this.note,
    this.bankid,
  });
}

class TransShunterResult {
  String sn;
  String person;
  String personName;
  String currency;
  int demandAmount;
  int state;
  String ctime;
  int status;
  String message;
  String note;
  String bankid;
  String shunter;

  TransShunterResult(
      {this.sn,
      this.person,
      this.personName,
      this.currency,
      this.demandAmount,
      this.state,
      this.ctime,
      this.status,
      this.message,
      this.note,
      this.bankid,
      this.shunter});
}

class P2PEvidence {
  String sn;
  String principal;
  String nickName;
  String actor;
  int pubTime;
  int expire;
  int useTimes;

  P2PEvidence(
      {this.sn,
      this.principal,
      this.nickName,
      this.actor,
      this.pubTime,
      this.expire,
      this.useTimes});
}

class PayChannel {
  String code;
  String name;
  String ctime;
  String note;

  PayChannel({this.code, this.name, this.ctime, this.note});
}

class ChannelAccountOR {
  String id;
  String appId;
  String channel;
  int balanceAmount;
  String balanceUtime;
  int limitAmount;
  String serviceUrl;
  String notifyUrl;
  String keyPubtime;
  int keyExpire;
  String publicKey;
  String privateKey;
  String note;

  ChannelAccountOR({
    this.id,
    this.appId,
    this.channel,
    this.balanceAmount,
    this.balanceUtime,
    this.limitAmount,
    this.serviceUrl,
    this.notifyUrl,
    this.keyPubtime,
    this.keyExpire,
    this.publicKey,
    this.privateKey,
    this.note,
  });
}

class ChannelBillOR {
  String sn;
  String title;
  String person;
  String personName;
  String channelAccount;
  String currency;
  int amount;
  int balance;
  int order;
  String refSn;
  String ctime;
  String workday;
  int day;
  int month;
  int season;
  int year;
  String refChSn;
  String notifyId;
  String channelPay;
  String note;

  ChannelBillOR({
    this.sn,
    this.title,
    this.person,
    this.personName,
    this.channelAccount,
    this.currency,
    this.amount,
    this.balance,
    this.order,
    this.refSn,
    this.ctime,
    this.workday,
    this.day,
    this.month,
    this.season,
    this.year,
    this.refChSn,
    this.notifyId,
    this.channelPay,
    this.note,
  });
}

class P2PResultOR {
  String sn;
  String payer;
  String payee;
  String status;
  String message;

  P2PResultOR({this.sn, this.payer, this.payee, this.status, this.message});
}

mixin IWalletTradeRemote {
  Future<ExchangeResult> exchange(String sn) {}

  Future<TransAbsorbResult> transAbsorb(int amount, String note) {}

  Future<TransProfitResult> transProfit(String bank, int profit, String s) {}

  Future<TransShunterResult> transShunter(
      String bank, String shunter, int amount, String note) {}

  Future<String> genReceivableEvidence(int expire, int useTimes) {}

  Future<String> genPayableEvidence(int expire, int useTimes) {}

  Future<P2PRecordOR> payToEvidence(
      String evidence, int amount, int type, String note);

  Future<P2PRecordOR> receiveFromEvidence(
      String evidence, int amount, int type, String note);

  Future<P2PEvidence> checkEvidence(String evidence) {}

  Future<PurchaseOR> purchaseWeny(String bank, int amount,int payMethod, String outTradeType,
      String outTradeSn, String note) {}

  Future<String> recharge(
      String currency, int amount, String payChannel, note) {}

  Future<P2PRecordOR> transTo(
      int amount, String payee, int type, String note) {}

  Future<WithdrawOR> withdraw(int amount, String personCard, note) {}
}

class WalletTradeRemote implements IWalletTradeRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletTradePorts => site.getService('@.prop.ports.wallet.trade.receipt');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<ExchangeResult> exchange(String sn) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'exchangeWeny',
      parameters: {
        'purchase_sn': sn,
        'note': '',
      },
    );
    return ExchangeResult(
      ctime: obj['ctime'],
      state: obj['state'],
      stock: obj['stock'],
      bankid: obj['bankid'],
      sn: obj['sn'],
      profit: obj['profit'],
      amount: obj['amount'],
      principalAmount: obj[''],
      currency: obj['currency'],
      personName: obj['personName'],
      purchaseAmount: obj['purchaseAmount'],
      serviceFeeamount: obj['serviceFeeamount'],
    );
  }

  @override
  Future<TransAbsorbResult> transAbsorb(int amount, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'transferAbsorb',
      parameters: {
        'amount': amount,
        'note': note,
      },
    );
    return TransAbsorbResult(
      ctime: obj['ctime'],
      state: obj['state'],
      demandAmount: obj['demandAmount'],
      sn: obj['sn'],
      currency: obj['currency'],
      personName: obj['personName'],
      person: obj['person'],
      note: obj['note'],
      message: obj['message'],
      status: obj['status'],
    );
  }

  @override
  Future<TransProfitResult> transProfit(
      String bank, int amount, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'transferProfit',
      parameters: {
        'wenyBankID': bank,
        'amount': amount,
        'note': note,
      },
    );
    return TransProfitResult(
      ctime: obj['ctime'],
      state: obj['state'],
      demandAmount: obj['demandAmount'],
      sn: obj['sn'],
      currency: obj['currency'],
      personName: obj['personName'],
      person: obj['person'],
      note: obj['note'],
      message: obj['message'],
      status: obj['status'],
      bankid: obj['bankid'],
    );
  }

  @override
  Future<TransShunterResult> transShunter(
      String bank, String shunter, int amount, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'transferShunter',
      parameters: {
        'wenyBankID': bank,
        'shunter': shunter,
        'amount': amount,
        'note': note,
      },
    );
    return TransShunterResult(
      ctime: obj['ctime'],
      state: obj['state'],
      demandAmount: obj['demandAmount'],
      sn: obj['sn'],
      currency: obj['currency'],
      personName: obj['personName'],
      person: obj['person'],
      note: obj['note'],
      message: obj['message'],
      status:
          (obj['status'] is String) ? int.parse(obj['status']) : obj['status'],
      bankid: obj['bankid'],
      shunter: obj['shunter'],
    );
  }

  @override
  Future<P2PRecordOR> transTo(
      int amount, String payee, int type, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'transTo',
      parameters: {
        'amount': amount,
        'payee': payee,
        'type': type,
        'note': note,
      },
    );
    if (obj == null) {
      return null;
    }
    return P2PRecordOR.parse(obj);
  }

  @override
  Future<String> genPayableEvidence(int expire, int useTimes) async {
    return await remotePorts.portGET(
      walletTradePorts,
      'genPayableEvidence',
      parameters: {
        'expire': expire,
        'useTimes': useTimes,
      },
    );
  }

  @override
  Future<String> genReceivableEvidence(int expire, int useTimes) async {
    return await remotePorts.portGET(
      walletTradePorts,
      'genReceivableEvidence',
      parameters: {
        'expire': expire,
        'useTimes': useTimes,
      },
    );
  }

  @override
  Future<P2PRecordOR> payToEvidence(
      String evidence, int amount, int type, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'payToEvidence',
      parameters: {
        'evidence': evidence,
        'amount': amount,
        'type': type,
        'note': note,
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

  @override
  Future<P2PRecordOR> receiveFromEvidence(
      String evidence, int amount, int type, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'receiveFromEvidence',
      parameters: {
        'evidence': evidence,
        'amount': amount,
        'type': type,
        'note': note,
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

  @override
  Future<P2PEvidence> checkEvidence(String evidence) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'checkEvidence',
      parameters: {
        'evidence': evidence,
      },
    );
    if (obj == null) {
      return null;
    }
    return P2PEvidence(
      sn: obj['sn'],
      nickName: obj['nickName'],
      pubTime: obj['pubTime'],
      actor: obj['actor'],
      expire: obj['expire'],
      principal: obj['principal'],
      useTimes: obj['useTimes'],
    );
  }

  @override
  Future<PurchaseOR> purchaseWeny(String bank, int amount,int payMethod, String outTradeType,
      String outTradeSn, String note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'purchaseWeny2',
      parameters: {
        'wenyBankID': bank,
        'amount': amount,
        'payMethod':payMethod,
        'outTradeType': outTradeType,
        'outTradeSn': outTradeSn,
        'note': note,
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
      outTradeSn: obj['outTradeSn'],
      outTradeType: obj['outTradeType'],
    );
  }

  @override
  Future<String> recharge(
      String currency, int amount, String payChannel, note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'recharge',
      parameters: {
        'currency': currency,
        'amount': amount,
        'payChannel': payChannel,
        'note': note,
      },
    );
    return obj;
  }

  @override
  Future<WithdrawOR> withdraw(int amount, String personCard, note) async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'withdraw',
      parameters: {
        'amount': amount,
        'personCard': personCard,
        'note': note,
      },
    );
    if(obj==null) {
      return null;
    }
    return WithdrawOR.parse(obj);
  }
}
