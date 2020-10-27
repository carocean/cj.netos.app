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

class PersonCardOR {
  String id;
  String person;
  String cardSn;
  String cardHolder;
  String cardName;
  String cardAvatar;
  String cardAttrBank;
  String cardPubBank;
  int cardType;
  String cardPhone;

  String payChannel;
  String payPwd;
  String ctime;

  PersonCardOR({
    this.id,
    this.person,
    this.cardSn,
    this.cardHolder,
    this.cardName,
    this.cardAvatar,
    this.cardAttrBank,
    this.cardPubBank,
    this.cardType,
    this.cardPhone,
    this.payChannel,
    this.payPwd,
    this.ctime,
  });

  PersonCardOR.parse(obj) {
    this.id = obj['id'];
    this.person = obj['person'];
    this.cardSn = obj['cardSn'];
    this.cardHolder = obj['cardHolder'];
    this.cardName = obj['cardName'];
    this.cardAvatar = obj['cardAvatar'];
    this.cardAttrBank = obj['cardAttrBank'];
    this.cardPubBank = obj['cardPubBank'];
    this.cardType = obj['cardType'];
    this.cardPhone = obj['cardPhone'];
    this.payChannel = obj['payChannel'];
    this.payPwd = obj['payPwd'];
    this.ctime = obj['ctime'];
  }
}

mixin IPayChannelRemote {
  Future<PersonCardOR> getPersonCardById(String id);

  Future<PersonCardOR> getPersonCard(String payChannelID);

  Future<List<PayChannel>> pagePayChannel(int limit, int offset);

  Future<PayChannel> getPayChannel(String payChannel) {}

  Future<int> totalPersonCard() {}

  Future<void> addAccount(
      String channel,
      String appid,
      String serviceUrl,
      String notifyUrl,
      String publicKey,
      String privateKey,
      String keyPubtime,
      int keyExpire,
      int weight,
      int limitAmount,
      String note) {}

  Future<void> addPayChannel(String code, String name, String note);

  Future<void> getAccount(String accountid) {}

  Future<List<ChannelAccountOR>> pageAccount(int limit, int offset) {}

  Future<List<ChannelAccountOR>> pageAccountOfChannel(
      String channel, int limit, int offset) {}

  Future<void> removeAccount(String accountid) {}

  Future<List<ChannelBillOR>> monthBillByAccount(
      String accountid, int year, int month, int limit, int offset) {}

  Future<int> totalAccountBalance(String channel) {}

  Future<int> totalMonthBillByAccount(
      String accountid, int order, int year, int month) {}

  Future<PersonCardOR> createPersonCardByAuthCode(
      String payChannel, String authCode) {}
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

  get channelBillPorts => site.getService('@.prop.ports.wallet.channelBill');

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

  @override
  Future<void> addAccount(
      String channel,
      String appid,
      String serviceUrl,
      String notifyUrl,
      String publicKey,
      String privateKey,
      String keyPubtime,
      int keyExpire,
      int weight,
      int limitAmount,
      String note) async {}

  @override
  Future<void> addPayChannel(String code, String name, String note) async {
    await remotePorts.portGET(
      payChannelPorts,
      'addPayChannel',
      parameters: {
        'code': code,
        'name': name,
        'note': note,
      },
    );
  }

  @override
  Future<void> getAccount(String accountid) async {
    var obj = await remotePorts.portGET(
      payChannelPorts,
      'getAccount',
      parameters: {
        'accountid': accountid,
      },
    );
    if (obj == null) {
      return null;
    }
    return ChannelAccountOR(
      note: obj['note'],
      appId: obj['appId'],
      balanceAmount: obj['balanceAmount'],
      balanceUtime: obj['balanceUtime'],
      channel: obj['channel'],
      id: obj['id'],
      keyExpire: obj['keyExpire'],
      keyPubtime: obj['keyPubtime'],
      limitAmount: obj['limitAmount'],
      notifyUrl: obj['notifyUrl'],
      privateKey: obj['privateKey'],
      publicKey: obj['publicKey'],
      serviceUrl: obj['serviceUrl'],
    );
  }

  @override
  Future<List<ChannelAccountOR>> pageAccount(int limit, int offset) async {
    var list = await remotePorts.portGET(
      payChannelPorts,
      'pageAccount',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var accounts = <ChannelAccountOR>[];
    for (var obj in list) {
      accounts.add(
        ChannelAccountOR(
          note: obj['note'],
          appId: obj['appId'],
          balanceAmount: obj['balanceAmount'],
          balanceUtime: obj['balanceUtime'],
          channel: obj['channel'],
          id: obj['id'],
          keyExpire: obj['keyExpire'],
          keyPubtime: obj['keyPubtime'],
          limitAmount: obj['limitAmount'],
          notifyUrl: obj['notifyUrl'],
          privateKey: obj['privateKey'],
          publicKey: obj['publicKey'],
          serviceUrl: obj['serviceUrl'],
        ),
      );
    }
    return accounts;
  }

  @override
  Future<List<ChannelAccountOR>> pageAccountOfChannel(
      String channel, int limit, int offset) async {
    var list = await remotePorts.portGET(
      payChannelPorts,
      'pageAccountOfChannel',
      parameters: {
        'channel': channel,
        'limit': limit,
        'offset': offset,
      },
    );
    var accounts = <ChannelAccountOR>[];
    for (var obj in list) {
      accounts.add(
        ChannelAccountOR(
          note: obj['note'],
          appId: obj['appId'],
          balanceAmount: obj['balanceAmount'],
          balanceUtime: obj['balanceUtime'],
          channel: obj['channel'],
          id: obj['id'],
          keyExpire: obj['keyExpire'],
          keyPubtime: obj['keyPubtime'],
          limitAmount: obj['limitAmount'],
          notifyUrl: obj['notifyUrl'],
          privateKey: obj['privateKey'],
          publicKey: obj['publicKey'],
          serviceUrl: obj['serviceUrl'],
        ),
      );
    }
    return accounts;
  }

  @override
  Future<void> removeAccount(String accountid) async {
    await remotePorts.portGET(
      payChannelPorts,
      'removeAccount',
      parameters: {
        'accountid': accountid,
      },
    );
  }

  @override
  Future<List<ChannelBillOR>> monthBillByAccount(
      String accountid, int year, int month, int limit, int offset) async {
    var list = await remotePorts.portGET(
      channelBillPorts,
      'monthBillByAccount',
      parameters: {
        'channelAccount': accountid,
        'year': year,
        'month': month,
        'limit': limit,
        'offset': offset,
      },
    );
    var bills = <ChannelBillOR>[];
    for (var obj in list) {
      bills.add(
        ChannelBillOR(
          note: obj['note'],
          ctime: obj['ctime'],
          title: obj['title'],
          amount: obj['amount'],
          balance: obj['balance'],
          channelAccount: obj['channelAccount'],
          channelPay: obj['channelPay'],
          currency: obj['currency'],
          day: obj['day'],
          month: obj['month'],
          notifyId: obj['notifyId'],
          order: obj['order'],
          person: obj['person'],
          personName: obj['personName'],
          refChSn: obj['refChSn'],
          refSn: obj['refSn'],
          season: obj['season'],
          sn: obj['sn'],
          workday: obj['workday'],
          year: obj['year'],
        ),
      );
    }
    return bills;
  }

  @override
  Future<int> totalMonthBillByAccount(
      String accountid, int order, int year, int month) async {
    return await remotePorts.portGET(
      channelBillPorts,
      'totalMonthBillByAccount',
      parameters: {
        'channelAccount': accountid,
        'order': order,
        'year': year,
        'month': month,
      },
    );
  }

  @override
  Future<int> totalAccountBalance(String channel) async {
    return await remotePorts.portGET(
      payChannelPorts,
      'totalAccountBalance',
      parameters: {
        'channel': channel,
      },
    );
  }

  @override
  Future<PersonCardOR> getPersonCard(String payChannelID) async {
    var obj = await remotePorts.portGET(
      payChannelPorts,
      'getPersonCard',
      parameters: {
        'payChannel': payChannelID,
      },
    );
    if (obj == null) {
      return null;
    }
    return PersonCardOR.parse(obj);
  }

  @override
  Future<PersonCardOR> getPersonCardById(String id) async {
    var obj = await remotePorts.portGET(
      payChannelPorts,
      'getPersonCardById',
      parameters: {
        'id': id,
      },
    );
    if (obj == null) {
      return null;
    }
    return PersonCardOR.parse(obj);
  }

  @override
  Future<PersonCardOR> createPersonCardByAuthCode(
      String payChannel, String authCode) async {
    var obj = await remotePorts.portGET(
      payChannelPorts,
      'createPersonCardByAuthCode',
      parameters: {
        'payChannel': payChannel,
        'authCode': authCode,
      },
    );
    if (obj == null) {
      return null;
    }
    return PersonCardOR.parse(obj);
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
