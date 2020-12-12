import 'dart:convert';

import 'package:framework/framework.dart';

class TipOffTypeOR {
  String id;
  String title;

  TipOffTypeOR({this.id, this.title});

  TipOffTypeOR.parse(obj) {
    id = obj['id'];
    title = obj['title'];
  }
}

class TipOffDirectFormOR {
  String id;
  String typeId;
  String typeTitle;
  String realName;
  String phone;
  String content;
  String attachment;
  String creator;
  int state; //0为正在处理；-1为已关闭
  int ctime;

  TipOffDirectFormOR({
    this.id,
    this.typeId,
    this.typeTitle,
    this.realName,
    this.phone,
    this.content,
    this.attachment,
    this.creator,
    this.state,
    this.ctime,
  });

  TipOffDirectFormOR.parse(obj) {
    this.id = obj['id'];
    this.typeId = obj['typeId'];
    this.typeTitle = obj['typeTitle'];
    this.realName = obj['realName'];
    this.phone = obj['phone'];
    this.content = obj['content'];
    this.attachment = obj['attachment'];
    this.creator = obj['creator'];
    this.state = obj['state'];
    this.ctime = obj['ctime'];
  }
}

class TipOffObjectFormOR {
  String id;
  String typeId;
  String typeTitle;
  String objId;
  String objSummary;
  String content;
  String creator;
  int state; //0为正在处理；-1为已关闭
  int ctime;

  TipOffObjectFormOR({
    this.id,
    this.typeId,
    this.typeTitle,
    this.objId,
    this.objSummary,
    this.content,
    this.creator,
    this.state,
    this.ctime,
  });

  TipOffObjectFormOR.parse(obj) {
    this.id=obj['id'];
    this.typeId=obj['typeId'];
    this.typeTitle=obj['typeTitle'];
    this.objId=obj['objId'];
    this.objSummary=obj['objSummary'];
    this.content=obj['content'];
    this.creator=obj['creator'];
    this.state=obj['state'];
    this.ctime=obj['ctime'];
  }
}

mixin ITipOffRemote {
  Future<List<TipOffTypeOR>> listTipOffTypes() {}

  Future<TipOffDirectFormOR> getDirectForm(String id) {}

  Future<List<TipOffDirectFormOR>> pageDirectForm(int limit, int offset) {}

  Future<void> createDirectForm(String typeId, String realName, String phone,
      String content, String attachment);

  Future<void> closeDirectForm(String formId);

  Future<TipOffObjectFormOR> getObjectForm(String id) {}

  Future<List<TipOffObjectFormOR>> pageObjectForm(int limit, int offset) {}

  Future<void> createObjectForm(
    String typeId,
    String objId,
    String objSummary,
    String content,
  );

  Future<void> closeObjectForm(String formId);

  Future<List<TipOffObjectFormOR>>  pageOpenedObjectForm(int limit, int offset) {}

  Future<List<TipOffObjectFormOR>>  pageClosedObjectForm(int limit, int offset) {}

  Future<List<TipOffDirectFormOR>>  pageOpenedDirectForm(int limit, int offset) {}

  Future<List<TipOffDirectFormOR>>  pageClosedDirectForm(int limit, int offset) {}
}

class TipOffRemote implements ITipOffRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  String get tipoffPortsUrl => site.getService('@.prop.ports.feedback.tipoff');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<void> closeDirectForm(String formId) async {
    await remotePorts.portGET(
      tipoffPortsUrl,
      'closeDirectForm',
      parameters: {
        'formId': formId,
      },
    );
  }

  @override
  Future<void> closeObjectForm(String formId) async {
    await remotePorts.portGET(
      tipoffPortsUrl,
      'closeObjectForm',
      parameters: {
        'formId': formId,
      },
    );
  }

  @override
  Future<void> createDirectForm(String typeId, String realName, String phone,
      String content, String attachment) async {
    await remotePorts.portPOST(
      tipoffPortsUrl,
      'createDirectForm',
      parameters: {
        'typeId': typeId,
        'realName': realName,
        'phone': phone,
        'attachment': attachment,
      },
      data: {
        'content': content,
      },
    );
  }

  @override
  Future<void> createObjectForm(
      String typeId, String objId, String objSummary, String content) async {
    await remotePorts.portPOST(
      tipoffPortsUrl,
      'createObjectForm',
      parameters: {
        'typeId': typeId,
        'objId': objId,
      },
      data: {
        'objSummary': objSummary,
        'content': content,
      },
    );
  }

  @override
  Future<TipOffDirectFormOR> getDirectForm(String id) async {
    var obj = await remotePorts.portGET(
      tipoffPortsUrl,
      'getDirectForm',
      parameters: {
        'id': id,
      },
    );
    if (obj == null) {
      return null;
    }
    return TipOffDirectFormOR.parse(obj);
  }

  @override
  Future<TipOffObjectFormOR> getObjectForm(String id) async {
    var obj = await remotePorts.portGET(
      tipoffPortsUrl,
      'getObjectForm',
      parameters: {
        'id': id,
      },
    );
    if (obj == null) {
      return null;
    }
    return TipOffObjectFormOR.parse(obj);
  }

  @override
  Future<List<TipOffTypeOR>> listTipOffTypes() async {
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'listTipOffTypes',
      parameters: {},
    );
    var types = <TipOffTypeOR>[];
    for (var obj in list) {
      types.add(TipOffTypeOR.parse(obj));
    }
    return types;
  }

  @override
  Future<List<TipOffDirectFormOR>> pageDirectForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'pageDirectForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <TipOffDirectFormOR>[];
    for (var obj in list) {
      items.add(TipOffDirectFormOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<TipOffObjectFormOR>> pageObjectForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'pageObjectForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <TipOffObjectFormOR>[];
    for (var obj in list) {
      items.add(TipOffObjectFormOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<TipOffDirectFormOR>> pageClosedDirectForm(int limit, int offset)async {
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'pageClosedDirectForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <TipOffDirectFormOR>[];
    for (var obj in list) {
      items.add(TipOffDirectFormOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<TipOffDirectFormOR>> pageOpenedDirectForm(int limit, int offset)async {
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'pageOpenedDirectForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <TipOffDirectFormOR>[];
    for (var obj in list) {
      items.add(TipOffDirectFormOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<TipOffObjectFormOR>> pageClosedObjectForm(int limit, int offset) async{
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'pageClosedObjectForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <TipOffObjectFormOR>[];
    for (var obj in list) {
      items.add(TipOffObjectFormOR.parse(obj));
    }
    return items;
  }

  @override
  Future<List<TipOffObjectFormOR>> pageOpenedObjectForm(int limit, int offset)async {
    var list = await remotePorts.portGET(
      tipoffPortsUrl,
      'pageOpenedObjectForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <TipOffObjectFormOR>[];
    for (var obj in list) {
      items.add(TipOffObjectFormOR.parse(obj));
    }
    return items;
  }
}
