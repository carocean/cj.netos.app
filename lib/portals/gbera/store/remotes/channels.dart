import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
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
  Future<Function> createChannel(String channel, String origin,
      {@required String title,
      @required String leading,
      @required String outPersonSelector,
      @required bool outGeoSelector}) async {
    await remotePorts.portGET(_networkPortsUrl, 'createChannel', parameters: {
      'channel': channel,
      'origin': origin,
      'title': title,
      'leading': leading,
      'outPersonSelector': outPersonSelector,
      'outGeoSelector': '$outGeoSelector',
    });
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
      var channelid=MD5Util.generateMd5('${Uuid().v1()}');
      channels.add(Channel(
        channelid,
        obj['origin'],
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
}
