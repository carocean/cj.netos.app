import 'dart:convert';

import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

import 'org.dart';

class BusinessBuckets {
  double price;
  double stock;
  int fundAmount;
  int freezenAmount;
  int freeAmount;

  BusinessBuckets({
    this.price,
    this.stock,
    this.fundAmount,
    this.freezenAmount,
    this.freeAmount,
  });
}

class ShuntBuckets {
  int platformAmount;
  int ispAmount;
  int laAmount;
  int absorbsAmount;

  ShuntBuckets({
    this.platformAmount,
    this.ispAmount,
    this.laAmount,
    this.absorbsAmount,
  });
}

class BulletinBoard {
  double openPrice;
  double closePrice;

  BulletinBoard({this.openPrice, this.closePrice});
}

mixin IWyBankRemote {
  Future<BankInfo> getWenyBankByLicence(String licence) {}

  Future<List<BankInfo>> pageWyBankOnUser(int limit, int offset) {}

  Future<BusinessBuckets> getBusinessBucketsOfBank(String bank) {}

  Future<ShuntBuckets> getShuntBucketsOfBank(String bank) {}

  Future<BulletinBoard> getBulletinBoard(String bank,DateTime dateTime) {}

  Future<int> totalInBillOfMonth(String bankid) {}

  Future<int> totalInBillOfYear(String bankid) {}

  Future<int> totalOutBillOfMonth(String bankid) {}

  Future<int> totalOutBillOfYear(String bankid) {}
}

class WybankRemote implements IWyBankRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  //
  get wybankPorts => site.getService('@.prop.ports.wybank');

  get balancePorts => site.getService('@.prop.ports.wybank.balance');

  get pricePorts => site.getService('@.prop.ports.wybank.bill.price');

  get fundPorts => site.getService('@.prop.ports.wybank.bill.fund');

  get personPorts => site.getService('@.prop.ports.uc.person');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<BankInfo> getWenyBankByLicence(String licence) async {
    var map = await remotePorts.portGET(
      wybankPorts,
      'getWenyBankByLicence',
      parameters: {
        'licence': licence,
      },
    );
    if (map == null) {
      return null;
    }
    return BankInfo(
      title: map['title'],
      id: map['id'],
      state: (map['state'] as double).floor(),
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

  @override
  Future<List<BankInfo>> pageWyBankOnUser(int limit, int offset) async {
    var list = await remotePorts.portGET(
      personPorts,
      'listMyAccount',
      parameters: {
        'appid': 'la.netos',
      },
    );
    var persons = <String>[];
    for (var obj in list) {
      persons.add(obj['person']);
    }
    var bankList = await remotePorts.portGET(
      wybankPorts,
      'pageWenyBankByCreators',
      parameters: {
        'creators': jsonEncode(persons),
        'limit': limit,
        'offset': offset,
      },
    );
    List<BankInfo> banks = [];
    for (var map in bankList) {
      banks.add(
        BankInfo(
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
        ),
      );
    }
    return banks;
  }

  @override
  Future<BusinessBuckets> getBusinessBucketsOfBank(String bank) async {
    Map<String, dynamic> map = await remotePorts.portGET(
      balancePorts,
      'getAllBucketOfBank',
      parameters: {
        'wenyBankID': bank,
      },
    );
    int freezen = 0;
    int fund = 0;
    int free = 0;
    double price = 0.00000000000000;
    double stock = 0.00000000000000;
    for (var key in map.keys) {
      var obj = map[key];
      switch (key) {
        case 'freezen':
          freezen = (obj['amount'] as double).floor();
          break;
        case 'fund':
          fund = (obj['amount'] as double).floor();
          break;
        case 'free':
          free = (obj['amount'] as double).floor();
          break;
        case 'price':
          price = obj['price'];
          break;
        case 'stock':
          stock = obj['stock'];
          break;
      }
    }
    return BusinessBuckets(
      freeAmount: free,
      freezenAmount: freezen,
      fundAmount: fund,
      price: price,
      stock: stock,
    );
  }

  @override
  Future<ShuntBuckets> getShuntBucketsOfBank(String bank) async {
    var list = await remotePorts.portGET(
      balancePorts,
      'getAllShuntBucket',
      parameters: {
        'wenyBankID': bank,
      },
    );
    int platform = 0;
    int isp = 0;
    int la = 0;
    int absorbs = 0;
    for (var obj in list) {
      switch (obj['shunter']) {
        case 'platform':
          platform = obj['amount'];
          break;
        case 'isp':
          isp = obj['amount'];
          break;
        case 'la':
          la = obj['amount'];
          break;
        case 'absorbs':
          absorbs = obj['amount'];
          break;
      }
    }
    return ShuntBuckets(
      absorbsAmount: absorbs,
      ispAmount: isp,
      laAmount: la,
      platformAmount: platform,
    );
  }

  @override
  Future<BulletinBoard> getBulletinBoard(String bankid,DateTime date) async {
    var obj = await remotePorts.portGET(
      pricePorts,
      'getBulletinBoard',
      parameters: {
        'wenyBankID': bankid,
        'year': date.year,
        'month': date.month - 1,
        'day': date.day,
      },
    );
    return BulletinBoard(
      closePrice: obj['closePrice'] ?? 0.001,
      openPrice: obj['openPrice'] ?? 0.001,
    );
  }

  @override
  Future<int> totalInBillOfMonth(String bankid) async {
    var date = DateTime.now();
    var obj = await remotePorts.portGET(
      fundPorts,
      'totalInBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': date.year,
        'month': date.month - 1,
      },
    );
    return obj;
  }

  @override
  Future<int> totalInBillOfYear(String bankid) async {
    var date = DateTime.now();
    var obj = await remotePorts.portGET(
      fundPorts,
      'totalInBillOfYear',
      parameters: {
        'wenyBankID': bankid,
        'year': date.year,
      },
    );
    return obj;
  }

  @override
  Future<int> totalOutBillOfMonth(String bankid) async {
    var date = DateTime.now();
    var obj = await remotePorts.portGET(
      fundPorts,
      'totalOutBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': date.year,
        'month': date.month - 1,
      },
    );
    return obj;
  }

  @override
  Future<int> totalOutBillOfYear(String bankid) async {
    var date = DateTime.now();
    var obj = await remotePorts.portGET(
      fundPorts,
      'totalOutBillOfYear',
      parameters: {
        'wenyBankID': bankid,
        'year': date.year,
      },
    );
    return obj;
  }
}
