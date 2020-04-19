import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/emoji.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chat_rooms.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatTalk extends StatefulWidget {
  PageContext context;

  ChatTalk({this.context});

  @override
  _ChatTalkState createState() => _ChatTalkState();
}

class _ChatTalkState extends State<ChatTalk> {
  List<Function()> _onTapEvents = [];

  TextEditingController _sendTextEditingController;
  ChatRoom _chatRoom;
  ChatRoomModel _model;

  EasyRefreshController _controller;
  ScrollController _scrollController;
  _RoomMode _roomMode;
  List<ChatMessage> _p2pMessages;
  int _limit = 12, _offset = 0;
  StreamSubscription _streamSubscription;
  bool _isloaded = false;

  @override
  void initState() {
    _sendTextEditingController = TextEditingController();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _p2pMessages = [];

    _model = widget.context.parameters['model'];
    _chatRoom = _model.chatRoom;
    if (!StringUtil.isEmpty(_chatRoom.p2pBackground) &&
        _chatRoom.p2pBackground.startsWith('http')) {
      _updateRoomBackground().then((v) {
        setState(() {});
      });
    }
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
      if (message == null ||
          message.sender == widget.context.principal.person ||
          message.room != _chatRoom.id) {
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
    _sendTextEditingController?.dispose();
    _streamSubscription?.cancel();
    _p2pMessages?.clear();
    _chatRoom = null;
    _controller?.dispose();
    _scrollController?.dispose();
    _isloaded = false;
    super.dispose();
  }

  void _goEnd([int milliseconds = 10]) {
    Future.delayed(
        Duration(
          milliseconds: milliseconds,
        ), () {
      if (mounted) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _updateRoomBackground() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IChatRoomRemote chatRoomRemote =
        widget.context.site.getService('/remote/chat/rooms');
    var path = await chatRoomRemote.downloadBackground(_chatRoom.p2pBackground);
    await chatRoomService.updateRoomBackground(_chatRoom, path);
    _chatRoom.p2pBackground = path;
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
    if (mounted) {
      setState(() {
        _goEnd(300);
      });
    }
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
        String content = jsonEncode(map);
        message = ChatMessage(
          MD5Util.MD5(Uuid().v1()),
          widget.context.principal.person,
          _chatRoom.id,
          'audio',
          content,
          'sended',
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          null,
          widget.context.principal.person,
        );
        break;
      case 'image':
        var image = cmd.message;
        var map = {'path': image};
        var content = jsonEncode(map);
        message = ChatMessage(
          MD5Util.MD5(Uuid().v1()),
          widget.context.principal.person,
          _chatRoom.id,
          'image',
          content,
          'sended',
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          null,
          widget.context.principal.person,
        );
        break;
      case 'video':
        var image = cmd.message;
        var map = {'path': image};
        var content = jsonEncode(map);
        message = ChatMessage(
          MD5Util.MD5(Uuid().v1()),
          widget.context.principal.person,
          _chatRoom.id,
          'video',
          content,
          'sended',
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          null,
          widget.context.principal.person,
        );
        break;
      case 'takePhoto':
        var image = cmd.message;
        var map = {'path': image};
        var content = jsonEncode(map);
        message = ChatMessage(
          MD5Util.MD5(Uuid().v1()),
          widget.context.principal.person,
          _chatRoom.id,
          'image',
          content,
          'sended',
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          null,
          widget.context.principal.person,
        );
        break;
      case 'recordVideo':
        var image = cmd.message;
        var map = {'path': image};
        var content = jsonEncode(map);
        message = ChatMessage(
          MD5Util.MD5(Uuid().v1()),
          widget.context.principal.person,
          _chatRoom.id,
          'video',
          content,
          'sended',
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          null,
          widget.context.principal.person,
        );
        break;
      default:
        print('不支持的发布命令：${cmd.cmd}');
        return;
    }
    if (message == null) {
      return;
    }
    await messageService.addMessage(_chatRoom.creator, message);
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
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: StringUtil.isEmpty(_chatRoom.p2pBackground)
            ? null
            : BoxDecoration(
                image: DecorationImage(
                  image: FileImage(
                    File(
                      _chatRoom.p2pBackground,
                    ),
                  ),
                  fit: BoxFit.fill,
                ),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MediaQuery.removePadding(
              removeBottom: true,
              removeLeft: true,
              removeRight: true,
              context: context,
              child: AppBar(
                title: Text.rich(
                  TextSpan(
                    text:
                        '${_model.displayRoomTitle(widget.context.principal)}',
                    children: [],
                  ),
                ),
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                toolbarOpacity: 1,
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      widget.context.forward('/portlet/chat/room/settings',
                          arguments: {'model': _model}).then((v) {
                        if (v == 'empty') {
                          _p2pMessages.clear();
                          _offset = 0;
                          setState(() {});
                        } else if (v == 'remove') {
                          widget.context.backward(result: v);
                        } else {
                          setState(() {});
                        }
                      });
                    },
                    icon: Icon(
                      Icons.more_vert,
                    ),
                  ),
                ],
              ),
            ),
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
                  onRefresh: _offset < _limit
                      ? null
                      : () async {
                          _onRefresh().then((v) {
                            setState(() {});
                          });
                        },
                  slivers: _getSlivers(),
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
              plusPanel: _PlusPannel(
                pluginTap: (cmd) {
                  _doCommand(cmd).then((v) {
                    if (mounted) {
                      setState(() {
                        _goEnd(100);
                      });
                    }
                  });
                },
              ),
              emojiPanel: _EmojiPanel(
                onselected: (text, emoji) {
                  _sendTextEditingController.text += text;
                },
              ),
              textRegionController: _scrollController,
              controller: _sendTextEditingController,
              onRoomModeChanged: (m) {
                _roomMode = m;
                setState(() {});
              },
              onCommand: (cmd) async {
                await _doCommand(cmd);
//              _resetMessages();
//              await _onRefresh();
                if (mounted) {
                  setState(() {
                    _goEnd(100);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getSlivers() {
    List<Widget> widgets = [];
    var reversed = _p2pMessages.reversed;
    for (var msg in reversed) {
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
      widgets.add(
        SliverToBoxAdapter(
          child: item,
        ),
      );
    }
    return widgets;
  }
}

class _EmojiPanel extends StatefulWidget {
  Function(String emojiText, dynamic emoji) onselected;

  _EmojiPanel({this.onselected});

  @override
  _EmojiPanelState createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<_EmojiPanel> {
  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    for (var emoji in emojiList) {
      var emojiText = String.fromCharCode(emoji['unicode']);
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (mounted && widget.onselected != null) {
              widget.onselected(emojiText, emoji);
            }
          },
          child: Container(
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
                Text(
                  emojiText,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
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
  Function(_ChatCommand command) pluginTap;

  _PlusPannel({this.pluginTap});

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
  void didUpdateWidget(_PlusPannel oldWidget) {
    if (oldWidget.pluginTap != widget.pluginTap) {
      oldWidget.pluginTap = widget.pluginTap;
    }
    super.didUpdateWidget(oldWidget);
  }

  _tapPlugin(TalkPlugin plugin) async {
    switch (plugin.id) {
      case 'image':
        var image = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (image == null) {
          break;
        }
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: image.path,
          ),
        );
        break;
      case 'video':
        var image = await ImagePicker.pickVideo(source: ImageSource.gallery);
        if (image == null) {
          break;
        }
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: image.path,
          ),
        );
        break;
      case 'takePhoto':
        var image = await ImagePicker.pickImage(source: ImageSource.camera);
        if (image == null) {
          break;
        }
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: image.path,
          ),
        );
        break;
      case 'recordVideo':
        var image = await ImagePicker.pickVideo(
          source: ImageSource.camera,
        );
        if (image == null) {
          break;
        }
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: image.path,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    var plugins = _getPlugins();
    for (var plugin in plugins) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _tapPlugin(plugin);
          },
          child: Container(
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
                plugin.leading,
                Text(
                  plugin.title,
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

  List<TalkPlugin> _getPlugins() {
    return [
      TalkPlugin(
        id: 'image',
        title: '图片',
        leading: Icon(
          Icons.image,
          size: 30,
          color: Colors.grey[600],
        ),
      ),
      TalkPlugin(
        id: 'video',
        title: '视频',
        leading: Icon(
          Icons.movie,
          size: 30,
          color: Colors.grey[600],
        ),
      ),
      TalkPlugin(
        id: 'takePhoto',
        title: '拍照',
        leading: Icon(
          Icons.camera_enhance,
          size: 30,
          color: Colors.grey[600],
        ),
      ),
      TalkPlugin(
        id: 'recordVideo',
        title: '录像',
        leading: Icon(
          Icons.videocam,
          size: 30,
          color: Colors.grey[600],
        ),
      ),
    ];
  }
}

class TalkPlugin {
  String id;
  String title;
  Widget leading;

  TalkPlugin({this.id, this.title, this.leading});
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
  Widget emojiPanel;
  ScrollController textRegionController;
  Function(_RoomMode roomMode) onRoomModeChanged;
  Function(_ChatCommand cmd) onCommand;
  Function() onFocus;
  TextEditingController controller;

  List<Function()> onTapEvents;

  _ChatSendPannel({
    this.context,
    this.onTapEvents,
    this.plusPanel,
    this.onFocus,
    this.emojiPanel,
    this.textRegionController,
    this.onRoomModeChanged,
    this.onCommand,
    this.controller,
  });

  @override
  _ChatSendPannelState createState() => _ChatSendPannelState();
}

class _ChatSendPannelState extends State<_ChatSendPannel> {
  _Action _action;
  FocusNode _contentFocusNode;
  _RoomMode _roomMode = _RoomMode.p2p;
  bool _isShowSendButton = false;
  TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller;
    _controller.addListener(_textListener);
    _contentFocusNode = FocusNode();
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
    _controller.removeListener(_textListener);
    _controller = null;
    _roomMode = _RoomMode.p2p;
    _contentFocusNode.dispose();
    widget.onTapEvents.clear();
    super.dispose();
  }

  _textListener() {
    var old = _isShowSendButton;
    var text = _controller.text ?? '';
    text = text.trim();
    _isShowSendButton = !StringUtil.isEmpty(text);
    if (mounted && old != _isShowSendButton) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var panel = null;
    switch (_action) {
      case _Action.plus:
        panel = widget.plusPanel;
        break;
      case _Action.sticker:
        panel = widget.emojiPanel;
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
                      maxLines: 6,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
//                      onSubmitted: (v) {
//                      },
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
                        child: _isShowSendButton
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
//                                  _action = null;
                                  var text = _controller.text ?? '';
                                  text = text.trim();
                                  if (StringUtil.isEmpty(text)) {
                                    return;
                                  }
                                  _controller.clear();
                                  if (widget.onCommand != null) {
                                    widget.onCommand(
                                      _ChatCommand(
                                        cmd: 'sendText',
                                        message: text,
                                      ),
                                    );
//                                    _contentFocusNode.requestFocus();
//                                    _contentFocusNode.unfocus();
                                  }
                                },
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : VoiceFloatingButton(
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
  RoomMember _member;
  bool isShowNick = false;

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

    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    ChatRoomModel _model = widget.context.parameters['model'];
    ChatRoom _chatRoom = _model.chatRoom;
    _member = await chatRoomService.getMemberOfPerson(
        _chatRoom.creator, _chatRoom.id, _sender.official);
    isShowNick = _member.isShowNick == 'true' ? true : false;
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
                _getContentDisplay(),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Text(
                        isShowNick
                            ? _member.nickName ?? _sender.nickName ?? ''
                            : _sender.nickName ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
                        color: Colors.grey[500],
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

  Widget _getContentDisplay() {
    switch (widget.p2pMessage.contentType ?? '') {
      case '':
      case 'text':
        return Text.rich(
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
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        );
      case 'audio':
        var content = jsonDecode(widget.p2pMessage.content);
        String path = content['path'];
        return MyAudioWidget(
          audioFile: path,
          timeLength: content['timelength'],
        );
      case 'image':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        var file = map['path'];
        return Container(
          padding: EdgeInsets.only(
            top: 5,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: Image.file(
            File(file),
            fit: BoxFit.fitWidth,
          ),
        );
      case 'video':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        var file = map['path'];
        return Container(
          padding: EdgeInsets.only(
            top: 5,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: VideoView(
            src: File(file),
          ),
        );
      default:
        print('不支持的消息类型:${widget.p2pMessage.contentType}');
        return Container(
          width: 0,
          height: 0,
        );
    }
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
  RoomMember _member;
  bool isShowNick = false;

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
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');

    ChatRoomModel _model = widget.context.parameters['model'];
    ChatRoom _chatRoom = _model.chatRoom;
    _member = await chatRoomService.getMember(_chatRoom.creator, _chatRoom.id);
    isShowNick = _member.isShowNick == 'true' ? true : false;
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
                _getContentDisplay(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Text(
                        isShowNick
                            ? _member.nickName ?? _sender?.nickName ?? ''
                            : _sender?.nickName ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
                        color: Colors.grey[500],
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

  Widget _getContentDisplay() {
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
            color: Colors.black87,
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
      case 'image':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        var file = map['path'];
        display = Container(
          padding: EdgeInsets.only(
            top: 5,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: Image.file(
            File(file),
            fit: BoxFit.fitWidth,
          ),
        );
        break;
      case 'video':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        var file = map['path'];
        display = Container(
          padding: EdgeInsets.only(
            top: 5,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: VideoView(
            src: File(file),
          ),
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
    return display;
  }
}
