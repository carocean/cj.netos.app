import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:uuid/uuid.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class ChannelService implements IChannelService, IServiceBuilder {
  ///固定管道
  final Map<String, String> _SYSTEM_CHANNELS = {
    ///地推id
    'geo_channel': MD5Util.MD5('4203EC25-1FC8-479D-A78F-74338FC7E769'),
  };

  IChannelDAO channelDAO;
  IChannelMessageService messageService;
  IChannelPinService pinService;
  IServiceProvider site;
  IChannelRemote channelRemote;
  IChannelCache channelCache;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelDAO = db.channelDAO;
    messageService = site.getService('/channel/messages');
    pinService = site.getService('/channel/pin');
    channelRemote = site.getService('/remote/channels');
    channelCache = site.getService('/cache/channels');
  }

  @override
  bool isSystemChannel(channelid) {
    return _SYSTEM_CHANNELS.containsValue(channelid);
  }

  @override
  String getSystemChannel(String channelid) {
    return _SYSTEM_CHANNELS[channelid];
  }

  @override
  Iterable<String> listSystemChannel() {
    return _SYSTEM_CHANNELS.values;
  }

  @override
  Future<void> initSystemChannel(UserPrincipal user) async {
    var _GEO_CHANNEL_ID = _SYSTEM_CHANNELS['geo_channel'];
    if (await channelDAO.getChannel(user?.person, _GEO_CHANNEL_ID) == null) {
      var channel = Channel(
          _GEO_CHANNEL_ID,
          '地推',
          user.person,
          user.person,
          null,
          null,
          null,
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch,
          user?.person);
      await channelDAO.addChannel(channel);
      await pinService.initChannelPin(_GEO_CHANNEL_ID);
      await pinService.setOutputGeoSelector(_GEO_CHANNEL_ID, true);
      await channelRemote.createChannel(
        channel.id,
        title: channel.name,
        leading: channel.leading,
        outPersonSelector: 'only_select',
        outGeoSelector: true,
      );
    }
  }

  @override
  Future<Function> updateUtime(String channel) async {
    await channelDAO.updateUtime(
        DateTime.now().millisecondsSinceEpoch, channel, principal?.person);
  }

  @override
  Future<Function> updateName(String channelid, String text) async {
    await this.channelDAO.updateName(text, channelid, principal?.person);
  }

  @override
  Future<void> updateLeading(
      String localPath, String remotePath, String channelid) async {
    await this
        .channelDAO
        .updateLeading(localPath, principal?.person, channelid);
    await this.channelRemote.updateLeading(channelid, remotePath);
  }

  @override
  Future<void> empty() async {
    await this.channelDAO.empty(principal?.person);
  }

  @override
  Future<List<Channel>> getChannelsOfPerson(String personid) async {
    return await this
        .channelDAO
        .getChannelsOfPerson(principal?.person, personid);
  }

  @override
  Future<List<Channel>> getAllChannel() async {
    return await this.channelDAO.getAllChannel(principal?.person);
  }

  @override
  Future<void> addChannel(Channel channel,
      {String upstreamPerson,
      String localLeading,
      String remoteLeading,
      bool isOnlyLocal = false}) async {
    if (StringUtil.isEmpty(channel.id)) {
      channel.id = MD5Util.MD5('${Uuid().v1()}');
    }
    if (!StringUtil.isEmpty(localLeading)) {
      channel.leading = localLeading;
    }
    await this.channelDAO.addChannel(channel);
    await pinService.initChannelPin(channel.id);
    if (!StringUtil.isEmpty(remoteLeading)) {
      channel.leading = remoteLeading;
    }
    if (!isOnlyLocal) {
      await channelRemote.createChannel(
        channel.id,
        title: channel.name,
        leading: channel.leading,
        upstreamPerson: channel.upstreamPerson,
        outPersonSelector: 'only_select',
        outGeoSelector: false,
      );
    }
  }

  @override
  Future<Function> remove(String channelid) async {
    await messageService.emptyBy(channelid);
    await this.pinService.removePin(channelid);
    await channelDAO.removeChannel(principal?.person, channelid);
    await channelRemote.removeChannel(channelid);
  }

  @override
  Future<Channel> getChannel(String channelid) async {
    var channel =
        await this.channelDAO.getChannel(principal?.person, channelid);
    if (channel == null) {
      var cachedchannel = await channelCache.get(channelid);
      if (cachedchannel != null) {
        channel = cachedchannel;
      }
    }
    return channel;
  }

  @override
  Future<Channel> getlastChannel() async {
    return await this.channelDAO.getlastChannel(principal?.person);
  }

  @override
  Future<Channel> findChannelOfPerson(String channelid, String person) async {
    Channel channel = await getChannel(channelid);
    if (channel == null) {
      var cachedchannel = await channelCache.get(channelid);
      if (cachedchannel != null) {
        channel = cachedchannel;
      }
      if (channel == null) {
        channel = await this.fetchChannelOfPerson(channelid, person);
      }
    }
    return channel;
  }

  @override
  Future<Channel> fetchChannelOfPerson(String channelid, String person) async {
    Channel channel =
        await this.channelRemote.findChannelOfPerson(channelid, person);
    return channel;
  }

  @override
  Future<List<Person>> pageOutputPersonOf(
      String channel, String person, int limit, int offset) async {
    return await this
        .channelRemote
        .pageOutputPersonOf(channel, person, limit, offset);
  }

  @override
  Future<List<Person>> pageInputPersonOf(
      String channel, String person, int limit, int offset) async {
    return await this
        .channelRemote
        .pageInputPersonOf(channel, person, limit, offset);
  }

  @override
  Future<List<Channel>> fetchChannelsOfPerson(String official) async {
    return await this.channelRemote.fetchChannelsOfPerson(official);
  }

  @override
  Future<bool> existsName(String channelName, String owner) async {
    var ch = await this
        .channelDAO
        .getChannelByName(principal?.person, channelName, owner);
    return ch == null ? false : true;
  }

  @override
  Future<bool> existsChannel(channelid) async {
    var ch = await this.channelDAO.getChannel(principal?.person, channelid);
    return ch == null ? false : true;
  }

  @override
  Future<void> emptyOfPerson(String personid) async {
    await this.channelDAO.emptyOfPerson(principal?.person, personid);
  }
}
