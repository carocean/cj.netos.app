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

mixin IReceivingBankRemote {
  Future<List<ReceivingBankOL>> getAll() {}
}
mixin IIspRemote {
  Future<WorkItem> applyRegisterByPerson(IspApplayBO ispApplayBO) {}

  Future<List<WorkItem>> pageMyWorkItemOnWorkflow() {}

 Future<WorkItem> confirmPayOrder(String id, String evidence) {}

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
  Future<WorkItem> confirmPayOrder(String workinst, String evidence) async{
    var obj = await remotePorts.portGET(
      ispPorts,
      'confirmPayOrder',
      parameters: {
        'workinst': workinst,
        'payEvidence':evidence,
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
  Future<List<WorkItem>> pageMyWorkItemOnWorkflow() async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageMyWorkItemOnWorkflow',
      parameters: {
        'workflow': workFlow,
        'filter': 0,
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
}
