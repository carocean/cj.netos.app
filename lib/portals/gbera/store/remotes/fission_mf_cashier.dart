import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/framework.dart';
import 'package:uuid/uuid.dart';

class FissionMFAttachmentOR {
  String person;
  String src;
  String type;
  String note;
  String ctime;

  FissionMFAttachmentOR({
    this.person,
    this.src,
    this.type,
    this.ctime,
    this.note,
  });

  FissionMFAttachmentOR.parse(obj) {
    this.person = obj['person'];
    this.src = obj['src'];
    this.type = obj['type'];
    this.ctime = obj['ctime'];
    this.note = obj['note'];
  }
}

class FissionMFLimitAreaOR {
  String person;
  String areaType;
  String areaCode;
  String areaTitle;
  String direct;

  FissionMFLimitAreaOR({
    this.person,
    this.areaType,
    this.areaCode,
    this.areaTitle,
    this.direct,
  });

  FissionMFLimitAreaOR.parse(obj) {
    this.person = obj['person'];
    this.areaType = obj['areaType'];
    this.areaCode = obj['areaCode'];
    this.areaTitle = obj['areaTitle'];
    this.direct = obj['direct'];
  }
}

class FissionMFTagOR {
  String id;
  String name;
  String opposite;
  int sort;

  FissionMFTagOR({
    this.id,
    this.name,
    this.opposite,
    this.sort,
  });

  FissionMFTagOR.parse(obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.opposite = obj['opposite'];
    this.sort = obj['sort'];
  }
}

class AlgorithmInfoOR {
  int upMaxBound;
  int baseLine;
  int amplitude;

  AlgorithmInfoOR({
    this.upMaxBound,
    this.baseLine,
    this.amplitude,
  });

  AlgorithmInfoOR.parse(obj) {
    this.upMaxBound = obj['upMaxBound'];
    this.baseLine = obj['baseLine'];
    this.amplitude = obj['amplitude'];
  }
}

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

  Future<void> stopCashier(String closedCause) {}

  Future<void> setCacAverage(int cac) {}

  Future<void> setAmplitudeFactor(double amplitudeFactor) {}

  Future<AlgorithmInfoOR> getAlgorithmInfo() {}

  Future<List<FissionMFTagOR>> listAllTag();

  Future<void> addPropertyTag(String tagId) {}

  Future<void> removePropertyTag(String tagId) {}

  Future<List<FissionMFTagOR>> listMyPropertyTag() {}

  Future<FissionMFTagOR> getTag(String opposite) {}

  Future<void> addLimitTag(String tagId, String direct) {}

  Future<void> removeLimitTag(String tagId, String direct) {}

  Future<List<FissionMFTagOR>> listLimitTag(String direct) {}

  Future<void> setLimitArea(
      String direct, String areaType, String areaTitle, String areaCode) {}

  Future<void> emptyLimitArea(String direct) {}

  Future<FissionMFLimitAreaOR> getLimitArea(String direct) {}

  Future<void> setAttachment(String src, String type) {}

  Future<void> emptyAttachment() {}

  Future<FissionMFAttachmentOR> getAttachment() {}

  Future<void> setAdvert(String note) {}

  Future<void> updateLocation(LatLng location,
      {String province, String city, String district, String town}) {}

  Future<List<FissionMFTagOR>> listPropertyTagOfPerson(String person) {}
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
  Future<void> stopCashier(String closedCause) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'stopCashier',
      parameters: {
        'closedCause': closedCause,
      },
    );
  }

  @override
  Future<void> startCashier() async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'startCashier',
      parameters: {},
    );
  }

  @override
  Future<void> setCacAverage(int cac) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'setCacAverage',
      parameters: {
        'cacAverage': cac,
      },
    );
  }

  @override
  Future<void> setAmplitudeFactor(double amplitudeFactor) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'setAmplitudeFactor',
      parameters: {
        'amplitudeFactor': amplitudeFactor,
      },
    );
  }

  @override
  Future<AlgorithmInfoOR> getAlgorithmInfo() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getAlgorithmInfo',
      parameters: {},
    );
    if (obj == null) {
      return AlgorithmInfoOR(amplitude: 0, baseLine: 0, upMaxBound: 0);
    }
    return AlgorithmInfoOR.parse(obj);
  }

  @override
  Future<List<FissionMFTagOR>> listAllTag() async {
    var list = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'listAllTag',
      parameters: {},
    );
    var tags = <FissionMFTagOR>[];
    for (var obj in list) {
      tags.add(FissionMFTagOR.parse(obj));
    }
    return tags;
  }

  @override
  Future<void> addPropertyTag(String tagId) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'addPropertyTag',
      parameters: {
        'tagId': tagId,
      },
    );
  }

  @override
  Future<void> removePropertyTag(String tagId) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'removePropertyTag',
      parameters: {
        'tagId': tagId,
      },
    );
  }

  @override
  Future<List<FissionMFTagOR>> listMyPropertyTag() async {
    var list = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'listMyPropertyTag',
      parameters: {},
    );
    var tags = <FissionMFTagOR>[];
    for (var obj in list) {
      tags.add(FissionMFTagOR.parse(obj));
    }
    return tags;
  }

  @override
  Future<List<FissionMFTagOR>> listPropertyTagOfPerson(String person) async {
    var list = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'listPropertyTagOfPerson',
      parameters: {
        'person': person,
      },
    );
    var tags = <FissionMFTagOR>[];
    for (var obj in list) {
      tags.add(FissionMFTagOR.parse(obj));
    }
    return tags;
  }

  @override
  Future<FissionMFTagOR> getTag(String opposite) async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getTag',
      parameters: {
        'tagId': opposite,
      },
    );
    if (obj == null) {
      return null;
    }
    return FissionMFTagOR.parse(obj);
  }

  @override
  Future<void> addLimitTag(String tagId, String direct) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'addLimitTag',
      parameters: {
        'tagId': tagId,
        'direct': direct,
      },
    );
  }

  @override
  Future<void> emptyLimitArea(String direct) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'emptyLimitArea',
      parameters: {
        'direct': direct,
      },
    );
  }

  @override
  Future<FissionMFLimitAreaOR> getLimitArea(String direct) async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getLimitArea',
      parameters: {
        'direct': direct,
      },
    );
    if (obj == null) {
      return null;
    }
    return FissionMFLimitAreaOR.parse(obj);
  }

  @override
  Future<List<FissionMFTagOR>> listLimitTag(String direct) async {
    var list = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'listLimitTag',
      parameters: {
        'direct': direct,
      },
    );
    var tags = <FissionMFTagOR>[];
    for (var obj in list) {
      tags.add(FissionMFTagOR.parse(obj));
    }
    return tags;
  }

  @override
  Future<void> removeLimitTag(String tagId, String direct) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'removeLimitTag',
      parameters: {
        'direct': direct,
        'tagId': tagId,
      },
    );
  }

  @override
  Future<void> setLimitArea(
      String direct, String areaType, String areaTitle, String areaCode) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'setLimitArea',
      parameters: {
        'direct': direct,
        'areaType': areaType,
        'areaTitle': areaTitle,
        'areaCode': areaCode,
      },
    );
  }

  @override
  Future<void> emptyAttachment() async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'emptyAttachment',
      parameters: {},
    );
  }

  @override
  Future<FissionMFAttachmentOR> getAttachment() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getAttachment',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return FissionMFAttachmentOR.parse(obj);
  }

  @override
  Future<void> setAdvert(String note) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'setAdvert',
      parameters: {
        'note': note,
      },
    );
  }

  @override
  Future<void> setAttachment(String src, String type) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'setAttachment',
      parameters: {
        'src': src,
        'type': type,
      },
    );
  }

  @override
  Future<void> updateLocation(LatLng location,
      {String province, String city, String district, String town}) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'updateLocation',
      parameters: {
        'province': province,
        'city': city,
        'district': district,
        'town': town,
      },
      data: {
        'location': jsonEncode(location.toJson()),
      },
    );
  }
}
