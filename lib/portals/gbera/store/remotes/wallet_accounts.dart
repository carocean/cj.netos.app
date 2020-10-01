import 'package:framework/framework.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

import 'wallet_trades.dart';

class MyWallet {
  int total;
  int change;
  double absorb;
  int onorder;
  List<WenyBank> banks;

  String get totalYan => ((total ?? 0) / 100.00).toStringAsFixed(2);

  String get changeYan => ((change ?? 0) / 100.00).toStringAsFixed(2);

  String get absorbYan => ((absorb ?? 0) / 100.00).toStringAsFixed(14);

  String get onorderYan => ((onorder ?? 0) / 100.00).toStringAsFixed(2);

  MyWallet({this.change, this.absorb, this.onorder, this.banks}) {
    var total = change + (absorb.floor()) + onorder;
    for (WenyBank bank in banks) {
      total += bank.freezen + bank.profit;
    }
    this.total = total;
  }
}

class WenyBank {
  int freezen;
  int profit;
  double stock;
  double price;
  String bank;
  BankInfo info;
  BulletinBoard board;

  String get freezenYan => ((freezen ?? 0) / 100.00).toStringAsFixed(2);

  String get profitYan => ((profit ?? 0) / 100.00).toStringAsFixed(2);

  double get change => double.parse(
      (((price - (board.closePrice ?? 0.001)) / (board.closePrice ?? 0.001)) *
              100.00)
          .toStringAsFixed(2));

  WenyBank({
    this.freezen,
    this.profit,
    this.stock,
    this.bank,
    this.info,
    this.price,
    this.board,
  });
}

class BankInfo {
  String creator;
  String ctime;
  String id;
  int state;
  String title;
  String districtTitle;
  String districtCode;
  String licence;
  String icon;
  double principalRatio;
  double reserveRatio;
  double freeRatio;

  BankInfo({
    this.creator,
    this.ctime,
    this.id,
    this.state,
    this.title,
    this.icon,
    this.districtCode,
    this.districtTitle,
    this.licence,
    this.reserveRatio,
    this.principalRatio,
    this.freeRatio,
  });
}

mixin IPayChannelRemote {
  Future<List<PayChannel>> pagePayChannel(int limit, int offset);

  Future<PayChannel> getPayChannel(String payChannel) {}

  Future<int> totalPersonCard() {}
}
mixin IWalletAccountRemote {
  Future<MyWallet> getAllAcounts() {}

  Future<WenyBank> getWenyBankAcount(String bank) {}

  Future<BulletinBoard> getBulletinBoard(bank, DateTime today);
}

class PayChannelRemote implements IPayChannelRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get payChannelPorts => site.getService('@.prop.ports.wallet.payChannel');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<List<PayChannel>> pagePayChannel(int limit, int offset) async {
    var list = await remotePorts.portGET(
      payChannelPorts,
      'pagePayChannel',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<PayChannel> channels = [];
    for (var obj in list) {
      channels.add(
        PayChannel(
          code: obj['code'],
          ctime: obj['ctime'],
          name: obj['name'],
          note: obj['note'],
        ),
      );
    }
    return channels;
  }

  @override
  Future<PayChannel> getPayChannel(String payChannel) async {
    var obj = await remotePorts.portGET(
      payChannelPorts,
      'getPayChannel',
      parameters: {
        'code': payChannel,
      },
    );
    if (obj == null) {
      return obj;
    }
    return PayChannel(
      code: obj['code'],
      note: obj['note'],
      name: obj['name'],
      ctime: obj['ctime'],
    );
  }

  @override
  Future<int> totalPersonCard() async {
    var obj = await remotePorts.portGET(
      payChannelPorts,
      'totalPersonCard',
    );
    return obj;
  }
}

class WalletAccountRemote implements IWalletAccountRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletBalancePorts => site.getService('@.prop.ports.wallet.balance');

  get walletPorts => site.getService('@.prop.ports.wallet');

  get bankBalancePorts => site.getService('@.prop.ports.wybank.balance');

  get pricePorts => site.getService('@.prop.ports.wybank.bill.price');

  get bankPorts => site.getService('@.prop.ports.wybank');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<WenyBank> getWenyBankAcount(String bank) async {
    var stockAccount = await remotePorts.portGET(
      walletBalancePorts,
      'getStockAccount',
      parameters: {
        'wenyBankID': bank,
      },
    );
    var profitAccount = await remotePorts.portGET(
      walletBalancePorts,
      'getProfitAccount',
      parameters: {
        'wenyBankID': bank,
      },
    );
    var freezenAccount = await remotePorts.portGET(
      walletBalancePorts,
      'getFreezenAccount',
      parameters: {
        'wenyBankID': bank,
      },
    );
    var priceAccount = await remotePorts.portGET(
      bankBalancePorts,
      'getPriceBucket',
      parameters: {
        'wenyBankID': bank,
      },
    );
    var bankInfo = await _getBankInfo(bank);
    var bulletinBoard = await getBulletinBoard(bank, DateTime.now());
    return new WenyBank(
      price: priceAccount['price'],
      profit: (profitAccount['amount'] as double).floor(),
      stock: stockAccount['stock'],
      freezen: (freezenAccount['amount'] as double).floor(),
      board: bulletinBoard,
      bank: bank,
      info: bankInfo,
    );
  }

  @override
  Future<MyWallet> getAllAcounts() async {
    var root = await remotePorts.portGET(
      walletBalancePorts,
      'getRootAccount',
    );
    if (root == null) {
      await _createWallet();
      root = await remotePorts.portGET(
        walletBalancePorts,
        'getRootAccount',
      );
    }
    var all = await remotePorts.portGET(
      walletBalancePorts,
      'getAllAccount',
    );
    var banks = <WenyBank>[];
    var stockAccounts = all['wenyAccounts'];
    var freezenAccounts = all['freezenAccounts'];
    var profitAccounts = all['profitAccounts'];
    for (var account in stockAccounts) {
      var bank = account['bankid'];
      var bankInfo = await _getBankInfo(bank);
      if (bankInfo == null) {
        continue;
      }
      var bulletinBoard = await getBulletinBoard(bank, DateTime.now());
      var price = await _getPrice(bank);
      var freezen = 0;
      for (var freezenAccount in freezenAccounts) {
        if (bank == freezenAccount['bankid']) {
          freezen = (freezenAccount['amount'] as double).floor();
          break;
        }
      }
      var profit = 0;
      for (var profitAccount in profitAccounts) {
        if (bank == profitAccount['bankid']) {
          profit = (profitAccount['amount'] as double).floor();
          break;
        }
      }
      banks.add(
        WenyBank(
          bank: bank,
          price: price,
          freezen: freezen,
          profit: profit,
          stock: account['stock'] as double,
          info: bankInfo,
          board: bulletinBoard,
        ),
      );
    }
    return MyWallet(
      onorder: (root['onorderAmount'] as double).floor(),
      absorb: (all['absorbAccount']['amount'] as double),
      change: (all['balanceAccount']['amount'] as double).floor(),
      banks: banks,
    );
  }

  _createWallet() async {
    await remotePorts.portGET(
      walletPorts,
      'createWallet',
    );
  }

  Future<BankInfo> _getBankInfo(bank) async {
    var map = await remotePorts.portGET(
      bankPorts,
      'getWenyBankInfo',
      parameters: {
        'banksn': bank,
      },
    );
    if (map == null) {
      return null;
    }
    return BankInfo(
      title: map['title'],
      id: map['id'],
      state: map['state'],
      creator: map['creator'],
      ctime: map['ctime'],
      icon: map['icon'],
      districtCode: map['districtCode'],
      districtTitle: map['districtTitle'],
      licence: map['licence'],
      principalRatio: map['principalRatio'],
      reserveRatio: map['reserveRatio'],
      freeRatio: map['freeRatio'],
    );
  }

  _getPrice(bank) async {
    var map = await remotePorts.portGET(
      bankBalancePorts,
      'getPriceBucket',
      parameters: {
        'wenyBankID': bank,
      },
    );
    return map['price'] as double;
  }

  @override
  Future<BulletinBoard> getBulletinBoard(bank, DateTime today) async {
    var obj = await remotePorts.portGET(
      pricePorts,
      'getBulletinBoard',
      parameters: {
        'wenyBankID': bank,
        'year': today.year,
        'month': today.month - 1,
        'day': today.day,
      },
    );
    return BulletinBoard(
      closePrice: obj['closePrice'] ?? 0.001,
      openPrice: obj['openPrice'] ?? 0.001,
    );
  }
}
