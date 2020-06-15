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

mixin IIspRemote {
  Future<WorkItem> applyRegisterByPerson(IspApplayBO ispApplayBO) {}

  Future<List<WorkItem>> pageMyWorkItemOnWorkflow() {}
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
  Future<List<WorkItem>> pageMyWorkItemOnWorkflow() async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageMyWorkItemOnWorkflow',
      parameters: {
        'workflow': workFlow,
        'filter':0,
        'limit':100,
        'offset':0,
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
