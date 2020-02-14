import 'package:framework/framework.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:uuid/uuid.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class ChannelService implements IChannelService,IServiceBuilder {
  ///固定管道
  static const Map<String, String> _SYSTEM_CHANNELS = {
    ///地推code
    'geo_channel': '4203EC25-1FC8-479D-A78F-74338FC7E769'
  };
  IChannelDAO channelDAO;
  IChannelMessageService messageService;
  IChannelPinService pinService;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelDAO = db.channelDAO;
    messageService = site.getService('/channel/messages');
    pinService = site.getService('/channel/pin');
  }

  @override
  bool isSystemChannel(code) {
    return _SYSTEM_CHANNELS.containsValue(code);
  }

  @override
  String getSystemChannel(String code) {
    return _SYSTEM_CHANNELS[code];
  }

  @override
  Iterable<String> listSystemChannel() {
    return _SYSTEM_CHANNELS.values;
  }

  @override
  Future<void> initSystemChannel(UserPrincipal user) async {
    var _GEO_CHANNEL_CODE = _SYSTEM_CHANNELS['geo_channel'];
    if (await channelDAO.getChannel(principal?.person, _GEO_CHANNEL_CODE) ==
        null) {
      await channelDAO.addChannel(
        Channel(
            '${Uuid().v1()}',
            _GEO_CHANNEL_CODE,
            '地推',
            user.person,
            'openLoop',
            null,
            null,
            DateTime.now().millisecondsSinceEpoch,
            principal?.person),
      );
      await pinService.initChannelPin(_GEO_CHANNEL_CODE);
      await pinService.setOutputGeoSelector(_GEO_CHANNEL_CODE, true);
    }
  }

  @override
  Future<Function> updateName(String code, String text) async {
    await this.channelDAO.updateName(text, code, principal?.person);
  }

  @override
  Future<void> updateLeading(String path, String channelcode) async {
    await this.channelDAO.updateLeading(path, principal?.person, channelcode);
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
    await this.channelDAO.addChannel(channel);
    await pinService.initChannelPin(channel.code);
  }

  @override
  Future<Function> remove(String code) async {
    await messageService.emptyBy(code);
    await this.pinService.removePin(code);
    await channelDAO.removeChannel(principal?.person, code);
  }

  @override
  Future<Channel> getChannel(String code) async {
    return await this.channelDAO.getChannel(principal?.person, code);
  }

  @override
  Future<bool> existsName(String channelName, String owner) async {
    var ch = await this
        .channelDAO
        .getChannelByName(principal?.person, channelName, owner);
    return ch == null ? false : true;
  }

  @override
  Future<bool> existsChannel(code) async {
    var ch = await this.channelDAO.getChannel(principal?.person, code);
    return ch == null ? false : true;
  }

  @override
  Future<void> emptyOfPerson(String personid) async {
    await this.channelDAO.emptyOfPerson(principal?.person, personid);
  }
}
