import 'dart:convert';

import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class IspApplayBO {
  String cropName;
  String simpleName;
  String cropCode;
  String licenceSrc;
  String cropLogo;
  String masterRealName;
  String masterPhone;
  int operatePeriod;
  int fee;
  String bussinessScop;
  String bussinessAreaTitle;
  String bussinessAreaCode;

  IspApplayBO({
    this.cropName,
    this.simpleName,
    this.cropCode,
    this.licenceSrc,
    this.cropLogo,
    this.masterRealName,
    this.masterPhone,
    this.operatePeriod,
    this.fee,
    this.bussinessScop,
    this.bussinessAreaTitle,
    this.bussinessAreaCode,
  });

  toMap() {
    return {
      'cropName': cropName,
      'simpleName': simpleName,
      'cropCode': cropCode,
      'licenceSrc': licenceSrc,
      'cropLogo': cropLogo,
      'masterRealName': masterRealName,
      'masterPhone': masterPhone,
      'operatePeriod': operatePeriod,
      'fee': fee,
      'bussinessScop': bussinessScop,
      'bussinessAreaTitle': bussinessAreaTitle,
      'bussinessAreaCode': bussinessAreaCode,
    };
  }
}

class LaApplayBO {
  String cropName;
  String simpleName;
  String cropCode;
  String licenceSrc;
  String cropLogo;
  String masterRealName;
  String masterPhone;
  int operatePeriod;
  int fee;
  String isp;
  String bussinessScop;
  String bussinessAreaTitle;
  String bussinessAreaCode;

  LaApplayBO({
    this.cropName,
    this.simpleName,
    this.cropCode,
    this.licenceSrc,
    this.cropLogo,
    this.masterRealName,
    this.masterPhone,
    this.operatePeriod,
    this.fee,
    this.isp,
    this.bussinessScop,
    this.bussinessAreaTitle,
    this.bussinessAreaCode,
  });

  toMap() {
    return {
      'cropName': cropName,
      'simpleName': simpleName,
      'cropCode': cropCode,
      'licenceSrc': licenceSrc,
      'cropLogo': cropLogo,
      'masterRealName': masterRealName,
      'masterPhone': masterPhone,
      'operatePeriod': operatePeriod,
      'fee': fee,
      'isp': isp,
      'bussinessScop': bussinessScop,
      'bussinessAreaTitle': bussinessAreaTitle,
      'bussinessAreaCode': bussinessAreaCode,
    };
  }
}

class WorkItem {
  WorkInst workInst;
  WorkEvent workEvent;

  WorkItem({this.workInst, this.workEvent});
}

class WorkInst {
  String id;
  String name;
  String workflow;
  String ctime;
  int isDone;
  String icon;
  String creator;
  String data;

  WorkInst(
      {this.id,
      this.name,
      this.workflow,
      this.ctime,
      this.isDone,
      this.icon,
      this.creator,
      this.data});
}

class WorkEvent {
  String id;
  String title;
  String code;
  int stepNo;
  String workInst;
  String ctime;
  String sender;
  String recipient;
  String operated;
  int isDone;
  String prevEvent;
  String dtime;
  String data;

  WorkEvent(
      {this.id,
      this.title,
      this.code,
      this.stepNo,
      this.workInst,
      this.ctime,
      this.sender,
      this.recipient,
      this.operated,
      this.isDone,
      this.prevEvent,
      this.dtime,
      this.data});
}

class ReceivingBankOL {
  String id;
  String bankName;
  String accountName;
  String accountNo;
  String note;

  ReceivingBankOL(
      {this.id, this.bankName, this.accountName, this.accountNo, this.note});
}

class OrgISPOL {
  String id;
  String corpName;
  String corpCode;
  String licenceSrc;
  String corpLogo;
  String masterPerson;
  String masterRealName;
  String masterPhone;
  String ctime;

  OrgISPOL({
    this.id,
    this.corpName,
    this.corpCode,
    this.licenceSrc,
    this.corpLogo,
    this.masterPerson,
    this.masterRealName,
    this.masterPhone,
    this.ctime,
  });
}

class OrgISPLicenceOL {
  OrgISPOL ispOL;
  OrgLicenceOL licenceOL;

  OrgISPLicenceOL({this.ispOL, this.licenceOL});
}

class OrgLAOL {
  String id;
  String corpName;
  String corpCode;
  String licenceSrc;
  String corpLogo;
  String masterPerson;
  String masterRealName;
  String masterPhone;
  String ctime;
  String isp;

  OrgLAOL(
      {this.id,
      this.corpName,
      this.corpCode,
      this.licenceSrc,
      this.corpLogo,
      this.masterPerson,
      this.masterRealName,
      this.masterPhone,
      this.ctime,
      this.isp});
}

class OrgLicenceOL {
  String id;
  String title;
  int operatePeriod;
  int fee;
  int privilegeLevel;
  String bussinessScop;
  String bussinessAreaTitle;
  String bussinessAreaCode;
  String organ;
  String signText;
  int state;
  String pubTime;
  String endTime;
  String payEvidence;

  OrgLicenceOL(
      {this.id,
      this.title,
      this.operatePeriod,
      this.fee,
      this.privilegeLevel,
      this.bussinessScop,
      this.bussinessAreaTitle,
      this.bussinessAreaCode,
      this.organ,
      this.signText,
      this.state,
      this.pubTime,
      this.endTime,
      this.payEvidence});
}

mixin IReceivingBankRemote {
  Future<List<ReceivingBankOL>> getAll() {}
}
mixin ILaRemote {
  Future<OrgLAOL> getLa(String laid) {}

  Future<List<WorkItem>> pageMyWorkItemOnWorkflow(int i) {}

  Future<WorkItem> applyRegisterByPerson(LaApplayBO laApplayBO) {}

  Future<WorkItem> confirmPayOrder(String id, String evidence) {}

  Future<void> checkApplyRegisterByPlatform(String id, bool bool,String ispid) {}
}
mixin ILicenceRemote {
  Future<OrgLicenceOL> getLicence(String organ, int privilegeLevel) {}
}
mixin IIspRemote {
  Future<WorkItem> applyRegisterByPerson(IspApplayBO ispApplayBO) {}

  Future<List<WorkItem>> pageMyWorkItemOnWorkflow(int filter) {}

  Future<WorkItem> confirmPayOrder(String id, String evidence) {}

  Future<void> checkApplyRegisterByPlatform(String id, bool bool) {}

  Future<OrgISPOL> getIsp(String ispid) {}

  Future<List<OrgISPLicenceOL>> pageIsp(int i, int j) {}
}

class ReceivingBankRemote implements IReceivingBankRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get receivingBankPorts => site.getService('@.prop.ports.org.receivingBank');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<ReceivingBankOL>> getAll() async {
    var list = await remotePorts.portGET(
      receivingBankPorts,
      'getAll',
      parameters: {},
    );
    List<ReceivingBankOL> banks = [];
    for (var obj in list) {
      banks.add(
        ReceivingBankOL(
          note: obj['note'],
          id: obj['id'],
          accountName: obj['accountName'],
          accountNo: obj['accountNo'],
          bankName: obj['bankName'],
        ),
      );
    }
    return banks;
  }
}

class IspRemote implements IIspRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get ispPorts => site.getService('@.prop.ports.org.isp');

  get workflowPorts => site.getService('@.prop.ports.org.workflow');

  get workFlow => site.getService('@.prop.org.workflow.isp');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<WorkItem> applyRegisterByPerson(IspApplayBO ispApplayBO) async {
    var obj = await remotePorts.portPOST(
      ispPorts,
      'applyRegisterByPerson',
      parameters: {
        'workflow': workFlow,
      },
      data: {
        'ispApplyBO': jsonEncode(ispApplayBO.toMap()),
      },
    );
    var workInstObj = obj['workInst'];
    var workEventObj = obj['workEvent'];
    return WorkItem(
      workEvent: WorkEvent(
        workInst: workEventObj['workInst'],
        data: workEventObj['data'],
        title: workEventObj['title'],
        id: workEventObj['id'],
        ctime: workEventObj['ctime'],
        dtime: workEventObj['dtime'],
        code: workEventObj['code'],
        isDone: workEventObj['isDone'],
        operated: workEventObj['operated'],
        prevEvent: workEventObj['prevEvent'],
        recipient: workEventObj['recipient'],
        sender: workEventObj['sender'],
        stepNo: workEventObj['stepNo'],
      ),
      workInst: WorkInst(
        isDone: workInstObj['isDone'],
        ctime: workInstObj['ctime'],
        id: workInstObj['id'],
        data: workInstObj['data'],
        creator: workInstObj['creator'],
        icon: workInstObj['icon'],
        name: workInstObj['name'],
        workflow: workInstObj['workflow'],
      ),
    );
  }

  @override
  Future<WorkItem> confirmPayOrder(String workinst, String evidence) async {
    var obj = await remotePorts.portGET(
      ispPorts,
      'confirmPayOrder',
      parameters: {
        'workinst': workinst,
        'payEvidence': evidence,
      },
    );
    var workInstObj = obj['workInst'];
    var workEventObj = obj['workEvent'];
    return WorkItem(
      workEvent: WorkEvent(
        workInst: workEventObj['workInst'],
        data: workEventObj['data'],
        title: workEventObj['title'],
        id: workEventObj['id'],
        ctime: workEventObj['ctime'],
        dtime: workEventObj['dtime'],
        code: workEventObj['code'],
        isDone: workEventObj['isDone'],
        operated: workEventObj['operated'],
        prevEvent: workEventObj['prevEvent'],
        recipient: workEventObj['recipient'],
        sender: workEventObj['sender'],
        stepNo: workEventObj['stepNo'],
      ),
      workInst: WorkInst(
        isDone: workInstObj['isDone'],
        ctime: workInstObj['ctime'],
        id: workInstObj['id'],
        data: workInstObj['data'],
        creator: workInstObj['creator'],
        icon: workInstObj['icon'],
        name: workInstObj['name'],
        workflow: workInstObj['workflow'],
      ),
    );
  }

  @override
  Future<List<WorkItem>> pageMyWorkItemOnWorkflow(int filter) async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageMyWorkItemOnWorkflow',
      parameters: {
        'workflow': workFlow,
        'filter': filter,
        'limit': 100,
        'offset': 0,
      },
    );
    var result = <WorkItem>[];
    for (var obj in list) {
      var workInstObj = obj['workInst'];
      var workEventObj = obj['workEvent'];
      result.add(
        WorkItem(
          workEvent: WorkEvent(
            workInst: workEventObj['workInst'],
            data: workEventObj['data'],
            title: workEventObj['title'],
            id: workEventObj['id'],
            ctime: workEventObj['ctime'],
            dtime: workEventObj['dtime'],
            code: workEventObj['code'],
            isDone: workEventObj['isDone'],
            operated: workEventObj['operated'],
            prevEvent: workEventObj['prevEvent'],
            recipient: workEventObj['recipient'],
            sender: workEventObj['sender'],
            stepNo: workEventObj['stepNo'],
          ),
          workInst: WorkInst(
            isDone: workInstObj['isDone'],
            ctime: workInstObj['ctime'],
            id: workInstObj['id'],
            data: workInstObj['data'],
            creator: workInstObj['creator'],
            icon: workInstObj['icon'],
            name: workInstObj['name'],
            workflow: workInstObj['workflow'],
          ),
        ),
      );
    }
    return result;
  }

  @override
  Future<Function> checkApplyRegisterByPlatform(
      String workinst, bool checkPass) async {
    await remotePorts.portGET(
      ispPorts,
      'checkApplyRegisterByPlatform',
      parameters: {
        'workinst': workinst,
        'checkPass': checkPass,
      },
    );
  }

  @override
  Future<OrgISPOL> getIsp(String ispid) async {
    var obj = await remotePorts.portGET(
      ispPorts,
      'getIsp',
      parameters: {
        'ispid': ispid,
      },
    );
    if (obj == null) {
      return null;
    }
    return OrgISPOL(
      corpCode: obj['corpCode'],
      corpLogo: obj['corpLogo'],
      corpName: obj['corpName'],
      ctime: obj['ctime'],
      id: obj['id'],
      licenceSrc: obj['licenceSrc'],
      masterPerson: obj['masterPerson'],
      masterPhone: obj['masterPhone'],
      masterRealName: obj['masterRealName'],
    );
  }

  @override
  Future<List<OrgISPLicenceOL>> pageIsp(int limit, int offset) async {
    var list = await remotePorts.portGET(
      ispPorts,
      'pageIspWithLicence',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<OrgISPLicenceOL> items = [];
    for (var item in list) {
      var ispObj = item['orgIsp'];
      var licenceObj = item['orgLicence'];
      if (licenceObj == null) {
        continue;
      }
      items.add(
        OrgISPLicenceOL(
          ispOL: OrgISPOL(
            corpCode: ispObj['corpCode'],
            corpLogo: ispObj['corpLogo'],
            corpName: ispObj['corpName'],
            ctime: ispObj['ctime'],
            id: ispObj['id'],
            licenceSrc: ispObj['licenceSrc'],
            masterPerson: ispObj['masterPerson'],
            masterPhone: ispObj['masterPhone'],
            masterRealName: ispObj['masterRealName'],
          ),
          licenceOL: OrgLicenceOL(
            id: licenceObj['id'],
            bussinessAreaCode: licenceObj['bussinessAreaCode'],
            bussinessAreaTitle: licenceObj['bussinessAreaTitle'],
            bussinessScop: licenceObj['bussinessScop'],
            endTime: licenceObj['endTime'],
            fee: licenceObj['fee'],
            operatePeriod: licenceObj['operatePeriod'],
            organ: licenceObj['organ'],
            payEvidence: licenceObj['payEvidence'],
            privilegeLevel: licenceObj['privilegeLevel'],
            pubTime: licenceObj['pubTime'],
            signText: licenceObj['signText'],
            state: licenceObj['state'],
            title: licenceObj['title'],
          ),
        ),
      );
    }
    return items;
  }
}

class LaRemote implements ILaRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get laPorts => site.getService('@.prop.ports.org.la');

  get workflowPorts => site.getService('@.prop.ports.org.workflow');

  get workFlow => site.getService('@.prop.org.workflow.la');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<OrgLAOL> getLa(String laid) async {
    var obj = await remotePorts.portGET(
      laPorts,
      'getLa',
      parameters: {
        'laid': laid,
      },
    );
    if (obj == null) {
      return null;
    }
    return OrgLAOL(
      corpCode: obj['corpCode'],
      corpLogo: obj['corpLogo'],
      corpName: obj['corpName'],
      ctime: obj['ctime'],
      id: obj['id'],
      licenceSrc: obj['licenceSrc'],
      masterPerson: obj['masterPerson'],
      masterPhone: obj['masterPhone'],
      masterRealName: obj['masterRealName'],
      isp: obj['isp'],
    );
  }

  @override
  Future<WorkItem> applyRegisterByPerson(LaApplayBO laApplayBO) async {
    var obj = await remotePorts.portPOST(
      laPorts,
      'applyRegisterByPerson',
      parameters: {
        'workflow': workFlow,
      },
      data: {
        'laApplyBO': jsonEncode(laApplayBO.toMap()),
      },
    );
    var workInstObj = obj['workInst'];
    var workEventObj = obj['workEvent'];
    return WorkItem(
      workEvent: WorkEvent(
        workInst: workEventObj['workInst'],
        data: workEventObj['data'],
        title: workEventObj['title'],
        id: workEventObj['id'],
        ctime: workEventObj['ctime'],
        dtime: workEventObj['dtime'],
        code: workEventObj['code'],
        isDone: workEventObj['isDone'],
        operated: workEventObj['operated'],
        prevEvent: workEventObj['prevEvent'],
        recipient: workEventObj['recipient'],
        sender: workEventObj['sender'],
        stepNo: workEventObj['stepNo'],
      ),
      workInst: WorkInst(
        isDone: workInstObj['isDone'],
        ctime: workInstObj['ctime'],
        id: workInstObj['id'],
        data: workInstObj['data'],
        creator: workInstObj['creator'],
        icon: workInstObj['icon'],
        name: workInstObj['name'],
        workflow: workInstObj['workflow'],
      ),
    );
  }

  @override
  Future<List<WorkItem>> pageMyWorkItemOnWorkflow(int filter) async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageMyWorkItemOnWorkflow',
      parameters: {
        'workflow': workFlow,
        'filter': filter,
        'limit': 100,
        'offset': 0,
      },
    );
    var result = <WorkItem>[];
    for (var obj in list) {
      var workInstObj = obj['workInst'];
      var workEventObj = obj['workEvent'];
      result.add(
        WorkItem(
          workEvent: WorkEvent(
            workInst: workEventObj['workInst'],
            data: workEventObj['data'],
            title: workEventObj['title'],
            id: workEventObj['id'],
            ctime: workEventObj['ctime'],
            dtime: workEventObj['dtime'],
            code: workEventObj['code'],
            isDone: workEventObj['isDone'],
            operated: workEventObj['operated'],
            prevEvent: workEventObj['prevEvent'],
            recipient: workEventObj['recipient'],
            sender: workEventObj['sender'],
            stepNo: workEventObj['stepNo'],
          ),
          workInst: WorkInst(
            isDone: workInstObj['isDone'],
            ctime: workInstObj['ctime'],
            id: workInstObj['id'],
            data: workInstObj['data'],
            creator: workInstObj['creator'],
            icon: workInstObj['icon'],
            name: workInstObj['name'],
            workflow: workInstObj['workflow'],
          ),
        ),
      );
    }
    return result;
  }

  @override
  Future<WorkItem> confirmPayOrder(String workinst, String evidence) async {
    var obj = await remotePorts.portGET(
      laPorts,
      'confirmPayOrder',
      parameters: {
        'workinst': workinst,
        'payEvidence': evidence,
      },
    );
    var workInstObj = obj['workInst'];
    var workEventObj = obj['workEvent'];
    return WorkItem(
      workEvent: WorkEvent(
        workInst: workEventObj['workInst'],
        data: workEventObj['data'],
        title: workEventObj['title'],
        id: workEventObj['id'],
        ctime: workEventObj['ctime'],
        dtime: workEventObj['dtime'],
        code: workEventObj['code'],
        isDone: workEventObj['isDone'],
        operated: workEventObj['operated'],
        prevEvent: workEventObj['prevEvent'],
        recipient: workEventObj['recipient'],
        sender: workEventObj['sender'],
        stepNo: workEventObj['stepNo'],
      ),
      workInst: WorkInst(
        isDone: workInstObj['isDone'],
        ctime: workInstObj['ctime'],
        id: workInstObj['id'],
        data: workInstObj['data'],
        creator: workInstObj['creator'],
        icon: workInstObj['icon'],
        name: workInstObj['name'],
        workflow: workInstObj['workflow'],
      ),
    );
  }

  @override
  Future<Function> checkApplyRegisterByPlatform(
      String workinst, bool checkPass,String ispid) async {
    await remotePorts.portGET(
      laPorts,
      'checkApplyRegisterByPlatform',
      parameters: {
        'workinst': workinst,
        'checkPass': checkPass,
        'ispid':ispid,
      },
    );
  }
}

class LicenceRemote implements ILicenceRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get licencePorts => site.getService('@.prop.ports.org.licence');

  get workflowPorts => site.getService('@.prop.ports.org.workflow');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<OrgLicenceOL> getLicence(String organ, int privilegeLevel) async {
    var obj = await remotePorts.portGET(
      licencePorts,
      'getLicenceByOrg',
      parameters: {
        'organ': organ,
        'privilegeLevel': privilegeLevel,
      },
    );
    if (obj == null) {
      return null;
    }
    return OrgLicenceOL(
      id: obj['id'],
      bussinessAreaCode: obj['bussinessAreaCode'],
      bussinessAreaTitle: obj['bussinessAreaTitle'],
      bussinessScop: obj['bussinessScop'],
      endTime: obj['endTime'],
      fee: obj['fee'],
      operatePeriod: obj['operatePeriod'],
      organ: obj['organ'],
      payEvidence: obj['payEvidence'],
      privilegeLevel: obj['privilegeLevel'],
      pubTime: obj['pubTime'],
      signText: obj['signText'],
      state: obj['state'],
      title: obj['title'],
    );
  }
}
