import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

final IChannelOpener channelOpener = _DefaultChannelOpener();

mixin IChannelOpener {
  Future<void> openMyChannelAndAddToInput(
      PageContext context, String channel, String owner) {}

  Future<bool> existsChannelAndOnInput(
      PageContext context, String channel, String owner) {}

  Future<void> removePersonFromInput(
      PageContext context, String channel, String owner) {}

  Future<void> openMyChannelAndAddToOutput(
      PageContext context, String channel, String owner) {}

  Future<bool> existsChannelAndOnOutput(
      PageContext context, String channel, String owner) {}

  Future<void> removePersonFromOutput(
      PageContext context, String channel, String owner) {}
}

class _DefaultChannelOpener implements IChannelOpener {
  @override
  Future<void> openMyChannelAndAddToInput(
      PageContext context, String channel, String owner) async {
    IChannelService channelService =
        context.site.getService('/netflow/channels');
    IChannelRemote channelRemote = context.site.getService('/remote/channels');
    IChannelPinService pinService = context.site.getService('/channel/pin');

    if (!(await channelService.existsChannel(channel))) {
      await _createChannel(context, channelService, channel, owner);
    }
    if (!await pinService.existsInputPerson(owner, channel)) {
      IPersonService personService = context.site.getService('/gbera/persons');
      if (!await personService.existsPerson(owner)) {
        var person =
            await personService.getPerson(owner, isDownloadAvatar: true);
        await personService.addPerson(person, isOnlyLocal: true);
      }
      await pinService.addInputPerson(ChannelInputPerson(
        MD5Util.MD5(Uuid().v1()),
        channel,
        owner,
        'allow',
        DateTime.now().millisecondsSinceEpoch,
        context.principal.person,
      ));
    }
    await channelRemote.removeOutputPersonOfCreator(owner, channel);
    await channelRemote.addOutputPersonOfCreator(owner, channel);
  }

  @override
  Future<void> openMyChannelAndAddToOutput(
      PageContext context, String channel, String owner) async {
    IChannelService channelService =
        context.site.getService('/netflow/channels');
    IChannelPinService pinService = context.site.getService('/channel/pin');

    if (!(await channelService.existsChannel(channel))) {
      await _createChannel(context, channelService, channel, owner);
    }
    if (!await pinService.existsOutputPerson(owner, channel)) {
      IPersonService personService = context.site.getService('/gbera/persons');
      if (!await personService.existsPerson(owner)) {
        var person =
            await personService.getPerson(owner, isDownloadAvatar: true);
        await personService.addPerson(person, isOnlyLocal: true);
      }
      //仅需要添加到我的管道出口，对方收到动态后来判断是否加入其输入端子
      await pinService.addOutputPerson(ChannelOutputPerson(
        MD5Util.MD5(Uuid().v1()),
        channel,
        owner,
        DateTime.now().millisecondsSinceEpoch,
        context.principal.person,
      ));
    }
  }

  Future<void> _createChannel(context, channelService, channel, owner) async {
    //创建channel
    Channel ch = await channelService.fetchChannelOfPerson(channel, owner);
    if (ch == null) {
      return;
    }
    var remoteLeadingUrl = ch.leading;
    var localLeadingFile;
    if (!StringUtil.isEmpty(ch.leading) && !ch.leading.startsWith('/')) {
      var dio = context.site.getService('@.http');
      localLeadingFile = await downloadChannelAvatar(
          dio: dio,
          avatarUrl:
              '${ch.leading}?accessToken=${context.principal.accessToken}');
    }
    await channelService.addChannel(ch,upstreamPerson: owner,
        localLeading: localLeadingFile, remoteLeading: remoteLeadingUrl);
  }

  @override
  Future<bool> existsChannelAndOnInput(
      PageContext context, String channel, String owner) async {
    IChannelService channelService =
        context.site.getService('/netflow/channels');
    IChannelPinService pinService = context.site.getService('/channel/pin');

    var existsChannel = await channelService.existsChannel(channel);
    var onInput = await pinService.existsInputPerson(owner, channel);
    return existsChannel && onInput;
  }

  @override
  Future<bool> existsChannelAndOnOutput(
      PageContext context, String channel, String owner) async {
    IChannelService channelService =
        context.site.getService('/netflow/channels');
    IChannelPinService pinService = context.site.getService('/channel/pin');

    var existsChannel = await channelService.existsChannel(channel);
    var onInput = await pinService.existsOutputPerson(owner, channel);
    return existsChannel && onInput;
  }

  @override
  Future<void> removePersonFromInput(
      PageContext context, String channel, String owner) async {
    IChannelPinService pinService = context.site.getService('/channel/pin');
    await pinService.removeInputPerson(owner, channel);
    IChannelRemote channelRemote = context.site.getService('/remote/channels');
    await channelRemote.removeOutputPersonOfCreator(
        context.principal.person, channel);
  }

  @override
  Future<void> removePersonFromOutput(
      PageContext context, String channel, String owner) async {
    IChannelPinService pinService = context.site.getService('/channel/pin');
    await pinService.removeOutputPerson(owner, channel);
  }
}
