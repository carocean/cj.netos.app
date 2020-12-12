import 'package:framework/framework.dart';

class WOTypeOR {
  String id;
  String title;

  WOTypeOR({this.id, this.title});

  WOTypeOR.parse(obj) {
    id = obj['id'];
    title = obj['title'];
  }
}

class WOFormOR {
  String id;
  String typeId;
  String typeTitle;
  String phone;
  String content;
  String attachment;
  String creator;
  int ctime;
  int state; //0是开始步骤；1是过程；-1是结束；

  WOFormOR({
    this.id,
    this.typeId,
    this.typeTitle,
    this.phone,
    this.content,
    this.attachment,
    this.creator,
    this.ctime,
    this.state,
  });

  WOFormOR.parse(obj) {
    this.id = obj['id'];
    this.typeId = obj['typeId'];
    this.typeTitle = obj['typeTitle'];
    this.phone = obj['phone'];
    this.content = obj['content'];
    this.attachment = obj['attachment'];
    this.creator = obj['creator'];
    this.ctime = obj['ctime'];
    this.state = obj['state'];
  }
}

class WOFlowActivityOR {
  String id;
  String content;
  String attachment;
  String formId;
  String participant;
  int type; //0是开始步骤；1是过程；-1是结束；
  int ctime;

  WOFlowActivityOR({
    this.id,
    this.content,
    this.attachment,
    this.formId,
    this.participant,
    this.type,
    this.ctime,
  });

  WOFlowActivityOR.parse(obj) {
    this.id = obj['id'];
    this.content = obj['content'];
    this.attachment = obj['attachment'];
    this.formId = obj['formId'];
    this.participant = obj['participant'];
    this.type = obj['type'];
    this.ctime = obj['ctime'];
  }
}

mixin IWOFlowRemote {
  Future<void> createWOForm(
      String typeId, String phone, String content, String attachment);

  Future<List<WOTypeOR>> listWOTypes();

  Future<List<WOFormOR>> pageMyForm(int limit, int offset) {}

  Future<List<WOFlowActivityOR>> listActivities(String formId);

  Future<WOFlowActivityOR> send(
      String formId, String content, String attachment);

  Future<List<WOFormOR>> pageClosedFormByType(
      String typeId, int limit, int offset) {}

  Future<List<WOFormOR>> pageOpenedForm(int limit, int offset) {}

  Future<List<WOFormOR>> pageClosedForm(int limit, int offset) {}

  Future<List<WOFormOR>> pageAllForm(int limit, int offset) {}

  Future<WOFlowActivityOR> sendAndCloseFlow(
      String formId, String content, String attachment) {}
}

class WOFlowRemote implements IWOFlowRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  String get woflowPortsUrl => site.getService('@.prop.ports.feedback.woflow');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<List<WOTypeOR>> listWOTypes() async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'listWOTypes',
      parameters: {},
    );
    List<WOTypeOR> types = [];
    for (var obj in list) {
      types.add(WOTypeOR.parse(obj));
    }
    return types;
  }

  @override
  Future<void> createWOForm(
      String typeId, String phone, String content, String attachment) async {
    await remotePorts.portPOST(
      woflowPortsUrl,
      'createWOForm',
      parameters: {
        'typeId': typeId,
        'phone': phone,
        'attachment': attachment,
      },
      data: {
        'content': content,
      },
    );
  }

  @override
  Future<List<WOFormOR>> pageMyForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'pageMyForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<WOFormOR> forms = [];
    for (var obj in list) {
      forms.add(WOFormOR.parse(obj));
    }
    return forms;
  }

  @override
  Future<List<WOFormOR>> pageAllForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'pageAllForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<WOFormOR> forms = [];
    for (var obj in list) {
      forms.add(WOFormOR.parse(obj));
    }
    return forms;
  }

  @override
  Future<List<WOFormOR>> pageClosedFormByType(
      String typeId, int limit, int offset) async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'pageClosedFormByType',
      parameters: {
        'typeId': typeId,
        'limit': limit,
        'offset': offset,
      },
    );
    List<WOFormOR> forms = [];
    for (var obj in list) {
      forms.add(WOFormOR.parse(obj));
    }
    return forms;
  }

  @override
  Future<List<WOFormOR>> pageOpenedForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'pageOpenedForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<WOFormOR> forms = [];
    for (var obj in list) {
      forms.add(WOFormOR.parse(obj));
    }
    return forms;
  }

  @override
  Future<List<WOFormOR>> pageClosedForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'pageClosedForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<WOFormOR> forms = [];
    for (var obj in list) {
      forms.add(WOFormOR.parse(obj));
    }
    return forms;
  }

  Future<List<WOFlowActivityOR>> listActivities(String formId) async {
    var list = await remotePorts.portGET(
      woflowPortsUrl,
      'listActivities',
      parameters: {
        'formId': formId,
      },
    );
    List<WOFlowActivityOR> activities = [];
    for (var obj in list) {
      activities.add(WOFlowActivityOR.parse(obj));
    }
    return activities;
  }

  @override
  Future<WOFlowActivityOR> send(
      String formId, String content, String attachment) async {
    var obj = await remotePorts.portPOST(
      woflowPortsUrl,
      'send',
      parameters: {
        'formId': formId,
        'attachment': attachment,
      },
      data: {
        'content': content,
      },
    );
    return WOFlowActivityOR.parse(obj);
  }

  @override
  Future<WOFlowActivityOR> sendAndCloseFlow(
      String formId, String content, String attachment) async {
    var obj = await remotePorts.portPOST(
      woflowPortsUrl,
      'sendAndCloseFlow',
      parameters: {
        'formId': formId,
        'attachment': attachment,
      },
      data: {
        'content': content,
      },
    );
    return WOFlowActivityOR.parse(obj);
  }
}
