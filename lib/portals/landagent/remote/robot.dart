import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class AbsorberOR {
  String id;
  String title;
  String bankid;
  int usage;
  String absorbabler;
  LatLng location;
  int radius;
  int type;
  String creator;
  String ctime;
  int maxRecipients;
  int state;
  String exitCause;

  AbsorberOR(
      {this.id,
      this.title,
      this.bankid,
      this.usage,
      this.absorbabler,
      this.location,
      this.radius,
      this.type,
      this.creator,
      this.ctime,
      this.maxRecipients,
      this.state,
      this.exitCause});

  void updateBy(AbsorberOR absorberOR) {
    this.id = absorberOR.id;
    this.title = absorberOR.title;
    this.bankid = absorberOR.bankid;
    this.usage = absorberOR.usage;
    this.absorbabler = absorberOR.absorbabler;
    this.location = absorberOR.location;
    this.radius = absorberOR.radius;
    this.type = absorberOR.type;
    this.creator = absorberOR.creator;
    this.ctime = absorberOR.ctime;
    this.maxRecipients = absorberOR.maxRecipients;
    this.state = absorberOR.state;
    this.exitCause = absorberOR.exitCause;
  }

  AbsorberOR.parse(Map<String, dynamic> obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.bankid = obj['bankid'];
    this.usage = obj['usage'];
    this.absorbabler = obj['absorbabler'];
    this.location =
        obj['type'] == 1 ? LatLng.fromJson(jsonDecode(obj['location'])) : null;
    this.radius = obj['radius'];
    this.type = obj['type'];
    this.creator = obj['creator'];
    this.ctime = obj['ctime'];
    this.maxRecipients = obj['maxRecipients'];
    this.state = obj['state'];
    this.exitCause = obj['exitCause'];
  }
}

class AbsorbBucketOR {
  String absorber;
  String bank;
  double wInvestAmount;
  double pInvestAmount;
  double price;
  int times;
  String utime;

  AbsorbBucketOR(
      {this.absorber,
      this.bank,
      this.wInvestAmount,
      this.pInvestAmount,
      this.price,
      this.times,
      this.utime});

  AbsorbBucketOR.parse(Map<String, dynamic> obj) {
    absorber = obj['absorber'];
    bank = obj['bank'];
    wInvestAmount = obj['wInvestAmount'];
    pInvestAmount = obj['pInvestAmount'];
    price = obj['price'];
    times = obj['times'];
    utime = obj['utime'];
  }

  void updateBy(AbsorbBucketOR bucket) {
    this.absorber = bucket.absorber;
    this.bank = bucket.bank;
    this.wInvestAmount = bucket.wInvestAmount;
    this.pInvestAmount = bucket.pInvestAmount;
    this.price = bucket.price;
    this.times = bucket.times;
    this.utime = bucket.utime;
  }
}

class AbsorberResultOR {
  AbsorberOR absorber;
  AbsorbBucketOR bucket;

  AbsorberResultOR({this.absorber, this.bucket});

  void updateBy(AbsorberResultOR absorberOR) {
    absorber.updateBy(absorberOR.absorber);
    bucket.updateBy(absorberOR.bucket);
  }
}

class DomainBulletin {
  DomainBucket bucket;
  double absorbWeights;
  int absorbCount;

  DomainBulletin({this.bucket, this.absorbWeights, this.absorbCount});
}

class DomainBucket {
  String bank;
  double waaPrice;
  String utime;

  DomainBucket({this.bank, this.waaPrice, this.utime});
}

class RecipientsOR {
  String id;
  String person;
  String absorber;
  String personName;
  String ctime;
  double weight;
  String encourageCode;
  String encourageCause;
  int desireAmount;
  double distance;

  RecipientsOR({
    this.id,
    this.person,
    this.absorber,
    this.personName,
    this.ctime,
    this.weight,
    this.encourageCode,
    this.encourageCause,
    this.desireAmount,
    this.distance,
  });
}

class RecipientsSummaryOR {
  String person;
  String absorber;
  String personName;
  String ctime;
  double weights;
  String encourageCauses;

  RecipientsSummaryOR({
    this.person,
    this.absorber,
    this.personName,
    this.ctime,
    this.weights,
    this.encourageCauses,
  });
}

class RecipientsRecordOR {
  String sn;
  String recipient;
  double amount;
  String ctime;
  String refsn;
  String absorber;
  String encourageCode;
  String encourageCause;
  int order;
  int year;
  int month;
  String recipientsId;

  RecipientsRecordOR({
    this.sn,
    this.recipient,
    this.amount,
    this.ctime,
    this.refsn,
    this.absorber,
    this.encourageCode,
    this.encourageCause,
    this.recipientsId,
    this.month,
    this.year,
    this.order,
  });

  RecipientsRecordOR.parse(obj) {
    this.order = obj['order'];
    this.year = obj['year'];
    this.month = obj['month'];
    this.absorber = obj['absorber'];
    this.sn = obj['sn'];
    this.amount = obj['amount'];
    this.ctime = obj['ctime'];
    this.encourageCause = obj['encourageCause'];
    this.encourageCode = obj['encourageCode'];
    this.recipient = obj['recipient'];
    this.recipientsId = obj['recipientsId'];
    this.refsn = obj['refsn'];
  }
}

class InvestRecordOR {
  String sn;
  String absorber;
  int amount;
  String invester;
  String ctime;
  String personName;
  String outTradeSn;
  String investOrderNo;
  String investOrderTitle;
  int payStatus;
  String payMessage;
  String note;

  InvestRecordOR({
    this.sn,
    this.absorber,
    this.amount,
    this.invester,
    this.ctime,
    this.personName,
    this.outTradeSn,
    this.investOrderNo,
    this.investOrderTitle,
    this.payStatus,
    this.payMessage,
    this.note,
  });

  InvestRecordOR.parse(obj) {
    this.sn = obj['sn'];
    this.absorber = obj['absorber'];
    this.amount = obj['amount'];
    this.invester = obj['invester'];
    this.ctime = obj['ctime'];
    this.personName = obj['personName'];
    this.outTradeSn = obj['outTradeSn'];
    this.investOrderNo = obj['investOrderNo'];
    this.investOrderTitle = obj['investOrderTitle'];
    this.payStatus = obj['payStatus'] ?? 200;
    this.payMessage = obj['payMessage'];
    this.note = obj['note'];
  }
}

class WithdrawRecordOR {
  String sn;
  String bankid;
  String shunter;
  String alias;
  String withdrawer;
  String personName;
  int reqAmount;
  int realAmount;
  String ctime;
  String cBtime;
  int state;
  String refsn;
  String status;
  String message;

  WithdrawRecordOR(
      {this.sn,
      this.bankid,
      this.shunter,
      this.alias,
      this.withdrawer,
      this.personName,
      this.reqAmount,
      this.realAmount,
      this.ctime,
      this.cBtime,
      this.state,
      this.refsn,
      this.status,
      this.message});

  WithdrawRecordOR.parse(obj) {
    this.sn = obj['sn'];
    this.bankid = obj['bankid'];
    this.shunter = obj['shunter'];
    this.alias = obj['alias'];
    this.withdrawer = obj['withdrawer'];
    this.personName = obj['personName'];
    this.reqAmount = obj['reqAmount'];
    this.realAmount = obj['realAmount'];
    this.ctime = obj['ctime'];
    this.cBtime = obj['cBtime'];
    this.state = obj['state'];
    this.refsn = obj['refsn'];
    this.status = obj['status'];
    this.message = obj['message'];
  }
}

class HubTailsBillOR {
  String sn;
  String person;
  String refsn;
  double amount;
  int order;
  String bankid;
  double balance;
  String ctime;
  String note;
  String workday;
  int day;
  int month;
  int season;
  int year;

  HubTailsBillOR(
      {this.sn,
      this.person,
      this.refsn,
      this.amount,
      this.order,
      this.bankid,
      this.balance,
      this.ctime,
      this.note,
      this.workday,
      this.day,
      this.month,
      this.season,
      this.year});
}

class QrcodeSliceOR {
  String id;
  String href;
  String creator;
  String cname;
  String consumer;
  String template;
  String ctime;
  int expire;
  String location;
  int radius;
  int maxAbsorbers;
  String originAbsorber;
  String originPerson;
  String batchNo;
  int state;
  String note;
  Map<String, SlicePropOR> props;

  QrcodeSliceOR({
    this.id,
    this.href,
    this.creator,
    this.cname,
    this.consumer,
    this.template,
    this.ctime,
    this.expire,
    this.location,
    this.radius,
    this.maxAbsorbers,
    this.originAbsorber,
    this.originPerson,
    this.batchNo,
    this.state,
    this.note,
    this.props,
  });

  QrcodeSliceOR.parse(obj) {
    this.id = obj['id'];
    this.href = obj['href'];
    this.creator = obj['creator'];
    this.cname = obj['cname'];
    this.consumer = obj['consumer'];
    this.template = obj['template'];
    this.ctime = obj['ctime'];
    this.expire = obj['expire'];
    this.location = obj['location'];
    this.radius = obj['radius'];
    this.maxAbsorbers = obj['maxAbsorbers'];
    this.originAbsorber = obj['originAbsorber'];
    this.originPerson = obj['originPerson'];
    this.batchNo = obj['batchNo'];
    this.state = obj['state'];
    this.note = obj['note'];
    var propList = obj['properties'];
    if (propList != null) {
      this.props = <String, SlicePropOR>{};
      for (var pobj in propList) {
        var prop = SlicePropOR.parse(pobj);
        this.props[prop.propId] = prop;
      }
    }
  }
}

class SlicePropOR {
  String qrcodeSlice;
  String propId;
  String type;
  String name;
  String note;
  String value;

  SlicePropOR({
    this.qrcodeSlice,
    this.propId,
    this.type,
    this.name,
    this.note,
    this.value,
  });

  SlicePropOR.parse(obj) {
    this.qrcodeSlice = obj['qrcodeSlice'];
    this.propId = obj['propId'];
    this.name = obj['name'];
    this.type = obj['type'];
    this.note = obj['note'];
    this.value = obj['value'];
  }
}

class SliceTemplateOR {
  String id;
  String name;
  String ctime;
  String background;
  String note;
  String copyright;
  int maxAbsorbers;
  int ownerWeight;
  int participWeight;
  int ingeoWeight;
  Map<String, TemplatePropOR> props;

  SliceTemplateOR({
    this.id,
    this.name,
    this.ctime,
    this.background,
    this.note,
    this.copyright,
    this.maxAbsorbers,
    this.ownerWeight,
    this.participWeight,
    this.ingeoWeight,
    this.props,
  });

  SliceTemplateOR.parse(obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.ctime = obj['ctime'];
    this.background = obj['background'];
    this.note = obj['note'];
    this.copyright = obj['copyright'];
    this.maxAbsorbers = obj['maxAbsorbers'];
    this.ownerWeight = obj['ownerWeight'];
    this.participWeight = obj['participWeight'];
    this.ingeoWeight = obj['ingeoWeight'];
    var propList = obj['properties'];
    this.props = <String, TemplatePropOR>{};
    for (var pobj in propList) {
      var prop = TemplatePropOR.parse(pobj);
      this.props[prop.id] = prop;
    }
  }
}

class TemplatePropOR {
  String id;
  String name;
  String type;
  String template;
  String value;
  String note;

  TemplatePropOR({
    this.id,
    this.name,
    this.type,
    this.template,
    this.value,
    this.note,
  });

  TemplatePropOR.parse(obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.type = obj['type'];
    this.template = obj['template'];
    this.value = obj['value'];
    this.note = obj['note'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'template': template,
      'value': value,
      'note': note,
    };
  }
}

class SliceBatchOR {
  String id;
  String creator;
  String ctime;

  SliceBatchOR({
    this.id,
    this.creator,
    this.ctime,
  });

  SliceBatchOR.parse(obj) {
    this.id = obj['id'];
    this.creator = obj['creator'];
    this.ctime = obj['ctime'];
  }
}

class RecipientsRecordInfo {
  String sn;
  String absorber;
  int order;
  String person;
  String personName;
  String bankid;

  RecipientsRecordInfo({
    this.sn,
    this.absorber,
    this.order,
    this.person,
    this.personName,
    this.bankid,
  });

  RecipientsRecordInfo.parse(obj) {
    this.sn=obj['sn'];
    this.absorber=obj['absorber'];
    this.order=obj['order'];
    this.person=obj['person'];
    this.personName=obj['personName'];
    this.bankid=obj['bankid'];
  }

  dynamic toMap() {
    return {
      'sn':sn,
      'absorber':absorber,
      'order':order,
      'person':person,
      'personName':personName,
      'bankid':bankid,
    };
  }

}

mixin IRobotRemote {
  Future<double> getHubTails(String bankid) {}

  Future<List<AbsorberResultOR>> pageAbsorber(
      String bankid, int type, int limit, int offset) {}

  Future<List<AbsorberResultOR>> pageMyAbsorber(
      int type, int limit, int offset) {}

  Future<List<AbsorberResultOR>> pageMyAbsorberByUsage(
      int usage, int limit, int offset) {}

  Future<List<AbsorberResultOR>> pageJioninAbsorberByUsage(
      int usage, int limit, int offset) {}

  Future<List<RecipientsOR>> pageRecipients(String id, int limit, int offset) {}

  Future<List<RecipientsOR>> pageSimpleRecipientsOnlyMe(
      String absorberid, int limit, int offset) {}

  Future<List<RecipientsOR>> pageRecipientsOnlyMe(
      String id, int limit, int offset) {}

  Future<void> startAbsorber(String absorberid) {}

  Future<void> stopAbsorber(String absorberid, String exitCause) {}

  Future<void> investAbsorber(
      int amount, int type, Map<String, dynamic> details, note);

  Future<AbsorberResultOR> getAbsorber(String absorberid) {}

  Future<AbsorberResultOR> getAbsorberByAbsorbabler(String absorbabler) {}

  Future<double> totalRecipientsRecord(String absorber, String person) {}

  Future<List<RecipientsSummaryOR>> pageSimpleRecipients(
      String absorber, int limit, int offset) {}

  Future<double> totalRecipientsRecordById(String recipientsId) {}

  Future<double> totalRecipientsRecordWhere(
      String absorberid, String recipientsId) {}

  Future<double> totalRecipientsRecordByOrderWhere(
      String absorberid, String recipientsId, int order);

  Future<double> totalRecipientsRecordByOrderWhere2(
      String absorberid, String recipientsId, int order, int year, int month);

  Future<List<RecipientsRecordOR>> pageRecipientsRecordByPerson(
      String absorberid, String recipients, int limit, int offset) {}

  Future<List<RecipientsRecordOR>> pageRecipientsRecordById(
      String recipientsId, int limit, int offset) {}

  Future<List<RecipientsRecordOR>> pageRecipientsRecordWhere(
      String absorberid, String recipientsId, int limit, int offset);

  Future<List<RecipientsRecordOR>> pageRecipientsRecordWhere3(String absorberid,
      String recipientsId, int year, int month, int limit, int offset);

  Future<List<RecipientsRecordOR>> pageRecipientsRecordByOrderWhere(
      String absorberid, String recipientsId, int order, int limit, int offset);

  Future<List<RecipientsRecordOR>> pageRecipientsRecordByOrderWhere2(
      String absorberid,
      String recipientsId,
      int order,
      int year,
      int month,
      int limit,
      int offset);

  Future<List<InvestRecordOR>> pageInvestRecord(
      String absorber, int limit, int offset);

  Future<InvestRecordOR> getInvestRecord(String record_sn);

  Future<int> totalAmountInvests(String absorber);

  Future<List<WithdrawRecordOR>> pageWithdrawRecord(
      String bankid, int limit, int offset);

  Future<int> totalAmountWithdraws(String bankid);

  Future<double> totalInBillOfMonth(String bankid, DateTime selected) {}

  Future<double> totalOutBillOfMonth(String bankid, DateTime selected) {}

  Future<List<HubTailsBillOR>> pageBillOfMonth(
      String bankid, DateTime selected, int order, int limit, int offset) {}

  Future<List<HubTailsBillOR>> getBillOfMonth(
      String bankid, DateTime selected, int limit, int offset) {}

  Future<DomainBulletin> getDomainBucket(String bankid);

  withdrawHubTails(String bankid) {}

  Future<AbsorberOR> createGeoAbsorber(String bankid, String title, int usage,
      absorbabler, LatLng location, double radius) {}

  Future<AbsorberOR> createSimpleAbsorber(
      String bankid, String title, int usage, absorbabler, int maxRecipients) {}

  Future<AbsorberOR> createBalanceAbsorber(String bankid, String title,
      int usage, absorbabler, LatLng location, double radius) {}

  Future<bool> isBindingsAbsorbabler(String absorberid, String absorbabler) {}

  Future<void> bindAbsorbabler(String absorberid, String absorbabler) {}

  Future<void> unbindAbsorbabler(String absorberid) {}

  Future<void> updateAbsorberLocation(String absorberid, LatLng location) {}

  Future<void> updateAbsorberRadius(String absorberid, int radius) {}

  Future<int> countRecipients(String id) {}

  Future<void> addRecipients(String absorberid, String encourageCode,
      String encourageCause, int desireAmount);

  Future<void> addRecipients2(String absorberid, String person, String nickName,
      String encourageCode, String encourageCause, int desireAmount);

  Future<void> addRecipients3(String absorberid, String encourageCode,
      String encourageCause, int desireAmount);

  Future<void> removeRecipients(String absorberid, String person) {}

  Future<void> removeRecipients2(
      String absorberid, String person, String encourageCode) {}

  Future<void> removeRecipients3(String absorberid, String encourageCode) {}

  Future<bool> existsRecipients(String absorberid, String person) {}

  Future<bool> existsRecipients2(
      String absorberid, String person, String encourageCode) {}

  Future<void> updateMaxRecipients(String absorberid, int maxRecipients) {}

  Future<void> updateRecipientsWeights(recipientsId, double weights) {}

  Future<void> addCommentWeightsOfRecipients(String absorberid) {}

  Future<bool> subCommentWeightOfRecipients(String absorberid);

  Future<List<QrcodeSliceOR>> pageQrcodeSlice(int limit, int offset) {}

  Future<List<QrcodeSliceOR>> pageQrcodeSliceOfBatch(
      String selectedBatchNo, int limit, int offset) {}

  Future<SliceTemplateOR> getQrcodeSliceTemplate(String id) {}

  Future<List<SliceTemplateOR>> pageQrcodeSliceTemplate(
      int limit, int offset) {}

  Future<List<SliceBatchOR>> pageQrcodeSliceBatch(int limit, int offset) {}

  Future<List<QrcodeSliceOR>> createQrcodeSlice(
      String template,
      int expire,
      LatLng location,
      int radius,
      String originAbsorber,
      String originPerson,
      int count,
      Map<String, TemplatePropOR> props,
      String note) {}

  Future<void> addQrcodeSliceRecipients(
      String absorberid, String qrcodeSlice) {}

  Future<bool> canntPubSliceRecipients(String absorberid) {}

  Future<bool> cannotCreateQrocdeSlice() {}

  Future<List<QrcodeSliceOR>> listUnconsumeSlices() {}

  Future<RecipientsRecordInfo> getRecipientsRecordInfo(outTradeSn) {}
}

class RobotRemote implements IRobotRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get robotHubPorts => site.getService('@.prop.ports.robot.hub');

  get robotRecordPorts => site.getService('@.prop.ports.robot.record');

  get walletTradePorts => site.getService('@.prop.ports.wallet.trade.receipt');

  get robotHubTailsPorts => site.getService('@.prop.ports.robot.hubTails');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<double> getHubTails(String bankid) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'getHubTails',
      parameters: {
        'bankid': bankid,
      },
    );
    if (obj == null) {
      return 0.00;
    }
    return obj['tailAdmount'];
  }

  @override
  Future<int> countRecipients(String absorberid) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'countRecipients',
      parameters: {
        'absorberid': absorberid,
      },
    );
    return obj;
  }

  @override
  Future<DomainBulletin> getDomainBucket(String bankid) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'getDomainBucket',
      parameters: {
        'bankid': bankid,
      },
    );
    if (obj == null) {
      return null;
    }
    var bucket = obj['bucket'];

    return DomainBulletin(
      absorbCount: obj['absorbCount'],
      absorbWeights: obj['absorbWeights'],
      bucket: DomainBucket(
        bank: bucket['bank'],
        utime: bucket['utime'],
        waaPrice: bucket['waaPrice'],
      ),
    );
  }

  @override
  Future<List<AbsorberResultOR>> pageAbsorber(
      String bankid, int type, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageAbsorber',
      parameters: {
        'bankid': bankid,
        'type': type,
        'limit': limit,
        'offset': offset,
      },
    );
    var results = <AbsorberResultOR>[];
    for (var result in list) {
      var absorber = result['absorber'];
      var bucket = result['bucket'];
      results.add(
        AbsorberResultOR(
          absorber: AbsorberOR.parse(absorber),
          bucket: AbsorbBucketOR.parse(bucket),
        ),
      );
    }

    return results;
  }

  @override
  Future<List<AbsorberResultOR>> pageMyAbsorber(
      int type, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageMyAbsorber',
      parameters: {
        'type': type,
        'limit': limit,
        'offset': offset,
      },
    );
    var results = <AbsorberResultOR>[];
    for (var result in list) {
      var absorber = result['absorber'];
      var bucket = result['bucket'];
      results.add(
        AbsorberResultOR(
          absorber: AbsorberOR.parse(absorber),
          bucket: AbsorbBucketOR.parse(bucket),
        ),
      );
    }

    return results;
  }

  @override
  Future<List<AbsorberResultOR>> pageMyAbsorberByUsage(
      int usage, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageMyAbsorberByUsage',
      parameters: {
        'usage': usage,
        'limit': limit,
        'offset': offset,
      },
    );
    var results = <AbsorberResultOR>[];
    for (var result in list) {
      var absorber = result['absorber'];
      var bucket = result['bucket'];
      results.add(
        AbsorberResultOR(
          absorber: AbsorberOR.parse(absorber),
          bucket: AbsorbBucketOR.parse(bucket),
        ),
      );
    }

    return results;
  }

  @override
  Future<List<AbsorberResultOR>> pageJioninAbsorberByUsage(
      int usage, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageJioninAbsorberByUsage',
      parameters: {
        'usage': usage,
        'limit': limit,
        'offset': offset,
      },
    );
    var results = <AbsorberResultOR>[];
    for (var result in list) {
      var absorber = result['absorber'];
      var bucket = result['bucket'];
      results.add(
        AbsorberResultOR(
          absorber: AbsorberOR.parse(absorber),
          bucket: AbsorbBucketOR.parse(bucket),
        ),
      );
    }

    return results;
  }

  @override
  Future<List<RecipientsOR>> pageRecipients(
      String absorberid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageRecipients',
      parameters: {
        'absorberid': absorberid,
        'limit': limit,
        'offset': offset,
      },
    );
    var recipients = <RecipientsOR>[];
    for (var obj in list) {
      recipients.add(
        RecipientsOR(
          weight: obj['weight'],
          ctime: obj['ctime'],
          id: obj['id'],
          personName: obj['personName'],
          absorber: obj['absorber'],
          desireAmount: obj['desireAmount'],
          encourageCause: obj['encourageCause'],
          encourageCode: obj['encourageCode'],
          person: obj['person'],
          distance: obj['distance'] == null
              ? null
              : double.parse('${obj['distance']}'),
        ),
      );
    }
    return recipients;
  }

  @override
  Future<List<RecipientsOR>> pageSimpleRecipientsOnlyMe(
      String absorberid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageSimpleRecipientsOnlyMe',
      parameters: {
        'absorberid': absorberid,
        'limit': limit,
        'offset': offset,
      },
    );
    var recipients = <RecipientsOR>[];
    for (var obj in list) {
      recipients.add(
        RecipientsOR(
          weight: obj['weight'],
          ctime: obj['ctime'],
          id: obj['id'],
          personName: obj['personName'],
          absorber: obj['absorber'],
          desireAmount: obj['desireAmount'],
          encourageCause: obj['encourageCause'],
          encourageCode: obj['encourageCode'],
          person: obj['person'],
          distance: obj['distance'] == null
              ? null
              : double.parse('${obj['distance']}'),
        ),
      );
    }
    return recipients;
  }

  @override
  Future<List<RecipientsOR>> pageRecipientsOnlyMe(
      String absorberid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageRecipientsOnlyMe',
      parameters: {
        'absorberid': absorberid,
        'limit': limit,
        'offset': offset,
      },
    );
    var recipients = <RecipientsOR>[];
    for (var obj in list) {
      recipients.add(
        RecipientsOR(
          weight: obj['weight'],
          ctime: obj['ctime'],
          id: obj['id'],
          personName: obj['personName'],
          absorber: obj['absorber'],
          desireAmount: obj['desireAmount'],
          encourageCause: obj['encourageCause'],
          encourageCode: obj['encourageCode'],
          person: obj['person'],
          distance: obj['distance'] == null
              ? null
              : double.parse('${obj['distance']}'),
        ),
      );
    }
    return recipients;
  }

  @override
  Future<void> startAbsorber(String absorberid) async {
    await remotePorts.portGET(
      robotHubPorts,
      'startAbsorber',
      parameters: {
        'absorberid': absorberid,
      },
    );
  }

  @override
  Future<void> stopAbsorber(String absorberid, String exitCause) async {
    await remotePorts.portGET(
      robotHubPorts,
      'stopAbsorber',
      parameters: {
        'absorberid': absorberid,
        'exitCause': exitCause,
      },
    );
  }

  @override
  Future<void> investAbsorber(
      int amount, int type, Map<String, dynamic> details, note) async {
    await remotePorts.portPOST(
      walletTradePorts,
      'payTrade',
      parameters: {
        'amount': amount,
        'type': type,
        'note': note,
      },
      data: {
        'details': jsonEncode(details),
      },
    );
  }

  @override
  Future<AbsorberResultOR> getAbsorber(String absorberid) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'getAbsorber',
      parameters: {
        'absorberid': absorberid,
      },
    );
    var absorber = obj['absorber'];
    var bucket = obj['bucket'];
    return AbsorberResultOR(
      absorber: AbsorberOR.parse(absorber),
      bucket: AbsorbBucketOR.parse(bucket),
    );
  }

  @override
  Future<AbsorberResultOR> getAbsorberByAbsorbabler(String absorbabler) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'getAbsorberByAbsorbabler',
      parameters: {
        'absorbabler': absorbabler,
      },
    );
    if (obj == null) {
      return null;
    }
    var absorber = obj['absorber'];
    var bucket = obj['bucket'];
    return AbsorberResultOR(
      absorber: AbsorberOR.parse(absorber),
      bucket: AbsorbBucketOR.parse(bucket),
    );
  }

  @override
  Future<double> totalRecipientsRecord(String absorber, String person) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecord',
      parameters: {
        'absorber': absorber,
        'recipients': person,
      },
    );
  }

  @override
  Future<double> totalRecipientsRecordById(String recipientsId) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecordById',
      parameters: {
        'recipientsId': recipientsId,
      },
    );
  }

  @override
  Future<double> totalRecipientsRecordWhere(
      String absorberid, String recipientsId) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecordWhere',
      parameters: {
        'absorberid': absorberid,
        'recipientsId': recipientsId,
      },
    );
  }

  @override
  Future<double> totalRecipientsRecordByOrderWhere(
      String absorberid, String recipientsId, int order) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecordByOrderWhere',
      parameters: {
        'absorberid': absorberid,
        'recipientsId': recipientsId,
        'order': order,
      },
    );
  }

  @override
  Future<double> totalRecipientsRecordByOrderWhere2(String absorberid,
      String recipientsId, int order, int year, int month) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalRecipientsRecordByOrderWhere2',
      parameters: {
        'absorberid': absorberid,
        'recipientsId': recipientsId,
        'order': order,
        'year': year,
        'month': month,
      },
    );
  }

  @override
  Future<List<RecipientsSummaryOR>> pageSimpleRecipients(
      String absorber, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageSimpleRecipients',
      parameters: {
        'absorberid': absorber,
        'limit': limit,
        'offset': offset,
      },
    );
    var recipients = <RecipientsSummaryOR>[];
    for (var obj in list) {
      recipients.add(
        RecipientsSummaryOR(
          weights: obj['weights'],
          ctime: obj['ctime'],
          personName: obj['personName'],
          absorber: obj['absorber'],
          encourageCauses: obj['encourageCauses'],
          person: obj['person'],
        ),
      );
    }
    return recipients;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordByPerson(
      String absorberid, String recipients, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordByPerson',
      parameters: {
        'absorberid': absorberid,
        'recipients': recipients,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordById(
      String recipientsId, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordById',
      parameters: {
        'recipientsId': recipientsId,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordWhere(
      String absorberid, String recipientsId, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordWhere',
      parameters: {
        'absorber': absorberid,
        'recipientsId': recipientsId,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordWhere3(String absorberid,
      String recipientsId, int year, int month, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordWhere3',
      parameters: {
        'absorber': absorberid,
        'recipientsId': recipientsId,
        'year': year,
        'month': month,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordByOrderWhere(
      String absorberid,
      String recipientsId,
      int order,
      int limit,
      int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordByOrderWhere',
      parameters: {
        'absorber': absorberid,
        'recipientsId': recipientsId,
        'order': order,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<List<RecipientsRecordOR>> pageRecipientsRecordByOrderWhere2(
      String absorberid,
      String recipientsId,
      int order,
      int year,
      int month,
      int limit,
      int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageRecipientsRecordByOrderWhere2',
      parameters: {
        'absorber': absorberid,
        'recipientsId': recipientsId,
        'order': order,
        'year': year,
        'month': month,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <RecipientsRecordOR>[];
    for (var obj in list) {
      recordList.add(
        RecipientsRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<InvestRecordOR> getInvestRecord(String record_sn) async {
    var obj = await remotePorts.portGET(
      robotRecordPorts,
      'getInvestRecord',
      parameters: {
        'record_sn': record_sn,
      },
    );
    if (obj == null) {
      return null;
    }
    return InvestRecordOR.parse(obj);
  }

  @override
  Future<List<InvestRecordOR>> pageInvestRecord(
      String absorber, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageInvestRecord',
      parameters: {
        'absorber': absorber,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <InvestRecordOR>[];
    for (var obj in list) {
      recordList.add(
        InvestRecordOR.parse(obj),
      );
    }
    return recordList;
  }

  @override
  Future<int> totalAmountInvests(String absorber) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalAmountInvests',
      parameters: {
        'absorber': absorber,
      },
    );
  }

  @override
  Future<List<WithdrawRecordOR>> pageWithdrawRecord(
      String bankid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotRecordPorts,
      'pageWithdrawRecord',
      parameters: {
        'bankid': bankid,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <WithdrawRecordOR>[];
    for (var obj in list) {
      recordList.add(
        WithdrawRecordOR(
          personName: obj['personName'],
          ctime: obj['ctime'],
          sn: obj['sn'],
          refsn: obj['refsn'],
          state: obj['state'],
          bankid: obj['bankid'],
          shunter: obj['shunter'],
          alias: obj['alias'],
          reqAmount: obj['reqAmount'],
          realAmount: obj['realAmount'],
          status: obj['status'],
          message: obj['message'],
          cBtime: obj['cBtime'],
          withdrawer: obj['withdrawer'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<int> totalAmountWithdraws(String bankid) async {
    return await remotePorts.portGET(
      robotRecordPorts,
      'totalAmountWithdraws',
      parameters: {
        'bankid': bankid,
      },
    );
  }

  @override
  Future<double> totalInBillOfMonth(String bankid, DateTime selected) async {
    var v = await remotePorts.portGET(
      robotHubTailsPorts,
      'totalInBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': selected.year,
        'month': selected.month - 1,
      },
    );
    if (v == null) {
      return 0.00;
    }
    return double.parse(v);
  }

  @override
  Future<double> totalOutBillOfMonth(String bankid, DateTime selected) async {
    var v = await remotePorts.portGET(
      robotHubTailsPorts,
      'totalOutBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': selected.year,
        'month': selected.month - 1,
      },
    );
    if (v == null) {
      return 0.00;
    }
    return double.parse(v);
  }

  @override
  Future<List<HubTailsBillOR>> getBillOfMonth(
      String bankid, DateTime selected, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubTailsPorts,
      'getBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'year': selected.year,
        'month': selected.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <HubTailsBillOR>[];
    for (var obj in list) {
      recordList.add(
        HubTailsBillOR(
          bankid: obj['bankid'],
          refsn: obj['refsn'],
          sn: obj['sn'],
          ctime: obj['ctime'],
          note: obj['note'],
          amount: obj['amount'],
          person: obj['person'],
          year: obj['year'],
          workday: obj['workday'],
          season: obj['season'],
          order: obj['order'],
          month: obj['month'],
          day: obj['day'],
          balance: obj['balance'],
        ),
      );
    }
    return recordList;
  }

  @override
  Future<List<HubTailsBillOR>> pageBillOfMonth(String bankid, DateTime selected,
      int order, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubTailsPorts,
      'pageBillOfMonth',
      parameters: {
        'wenyBankID': bankid,
        'order': order,
        'year': selected.year,
        'month': selected.month - 1,
        'limit': limit,
        'offset': offset,
      },
    );
    var recordList = <HubTailsBillOR>[];
    for (var obj in list) {
      recordList.add(
        HubTailsBillOR(
          bankid: obj['bankid'],
          refsn: obj['refsn'],
          sn: obj['sn'],
          ctime: obj['ctime'],
          note: obj['note'],
          amount: obj['amount'],
          person: obj['person'],
          year: obj['year'],
          workday: obj['workday'],
          season: obj['season'],
          order: obj['order'],
          month: obj['month'],
          day: obj['day'],
          balance: obj['balance'],
        ),
      );
    }
    return recordList;
  }

  @override
  withdrawHubTails(String bankid) async {
    await remotePorts.portGET(
      robotHubPorts,
      'withdrawHubTails',
      parameters: {
        'bankid': bankid,
      },
    );
  }

  @override
  Future<AbsorberOR> createGeoAbsorber(String bankid, String title, int usage,
      absorbabler, LatLng location, double radius) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'createGeoAbsorber',
      parameters: {
        'bankid': bankid,
        'title': title,
        'usage': usage,
        'absorbabler': absorbabler,
        'location': jsonEncode(location),
        'radius': radius,
      },
    );
    if (obj == null) {
      return null;
    }
    return AbsorberOR.parse(obj);
  }

  @override
  Future<AbsorberOR> createBalanceAbsorber(String bankid, String title,
      int usage, absorbabler, LatLng location, double radius) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'createBalanceAbsorber',
      parameters: {
        'bankid': bankid,
        'title': title,
        'usage': usage,
        'absorbabler': absorbabler,
        'location': jsonEncode(location),
        'radius': radius,
      },
    );
    if (obj == null) {
      return null;
    }
    return AbsorberOR.parse(obj);
  }

  @override
  Future<AbsorberOR> createSimpleAbsorber(String bankid, String title,
      int usage, absorbabler, int maxRecipients) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'createSimpleAbsorber',
      parameters: {
        'bankid': bankid,
        'title': title,
        'usage': usage,
        'absorbabler': absorbabler,
        'maxRecipients': maxRecipients,
      },
    );
    if (obj == null) {
      return null;
    }
    return AbsorberOR.parse(obj);
  }

  @override
  Future<bool> isBindingsAbsorbabler(
      String absorberid, String absorbabler) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'isBindingsAbsorbabler',
      parameters: {
        'absorberid': absorberid,
        'absorbabler': absorbabler,
      },
    );
    if (obj == null) {
      return false;
    }
    return obj;
  }

  @override
  Future<void> bindAbsorbabler(String absorberid, String absorbabler) async {
    await remotePorts.portGET(
      robotHubPorts,
      'bindAbsorbabler',
      parameters: {
        'absorberid': absorberid,
        'absorbabler': absorbabler,
      },
    );
  }

  @override
  Future<void> unbindAbsorbabler(String absorberid) async {
    await remotePorts.portGET(
      robotHubPorts,
      'unbindAbsorbabler',
      parameters: {
        'absorberid': absorberid,
      },
    );
  }

  @override
  Future<void> updateAbsorberLocation(
      String absorberid, LatLng location) async {
    await remotePorts.portGET(
      robotHubPorts,
      'updateAbsorberLocation',
      parameters: {
        'absorberid': absorberid,
        'location': jsonEncode(location.toJson()),
      },
    );
  }

  @override
  Future<void> updateAbsorberRadius(String absorberid, int radius) async {
    await remotePorts.portGET(
      robotHubPorts,
      'updateAbsorberRadius',
      parameters: {
        'absorberid': absorberid,
        'radius': radius,
      },
    );
  }

  @override
  Future<void> addRecipients(String absorberid, String encourageCode,
      String encourageCause, int desireAmount) async {
    await remotePorts.portGET(
      robotHubPorts,
      'addRecipients',
      parameters: {
        'absorberid': absorberid,
        'encourageCode': encourageCode,
        'encourageCause': encourageCause,
        'desireAmount': desireAmount,
      },
    );
  }

  @override
  Future<void> addRecipients2(String absorberid, String person, String nickName,
      String encourageCode, String encourageCause, int desireAmount) async {
    await remotePorts.portGET(
      robotHubPorts,
      'addRecipients2',
      parameters: {
        'absorberid': absorberid,
        'person': person,
        'nickName': nickName,
        'encourageCode': encourageCode,
        'encourageCause': encourageCause,
        'desireAmount': desireAmount,
      },
    );
  }

  @override
  Future<void> addRecipients3(String absorberid, String encourageCode,
      String encourageCause, int desireAmount) async {
    await remotePorts.portGET(
      robotHubPorts,
      'addRecipients',
      parameters: {
        'absorberid': absorberid,
        'encourageCode': encourageCode,
        'encourageCause': encourageCause,
        'desireAmount': desireAmount,
      },
    );
  }

  @override
  Future<void> removeRecipients(String absorberid, String person) async {
    await remotePorts.portGET(
      robotHubPorts,
      'removeRecipients',
      parameters: {
        'absorberid': absorberid,
        'person': person,
      },
    );
  }

  @override
  Future<Function> removeRecipients2(
      String absorberid, String person, String encourageCode) async {
    await remotePorts.portGET(
      robotHubPorts,
      'removeRecipients2',
      parameters: {
        'absorberid': absorberid,
        'person': person,
        'encourageCode': encourageCode,
      },
    );
  }

  @override
  Future<Function> removeRecipients3(
      String absorberid, String encourageCode) async {
    await remotePorts.portGET(
      robotHubPorts,
      'removeRecipients3',
      parameters: {
        'absorberid': absorberid,
        'encourageCode': encourageCode,
      },
    );
  }

  @override
  Future<bool> existsRecipients(String absorberid, String person) async {
    return await remotePorts.portGET(
      robotHubPorts,
      'existsRecipients',
      parameters: {
        'absorberid': absorberid,
        'person': person,
      },
    );
  }

  @override
  Future<bool> existsRecipients2(
      String absorberid, String person, String encourageCode) async {
    return await remotePorts.portGET(
      robotHubPorts,
      'existsRecipients2',
      parameters: {
        'absorberid': absorberid,
        'person': person,
        'encourageCode': encourageCode,
      },
    );
  }

  @override
  Future<void> updateMaxRecipients(String absorberid, int maxRecipients) async {
    await remotePorts.portGET(
      robotHubPorts,
      'updateMaxRecipients',
      parameters: {
        'absorberid': absorberid,
        'maxRecipients': maxRecipients,
      },
    );
  }

  @override
  Future<void> updateRecipientsWeights(recipientsId, double weights) async {
    await remotePorts.portGET(
      robotHubPorts,
      'updateRecipientsWeights',
      parameters: {
        'recipientsId': recipientsId,
        'weights': weights,
      },
    );
  }

  @override
  Future<Function> addCommentWeightsOfRecipients(String absorberid) async {
    await remotePorts.portGET(
      robotHubPorts,
      'addCommentWeightsOfRecipients',
      parameters: {
        'absorberid': absorberid,
        'encourageCode': 'comment',
      },
    );
  }

  @override
  Future<bool> subCommentWeightOfRecipients(String absorberid) async {
    return await remotePorts.portGET(
      robotHubPorts,
      'subCommentWeightOfRecipients',
      parameters: {
        'absorberid': absorberid,
        'encourageCode': 'comment',
      },
    );
  }

  @override
  Future<List<QrcodeSliceOR>> pageQrcodeSlice(int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageQrcodeSlice',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var slices = <QrcodeSliceOR>[];
    for (var slice in list) {
      slices.add(
        QrcodeSliceOR.parse(slice),
      );
    }
    return slices;
  }

  @override
  Future<List<QrcodeSliceOR>> pageQrcodeSliceOfBatch(
      String selectedBatchNo, int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageQrcodeSliceOfBatch',
      parameters: {
        'limit': limit,
        'offset': offset,
        'batchno': selectedBatchNo,
      },
    );
    var slices = <QrcodeSliceOR>[];
    for (var slice in list) {
      slices.add(
        QrcodeSliceOR.parse(slice),
      );
    }
    return slices;
  }

  @override
  Future<SliceTemplateOR> getQrcodeSliceTemplate(String id) async {
    var obj = await remotePorts.portGET(
      robotHubPorts,
      'getQrcodeSliceTemplate',
      parameters: {
        'id': id,
      },
    );
    if (obj == null) {
      return null;
    }
    return SliceTemplateOR.parse(obj);
  }

  @override
  Future<List<SliceTemplateOR>> pageQrcodeSliceTemplate(
      int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageQrcodeSliceTemplate',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<SliceTemplateOR> items = [];
    for (var obj in list) {
      items.add(SliceTemplateOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<SliceBatchOR>> pageQrcodeSliceBatch(int limit, int offset) async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'pageQrcodeSliceBatch',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<SliceBatchOR> items = [];
    for (var obj in list) {
      items.add(SliceBatchOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<QrcodeSliceOR>> createQrcodeSlice(
      String template,
      int expire,
      LatLng location,
      int radius,
      String originAbsorber,
      String originPerson,
      int count,
      Map<String, TemplatePropOR> props,
      String note) async {
    Map<String, Map<String, dynamic>> _props = {};
    for (String key in props.keys) {
      var p = props[key];
      _props[key] = p.toJson();
    }
    var list = await remotePorts.portGET(
      robotHubPorts,
      'createQrcodeSlice',
      parameters: {
        'template': template,
        'expire': expire,
        'location': jsonEncode(location.toJson()),
        'radius': radius,
        'originAbsorber': originAbsorber,
        'originPerson': originPerson,
        'count': count,
        'props': jsonEncode(_props),
        'note': note,
      },
    );
    List<QrcodeSliceOR> items = [];
    for (var obj in list) {
      items.add(QrcodeSliceOR.parse(obj));
    }
    return items;
  }

  @override
  Future<void> addQrcodeSliceRecipients(
      String absorberid, String qrcodeSlice) async {
    await remotePorts.portGET(
      robotHubPorts,
      'addQrcodeSliceRecipients',
      parameters: {
        'absorberid': absorberid,
        'qrcodeSlice': qrcodeSlice,
      },
    );
  }

  @override
  Future<bool> canntPubSliceRecipients(String absorberid) async {
    return await remotePorts.portGET(
      robotHubPorts,
      'canntPubSliceRecipients',
      parameters: {
        'absorberid': absorberid,
      },
    );
  }

  @override
  Future<bool> cannotCreateQrocdeSlice() async {
    return await remotePorts.portGET(
      robotHubPorts,
      'cannotCreateQrocdeSlice',
    );
  }

  @override
  Future<List<QrcodeSliceOR>> listUnconsumeSlices() async {
    var list = await remotePorts.portGET(
      robotHubPorts,
      'listUnconsumeSlices',
      parameters: {},
    );
    List<QrcodeSliceOR> items = [];
    for (var obj in list) {
      items.add(QrcodeSliceOR.parse(obj));
    }
    return items;
  }

  @override
  Future<RecipientsRecordInfo> getRecipientsRecordInfo(outTradeSn) async {
    var obj = await remotePorts.portGET(
      robotRecordPorts,
      'getRecipientsRecordInfo',
      parameters: {
        'record_sn': outTradeSn,
      },
    );
    if (obj == null) {
      return null;
    }
    return RecipientsRecordInfo.parse(obj);
  }
}
