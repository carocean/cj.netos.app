import 'dart:convert';

import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';

mixin IPersonRemote {
  Future<void> addPerson(Person person) {}

  Future<void> removePerson(String person) {}

}

class PersonRemote implements IPersonRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _networkPortsUrl => site.getService('@.prop.ports.link.network');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<void> addPerson(Person person) async {
    var response = await remotePorts.upload(
      '/app',
      <String>[
        person.avatar,
      ],
    );
    var obj = {
      'official': person.official,
      'uid': '${person.uid}',
      'accountName': person.accountCode,
      'appid': person.appid,
      'nickName': person.nickName,
      'pyname': person.pyname,
      'signature': person.signature,
      'avatar': response[person.avatar],
    };
//    await remotePorts.portPOST(
//      _networkPortsUrl,
//      'addPerson',
//      data: {'person': jsonEncode(obj)},
//    );
    remotePorts.portTask.addPortPOSTTask(
      _networkPortsUrl,
      'addPerson',
      data: {
        'person': jsonEncode(obj),
      },
    );
  }

  @override
  Future<void> removePerson(String person) async {
//    await remotePorts.portGET(
//      _networkPortsUrl,
//      'removePerson',
//      parameters: {
//        'person': person,
//      },
//    );
  remotePorts.portTask.addPortGETTask( _networkPortsUrl,
      'removePerson',
      parameters: {
        'person': person,
      },
    );
    return null;
  }

}
