import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class ChannelRemote implements IChannelRemote, IServiceBuilder {
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
  Future<Function> createChannel(String channel,
      {@required String title,
      @required String leading,
      @required String outPersonSelector,
      @required bool outGeoSelector}) async {
    await remotePorts.portGET(_networkPortsUrl, 'createChannel', parameters: {
      'channel': channel,
      'title': title,
      'leading': leading,
      'outPersonSelector': outPersonSelector,
      'outGeoSelector': '$outGeoSelector',
    });
  }

  @override
  Future<Channel> findChannelOfPerson(String channel, String person) async {
    Map<String, dynamic> map = await remotePorts
        .portGET(_networkPortsUrl, 'getPersonChannel', parameters: {
      'channel': channel,
      'person': person,
    });
    if (map == null) {
      return null;
    }
    return Channel(
      map['channel'],
      map['title'],
      map['creator'],
      map['leading'],
      map['site'],
      map['ctime'],
      principal.person,
    );
  }

  @override
  Future<List<Person>> pageOutputPersonOf(
      String channel, String person, int limit, int offset) async {
    List list = await remotePorts
        .portGET(_networkPortsUrl, 'pageOutputPersonOf', parameters: {
      'channel': channel,
      'person': person,
      'limit': limit,
      'offset': offset,
    });
    var persons = <Person>[];
    for (var obj in list) {
      persons.add(
        Person(
          obj['official'],
          obj['uid'],
          obj['accountName'],
          obj['appid'],
          obj['avatar'],
          obj['rights'],
          obj['nickName'],
          obj['signature'],
          obj['pyname'],
          principal.person,
        ),
      );
    }
    return persons;
  }

  @override
  Future<List<Person>> pageInputPersonOf(
      String channel, String person, int limit, int offset) async{
    List list = await remotePorts
        .portGET(_networkPortsUrl, 'pageInputPersonOf', parameters: {
      'channel': channel,
      'person': person,
      'limit': limit,
      'offset': offset,
    });
    var persons = <Person>[];
    for (var obj in list) {
      persons.add(
        Person(
          obj['official'],
          obj['uid'],
          obj['accountName'],
          obj['appid'],
          obj['avatar'],
          obj['rights'],
          obj['nickName'],
          obj['signature'],
          obj['pyname'],
          principal.person,
        ),
      );
    }
    return persons;
  }

  @override
  Future<List<Channel>> fetchChannelsOfPerson(String official) async {
    List<dynamic> list = await remotePorts
        .portGET(_networkPortsUrl, 'listPersonChannels', parameters: {
      'person': official,
    });
    if (list == null) {
      return null;
    }
    List<Channel> channels = [];
    for (var map in list) {
      channels.add(Channel(
        map['channel'],
        map['title'],
        map['creator'],
        map['leading'],
        map['site'],
        map['ctime'],
        principal.person,
      ));
    }
    return channels;
  }

  @override
  Future<List<Channel>> pageChannel({int limit = 20, int offset = 0}) async {
    var list =
        await remotePorts.portGET(_networkPortsUrl, 'pageChannel', parameters: {
      'limit': '$limit',
      'offset': '$offset',
    });
    var channels = <Channel>[];
    for (var obj in list) {
      var channelid = MD5Util.generateMd5('${Uuid().v1()}');
      channels.add(Channel(
        channelid,
        obj['title'],
        obj['owner'],
        obj['leading'],
        obj['site'],
        obj['ctime'],
        principal.person,
      ));
    }
    return channels;
  }

  @override
  Future<Function> removeChannel(String channel) async {
    await remotePorts.portGET(_networkPortsUrl, 'removeChannel', parameters: {
      'channel': channel,
    });
  }

  @override
  Future<void> updateLeading(String channelid, String remotePath) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'updateChannelLeading',
      parameters: {'channel': channelid, 'leading': remotePath},
    );
  }

  @override
  Future<void> addInputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'addInputPerson',
      parameters: {
        'channel': channel,
        'person': person,
      },
    );
  }

  @override
  Future<void> addOutputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'addOutputPerson',
      parameters: {
        'channel': channel,
        'person': person,
      },
    );
  }

  @override
  Future<void> removeInputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'removeInputPerson',
      parameters: {
        'channel': channel,
        'person': person,
      },
    );
  }

  @override
  Future<void> removeOutputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'removeOutputPerson',
      parameters: {
        'channel': channel,
        'person': person,
      },
    );
  }

  @override
  Future<void> updateOutGeoSelector(
      String channel, String outGeoSelector) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'updateOutGeoSelector',
      parameters: {
        'channel': channel,
        'outGeoSelector': outGeoSelector,
      },
    );
  }

  @override
  Future<void> updateOutPersonSelector(
      String channel, outPersonSelector) async {
    await remotePorts.portGET(
      _networkPortsUrl,
      'updateOutPersonSelector',
      parameters: {
        'channel': channel,
        'outPersonSelector': outPersonSelector,
      },
    );
  }
}
