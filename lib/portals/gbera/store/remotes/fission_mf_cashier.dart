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
  int checkedWithdrawPt;
  int stayBalance;
  String referrer;
  String referrerName;
  int supportsChatroom;
  String salesman;
  String areaMaster;
  int stage;
  int level;

  CashierOR({
    this.person,
    this.state,
    this.type,
    this.dayAmount,
    this.cacAverage,
    this.amplitudeFactor,
    this.closedCause,
    this.checkedWithdrawPt,
    this.stayBalance,
    this.referrer,
    this.referrerName,
    this.supportsChatroom,
    this.salesman,
    this.areaMaster,
    this.stage,
    this.level,
  });

  CashierOR.parse(obj) {
    this.person = obj['person'];
    this.state = obj['state'];
    this.type = obj['type'];
    this.dayAmount = obj['dayAmount'];
    this.cacAverage = obj['cacAverage'];
    this.amplitudeFactor = obj['amplitudeFactor'];
    this.closedCause = obj['closedCause'];
    this.checkedWithdrawPt = obj['checkedWithdrawPt'];
    this.stayBalance = obj['stayBalance'];
    this.referrer = obj['referrer'];
    this.referrerName = obj['referrerName'];
    this.supportsChatroom = obj['supportsChatroom'];
    this.salesman = obj['salesman'];
    this.areaMaster = obj['areaMaster'];
    this.stage = obj['stage'];
    this.level = obj['level'];
  }
}

class MFSettingsOR {
  String id;
  int stayBalance;
  double withdrawIncomeRatio;
  double withdrawAbsorbRatio;
  double withdrawCommRatio;
  double withdrawShuntRatio;
  int refundLimitDay;
  double commissionStage1;
  double commissionStage2;
  double commissionStage3;
  double platformReturnLevel2;
  double platformReturnCityRatio;
  double platformReturnProvinceRatio;

  MFSettingsOR({
    this.id,
    this.stayBalance,
    this.withdrawIncomeRatio,
    this.withdrawAbsorbRatio,
    this.withdrawCommRatio,
    this.withdrawShuntRatio,
    this.refundLimitDay,
    this.commissionStage1,
    this.commissionStage2,
    this.commissionStage3,
    this.platformReturnLevel2,
    this.platformReturnCityRatio,
    this.platformReturnProvinceRatio,
  });

  MFSettingsOR.parse(obj) {
    this.id = obj['id'];
    this.stayBalance = obj['stayBalance'];
    this.withdrawIncomeRatio = obj['withdrawIncomeRatio'];
    this.withdrawAbsorbRatio = obj['withdrawAbsorbRatio'];
    this.withdrawCommRatio = obj['withdrawCommRatio'];
    this.withdrawShuntRatio = obj['withdrawShuntRatio'];
    this.refundLimitDay = obj['refundLimitDay'];
    this.commissionStage1 = obj['commissionStage1'];
    this.commissionStage2 = obj['commissionStage2'];
    this.commissionStage3 = obj['commissionStage3'];
    this.platformReturnLevel2 = obj['platformReturnLevel2'];
    this.platformReturnCityRatio = obj['platformReturnCityRatio'];
    this.platformReturnProvinceRatio = obj['platformReturnProvinceRatio'];
  }
}

class WithdrawShuntOR {
  int gainAmount;
  int shuntAmount;
  int absorbAmount;
  int commissionAmount;
  int incomeAmount;
  double withdrawIncomeRatio;
  double withdrawAbsorbRatio;
  double withdrawCommRatio;
  double withdrawShuntRatio;

  WithdrawShuntOR({
    this.gainAmount,
    this.shuntAmount,
    this.absorbAmount,
    this.commissionAmount,
    this.incomeAmount,
    this.withdrawIncomeRatio,
    this.withdrawAbsorbRatio,
    this.withdrawCommRatio,
    this.withdrawShuntRatio,
  });

  WithdrawShuntOR.parse(obj) {
    this.gainAmount = obj['gainAmount'];
    this.shuntAmount = obj['shuntAmount'];
    this.absorbAmount = obj['absorbAmount'];
    this.commissionAmount = obj['commissionAmount'];
    this.incomeAmount = obj['incomeAmount'];
    this.withdrawIncomeRatio = obj['withdrawIncomeRatio'];
    this.withdrawAbsorbRatio = obj['withdrawAbsorbRatio'];
    this.withdrawCommRatio = obj['withdrawCommRatio'];
    this.withdrawShuntRatio = obj['withdrawShuntRatio'];
  }
}

class BusinessIncomeRatioOR {
  String id;
  int minAmountEdge;
  int maxAmountEdge;
  double ratio;

  BusinessIncomeRatioOR({
    this.id,
    this.minAmountEdge,
    this.maxAmountEdge,
    this.ratio,
  });

  BusinessIncomeRatioOR.parse(obj) {
    this.id = obj['id'];
    this.minAmountEdge = obj['minAmountEdge'];
    this.maxAmountEdge = obj['maxAmountEdge'];
    this.ratio = obj['ratio'];
  }
}

mixin IFissionMFCashierRemote {
  Future<MFSettingsOR> getSettings();

  Future<WithdrawShuntOR> computeWithdrawShuntInfo(int amount);

  Future<void> recharge(int amount, String salesman);

  Future<CashierBalanceOR> getCashierBalance();

  Future<int> getStayBalance() {}

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
      {String province,
      String provinceCode,
      String city,
      String cityCode,
      String district,
      String districtCode,
      String town,
      String townCode}) {}

  Future<List<FissionMFTagOR>> listPropertyTagOfPerson(String person) {}

  Future<List<BusinessIncomeRatioOR>> listBusinessIncomeRatio() {}

  Future<void>setSalesman(String official) {}

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
  Future<void> recharge(int amount, String salesman) async {
    var details = <String, dynamic>{
      "payeeCode": "${principal.person}",
      "payeeName": "${principal.nickName}",
      "payeeType": "fission-mf",
      "orderno": "${MD5Util.MD5(Uuid().v1())}",
      "orderTitle": "付款到${principal.nickName}的裂变游戏·交个朋友出纳柜台",
      "serviceid": "fission/mf",
      "serviceName": "裂变游戏·交个朋友",
      "salesman": salesman,
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
  Future<int> getStayBalance() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getStayBalance',
      parameters: {},
    );
    if (obj == null) {
      return 0;
    }
    return obj;
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
  Future<WithdrawShuntOR> computeWithdrawShuntInfo(int amount) async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'computeWithdrawShuntInfo',
      parameters: {
        'amount': amount,
      },
    );
    if (obj == null) {
      return null;
    }
    return WithdrawShuntOR.parse(obj);
  }

  @override
  Future<List<BusinessIncomeRatioOR>> listBusinessIncomeRatio() async {
    var list = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'listBusinessIncomeRatio',
      parameters: {},
    );
    List<BusinessIncomeRatioOR> ratios = [];
    for (var obj in list) {
      ratios.add(BusinessIncomeRatioOR.parse(obj));
    }
    return ratios;
  }

  @override
  Future<Function> setSalesman(String official) async{
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'setSalesman',
      parameters: {
        'person':official,
      },
    );
  }

  @override
  Future<MFSettingsOR> getSettings() async {
    var obj = await remotePorts.portPOST(
      fissionMfCashierPorts,
      'getSettings',
      parameters: {},
    );
    if (obj == null) {
      return null;
    }
    return MFSettingsOR.parse(obj);
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
      {String province,
      String provinceCode,
      String city,
      String cityCode,
      String district,
      String districtCode,
      String town,
      String townCode}) async {
    await remotePorts.portPOST(
      fissionMfCashierPorts,
      'updateLocation',
      parameters: {
        'province': province,
        'city': city,
        'district': district,
        'town': town,
        'provinceCode': provinceCode,
        'cityCode': cityCode,
        'districtCode': districtCode,
        'townCode': townCode,
      },
      data: {
        'location': jsonEncode(location.toJson()),
      },
    );
  }
}
