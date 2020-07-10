import 'dart:convert';

import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';

mixin IOrgLaRemote {
  Future<List<OrgLAOL>> listMyOrgLA() {}

  Future<OrgISPOL> getIsp(String ispid) {}

  Future<OrgLicenceOL> getLicence(String organ, int privilegeLevel) {}

  Future<List<OrgLicenceOL>> pageLicenceByIsps(
      List<String> isps, int limit, int offset);
}

class OrgLaRemote implements IOrgLaRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get laPorts => site.getService('@.prop.ports.org.la');

  get personPorts => site.getService('@.prop.ports.uc.person');

  get ispPorts => site.getService('@.prop.ports.org.isp');

  get licencePorts => site.getService('@.prop.ports.org.licence');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<OrgLAOL>> listMyOrgLA() async {
    var list = await remotePorts.portGET(
      personPorts,
      'listMyAccount',
      parameters: {
        'appid': 'gbera.netos',
      },
    );
    var persons = <String>[];
    for (var obj in list) {
      persons.add(obj['person']);
    }
    list = await remotePorts.portPOST(
      laPorts,
      'listLaOfMasters',
      data: {
        'masters': jsonEncode(persons),
      },
    );
    var laList = <OrgLAOL>[];
    for (var obj in list) {
      laList.add(
        OrgLAOL(
          corpCode: obj['corpCode'],
          corpLogo: obj['corpLogo'],
          corpName: obj['corpName'],
          corpSimple: obj['corpSimple'],
          ctime: obj['time'],
          id: obj['id'],
          licenceSrc: obj['licenceSrc'],
          masterPerson: obj['masterPerson'],
          masterPhone: obj['masterPhone'],
          masterRealName: obj['masterRealName'],
          isp: obj['isp'],
        ),
      );
    }
    return laList;
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
      corpSimple: obj['corpSimple'],
      ctime: obj['ctime'],
      id: obj['id'],
      licenceSrc: obj['licenceSrc'],
      masterPerson: obj['masterPerson'],
      masterPhone: obj['masterPhone'],
      masterRealName: obj['masterRealName'],
    );
  }

  @override
  Future<List<OrgLicenceOL>> pageLicenceByIsps(
      List<String> isps, int limit, int offset) async {
    var list = await remotePorts.portGET(
      licencePorts,
      'pageLicenceByIsps',
      parameters: {
        'isps': jsonEncode(isps),
        'limit': limit,
        'offset': offset,
      },
    );
    List<OrgLicenceOL> licences = [];
    for (var obj in list) {
      licences.add(
        OrgLicenceOL(
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
        ),
      );
    }
    return licences;
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
