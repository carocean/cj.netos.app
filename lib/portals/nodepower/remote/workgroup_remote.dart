import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class Workgroup {
  String code;
  String name;
  String ctime;
  String creator;
  String note;

  Workgroup({this.code, this.name, this.ctime, this.creator, this.note});
}

mixin IWorkgroupRemote {
  Future<List<Workgroup>> pageWorkgroup(int limit, int offset) {}

  Future<Workgroup> createWorkgroup(String text, String text2, String text3) {}

Future<void>  removeWorkgroup(String code) {}

}

class WorkgroupRemote implements IWorkgroupRemote, IServiceBuilder {
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
  Future<List<Workgroup>> pageWorkgroup(int limit, int offset) async {
    var list = await remotePorts.portGET(
      workflowPorts,
      'pageWorkGroup',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var workgroups = <Workgroup>[];
    for (var obj in list) {
      workgroups.add(
        Workgroup(
          code: obj['code'],
          name: obj['name'],
          creator: obj['creator'],
          ctime: obj['ctime'],
          note: obj['note'],
        ),
      );
    }
    return workgroups;
  }

  @override
  Future<Workgroup> createWorkgroup(
      String code, String name, String note) async {
    var obj = await remotePorts.portGET(
      workflowPorts,
      'addWorkGroup',
      parameters: {
        'code': code,
        'name': name,
        'note': note,
      },
    );
    return Workgroup(
      code: obj['code'],
      name: obj['name'],
      creator: obj['creator'],
      ctime: obj['ctime'],
      note: obj['note'],
    );
  }

  @override
  Future<void> removeWorkgroup(String code) async{
    await remotePorts.portGET(
      workflowPorts,
      'removeWorkGroup',
      parameters: {
        'code': code,
      },
    );
  }
}
