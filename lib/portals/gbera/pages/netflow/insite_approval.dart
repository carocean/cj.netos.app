import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

import 'cat_widget.dart';

class InsiteApprovals extends StatefulWidget {
  PageContext context;

  InsiteApprovals({this.context});

  @override
  _InsiteApprovalsState createState() => _InsiteApprovalsState();
}

class _InsiteApprovalsState extends State<InsiteApprovals> {
  InsiteMessage _message;
  Channel _channel;
  Person _person;
  Person _creator;
  bool _check_rejectAllMessages = false;
  bool _check_receive_to_channel = false;
  bool _check_channel_exists = false;
  bool _disabled__check_receive_to_channel = false;
  bool _disabled__check_rejectAllMessages = false;
  bool _disabled__check_rejectChannelMessages = false;
  PurchaseOR _purchaseOR;

  @override
  void initState() {
    _message = widget.context.page.parameters['message'];
    _channel = widget.context.page.parameters['channel'];
    _person = widget.context.page.parameters['person'];

    _existsChannel().then((v) {
      setState(() {});
    });

    () async {
      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
      var person = await personService.getPerson(_person.official);
      switch (person.rights) {
        case 'denyUpstream':
          _check_rejectAllMessages = true;
          break;
        case 'denyDownstream':
          _check_rejectAllMessages = false;
          break;
        case 'denyBoth':
          _check_rejectAllMessages = true;
          break;
        default:
          _check_rejectAllMessages = false;
          break;
      }
      _creator = await personService.getPerson(_message.creator);
      _purchaseOR = await _getPurchase();
      IChannelPinService pinService =
          widget.context.site.getService('/channel/pin');
      var iperson =
          await pinService.getInputPerson(_person.official, _channel.id);
      _check_receive_to_channel = iperson?.rights != 'deny';
      IChannelService channelService =
          widget.context.site.getService('/netflow/channels');
      _check_channel_exists = await channelService.existsChannel(_channel.id);
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _message = null;
    _channel = null;
    _person = null;
    super.dispose();
  }

  Future<PurchaseOR> _getPurchase() async {
    var sn = _message.purchaseSn;
    if (StringUtil.isEmpty(sn)) {
      return null;
    }
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    return await purchaserRemote.getPurchaseRecordPerson(_message.creator, sn);
  }

  Future<void> addPersonToLocal() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    if (await personService.existsPerson(_person.official)) {
      return;
    }
    var person =
        await personService.getPerson(_person.official, isDownloadAvatar: true);
    await personService.addPerson(person);
  }

  Future<bool> _existsChannel() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    return await channelService.existsChannel(_channel.id);
  }

  Future<void> _rejectHisChannelMessage() async {
    await addPersonToLocal();
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    if (!await pinService.existsInputPerson(_person.official, _channel.id)) {
      await pinService.addInputPerson(ChannelInputPerson(
        Uuid().v1(),
        _channel.id,
        _person.official,
        'allow',
        DateTime.now().millisecondsSinceEpoch,
        widget.context.principal.person,
      ));
    }
    var iperson =
        await pinService.getInputPerson(_person.official, _channel.id);
    if (iperson.rights == 'allow') {
      await pinService.updateInputPersonRights(
          _person.official, _channel.id, 'deny');
      _check_receive_to_channel = false;
    } else {
      await pinService.updateInputPersonRights(
          _person.official, _channel.id, 'allow');
      _check_receive_to_channel = true;
    }
  }

  Future<void> _rejectHisAllMessage() async {
    await addPersonToLocal();
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var person = await personService.getPerson(_person.official);
    switch (person.rights) {
      case 'denyUpstream':
        await personService.updateRights(person.official, '');
        _person.rights = null;
        _check_rejectAllMessages = false;
        break;
      case 'denyDownstream':
        await personService.updateRights(person.official, 'denyBoth');
        _person.rights = 'denyBoth';
        _check_rejectAllMessages = true;
        break;
      case 'denyBoth':
        await personService.updateRights(person.official, 'denyDownstream');
        _person.rights = 'denyDownstream';
        _check_rejectAllMessages = false;
        break;
      default:
        await personService.updateRights(person.official, 'denyUpstream');
        _person.rights = 'denyUpstream';
        _check_rejectAllMessages = true;
        if (_check_receive_to_channel) {
          IChannelPinService pinService =
              widget.context.site.getService('/channel/pin');
          if (!await pinService.existsInputPerson(
              _person.official, _channel.id)) {
            await pinService.addInputPerson(ChannelInputPerson(
              Uuid().v1(),
              _channel.id,
              _person.official,
              'deny',
              DateTime.now().millisecondsSinceEpoch,
              widget.context.principal.person,
            ));
          } else {
            await pinService.updateInputPersonRights(
                _person.official, _channel.id, 'deny');
          }
          _check_receive_to_channel = false;
        }
        break;
    }
  }

  Future<void> _addOrRemoveChannel() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');

    if (await _existsChannel()) {
      if (await pinService.existsInputPerson(_person.official, _channel.id)) {
        await pinService.updateInputPersonRights(
            _person.official, _channel.id, 'allow');
        await _moveInsiteMessageToChannel();
      } else {
        await pinService.addInputPerson(ChannelInputPerson(
          Uuid().v1(),
          _channel.id,
          _person.official,
          'allow',
          DateTime.now().millisecondsSinceEpoch,
          widget.context.principal.person,
        ));
        //将该管道的公共活动移动到管道内，并标为arrived状态
        await _moveInsiteMessageToChannel();
        await addPersonToLocal();
        //将公众加入管道的输入端
      }
      _check_receive_to_channel = true;
      return;
    }
    //添加管道
    var remoteLeadingUrl = _channel.leading;
    var localLeadingFile;
    if (!StringUtil.isEmpty(_channel.leading) &&
        !_channel.leading.startsWith('/')) {
      var dio = widget.context.site.getService('@.http');
      localLeadingFile = await downloadChannelAvatar(
          dio: dio,
          avatarUrl:
              '${_channel.leading}?accessToken=${widget.context.principal.accessToken}');
    }
    await channelService.addChannel(_channel,
        upstreamPerson: _person.official,
        localLeading: localLeadingFile,
        remoteLeading: remoteLeadingUrl);

    if (!await pinService.existsInputPerson(_person.official, _channel.id)) {
      await pinService.addInputPerson(ChannelInputPerson(
        Uuid().v1(),
        _channel.id,
        _person.official,
        'allow',
        DateTime.now().millisecondsSinceEpoch,
        widget.context.principal.person,
      ));
    }

    //将该管道的公共活动移动到管道内，并标为arrived状态
    await _moveInsiteMessageToChannel();
    await addPersonToLocal();

    //将公众加入管道的输入端
    if (!_check_receive_to_channel) {
      await pinService.updateInputPersonRights(
          _person.official, _channel.id, 'allow');
    }
    if (_check_rejectAllMessages) {
      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
      var person = await personService.getPerson(_person.official);
      await personService.updateRights(person.official, '');
      _person.rights = null;
      _check_rejectAllMessages = false;
    }
    _check_channel_exists = true;
    _check_receive_to_channel = true;
  }

  Future<void> _moveInsiteMessageToChannel() async {
    IInsiteMessageService insiteMessageService =
        widget.context.site.getService('/insite/messages');
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    List<InsiteMessage> messages =
        await insiteMessageService.getMessageByChannel(_channel.id);
    for (var msg in messages) {
      await insiteMessageService.remove(msg.id);
      ChannelMessage cm = msg.copy();
      cm.state = 'arrived';
      await channelMessageService.addMessage(cm);
      //后台任务拉取赞、评论、媒体文件
      await channelMessageService.loadMessageExtraTask(
          cm.creator, cm.id, cm.onChannel);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_creator == null) {
      return Center(
        child: Text('正在加载...'),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        overflow: Overflow.visible,
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: [
              Container(
                color: Colors.transparent,
                height: 45,
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 40,
                      ),
                      Container(
                        constraints: BoxConstraints.tightForFinite(
                          width: double.maxFinite,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 5,
                              offset: Offset.zero,
                              blurRadius: 3,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(
                          left: 40,
                          right: 40,
                        ),
                        padding: EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            widget.context.forward(
                                '/netflow/channel/document/path',
                                arguments: {
                                  'person': _person,
                                  'channel': _channel,
                                  'message': _message,
                                  'purchase': _purchaseOR,
                                });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: getAvatarWidget(
                                        _creator?.avatar, widget.context),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 2,
                                      ),
                                      child: Text(
                                        '${_creator?.nickName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '${_message.digests ?? ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 2,
                                        top: 5,
                                      ),
                                      child: Text.rich(
                                        TextSpan(
                                          text: '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${TimelineUtil.format(
                                                _message.ctime,
                                                locale: 'zh',
                                                dayFormat: DayFormat.Simple,
                                              )}',
                                              children: [
                                                TextSpan(text: '  '),
                                              ],
                                            ),
                                            TextSpan(
                                              text: '¥',
                                              children: [
                                                TextSpan(
                                                    text: ((_purchaseOR
                                                                    ?.principalAmount ??
                                                                0.00) /
                                                            100.00)
                                                        .toStringAsFixed(2)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _message.creator == widget.context.principal.person
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : Container(
                              constraints: BoxConstraints.tightForFinite(
                                width: double.maxFinite,
                              ),
                              margin: EdgeInsets.only(
                                left: 40,
                                right: 40,
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  Container(
//                    color: Colors.white,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap:
                                              _disabled__check_rejectChannelMessages
                                                  ? null
                                                  : () {
                                                      _disabled__check_rejectChannelMessages =
                                                          true;
                                                      setState(() {});
                                                      _rejectHisChannelMessage()
                                                          .then((v) {
                                                        _disabled__check_rejectChannelMessages =
                                                            false;
                                                        setState(() {});
                                                      });
                                                    },
                                          child: CardItem(
                                            paddingTop: 10,
                                            paddingBottom: 10,
                                            title:
                                                '${_disabled__check_rejectChannelMessages ? '处理中...' : '拒收这个管道消息'}',
                                            titleColor: Colors.black87,
                                            titleSize: 12,
                                            tail: _check_receive_to_channel
                                                ? Icon(
                                                    Icons.remove,
                                                    color: Colors.grey[400],
                                                    size: 12,
                                                  )
                                                : Icon(
                                                    Icons.check,
                                                    color: Colors.red,
                                                    size: 14,
                                                  ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap:
                                              _disabled__check_rejectAllMessages
                                                  ? null
                                                  : () {
                                                      _disabled__check_rejectAllMessages =
                                                          true;
                                                      setState(() {});
                                                      _rejectHisAllMessage()
                                                          .then((v) {
                                                        _disabled__check_rejectAllMessages =
                                                            false;
                                                        setState(() {});
                                                      });
                                                    },
                                          child: CardItem(
                                            paddingTop: 10,
                                            paddingBottom: 10,
                                            title:
                                                '${_disabled__check_rejectAllMessages ? '处理中...' : '拒收他的所有消息'}',
                                            titleColor: Colors.black87,
                                            titleSize: 12,
                                            tail: !_check_rejectAllMessages
                                                ? Icon(
                                                    Icons.remove,
                                                    color: Colors.grey[400],
                                                    size: 12,
                                                  )
                                                : Icon(
                                                    Icons.check,
                                                    color: Colors.red,
                                                    size: 14,
                                                  ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap:
                                              _disabled__check_receive_to_channel
                                                  ? null
                                                  : () {
                                                      _disabled__check_receive_to_channel =
                                                          true;
                                                      setState(() {});
                                                      _addOrRemoveChannel()
                                                          .then((v) {
                                                        _disabled__check_receive_to_channel =
                                                            true;
                                                        setState(() {});
                                                        widget.context.backward(
                                                            result: {
                                                              'refresh': true
                                                            });
                                                      });
                                                    },
                                          child: CardItem(
                                            paddingTop: 10,
                                            paddingBottom: 10,
                                            title:
                                                '${_disabled__check_receive_to_channel ? '处理中...' : '将消息收取到管道'}',
                                            tipsSize: 10,
                                            titleColor: Colors.black87,
                                            titleSize: 12,
                                            tail: Row(
                                              children: [
                                                CatWidget(
                                                  context: widget.context,
                                                  channelId: _channel.id,
                                                  size: 14,
                                                  canTap: false,
                                                  tipsWidget: Text(
                                                    '可加猫',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                !_check_channel_exists ||
                                                        !_check_receive_to_channel
                                                    ? Icon(
                                                        Icons.remove,
                                                        color: Colors.grey[400],
                                                        size: 12,
                                                      )
                                                    : Icon(
                                                        Icons.check,
                                                        color: Colors.red,
                                                        size: 14,
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 5,
                              offset: Offset.zero,
                              blurRadius: 3,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(
                          top: 10,
                        ),
                        constraints: BoxConstraints.tightForFinite(
                          width: double.maxFinite,
                        ),
                        child: FlatButton(
                          onPressed: () {
                            widget.context
                                .backward(result: {'action': 'cancel'});
                          },
                          child: Text(
                            '取消',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 8,
                          color: Colors.white,
                        ),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: _channel?.leading == null
                              ? AssetImage(
                                  'lib/portals/gbera/images/netflow.png',
                                )
                              : _channel?.leading.startsWith('/')
                                  ? FileImage(
                                      File(
                                        _channel?.leading,
                                      ),
                                    )
                                  : CachedNetworkImageProvider(
                                      '${_channel?.leading}?accessToken=${widget.context.principal.accessToken}',
                                    ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            offset: Offset.zero,
                            spreadRadius: 3,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      widget.context.backward();
                      widget.context.forward("/netflow/channel/portal/channel", arguments: {
                        'channel': _channel.id,
                        'origin':_person.official,
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.backward();
                        widget.context.forward("/netflow/channel/portal/channel", arguments: {
                          'channel': _channel.id,
                          'origin':_person.official,
                        });
                      },
                      child: Text(
                        '${_channel?.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.grey,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
