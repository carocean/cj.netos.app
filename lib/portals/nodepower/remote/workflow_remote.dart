import 'dart:convert';

import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/remote/workgroup_remote.dart';

class Workflow {
  String id;
  String name;
  String icon;
  String ctime;
  String creator;
  String note;

  Workflow(
      {this.id, this.name, this.icon, this.ctime, this.creator, this.note});
}

mixin IWorkflowRemote {
  Future<List<Workflow>> pageWorkflow(int limit, int offset) {}

  Future<Workflow> createWorkflow(
      String id, String name, String icon, String note) {}

  Future<void> removeWorkRecipient(String workgroup, String person) {}

  Future<void> addWorkRecipient(String workgroup, String person) {}

  Future<bool> existsRecipientInWorkgroup(String code, String person) {}

  Future<List<String>> getWorkGroupRecipients(String workgroup) {}

  Future<List<WorkItem>> pageMyWorkItem(int limit, int offset) {}

  Future<List<WorkItem>> pageMyWorkItemByFilter(
      int filter, int limit, int offset);

  Future<bool> doMyWorkItem(
      String workinst, String operated, bool doneWorkInst, String note) {}

  Future<bool> doMyWorkItem2(String workinst, String operated,
      bool doneWorkInst, String note, dynamic data, bool putonMHub) {}

  Future<WorkItem> createWorkInstance(String workflow, String data) {}

  Future<bool> doWorkItemAndSend(
      String workinst,
      String operated,
      bool doneWorkInst,
      String note,
      String recipients,
      String eventCode,
      String stepName) {}

  Future<bool> doWorkItemAndSend2(
      String workinst,
      String operated,
      bool doneWorkInst,
      String note,
      dynamic data,
      bool putonMHub,
      String recipients,
      String eventCode,
      String stepName) {}
}

class WorkflowRemote implements IWorkflowRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get workflowPorts => site.getService('@.prop.ports.org.workflow');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<Workflow>> pageWorkflow(int limit, int offset) async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageWorkflow',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var workflows = <Workflow>[];
    for (var obj in list) {
      workflows.add(
        Workflow(
          id: obj['id'],
          icon: obj['icon'],
          name: obj['name'],
          creator: obj['creator'],
          ctime: obj['ctime'],
          note: obj['note'],
        ),
      );
    }
    return workflows;
  }

  @override
  Future<Workflow> createWorkflow(
      String id, String name, String icon, String note) async {
    var obj = await remotePorts.portGET(
      workflowPorts,
      'createWorkflow',
      parameters: {
        'workflowid': id,
        'name': name,
        'icon': icon,
        'note': note,
      },
    );
    return Workflow(
      id: obj['id'],
      icon: obj['icon'],
      name: obj['name'],
      creator: obj['creator'],
      ctime: obj['ctime'],
      note: obj['note'],
    );
  }

  @override
  Future<void> addWorkRecipient(String workgroup, String person) async {
    await remotePorts.portGET(
      workflowPorts,
      'addWorkRecipient',
      parameters: {
        'workgroup': workgroup,
        'person': person,
        'sort': 0,
      },
    );
  }

  @override
  Future<void> removeWorkRecipient(String workgroup, String person) async {
    await remotePorts.portGET(
      workflowPorts,
      'removeWorkRecipient',
      parameters: {
        'code': workgroup,
        'person': person,
      },
    );
  }

  @override
  Future<bool> existsRecipientInWorkgroup(
      String workgroup, String person) async {
    return await remotePorts.portGET(
      workflowPorts,
      'existsWorkRecipient',
      parameters: {
        'code': workgroup,
        'person': person,
      },
    );
  }

  @override
  Future<List<String>> getWorkGroupRecipients(String workgroup) async {
    var obj = await remotePorts.portGET(
      workflowPorts,
      'getWorkGroupRecipients',
      parameters: {
        'code': workgroup,
      },
    );
    List<String> recipients = [];
    if (obj == null) {
      return recipients;
    }
    var list = obj['workRecipients'];
    for (var obj in list) {
      recipients.add(obj['person']);
    }
    return recipients;
  }

  @override
  Future<List<WorkItem>> pageMyWorkItemByFilter(
      int filter, int limit, int offset) async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageMyWorkItem',
      parameters: {
        'filter': filter,
        'limit': limit,
        'offset': offset,
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
  Future<List<WorkItem>> pageMyWorkItem(int limit, int offset) async {
    return await this.pageMyWorkItemByFilter(0, limit, offset);
  }

  @override
  Future<bool> doMyWorkItem(
      String workinst, String operated, bool doneWorkInst, String note) async {
    var obj = await remotePorts.portGET(
      workflowPorts,
      'doMyWorkItem',
      parameters: {
        'workinst': workinst,
        'operated': operated,
        'doneWorkInst': doneWorkInst,
        'note': note,
      },
    );
    return obj;
  }

  @override
  Future<bool> doMyWorkItem2(String workinst, String operated,
      bool doneWorkInst, String note, dynamic data, bool putonMHub) async{
    var obj = await remotePorts.portPOST(
      workflowPorts,
      'doMyWorkItem2',
      parameters: {
        'workinst': workinst,
        'operated': operated,
        'doneWorkInst': doneWorkInst,
        'note': note,
        'putonMHub':putonMHub,
      },
      data: {
        'data':jsonEncode(data),
      },
    );
    return obj;
  }

  @override
  Future<bool> doWorkItemAndSend(
      String workinst,
      String operated,
      bool doneWorkInst,
      String note,
      String recipients,
      String eventCode,
      String stepName) async {
    var obj = await remotePorts.portGET(
      workflowPorts,
      'doWorkItemAndSend',
      parameters: {
        'workinst': workinst,
        'operated': operated,
        'doneWorkInst': doneWorkInst,
        'note': note,
        'recipients': recipients,
        'eventCode': eventCode,
        'stepName': stepName,
      },
    );
    return obj;
  }

  @override
  Future<bool> doWorkItemAndSend2(
      String workinst,
      String operated,
      bool doneWorkInst,
      String note,
      dynamic data,
      bool putonMHub,
      String recipients,
      String eventCode,
      String stepName) async{
    var obj = await remotePorts.portPOST(
      workflowPorts,
      'doWorkItemAndSend2',
      parameters: {
        'workinst': workinst,
        'operated': operated,
        'doneWorkInst': doneWorkInst,
        'note': note,
        'putonMHub':putonMHub,
        'recipients': recipients,
        'eventCode': eventCode,
        'stepName': stepName,
      },
      data: {
        'data':jsonEncode(data),
      },
    );
    return obj;
  }

  @override
  Future<WorkItem> createWorkInstance(String workflow, String data) async {
    var obj = await remotePorts.portGET(
      workflowPorts,
      'createWorkInstance',
      parameters: {
        'workflow': workflow,
        'data': data,
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
}
