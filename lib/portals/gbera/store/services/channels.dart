import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:uuid/uuid.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class ChannelService implements IChannelService, IServiceBuilder {
  ///固定管道
  final Map<String, String> _SYSTEM_CHANNELS = {
    ///地推origin
    'geo_channel': MD5Util.generateMd5('4203EC25-1FC8-479D-A78F-74338FC7E769'),
  };

  IChannelDAO channelDAO;
  IChannelMessageService messageService;
  IChannelPinService pinService;
  IServiceProvider site;
  IChannelRemote channelRemote;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelDAO = db.channelDAO;
    messageService = site.getService('/channel/messages');
    pinService = site.getService('/channel/pin');
    channelRemote = site.getService('/remote/channels');
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
    var _GEO_CHANNEL_ORIGIN = _SYSTEM_CHANNELS['geo_channel'];
    if (await channelDAO.getChannelByOrigin(
            user?.person, user?.person, _GEO_CHANNEL_ORIGIN) ==
        null) {
      var channelid = MD5Util.generateMd5('${Uuid().v1()}');
      var channel = Channel(channelid, _GEO_CHANNEL_ORIGIN, '地推', user.person,
          null, null, DateTime.now().millisecondsSinceEpoch, user?.person);
      await channelDAO.addChannel(channel);
      await pinService.initChannelPin(channelid);
      await pinService.setOutputGeoSelector(channelid, true);
      await channelRemote.createChannel(
        channel.id,
        channel.origin,
        title: channel.name,
        leading: channel.leading,
        outPersonSelector: 'all_except',
        outGeoSelector: true,
      );
    }
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
  Future<void> addChannel(Channel channel) async {
    if (StringUtil.isEmpty(channel.id)) {
      channel.id = MD5Util.generateMd5('${Uuid().v1()}');
    }

    await this.channelDAO.addChannel(channel);
    await pinService.initChannelPin(channel.id);
    await channelRemote.createChannel(
      channel.id,
      channel.origin,
      title: channel.name,
      leading: channel.leading,
      outPersonSelector: 'all_except',
      outGeoSelector: false,
    );
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
    return await this.channelDAO.getChannel(principal?.person, channelid);
  }

  @override
  Future<Channel> getChannelOfPerson(String channelid, String person) async {
    Channel channel = await getChannel(channelid);
    if (channel == null) {
      channel = await this.channelRemote.getChannelOfPerson(channelid, person);
    }
    return channel;
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
