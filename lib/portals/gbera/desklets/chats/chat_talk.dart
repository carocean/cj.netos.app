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
  StreamSubscription _streamSubscription;
  bool _isloaded = false;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _p2pMessages = [];
    _chatRoom = widget.context.parameters['chatRoom'];
    _displayRoomTitle = widget.context.parameters['displayRoomTitle'];
    _flagReadMessages().then((v) {
      _onRefresh().then((v) {
        if (mounted) {
          _goEnd(500);
          _isloaded = true;
          setState(() {});
        }
      });
    });
    Stream notify = widget.context.parameters['notify'];
    _streamSubscription = notify.listen((command) {
      ChatMessage message = command['message'];
      if (message == null||message.sender==widget.context.principal.person || message.room != _chatRoom.id) {
        return;
      }
      switch (command['action']) {
        case 'arrivePushMessageCommand':
          _arrivePushMessageCommand(message);
          break;
        default:
          print('不支持的命令:${command['action']}');
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _p2pMessages.clear();
    _chatRoom = null;
    _controller.dispose();
    _scrollController.dispose();
    _isloaded = false;
    super.dispose();
  }

  void _goEnd([int milliseconds = 10]) {
    Future.delayed(
        Duration(
          milliseconds: milliseconds,
        ), () {
      if (_scrollController == null) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _arrivePushMessageCommand(message) async {
    //为了去除屏动效果
    //加载未读的消息并添加到_p2pMessages
    //然后标记为已读
    //再定位为结尾
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    var unreadMessages = await messageService.listUnreadMessages(_chatRoom.id);
    if (unreadMessages.length == null) {
      return;
    }
    await _flagReadMessages();
    _p2pMessages.insertAll(0, unreadMessages);
    setState(() {
      _goEnd(300);
    });
  }

  _resetMessages() {
    _p2pMessages.clear();
    _offset = 0;
    _controller.resetRefreshState();
  }

  Future<void> _flagReadMessages() async {
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    await messageService.flatReadMessages(_chatRoom.id);
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
    var message;
    switch (cmd.cmd) {
      case 'sendText':
        message = ChatMessage(
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
        );
        break;
      case 'sendAudio':
        var msg = cmd.message as Map;
        var map = {'path': msg['path'], 'timelength': msg['timelength']};
        String text = jsonEncode(map);
        message = ChatMessage(
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
        );
        break;
    }
    if (message == null) {
      return;
    }
    await messageService.addMessage(_chatRoom.creator,message);
    _p2pMessages.insert(0, message);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isloaded) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(),
        ),
      );
    }
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
                      context: widget.context,
                    );
                  }
                  return SliverToBoxAdapter(
                    child: item,
                  );
                }).toList(),
              ),
            ),
          ),
          _ChatSendPannel(
            context: widget.context,
            onTapEvents: _onTapEvents,
            onFocus: () {
              if (mounted) {
                setState(() {
                  _goEnd(300);
                });
              }
            },
            plusPanel: _PlusPannel(),
            stickerPanel: _StickerPanel(),
            textRegionController: _scrollController,
            onRoomModeChanged: (m) {
              _roomMode = m;
              setState(() {});
            },
            onCommand: (cmd) async {
              await _doCommand(cmd);
//              _resetMessages();
//              await _onRefresh();
              setState(() {
                _goEnd(100);
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

class _ChatSendPannel extends StatefulWidget {
  PageContext context;
  Widget plusPanel;
  Widget stickerPanel;
  ScrollController textRegionController;
  Function(_RoomMode roomMode) onRoomModeChanged;
  Function(_ChatCommand cmd) onCommand;
  Function() onFocus;

  List<Function()> onTapEvents;

  _ChatSendPannel({
    this.context,
    this.onTapEvents,
    this.plusPanel,
    this.onFocus,
    this.stickerPanel,
    this.textRegionController,
    this.onRoomModeChanged,
    this.onCommand,
  });

  @override
  _ChatSendPannelState createState() => _ChatSendPannelState();
}

class _ChatSendPannelState extends State<_ChatSendPannel> {
  _Action _action;
  TextEditingController _controller;
  FocusNode _contentFocusNode;
  _RoomMode _roomMode = _RoomMode.p2p;

  @override
  void initState() {
    _contentFocusNode = FocusNode();
    _controller = TextEditingController();
    _contentFocusNode.addListener(widget.onFocus);
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
  PageContext context;

  _ReceiveMessageItem({
    this.p2pMessage,
    this.context,
  });

  @override
  _ReceiveMessageItemState createState() => _ReceiveMessageItemState();
}

class _ReceiveMessageItemState extends State<_ReceiveMessageItem> {
  Friend _sender;
  bool _isloaded = false;

  @override
  void initState() {
    _load().then((v) {
      if (mounted) {
        _isloaded = true;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(_ReceiveMessageItem oldWidget) {
    if (widget.p2pMessage == oldWidget.p2pMessage) {
      oldWidget.p2pMessage = widget.p2pMessage;
      _load().then((v) {
        if (mounted) {
          _isloaded = true;
          setState(() {});
        }
      });
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    _sender = await friendService.getFriend(widget.p2pMessage.sender);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isloaded) {
      return Container(
        height: 0,
        width: 0,
      );
    }
    var avatar;
    if (_sender.avatar == null) {
      avatar = Container(
        width: 0,
        height: 0,
      );
    } else {
      if (_sender.avatar.startsWith('/')) {
        avatar = Image.file(
          File(
            _sender.avatar,
          ),
          fit: BoxFit.fill,
        );
      } else {
        avatar = FadeInImage.assetNetwork(
          placeholder: 'lib/portals/gbera/images/netflow.png',
          image:
              '${_sender.avatar}?accessToken=${widget.context.principal.accessToken}',
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(
        top: 15,
        bottom: 15,
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
              top: 5,
            ),
            child: SizedBox(
              width: 35,
              height: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
                child: avatar,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    text: widget.p2pMessage.content ?? '',
                    children: [],
                  ),
                  softWrap: true,
                  strutStyle: StrutStyle(
                    height: 1.8,
                  ),
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Text(
                        _sender.nickName ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600,
                        ),
                        strutStyle: StrutStyle(
                          height: 1.6,
                        ),
                      ),
                    ),
                    Text(
                      TimelineUtil.format(
                        widget.p2pMessage.atime,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                      strutStyle: StrutStyle(
                        height: 1.6,
                      ),
                    ),
                  ],
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
            text: widget.p2pMessage.content ?? '',
            children: [],
          ),
          softWrap: true,
          strutStyle: StrutStyle(
            height: 1.8,
          ),
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
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
        top: 15,
        bottom: 15,
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
                display,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Text(
                        _sender?.nickName ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600,
                        ),
                        strutStyle: StrutStyle(
                          height: 1.6,
                        ),
                      ),
                    ),
                    Text(
                      TimelineUtil.format(
                        widget.p2pMessage.ctime,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                      strutStyle: StrutStyle(
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: 5,
            ),
            child: SizedBox(
              width: 35,
              height: 35,
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
