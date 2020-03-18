import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

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
  bool _check_rejectAllMessages = false;
  bool _check_receive_to_channel = false;
  bool _check_channel_exists = false;
  bool _disabled__check_receive_to_channel = false;
  bool _disabled__check_rejectAllMessages = false;
  bool _disabled__check_rejectChannelMessages = false;

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

      IChannelPinService pinService =
          widget.context.site.getService('/channel/pin');
      var iperson =
          await pinService.getInputPerson(_person.official, _channel.id);
      _check_receive_to_channel = iperson?.rights != 'deny';
      IChannelService channelService =
          widget.context.site.getService('/netflow/channels');
      _check_channel_exists = await channelService.existsChannel(_channel.id);
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
        widget.context.principal.person,
      ));
    }
    var iperson =
    await pinService.getInputPerson(_person.official, _channel.id);
    if(iperson.rights=='allow') {
      await pinService.updateInputPersonRights(
          _person.official, _channel.id, 'deny');
      _check_receive_to_channel =false;
    }else{
      await pinService.updateInputPersonRights(
          _person.official, _channel.id, 'allow');
      _check_receive_to_channel =true;
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
          if (!await pinService.existsInputPerson(_person.official, _channel.id)) {
            await pinService.addInputPerson(ChannelInputPerson(
              Uuid().v1(),
              _channel.id,
              _person.official,
              'deny',
              widget.context.principal.person,
            ));
          }else {
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
        await pinService.updateInputPersonRights(_person.official, _channel.id,'allow');
        await _moveInsiteMessageToChannel();
      } else {
        await pinService.addInputPerson(ChannelInputPerson(
          Uuid().v1(),
          _channel.id,
          _person.official,
          'allow',
          widget.context.principal.person,
        ));
        //将该管道的公共活动移动到管道内，并标为arrived状态
        await _moveInsiteMessageToChannel();
        await addPersonToLocal();
        //将公众加入管道的输入端
      }
      _check_receive_to_channel =true;
      return;
    }
    //添加管道
    if (!StringUtil.isEmpty(_channel.leading)) {
      var dio = widget.context.site.getService('@.http');
      var localLeadingFile = await downloadChannelAvatar(
          dio: dio,
          avatarUrl:
              '${_channel.leading}?accessToken=${widget.context.principal.accessToken}');
      _channel.leading = localLeadingFile;
    }
    await channelService.addChannel(_channel);

    if (!await pinService.existsInputPerson(_person.official, _channel.id)) {
      await pinService.addInputPerson(ChannelInputPerson(
        Uuid().v1(),
        _channel.id,
        _person.official,
        'allow',
        widget.context.principal.person,
      ));
    }

    //将该管道的公共活动移动到管道内，并标为arrived状态
    await _moveInsiteMessageToChannel();
    await addPersonToLocal();
    //将公众加入管道的输入端
    if(!_check_receive_to_channel) {
      await pinService.updateInputPersonRights(
          _person.official, _channel.id, 'allow');
    }
    if(_check_rejectAllMessages) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      fit: StackFit.expand,
      children: <Widget>[
        Column(
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
                  widget.context
                      .forward('/netflow/channel/document/path', arguments: {
                    'person': _person,
                    'channel': _channel,
                    'message': _message,
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: _person.avatar.startsWith('/')
                          ? Image.file(
                              File(_person.avatar),
                              width: 40,
                              height: 40,
                            )
                          : Image.network(
                              _person.avatar,
                              width: 40,
                              height: 40,
                            ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 2,
                            ),
                            child: Text(
                              '${_person.nickName ?? _person.accountCode}',
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
                                      dayFormat: DayFormat.Simple,
                                    )}',
                                    children: [
                                      TextSpan(text: '  '),
                                    ],
                                  ),
                                  TextSpan(
                                    text: '洇金:¥',
                                    children: [
                                      TextSpan(
                                          text: (_message.wy * 0.001)
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
            Container(
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
                          onTap: _disabled__check_rejectChannelMessages
                              ? null
                              : () {
                                  _disabled__check_rejectChannelMessages = true;
                                  setState(() {});
                                  _rejectHisChannelMessage().then((v) {
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
                          onTap: _disabled__check_rejectAllMessages
                              ? null
                              : () {
                                  _disabled__check_rejectAllMessages = true;
                                  setState(() {});
                                  _rejectHisAllMessage().then((v) {
                                    _disabled__check_rejectAllMessages = false;
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
                          onTap: _disabled__check_receive_to_channel
                              ? null
                              : () {
                                  _disabled__check_receive_to_channel = true;
                                  setState(() {});
                                  _addOrRemoveChannel().then((v) {
                                    _disabled__check_receive_to_channel = true;
                                    setState(() {});
                                    widget.context
                                        .backward(result: {'refresh': true});
                                  });
                                },
                          child: CardItem(
                            paddingTop: 10,
                            paddingBottom: 10,
                            title:
                                '${_disabled__check_receive_to_channel ? '处理中...' : '将消息收取到管道'}',
                            tipsText: '您可获得: ¥2.21',
                            tipsSize: 10,
                            titleColor: Colors.black87,
                            titleSize: 12,
                            tail: !_check_channel_exists ||
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
                  widget.context.backward(result: {'action': 'cancel'});
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
        Positioned(
          top: -40,
          left: 20,
          child: Row(
            children: <Widget>[
              GestureDetector(
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
                              : NetworkImage(
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
                  print('xxxx');
                  widget.context.backward();
//                  widget.context.forward('/channel/viewer');
                  widget.context.forward('/netflow/portal/channel',
                      arguments: {'channel': _channel}).then((v) {});
                },
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 2,
                  right: 10,
                ),
                height: 55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${_channel?.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
