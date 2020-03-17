import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class ChannelRemote implements IChannelRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _netflowPortsUrl => site.getService('@.prop.ports.link.netflow');

  get _channelPortsUrl =>
      site.getService('@.prop.ports.document.network.channel');

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
    await remotePorts.portGET(_netflowPortsUrl, 'createChannel', parameters: {
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
        .portGET(_netflowPortsUrl, 'getPersonChannel', parameters: {
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
        .portGET(_netflowPortsUrl, 'pageOutputPersonOf', parameters: {
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
      String channel, String person, int limit, int offset) async {
    List list = await remotePorts
        .portGET(_netflowPortsUrl, 'pageInputPersonOf', parameters: {
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
        .portGET(_netflowPortsUrl, 'listPersonChannels', parameters: {
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
        await remotePorts.portGET(_netflowPortsUrl, 'pageChannel', parameters: {
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
    await remotePorts.portGET(_netflowPortsUrl, 'removeChannel', parameters: {
      'channel': channel,
    });
  }

  @override
  Future<void> updateLeading(String channelid, String remotePath) async {
    await remotePorts.portGET(
      _netflowPortsUrl,
      'updateChannelLeading',
      parameters: {'channel': channelid, 'leading': remotePath},
    );
  }

  @override
  Future<void> addInputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _netflowPortsUrl,
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
      _netflowPortsUrl,
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
      _netflowPortsUrl,
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
      _netflowPortsUrl,
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
      _netflowPortsUrl,
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
      _netflowPortsUrl,
      'updateOutPersonSelector',
      parameters: {
        'channel': channel,
        'outPersonSelector': outPersonSelector,
      },
    );
  }

  @override
  Future<void> like(String msgid) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'likeDocument',
      parameters: {'docid': msgid},
    );
    return null;
  }

  @override
  Future<void> unlike(String msgid) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'unlikeDocument',
      parameters: {'docid': msgid},
    );
  }

  @override
  Future<Function> removeComment(String msgid, String commentid) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'uncommentDocument',
      parameters: {
        'docid': msgid,
        'commentid': commentid,
      },
    );
  }

  @override
  Future<Function> addComment(String msgid, String text, String commentid) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'commentDocument',
      parameters: {
        'docid': msgid,
        'commentid': commentid,
        'content': text,
      },
    );
  }
}
