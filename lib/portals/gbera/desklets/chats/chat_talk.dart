import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/emoji.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/common/zefyr_selectable.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chat_rooms.dart';
import 'package:netos_app/portals/gbera/desklets/chats/media_card.dart';
import 'package:netos_app/portals/gbera/desklets/chats/message_toolbar.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:zefyr/zefyr.dart';

import 'chatroom_handler.dart';

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
  bool _isVideoCompressing = false;

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
    Stream notify = chatroomNotifyStreamController.stream.asBroadcastStream();
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
        case 'arriveCancelMessageCommand':
          var msg =
              _p2pMessages.singleWhere((element) => element.id == message.id);
          if (msg == null) {
            return;
          }
          msg.state = 'canceled';
          if (mounted) {
            setState(() {});
          }
          break;
        default:
          print('不支持的命令:${command['action']}');
          break;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        _syncRoomMembers();
      } catch (e) {
        print('chat_talk error: $e');
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

  Future<void> _syncRoomMembers() async {
    //返回被标记移除的群或成员，如果为移除群，则只将本地成员移除，群仍留下
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    var chatroom =
        await chatRoomService.fetchRoom(_chatRoom.creator, _chatRoom.id);
    if (chatroom == null || (chatroom.flag != null && chatroom.flag == 1)) {
      //如果聊为标记已删除
      await chatRoomService.emptyChatMembersOnLocal(_chatRoom.id);
      return;
    }
    List<String> members = await chatRoomService.listFlagRoomMember(
        _chatRoom.creator, _chatRoom.id);
    await chatRoomService.removeChatMembersOnLocal(_chatRoom.id, members);
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
    await chatRoomService.updateRoomBackground(_chatRoom, path,
        isOnlyLocal: true);
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
        if ('beginVideoCompressing' == cmd.message) {
          _isVideoCompressing = true;
          return;
        }
        if ('doneVideoCompressing' == cmd.message) {
          _isVideoCompressing = false;
          return;
        }
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
        if ('beginVideoCompressing' == cmd.message) {
          _isVideoCompressing = true;
          return;
        }
        if ('doneVideoCompressing' == cmd.message) {
          _isVideoCompressing = false;
          return;
        }
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
      case 'transTo':
        var content = cmd.message;
        message = ChatMessage(
          MD5Util.MD5(Uuid().v1()),
          widget.context.principal.person,
          _chatRoom.id,
          'transTo',
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
        decoration: _renderBackground(),
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
                child: NotificationListener(
                  onNotification: (notification) {
                    if (notification is ToolbarNotification) {
                      switch (notification.command) {
                        case 'delete':
                          _p2pMessages.removeWhere(
                              (element) => element == notification.message);
                          if (mounted) {
                            setState(() {});
                          }
                          break;
                        case 'cancelMessage':
                          var msg = _p2pMessages.singleWhere(
                              (element) => element == notification.message);
                          if (msg != null) {
                            msg.state = 'canceled';
                            if (mounted) {
                              setState(() {});
                            }
                          }
                          break;
                      }
                    }
                    return false;
                  },
                  child: EasyRefresh.custom(
                    shrinkWrap: true,
                    header: easyRefreshHeader(),
                    footer: easyRefreshFooter(),
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
            ),
            !_isVideoCompressing
                ? SizedBox(
                    height: 0,
                    width: 0,
                  )
                : Container(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '正在压缩视频...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
                context: widget.context,
                room: _model,
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
          isForegroundWhite:
              _chatRoom.isForegoundWhite == 'true' ? true : false,
        );
      } else {
        item = _ReceiveMessageItem(
          p2pMessage: msg,
          context: widget.context,
          isForegroundWhite:
              _chatRoom.isForegoundWhite == 'true' ? true : false,
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

  _renderBackground() {
    if (StringUtil.isEmpty(_chatRoom.p2pBackground)) {
      return null;
    }
    if (_chatRoom.p2pBackground.startsWith('/')) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(
            File(
              _chatRoom.p2pBackground,
            ),
          ),
          fit: BoxFit.fill,
        ),
      );
    }
    return BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
          '${_chatRoom.p2pBackground}?accessToken=${widget.context.principal.accessToken}',
        ),
        fit: BoxFit.fill,
      ),
    );
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
  PageContext context;
  ChatRoomModel room;

  _PlusPannel({this.pluginTap, this.context, this.room});

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
        var image = await ImagePicker().getImage(
          source: ImageSource.gallery,
          imageQuality: 80,
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
      case 'video':
        var image = await ImagePicker().getVideo(
          source: ImageSource.gallery,
          maxDuration: Duration(seconds: 15),
        );
        if (image == null) {
          return;
        }
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: 'beginVideoCompressing',
          ),
        );
        // var info= await VideoCompress.compressVideo(
        //   image.path,
        //   quality: VideoQuality.MediumQuality,
        //   deleteOrigin: true, // It's false by default
        // );
        // var newfile=await copyVideoCompressFile(info.file);
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: 'doneVideoCompressing',
          ),
        );
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: image.path,
          ),
        );
        break;
      case 'takePhoto':
        var image = await ImagePicker().getImage(
          source: ImageSource.camera,
          imageQuality: 80,
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
      case 'recordVideo':
        var image = await ImagePicker().getVideo(
          source: ImageSource.camera,
          maxDuration: Duration(seconds: 15),
        );
        if (image == null) {
          break;
        }
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: 'beginVideoCompressing',
          ),
        );
        var info = await VideoCompress.compressVideo(
          image.path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: true, // It's false by default
        );
        var newfile = await copyVideoCompressFile(info.file);
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: 'doneVideoCompressing',
          ),
        );
        widget.pluginTap(
          _ChatCommand(
            cmd: plugin.id,
            message: newfile,
          ),
        );
        break;
      case 'transTo':
        var members = widget.room.members;
        var payee;
        for (var m in members) {
          if (m.official != widget.context.principal.person) {
            payee = m;
            break;
          }
        }
        showDialog(
            context: context,
            builder: (ctx) {
              return widget.context.part('/wallet/receipt/transTo', context,
                  arguments: {'payee': payee});
            }).then((value) {
          if (value == null || value == '') {
            return;
          }
          P2PRecordOR recordOR = value as P2PRecordOR;
          widget.pluginTap(
            _ChatCommand(
              cmd: plugin.id,
              message: jsonEncode(recordOR.toJson()),
            ),
          );
        });
        break;
      default:
        print('不支持的发布插件:${plugin.id}');
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
        maxCrossAxisExtent: 60,
      ),
      scrollDirection: Axis.vertical,
      children: items.map((item) {
        return item;
      }).toList(),
    );
  }

  List<TalkPlugin> _getPlugins() {
    var plugins = <TalkPlugin>[
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
    var room = widget.room;
    var members = room.members;
    if (members.length == 2) {
      var hasMe = false;
      for (var m in members) {
        if (m.official == widget.context.principal.person) {
          hasMe = true;
          break;
        }
      }
      if (hasMe) {
        plugins.add(
          TalkPlugin(
            id: 'transTo',
            title: '转账',
            leading: SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                FontAwesomeIcons.exchangeAlt,
                size: 25,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }
    }
    return plugins;
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
  bool isForegroundWhite;

  _ReceiveMessageItem({
    this.p2pMessage,
    this.context,
    this.isForegroundWhite,
  });

  @override
  _ReceiveMessageItemState createState() => _ReceiveMessageItemState();
}

class _ReceiveMessageItemState extends State<_ReceiveMessageItem> {
  Friend _sender;
  bool _isloaded = false;
  RoomMember _member;
  bool isShowNick = false;
  ChatRoomModel _model;
  ZefyrController _controller;

  @override
  void initState() {
    _model = widget.context.parameters['model'];
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ReceiveMessageItem oldWidget) {
    if (widget.p2pMessage.id != oldWidget.p2pMessage.id) {
      oldWidget.p2pMessage = widget.p2pMessage;
      oldWidget.isForegroundWhite = widget.isForegroundWhite;
      _model = widget.context.parameters['model'];
      _controller = null;
      _load().then((v) {
        if (mounted) {
          _isloaded = true;
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');

    ChatRoom _chatRoom = _model.chatRoom;
    _member = await chatRoomService.getMemberOfPerson(
        _chatRoom.creator, _chatRoom.id, widget.p2pMessage.sender);
    if (_member == null) {
      _sender = await friendService.getFriend(widget.p2pMessage.sender);
      isShowNick = false;
      return;
    }

    if (_member.type == 'wybank') {
      return;
    }
    isShowNick = _member.isShowNick == 'true' ? true : false;
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (_member != null && _member.type == 'wybank') {
                widget.context
                    .forward('/portlet/chat/room/view_licence', arguments: {
                  'bankid': _member.person,
                });
                return;
              }
              IPersonService personService =
                  widget.context.site.getService('/gbera/persons');
              var person = await personService.getPerson(_sender.official);
              widget.context
                  .forward('/person/view', arguments: {'person': person});
            },
            child: Padding(
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
                  child: getAvatarWidget(_renderLeading(), widget.context),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.p2pMessage.state == 'canceled'
                    ? Stack(
                        children: [
                          Container(
                            child: Text(
                              '消息已被对方撤回',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: -14,
                            child: Icon(
                              Icons.arrow_left,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        overflow: Overflow.visible,
                      )
                    : _getContentDisplay(),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Text(
                        _renderMemberName(),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isForegroundWhite
                              ? Colors.white54
                              : Colors.grey[500],
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
                        locale: 'zh',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isForegroundWhite
                            ? Colors.white54
                            : Colors.grey[500],
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
    dynamic display;
    switch (widget.p2pMessage.contentType ?? '') {
      case '':
      case 'text':
        var text = widget.p2pMessage.content ?? '';
        var json = [
          {"insert": "$text"},
          {"insert": "\n"}
        ];
        var doc = NotusDocument.fromJson(json);
        if (_controller == null) {
          _controller = ZefyrController(doc);
        }
        display = ZefyrSelectableView(
          controller: _controller,
          focusNode: FocusNode(),
          mode: ZefyrMode.view,
          buildChild: (child) {
            return EditorBuildChild(
              align: Alignment.centerLeft,
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MessageToolbar(
                      child: child,
                      context: widget.context,
                      message: widget.p2pMessage,
                      controller: _controller,
                      buildContext: context,
                      chatRoom: _model.chatRoom,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: -14,
                    child: Icon(
                      Icons.arrow_left,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
        break;
      case 'share':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        var items = <Widget>[
          renderShareCard(
            fontSize: 14,
            margin: EdgeInsets.only(
              left: 0,
              right: 0,
            ),
            background: Colors.grey[300],
            context: widget.context,
            title: map['title'],
            href: map['href'],
            leading: map['leading'],
            summary: map['summary'],
          ),
        ];
        if (!StringUtil.isEmpty(map['comment'])) {
          items.add(
            SizedBox(
              height: 10,
            ),
          );
          items.add(
            Row(
              children: [
                Expanded(
                  child: Text('${map['comment'] ?? ''}'),
                ),
              ],
            ),
          );
        }
        display = Column(
          children: items,
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
        );
        break;
      case 'audio':
        var content = jsonDecode(widget.p2pMessage.content);
        String path = content['path'];
        display = MediaCard(
          media: RoomMessageMedia(
            src: path,
            type: 'audio',
            args: content['timelength'],
          ),
          room: _model.chatRoom.id,
          beginTime: widget.p2pMessage.ctime,
          pageContext: widget.context,
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
        );
        break;
      case 'image':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        String file = map['path'];
        display = Container(
          padding: EdgeInsets.only(
            top: 5,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          // child: file.startsWith('/')
          //     ? Image.file(
          //         File(file),
          //         fit: BoxFit.fitWidth,
          //       )
          //     : Image.network(
          //         '$file?accessToken=${widget.context.principal.accessToken}',
          //         fit: BoxFit.fitWidth,
          //       ),
          child: MediaCard(
            media: RoomMessageMedia(
              src: file,
              type: 'image',
            ),
            room: _model.chatRoom.id,
            beginTime: widget.p2pMessage.ctime,
            pageContext: widget.context,
          ),
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
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
          // child: VideoView(
          //   src: File(file),
          // ),
          child: MediaCard(
            media: RoomMessageMedia(
              src: file,
              type: 'video',
            ),
            room: _model.chatRoom.id,
            beginTime: widget.p2pMessage.ctime,
            pageContext: widget.context,
          ),
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
        );
        break;
      case 'transTo':
        var json = widget.p2pMessage.content;
        var obj = jsonDecode(json);
        var record = P2PRecordOR.parse(obj);
        //
        display = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context
                .forward('/wallet/p2p/details', arguments: {'p2p': record});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: 5,
            ),
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFD81919),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '收到转账！',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      '¥${(record.amount / 100.00).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case '/pay/absorbs':
        var colors = [
          Color(0xFFccffff),
          Color(0xFFCDCDB4),
          Color(0xFFF5F5DC),
          Color(0xFFCAE1FF),
        ];
        var json = widget.p2pMessage.content;
        var obj = jsonDecode(json);
        double amount = obj['amount'] / 100.00;
        var title = obj['title'];
        var encourageCause = obj['encourageCause'];
        display = Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: colors[(title.hashCode.abs() % colors.length)],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '给你',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                '¥${amount.toStringAsFixed(14)}',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      '发放自猫',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    '${title ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      '奖励原因',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    '${encourageCause ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        break;
      case '/pay/trials':
        var json = widget.p2pMessage.content;
        var obj = jsonDecode(json);
        var record = DepositTrialOR.parse(obj);
        double amount = record.amount / 100.00;
        display = Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '体验金到账！',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 25,
                  right: 15,
                ),
                child: Text(
                  '¥$amount元',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '发放原因:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '- 您的码片被"${record.qrsliceCname}"初次消费，故而得到奖励\r\n',
                      ),
                      TextSpan(
                        text: '- 体验金可在钱包->体验金账户中查看\r\n',
                      ),
                      TextSpan(
                        text: '- 如想得到更多体验金，请多',
                      ),
                      TextSpan(
                        text: '发码',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.context
                                .forward('/robot/createSlices')
                                .then((value) {});
                          },
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      default:
        print('不支持的消息类型:${widget.p2pMessage.contentType}');
        display = Container(
          width: 0,
          height: 0,
        );
        break;
    }
    return display;
  }

  String _renderMemberName() {
    if (_member?.type == 'wybank') {
      return _member?.nickName;
    }
    return isShowNick
        ? _member?.nickName ?? (_sender?.nickName ?? '')
        : _sender?.nickName ?? '';
  }

  String _renderLeading() {
    if (_member?.type == 'wybank') {
      return _member?.leading;
    }
    return _sender?.avatar;
  }
}

class _SendMessageItem extends StatefulWidget {
  ChatMessage p2pMessage;
  PageContext context;
  bool isForegroundWhite;

  _SendMessageItem({
    this.p2pMessage,
    this.context,
    this.isForegroundWhite,
  });

  @override
  __SendMessageItemState createState() => __SendMessageItemState();
}

class __SendMessageItemState extends State<_SendMessageItem> {
  UserPrincipal _sender;
  RoomMember _member;
  bool isShowNick = false;
  ChatRoomModel _model;
  ZefyrController _controller;

  @override
  void initState() {
    _model = widget.context.parameters['model'];
    _loadSender().then((p) {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  Future<void> _loadSender() async {
    _sender = widget.context.principal;
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    ChatRoom _chatRoom = _model.chatRoom;
    _member = await chatRoomService.getMember(_chatRoom.creator, _chatRoom.id);
    if (_member == null) {
      return;
    }
    isShowNick = _member.isShowNick == 'true' ? true : false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SendMessageItem oldWidget) {
    if (oldWidget.p2pMessage.id == widget.p2pMessage.id) {
      super.didUpdateWidget(oldWidget);
      return;
    }
    oldWidget.p2pMessage = widget.p2pMessage;
    oldWidget.isForegroundWhite = widget.isForegroundWhite;
    _model = widget.context.parameters['model'];
    _controller = null;
    _loadSender().then((p) {
      if (mounted) setState(() {});
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
                widget.p2pMessage.state == 'canceled'
                    ? Stack(
                        overflow: Overflow.visible,
                        children: [
                          _getContentDisplay(),
                          Positioned(
                            right: -9,
                            top: -9,
                            child: Icon(
                              Icons.redo,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    : _getContentDisplay(),
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
                          color: widget.isForegroundWhite == true
                              ? Colors.white54
                              : Colors.grey[500],
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
                        locale: 'zh',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isForegroundWhite == true
                            ? Colors.white54
                            : Colors.grey[500],
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              widget.context
                  .forward('/person/view', arguments: {'person': _sender});
            },
            child: Padding(
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
                  child:
                      getAvatarWidget(_sender?.avatarOnLocal, widget.context),
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
        var text = widget.p2pMessage.content ?? '';
        var json = [
          {"insert": "$text"},
          {"insert": "\n"}
        ];
        var doc = NotusDocument.fromJson(json);
        if (_controller == null) {
          _controller = ZefyrController(doc);
        }
        display = ZefyrSelectableView(
          controller: _controller,
          focusNode: FocusNode(),
          mode: ZefyrMode.view,
          buildChild: (child) {
            return EditorBuildChild(
              align: Alignment.centerRight,
              child: Stack(
                overflow: Overflow.visible,
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MessageToolbar(
                      child: child,
                      context: widget.context,
                      message: widget.p2pMessage,
                      controller: _controller,
                      buildContext: context,
                      chatRoom: _model.chatRoom,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: -14,
                    child: Icon(
                      Icons.arrow_right,
                      size: 25,
                      color: Colors.lightGreen[300],
                    ),
                  ),
                ],
              ),
            );
          },
        );
        break;
      case 'share':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        var items = <Widget>[
          renderShareCard(
            fontSize: 14,
            margin: EdgeInsets.only(
              left: 0,
              right: 0,
            ),
            background: Colors.grey[300],
            context: widget.context,
            title: map['title'],
            href: map['href'],
            leading: map['leading'],
            summary: map['summary'],
          ),
        ];
        if (!StringUtil.isEmpty(map['comment'])) {
          items.add(
            SizedBox(
              height: 10,
            ),
          );
          items.add(
            Row(
              children: [
                Expanded(
                  child: Text('${map['comment'] ?? ''}'),
                ),
              ],
            ),
          );
        }
        display = Column(
          children: items,
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
        );
        break;
      case 'audio':
        var json = widget.p2pMessage.content;
        Map<String, dynamic> map = jsonDecode(json);
        display = MediaCard(
          media: RoomMessageMedia(
            src: map['path'],
            type: 'audio',
            args: map['timelength'],
          ),
          room: _model.chatRoom.id,
          beginTime: widget.p2pMessage.ctime,
          pageContext: widget.context,
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
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
          // child: Image.file(
          //   File(file),
          //   fit: BoxFit.fitWidth,
          // ),
          child: MediaCard(
            media: RoomMessageMedia(
              src: file,
              type: 'image',
            ),
            room: _model.chatRoom.id,
            beginTime: widget.p2pMessage.ctime,
            pageContext: widget.context,
          ),
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
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
          // child: VideoView(
          //   src: File(file),
          // ),
          child: MediaCard(
            media: RoomMessageMedia(
              src: file,
              type: 'video',
            ),
            room: _model.chatRoom.id,
            beginTime: widget.p2pMessage.ctime,
            pageContext: widget.context,
          ),
        );
        display = MessageToolbar(
          child: display,
          context: widget.context,
          message: widget.p2pMessage,
          buildContext: context,
          chatRoom: _model.chatRoom,
        );
        break;
      case 'transTo':
        var json = widget.p2pMessage.content;
        var obj = jsonDecode(json);
        var record = P2PRecordOR.parse(obj);
        display = Container(
          padding: EdgeInsets.only(
            top: 5,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context
                  .forward('/wallet/p2p/details', arguments: {'p2p': record});
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFD81919),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '转出成功！',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      '¥${(record.amount / 100.00).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case '/pay/absorbs':
        var json = widget.p2pMessage.content;
        var obj = jsonDecode(json);
        double amount = obj['amount'] / 100.00;
        var title = obj['title'];
        var encourageCause = obj['encourageCause'];
        display = Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '给你',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                '¥${amount.toStringAsFixed(14)}',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      '发放自',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    '${title ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      '奖励原因',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    '${encourageCause ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
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
