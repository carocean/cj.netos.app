import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:objectdb/objectdb.dart';
import 'package:uuid/uuid.dart';

class ChatTalk extends StatefulWidget {
  PageContext context;

  ChatTalk({this.context});

  @override
  _ChatTalkState createState() => _ChatTalkState();
}

class _ChatTalkState extends State<ChatTalk> {
  List<Function()> _onTapEvents = [];

  ChatRoom _chatRoom;
  EasyRefreshController _controller;
  ScrollController _scrollController;
  _RoomMode _roomMode;
  List<ChatMessage> _p2pMessages;
  int _limit = 12, _offset = 0;
  String _displayRoomTitle;

  @override
  void initState() {
    _p2pMessages = [];
    _chatRoom = widget.context.parameters['chatRoom'];
    _displayRoomTitle = widget.context.parameters['displayRoomTitle'];
    _onRefresh().then((v) {
      setState(() {
        _goEnd();
      });
    });
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
  }

  void _goEnd([int milliseconds = 300]) {
    Timer(
        Duration(
          milliseconds: milliseconds,
        ), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _p2pMessages.clear();
    _chatRoom = null;
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _resetMessages() {
    _p2pMessages.clear();
    _offset = 0;
    _controller.resetRefreshState();
  }

  Future<void> _onRefresh() async {
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    List<ChatMessage> messages =
        await messageService.pageMessage(_chatRoom.id, _limit, _offset);
    if (messages.isEmpty) {
      _controller.finishRefresh(success: true, noMore: true);
      return;
    }
    _offset += messages.length;
    _p2pMessages.addAll(messages);
  }

  Future<void> _doCommand(_ChatCommand cmd) async {
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    switch (cmd.cmd) {
      case 'sendText':
        await messageService.addMessage(
          ChatMessage(
            MD5Util.MD5(Uuid().v1()),
            widget.context.principal.person,
            _chatRoom.id,
            'text',
            cmd.message,
            'sended',
            DateTime.now().millisecondsSinceEpoch,
            null,
            null,
            null,
            widget.context.principal.person,
          ),
        );
        break;
      case 'sendAudio':
        var msg = cmd.message as Map;
        var map = {'path': msg['path'], 'timelength': msg['timelength']};
        String text = jsonEncode(map);
        await messageService.addMessage(
          ChatMessage(
            MD5Util.MD5(Uuid().v1()),
            widget.context.principal.person,
            _chatRoom.id,
            'audio',
            text,
            'sended',
            DateTime.now().millisecondsSinceEpoch,
            null,
            null,
            null,
            widget.context.principal.person,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: '$_displayRoomTitle',
            children: [
//              TextSpan(
//                text: _roomMode == null || _roomMode == _RoomMode.p2p
//                    ? ' 聊天'
//                    : ' 服务',
//                style: TextStyle(
//                  fontSize: 12,
//                ),
//              ),
            ],
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              widget.context.forward('/portlet/chat/room/settings',
                  arguments: {'chatRoom': _chatRoom});
            },
            icon: Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                _onTapEvents.forEach((cb) {
                  cb();
                });
              },
              behavior: HitTestBehavior.opaque,
              child: EasyRefresh.custom(
                shrinkWrap: true,
                scrollController: _scrollController,
                controller: _controller,
                onRefresh: () async {
                  _onRefresh().then((v) {
                    setState(() {});
                  });
                },
                slivers: _p2pMessages.reversed.map((msg) {
                  var item;
                  if (msg.sender == widget.context.principal.person) {
                    item = _SendMessageItem(
                      p2pMessage: msg,
                      context: widget.context,
                    );
                  } else {
                    item = _ReceiveMessageItem(
                      p2pMessage: msg,
                    );
                  }
                  return SliverToBoxAdapter(
                    child: item,
                  );
                }).toList(),
              ),
            ),
          ),
          _ChatSender(
            context: widget.context,
            onTapEvents: _onTapEvents,
            plusPanel: _PlusPannel(),
            stickerPanel: _StickerPanel(),
            textRegionController: _scrollController,
            onRoomModeChanged: (m) {
              _roomMode = m;
              setState(() {});
            },
            onCommand: (cmd) async {
              await _doCommand(cmd);
              _resetMessages();
              await _onRefresh();
              setState(() {
                _goEnd(500);
              });
            },
          ),
        ],
      ),
    );
  }
}

class _StickerPanel extends StatefulWidget {
  @override
  __StickerPanelState createState() => __StickerPanelState();
}

class __StickerPanelState extends State<_StickerPanel> {
  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    for (var i = 0; i < 50; i++) {
      items.add(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          alignment: Alignment.center,
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Icon(
                Icons.face,
                size: 30,
                color: Colors.grey[700],
              ),
            ],
          ),
        ),
      );
    }
    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        maxCrossAxisExtent: 40,
      ),
      scrollDirection: Axis.vertical,
      children: items.map((item) {
        return item;
      }).toList(),
    );
  }
}

class _PlusPannel extends StatefulWidget {
  @override
  _PlusPannelState createState() => _PlusPannelState();
}

class _PlusPannelState extends State<_PlusPannel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    for (var i = 0; i < 13; i++) {
      items.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          alignment: Alignment.center,
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_enhance,
                size: 35,
                color: Colors.grey[700],
              ),
              Text(
                '拍照',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 30.0,
        maxCrossAxisExtent: 80,
      ),
      scrollDirection: Axis.vertical,
      children: items.map((item) {
        return item;
      }).toList(),
    );
  }
}

enum _Action {
  plus,
  sticker,
}
enum _RoomMode {
  ///p2p互聊，普通群
  p2p,

  ///B2P互聊，企业客服到用户
  b2p,
}

class _ChatCommand {
  String cmd;
  Object message;

  _ChatCommand({this.cmd, this.message});
}

class _ChatSender extends StatefulWidget {
  PageContext context;
  Widget plusPanel;
  Widget stickerPanel;
  ScrollController textRegionController;
  Function(_RoomMode roomMode) onRoomModeChanged;
  Function(_ChatCommand cmd) onCommand;

  List<Function()> onTapEvents;

  _ChatSender({
    this.context,
    this.onTapEvents,
    this.plusPanel,
    this.stickerPanel,
    this.textRegionController,
    this.onRoomModeChanged,
    this.onCommand,
  });

  @override
  __ChatSenderState createState() => __ChatSenderState();
}

class __ChatSenderState extends State<_ChatSender> {
  _Action _action;
  TextEditingController _controller;
  FocusNode _contentFocusNode;
  _RoomMode _roomMode = _RoomMode.p2p;

  @override
  void initState() {
    _contentFocusNode = FocusNode();
    _controller = TextEditingController();
    widget.onTapEvents.add(() {
      _action = null;
      _contentFocusNode.unfocus();
      setState(() {});
    });
    _contentFocusNode.unfocus();
    super.initState();
  }

  @override
  void dispose() {
    _roomMode = _RoomMode.p2p;
    _contentFocusNode.dispose();
    _controller.dispose();
    widget.onTapEvents.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var panel = null;
    switch (_action) {
      case _Action.plus:
        panel = widget.plusPanel;
        break;
      case _Action.sticker:
        panel = widget.stickerPanel;
        break;
    }
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    ExtendedTextField(
                      controller: _controller,
                      focusNode: _contentFocusNode,
                      maxLines: 1,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (v) {
                        _controller.clear();
                        if (widget.onCommand != null) {
                          widget.onCommand(
                            _ChatCommand(
                              cmd: 'sendText',
                              message: v,
                            ),
                          );
                          _contentFocusNode.requestFocus();
                        }
                      },
                      autofocus: false,
                      onTap: () {
                        _action = null;
                        if (widget.textRegionController != null) {
                          widget.textRegionController.jumpTo(widget
                              .textRegionController.position.maxScrollExtent);
                        }
                        setState(() {});
                      },
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText:
                            _roomMode == _RoomMode.p2p ? '聊天中...' : '服务中...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(0),
                            topRight: Radius.circular(20),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.only(
                          left: 5,
                          right: 38,
                          top: 15,
                          bottom: 15,
                        ),
                        prefixIcon: GestureDetector(
                          child: Icon(
                            _roomMode == _RoomMode.p2p
                                ? IconData(0xe60c, fontFamily: 'chats')
                                : IconData(0xe6bc, fontFamily: 'chats'),
                            size: 25,
                            color: Colors.grey[500],
                          ),
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _roomMode = _roomMode == _RoomMode.p2p
                                ? _RoomMode.b2p
                                : _RoomMode.p2p;
                            if (widget.onRoomModeChanged != null) {
                              widget.onRoomModeChanged(_roomMode);
                            }
                            _contentFocusNode.unfocus();
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 7,
                      bottom: 9,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: VoiceFloatingButton(
                          context: widget.context,
                          iconSize: 18,
                          onStopRecord: (a, b, FlutterPluginRecord c, d) {
                            if (d != 'send') {
                              return;
                            }
                            if (widget.onCommand != null) {
                              widget.onCommand(
                                _ChatCommand(
                                  cmd: 'sendAudio',
                                  message: {
                                    'path': a,
                                    'timelength': b,
                                    'action': d,
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.textRegionController != null) {
                    widget.textRegionController.jumpTo(
                        widget.textRegionController.position.maxScrollExtent);
                  }
                  _action = _Action.sticker;
                  _contentFocusNode.unfocus();
                  setState(() {});
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 5,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Icon(
                    FontAwesomeIcons.smileBeam,
                    size: 22,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.textRegionController != null) {
                    widget.textRegionController.jumpTo(
                        widget.textRegionController.position.maxScrollExtent);
                  }
                  _action = _Action.plus;
                  _contentFocusNode.unfocus();
                  setState(() {});
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 10,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
          _action == null
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Container(
                  height: 200,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  child: panel,
                ),
        ],
      ),
    );
  }
}

class _ReceiveMessageItem extends StatefulWidget {
  ChatMessage p2pMessage;

  _ReceiveMessageItem({this.p2pMessage});

  @override
  _ReceiveMessageItemState createState() => _ReceiveMessageItemState();
}

class _ReceiveMessageItemState extends State<_ReceiveMessageItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 60,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
                child: Image.network(
                  'http://47.105.165.186:7100/public/avatar/24f8e8d3f423d40b5b390691fbbfb5d7.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              runSpacing: 5,
              direction: Axis.horizontal,
              children: <Widget>[
                Text(
                  TimelineUtil.format(
                    DateTime.now().millisecondsSinceEpoch,
                  ),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text:
                            '新京报快讯 据贵州省卫生健康委员会官方微博消息，1月26日晚，贵州省疫情防控工作领导小组接报，泰国亚洲航空公司FD428航班将于当晚22时50分落地贵阳，机上一名有武汉旅行史的福建旅客林某某（男，44岁）和一名贵州省六盘水市旅客康某某（女，7岁）出现发热状况。',
                      ),
                    ],
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendMessageItem extends StatefulWidget {
  ChatMessage p2pMessage;
  PageContext context;

  _SendMessageItem({this.p2pMessage, this.context});

  @override
  __SendMessageItemState createState() => __SendMessageItemState();
}

class __SendMessageItemState extends State<_SendMessageItem> {
  Person _sender;

  @override
  void initState() {
    _loadSender().then((p) {
      setState(() {});
    });
    super.initState();
  }

  Future<void> _loadSender() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _sender = await personService.getPerson(widget.p2pMessage.sender);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(_SendMessageItem oldWidget) {
    if (oldWidget.p2pMessage == widget.p2pMessage) {
      super.didUpdateWidget(oldWidget);
      return;
    }
    _loadSender().then((p) {
      setState(() {});
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var display;
    switch (widget.p2pMessage.contentType) {
      case 'text':
        display = Text.rich(
          TextSpan(
            text: '',
            children: [
              TextSpan(
                text: '${widget.p2pMessage.content ?? ''}',
              ),
            ],
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        );
        break;
      case 'audio':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        display = MyAudioWidget(
          audioFile: map['path'],
          timeLength: map['timelength'],
        );
        break;
      default:
        print('未识别的消息类型:${widget.p2pMessage.contentType}');
        display = Container(
          width: 0,
          height: 0,
        );
        break;
    }
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      padding: EdgeInsets.only(
        left: 60,
        right: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  TimelineUtil.format(
                    widget.p2pMessage.ctime,
                  ),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                display,
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
                child: _sender == null
                    ? Container(
                        height: 0,
                        width: 0,
                      )
                    : Image.file(
                        File(_sender.avatar),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
