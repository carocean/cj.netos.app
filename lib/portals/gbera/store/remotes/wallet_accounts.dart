import 'package:framework/framework.dart';

class MyWallet {
  int total;
  int change;
  int absorb;
  int onorder;
  List<WenyBank> banks;

  String get totalYan => ((total ?? 0) / 100.00).toStringAsFixed(2);

  String get changeYan => ((change ?? 0) / 100.00).toStringAsFixed(2);

  String get absorbYan => ((absorb ?? 0) / 100.00).toStringAsFixed(2);

  String get onorderYan => ((onorder ?? 0) / 100.00).toStringAsFixed(2);

  MyWallet({this.change, this.absorb, this.onorder, this.banks}) {
    var total = change + absorb + onorder;
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

  String get freezenYan => ((freezen ?? 0) / 100.00).toStringAsFixed(2);

  String get profitYan => ((profit ?? 0) / 100.00).toStringAsFixed(2);

  WenyBank({
    this.freezen,
    this.profit,
    this.stock,
    this.bank,
    this.info,
    this.price,
  });
}

class BankInfo {
  String creator;
  String ctime;
  String id;
  int state;
  String title;
  String masterId;
  int masterType;
  String masterPerson;
  String icon;

  BankInfo({
    this.creator,
    this.ctime,
    this.id,
    this.state,
    this.title,
    this.masterId,
    this.masterPerson,
    this.masterType,
    this.icon,
  });
}

mixin IWalletAccountRemote {
  Future<MyWallet> getAllAcounts() {}

  Future<WenyBank> getWenyBankAcount(String bank) {}
}

class WalletAccountRemote implements IWalletAccountRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletBalancePorts => site.getService('@.prop.ports.wallet.balance');

  get walletPorts => site.getService('@.prop.ports.wallet');

  get bankBalancePorts => site.getService('@.prop.ports.wybank.balance');

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
    return new WenyBank(
      price: priceAccount['price'],
      profit: (profitAccount['amount'] as double).floor(),
      stock: stockAccount['stock'],
      freezen: (freezenAccount['amount'] as double).floor(),
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
        ),
      );
    }
    return MyWallet(
      onorder: (root['onorderAmount'] as double).floor(),
      absorb: (all['absorbAccount']['amount'] as double).floor(),
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
    return BankInfo(
      title: map['title'],
      id: map['id'],
      state: map['state'],
      creator: map['creator'],
      ctime: map['ctime'],
      icon: map['icon'],
      masterId: map['masterId'],
      masterPerson:map['masterPerson'] ,
      masterType:map['masterType'] ,
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
}
