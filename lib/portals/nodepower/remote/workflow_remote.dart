import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

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
}
