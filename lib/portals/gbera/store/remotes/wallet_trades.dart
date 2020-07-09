import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';

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

mixin IWalletTradeRemote {
  Future<ExchangeResult> exchange(String sn) {}

  Future<TransAbsorbResult> transAbsorb(int amount, String note) {}

  Future<TransProfitResult> transProfit(String bank, int profit, String s) {}

  Future<TransShunterResult> transShunter(
      String bank, String shunter, int amount, String note) {}
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
}
