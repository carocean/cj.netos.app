import 'dart:async';

import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class StockBillOR {
  String sn;
  String accountid;
  String title;
  int order;
  double stock;
  double balance;
  String refsn;
  String ctime;
  String note;
  String bankid;

  StockBillOR(
      {this.sn,
      this.accountid,
      this.title,
      this.order,
      this.stock,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.bankid});
}

class FreezenBillOR {
  String sn;
  String accountid;
  String title;
  int order;
  int amount;
  int balance;
  String refsn;
  String ctime;
  String note;
  String bankid;

  FreezenBillOR(
      {this.sn,
      this.accountid,
      this.title,
      this.order,
      this.amount,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.bankid});
}

class ProfitBillOR {
  String sn;
  String accountid;
  String title;
  int order;
  int amount;
  int balance;
  String refsn;
  String ctime;
  String note;
  String bankid;

  ProfitBillOR(
      {this.sn,
      this.accountid,
      this.title,
      this.order,
      this.amount,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.bankid});
}

class BalanceBillOR {
  String sn;
  String accountid;
  String title;
  int order;
  int amount;
  int balance;
  String refsn;
  String ctime;
  String note;
  String bankid;

  BalanceBillOR(
      {this.sn,
      this.accountid,
      this.title,
      this.order,
      this.amount,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.bankid});

  BalanceBillOR.parse(obj) {
    this.sn = obj['sn'];
    this.accountid = obj['accountid'];
    this.title = obj['title'];
    this.order = obj['order'];
    this.amount = obj['amount'];
    this.balance = obj['balance'];
    this.refsn = obj['refsn'];
    this.ctime = obj['ctime'];
    this.note = obj['note'];
    this.bankid = obj['bankid'];
  }
}

class OnorderBillOR {
  String sn;
  String accountid;
  String title;
  int order;
  int amount;
  int balance;
  String refsn;
  String ctime;
  String note;
  String bankid;

  OnorderBillOR(
      {this.sn,
      this.accountid,
      this.title,
      this.order,
      this.amount,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.bankid});
}

class AbsorbBillOR {
  String sn;
  String accountid;
  String title;
  int order;
  double amount;
  int balance;
  String refsn;
  String ctime;
  String note;
  String bankid;

  AbsorbBillOR(
      {this.sn,
      this.accountid,
      this.title,
      this.order,
      this.amount,
      this.balance,
      this.refsn,
      this.ctime,
      this.note,
      this.bankid});
}

mixin IWalletBillRemote {
  Future<List<StockBillOR>> pageStockBill(String bank, int limit, int offset) {}

  Future<List<FreezenBillOR>> pageFreezenBill(
      String bank, int limit, int offset) {}

  Future<List<ProfitBillOR>> pageProfitBill(
      String bank, int limit, int offset) {}

  Future<List<BalanceBillOR>> pageBalanceBill(int limit, int offset) {}

  Future<List<OnorderBillOR>> pageOnorderBill(int limit, int offset) {}

  Future<List<AbsorbBillOR>> pageAbsorbBill(int limit, int offset) {}

  Future<List<BalanceBillOR>> pageBalanceBillByOrder(
      int order, int limit, int offset) {}
}

class WalletBillRemote implements IWalletBillRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletStockBillPorts => site.getService('@.prop.ports.wallet.bill.stock');

  get walletFreezenBillPorts =>
      site.getService('@.prop.ports.wallet.bill.freezen');

  get walletProfitBillPorts =>
      site.getService('@.prop.ports.wallet.bill.profit');

  get walletBalanceBillPorts =>
      site.getService('@.prop.ports.wallet.bill.balance');

  get walletOnorderBillPorts =>
      site.getService('@.prop.ports.wallet.bill.onorder');

  get walletAbsorbBillPorts =>
      site.getService('@.prop.ports.wallet.bill.absorb');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<StockBillOR>> pageStockBill(
      String bank, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletStockBillPorts,
      'pageBill',
      parameters: {
        'wenyBankID': bank,
        'limit': limit,
        'offset': offset,
      },
    );
    List<StockBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        StockBillOR(
          ctime: obj['ctime'],
          stock: obj['stock'],
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: obj['balance'],
        ),
      );
    }
    return bills;
  }

  @override
  Future<List<FreezenBillOR>> pageFreezenBill(
      String bank, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletFreezenBillPorts,
      'pageBill',
      parameters: {
        'wenyBankID': bank,
        'limit': limit,
        'offset': offset,
      },
    );
    List<FreezenBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        FreezenBillOR(
          ctime: obj['ctime'],
          amount: (obj['amount'] as double).floor(),
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: (obj['balance'] as double).floor(),
        ),
      );
    }
    return bills;
  }

  @override
  Future<List<ProfitBillOR>> pageProfitBill(
      String bank, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletProfitBillPorts,
      'pageBill',
      parameters: {
        'wenyBankID': bank,
        'limit': limit,
        'offset': offset,
      },
    );
    List<ProfitBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        ProfitBillOR(
          ctime: obj['ctime'],
          amount: (obj['amount'] as double).floor(),
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: (obj['balance'] as double).floor(),
        ),
      );
    }
    return bills;
  }

  @override
  Future<List<BalanceBillOR>> pageBalanceBill(int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletBalanceBillPorts,
      'pageBill',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<BalanceBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        BalanceBillOR(
          ctime: obj['ctime'],
          amount: (obj['amount'] as double).floor(),
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: (obj['balance'] as double).floor(),
        ),
      );
    }
    return bills;
  }

  @override
  Future<List<BalanceBillOR>> pageBalanceBillByOrder(
      int order, int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletBalanceBillPorts,
      'pageBillByOrder',
      parameters: {
        'order': order,
        'limit': limit,
        'offset': offset,
      },
    );
    List<BalanceBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        BalanceBillOR(
          ctime: obj['ctime'],
          amount: (obj['amount'] as double).floor(),
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: (obj['balance'] as double).floor(),
        ),
      );
    }
    return bills;
  }

  @override
  Future<List<OnorderBillOR>> pageOnorderBill(int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletOnorderBillPorts,
      'pageBill',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<OnorderBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        OnorderBillOR(
          ctime: obj['ctime'],
          amount: (obj['amount'] as double).floor(),
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: (obj['balance'] as double).floor(),
        ),
      );
    }
    return bills;
  }

  @override
  Future<List<AbsorbBillOR>> pageAbsorbBill(int limit, int offset) async {
    var list = await remotePorts.portGET(
      walletAbsorbBillPorts,
      'pageBill',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<AbsorbBillOR> bills = [];
    for (var obj in list) {
      bills.add(
        AbsorbBillOR(
          ctime: obj['ctime'],
          amount: (obj['amount'] as double),
          refsn: obj['refsn'],
          order: (obj['order'] as double).floor(),
          title: obj['title'],
          bankid: obj['bankid'],
          note: obj['note'],
          sn: obj['sn'],
          accountid: obj['accountid'],
          balance: (obj['balance'] as double).floor(),
        ),
      );
    }
    return bills;
  }
}
