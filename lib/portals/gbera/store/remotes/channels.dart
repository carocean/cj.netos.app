import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class ChannelRemote implements IChannelRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _linkNetflowPortsUrl => site.getService('@.prop.ports.link.netflow');

  get _flowChannelPortsUrl => site.getService('@.prop.ports.flow.channel');

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
        @required String upstreamPerson,
      @required String outPersonSelector,
      @required bool outGeoSelector}) async {
    await remotePorts
        .portGET(_linkNetflowPortsUrl, 'createChannel', parameters: {
      'channel': channel,
      'title': title,
      'leading': leading,
      'upstreamPerson':upstreamPerson,
      'outPersonSelector': outPersonSelector,
      'outGeoSelector': '$outGeoSelector',
    });
  }

  @override
  Future<Channel> findChannelOfPerson(String channel, String person) async {
    Map<String, dynamic> map = await remotePorts
        .portGET(_linkNetflowPortsUrl, 'getPersonChannel', parameters: {
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
      map['upstreamPerson'],
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
        .portGET(_linkNetflowPortsUrl, 'pageOutputPersonOf', parameters: {
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
        .portGET(_linkNetflowPortsUrl, 'pageInputPersonOf', parameters: {
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
  Future<List<ChannelInputPerson>> getAllInputPerson(
      String channel, int atime) async {
    List list = await remotePorts
        .portGET(_linkNetflowPortsUrl, 'listAllInputPerson', parameters: {
      'channel': channel,
      'atime': atime,
    });
    List<ChannelInputPerson> persons = [];
    for (var obj in list) {
      persons.add(
        ChannelInputPerson(
          obj['id'],
          obj['channel'],
          obj['person'],
          obj['rights'],
          obj['atime'],
          principal.person,
        ),
      );
    }
    return persons;
  }

  @override
  Future<List<ChannelOutputPerson>> getAllOutputPerson(
      String channel, int atime) async {
    List list = await remotePorts
        .portGET(_linkNetflowPortsUrl, 'listAllOutputPerson', parameters: {
      'channel': channel,
      'atime': atime,
    });
    List<ChannelOutputPerson> persons = [];
    for (var obj in list) {
      persons.add(
        ChannelOutputPerson(
          obj['id'],
          obj['channel'],
          obj['person'],
          obj['atime'],
          principal.person,
        ),
      );
    }
    return persons;
  }

  @override
  Future<List<Channel>> fetchChannelsOfPerson(String official) async {
    List<dynamic> list = await remotePorts
        .portGET(_linkNetflowPortsUrl, 'listPersonChannels', parameters: {
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
        map['upstreamPerson'],
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
    var list = await remotePorts
        .portGET(_linkNetflowPortsUrl, 'pageChannel', parameters: {
      'limit': '$limit',
      'offset': '$offset',
    });
    var channels = <Channel>[];
    for (var obj in list) {
      var channelid = MD5Util.MD5('${Uuid().v1()}');
      channels.add(Channel(
        channelid,
        obj['title'],
        obj['owner'],
        obj['upstreamPerson'],
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
    await remotePorts
        .portGET(_linkNetflowPortsUrl, 'removeChannel', parameters: {
      'channel': channel,
    });
  }

  @override
  Future<void> updateLeading(String channelid, String remotePath) async {
    await remotePorts.portGET(
      _linkNetflowPortsUrl,
      'updateChannelLeading',
      parameters: {'channel': channelid, 'leading': remotePath},
    );
  }

  @override
  Future<void> addInputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _linkNetflowPortsUrl,
      'addInputPerson',
      parameters: {
        'channel': channel,
        'person': person,
      },
    );
  }

  @override
  Future<Function> addOutputPersonOfCreator(
      String creator, String channel) async {
    await remotePorts.portGET(
      _linkNetflowPortsUrl,
      'addOutputPersonOfCreator',
      parameters: {
        'creator': creator,
        'channel': channel,
        'person': principal.person,
      },
    );
  }

  @override
  Future<void> addOutputPerson(String person, String channel) async {
    await remotePorts.portGET(
      _linkNetflowPortsUrl,
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
      _linkNetflowPortsUrl,
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
      _linkNetflowPortsUrl,
      'removeOutputPerson',
      parameters: {
        'channel': channel,
        'person': person,
      },
    );
  }

  @override
  Future<Function> removeOutputPersonOfCreator(
      String creator, String channel) async {
    await remotePorts.portGET(
      _linkNetflowPortsUrl,
      'removeOutputPersonOfCreator',
      parameters: {
        'creator': creator,
        'channel': channel,
        'person': principal.person,
      },
    );
  }

  @override
  Future<void> updateOutGeoSelector(
      String channel, String outGeoSelector) async {
    await remotePorts.portGET(
      _linkNetflowPortsUrl,
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
      _linkNetflowPortsUrl,
      'updateOutPersonSelector',
      parameters: {
        'channel': channel,
        'outPersonSelector': outPersonSelector,
      },
    );
  }

  @override
  Future<void> like(String msgid, String channel, String creator) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'likeDocument',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
      },
    );
    remotePorts.portTask.addPortGETTask(
      _flowChannelPortsUrl,
      'pushChannelDocumentLike',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
        'interval': 10,
      },
    );
    return null;
  }

  @override
  Future<void> unlike(String msgid, String channel, String creator) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'unlikeDocument',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
      },
    );

    remotePorts.portTask.addPortGETTask(
      _flowChannelPortsUrl,
      'pushChannelDocumentUnlike',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
        'interval': 10,
      },
    );
  }

  @override
  Future<Function> removeComment(
      String msgid, String channel, String creator, String commentid) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'uncommentDocument',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
        'commentid': commentid,
      },
    );

    remotePorts.portTask.addPortGETTask(
      _flowChannelPortsUrl,
      'pushChannelDocumentUncomment',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
        'commentid': commentid,
        'interval': 10,
      },
    );
  }

  @override
  Future<Function> addComment(String msgid, String channel, String creator,
      String text, String commentid) {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'commentDocument',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
        'commentid': commentid,
        'content': text,
      },
    );

    remotePorts.portTask.addPortGETTask(
      _flowChannelPortsUrl,
      'pushChannelDocumentComment',
      parameters: {
        'docid': msgid,
        'channel': channel,
        'creator': creator,
        'commentid': commentid,
        'comments': text,
        'interval': 10,
      },
    );
  }

  @override
  Future<Function> setCurrentActivityTask(
      {String creator,
      String docid,
      String channel,
      String action,
      String attach}) async {
    await remotePorts.portGET(
      _channelPortsUrl,
      'addExtraActivity',
      parameters: {
        'creator': creator,
        'docid': docid,
        'channel': channel,
        'action': action ?? '',
        'attach': attach ?? '',
      },
    );
  }

  @override
  void listenLikeTaskCallback(Function callback) {
    if (remotePorts.portTask.hasListener('/network/channel/extra/likes')) {
      return;
    }
    remotePorts.portTask.listener('/network/channel/extra/likes', (frame) {
      switch (frame.head('sub-command')) {
        case 'begin':
          break;
        case 'done':
          var text = frame.contentText;
          if (!StringUtil.isEmpty(text)) {
            var list = jsonDecode(text);
            callback(list);
          }
          break;
      }
    });
  }

  @override
  Future<void> pageLikeTask(String docCreator, String docid, String channel,
      int limit, int offset) async {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'pageExtraLike',
      parameters: {
        'creator': docCreator,
        'docid': docid,
        'channel': channel,
        'limit': limit,
        'offset': offset,
      },
      callbackUrl: '/network/channel/extra/likes',
    );
  }

  @override
  void listenCommentTaskCallback(Function callback) {
    if (remotePorts.portTask.hasListener('/network/channel/extra/comments')) {
      return;
    }
    remotePorts.portTask.listener('/network/channel/extra/comments', (frame) {
      switch (frame.head('sub-command')) {
        case 'begin':
          break;
        case 'done':
          var text = frame.contentText;
          if (!StringUtil.isEmpty(text)) {
            var list = jsonDecode(text);
            callback(list);
          }
          break;
      }
    });
  }

  @override
  Future<void> pageCommentTask(String docCreator, String docid, String channel,
      int limit, int offset) async {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'pageExtraComment',
      parameters: {
        'creator': docCreator,
        'docid': docid,
        'channel': channel,
        'limit': limit,
        'offset': offset,
      },
      callbackUrl: '/network/channel/extra/comments',
    );
  }

  @override
  void listenMediaTaskCallback(Function callback) {
    if (remotePorts.portTask.hasListener('/network/channel/extra/medias')) {
      return;
    }
    remotePorts.portTask.listener('/network/channel/extra/medias', (frame) {
      switch (frame.head('sub-command')) {
        case 'begin':
          break;
        case 'done':
          var text = frame.contentText;
          if (!StringUtil.isEmpty(text)) {
            var list = jsonDecode(text);
            callback(list);
          }
          break;
      }
    });
  }

  @override
  Future<void> listMediaTask(
      String docCreator, String docid, String channel) async {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'listExtraMedia',
      parameters: {
        'creator': docCreator,
        'docid': docid,
        'channel': channel,
      },
      callbackUrl: '/network/channel/extra/medias',
    );
  }

  @override
  void listenActivityTaskCallback(Function callback) {
    if (remotePorts.portTask.hasListener('/network/channel/extra/activities')) {
      return;
    }
    remotePorts.portTask.listener('/network/channel/extra/activities', (frame) {
      switch (frame.head('sub-command')) {
        case 'begin':
          break;
        case 'done':
          var list = jsonDecode(frame.contentText);
          callback(list);
          break;
      }
    });
  }

  @override
  Future<void> pageActivityTask(
      ChannelMessage channelMessage, int limit, int offset) async {
    remotePorts.portTask.addPortGETTask(
      _channelPortsUrl,
      'pageExtraActivity',
      parameters: {
        'creator': channelMessage.creator,
        'docid': channelMessage.id,
        'channel': channelMessage.onChannel,
        'limit': limit,
        'offset': offset,
      },
      callbackUrl: '/network/channel/extra/activities',
    );
  }

  @override
  Future<ChannelMessageOR> getMessage(String person, String docid) async {
    var obj = await remotePorts.portGET(
      _channelPortsUrl,
      'getDocument',
      parameters: {
        'creator': person,
        'docid': docid,
      },
    );
    if (obj == null) {
      return null;
    }
    return ChannelMessageOR(
      purchaseSn: obj['purchaseSn'],
      location:
          obj['location'] == null ? null : LatLng.fromJson(obj['location']),
      id: obj['id'],
      ctime: obj['ctime'],
      creator: obj['creator'],
      channel: obj['channel'],
      content: obj['content'],
    );
  }

  @override
  Future<List<ChannelMessageOR>> pageDocument(
      String creator, String channel, int limit, int offset) async {
    var list = await remotePorts.portGET(
      _channelPortsUrl,
      'pageDocument',
      parameters: {
        'creator': creator,
        'channel': channel,
        'limit': limit,
        'offset': offset,
      },
    );
    var docs=<ChannelMessageOR>[];
    for(var obj in list) {
      docs.add(ChannelMessageOR.parse(obj));
    }
    return docs;
  }

  @override
  Future<List<ChannelMediaOR>> listExtraMedia(
      String docid, String creator, String channel) async {
    var list = await remotePorts.portGET(
      _channelPortsUrl,
      'listExtraMedia',
      parameters: {
        'creator': creator,
        'docid': docid,
        'channel': channel,
      },
    );
    var items = <ChannelMediaOR>[];
    for (var obj in list) {
      items.add(
        ChannelMediaOR(
          type: obj['type'],
          channel: obj['channel'],
          id: obj['id'],
          ctime: obj['ctime'],
          text: obj['text'],
          src: obj['src'],
          docid: obj['docid'],
          leading: obj['leading'],
        ),
      );
    }
    return items;
  }
}
