import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:nineold/nine_old_frame.dart';
import 'package:uuid/uuid.dart';

import 'friend_page.dart';

class ChatRoomsPortlet extends StatefulWidget {
  Portlet portlet;
  Desklet desklet;
  PageContext context;

  ChatRoomsPortlet({this.portlet, this.desklet, this.context});

  @override
  _ChatRoomsPortletState createState() => _ChatRoomsPortletState();
}

class _ChatRoomsPortletState extends State<ChatRoomsPortlet> {
  bool _isloaded = false;
  StreamController<dynamic> _notifyStreamController;
  List<_ChatRoomModel> _models = [];

  @override
  void initState() {
    _notifyStreamController = StreamController.broadcast();
    if (!widget.context.isListening(matchPath: '/chat/room/message')) {
      widget.context.listenNetwork(_onmessage, matchPath: '/chat/room/message');
    }
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
    _notifyStreamController.close();
    _models.clear();
    widget.context.unlistenNetwork(matchPath: '/chat/room/message');
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatRoomsPortlet oldWidget) {
    var changed = oldWidget.portlet != widget.portlet ||
        oldWidget.desklet != widget.desklet ||
        oldWidget.runtimeType != widget.runtimeType;
    if (changed) {
      _models.clear();
      _load().then((v) {
        if (mounted) {
          _isloaded = true;
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onmessage(Frame frame) async {
    if (!frame.url.startsWith('/chat/room/message')) {
      return;
    }
    switch (frame.command) {
      case 'pushMessage':
        _arrivePushMessageCommand(frame).then((message) {
          if (mounted) {
            setState(() {});
          }
        });
        break;
    }
  }

  Future<void> _arrivePushMessageCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    if (frame.head("sender") == widget.context.principal.person) {
      print('自已的消息又发给自己，被丢弃。');
      return null;
    }
    var room = frame.parameter('room');
    var contentType = frame.parameter('contentType');
    var msgid = frame.parameter('msgid');
    var ctime = frame.parameter('ctime');
    var sender = frame.head('sender');
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    if (!await friendService.exists(sender)) {
      var person = await friendService.getFriend(sender);
      await friendService.addFriend(person);
    }

    var chatRoom = await chatRoomService.get(room, isOnlyLocal: true);
    if (chatRoom == null) {
      //添加聊天室
      chatRoom = await chatRoomService.fetchAndSaveRoom(
        sender,
        room,
      );
      await chatRoomService.loadAndSaveRoomMembers(room, sender);
      _models.clear();
      await _loadChatroom();
    }
    var message = ChatMessage(
      msgid,
      sender,
      room,
      contentType,
      text,
      'arrived',
      StringUtil.isEmpty(ctime) ? null : int.parse(ctime),
      DateTime.now().millisecondsSinceEpoch,
      null,
      null,
      widget.context.principal.person,
    );
    await messageService.addMessage(message);

    _notifyStreamController
        .add({'action': 'arrivePushMessageCommand', 'message': message});
  }

  Future<void> _load() async {
    await _loadChatroom();
  }

  Future<void> _loadChatroom() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    List<ChatRoom> rooms = await chatRoomService.listChatRoom();
    for (var room in rooms) {
      List<Friend> friends = await chatRoomService.listdMember(room.id);
      _models.add(
        _ChatRoomModel(
          chatRoom: room,
          members: friends,
        ),
      );
    }
  }

  Future<void> _createChatroom(List<String> members) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    var roomCode = MD5Util.MD5(Uuid().v1());
    await chatRoomService.addRoom(
      ChatRoom(
        roomCode,
        null,
        null,
        widget.context.principal.person,
        DateTime.now().millisecondsSinceEpoch,
        null,
        null,
        'false',
        null,
        widget.context.principal.person,
      ),
    );
    for (var i = 0; i < members.length; i++) {
      var official = members[i];
      await chatRoomService.addMember(
        RoomMember(
          MD5Util.MD5(Uuid().v1()),
          roomCode,
          official,
          widget.context.principal.person,
          widget.context.principal.person,
        ),
      );
    }
    return;
  }

  Future<void> _removeChatRoom(ChatRoom room) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.removeChatRoom(room.id);
    return;
  }

  Future<void> _updateRoomLeading(String roomid, String file) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.updateRoomLeading(roomid, file);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isloaded) {
      return Center(
        child: Text('加载中...'),
      );
    }
    var content;

    if (_models.isEmpty) {
      content = Padding(
        padding: EdgeInsets.only(
          bottom: 20,
          top: 20,
        ),
        child: Center(
          child: Text.rich(
            TextSpan(
              text: '没有聊天室！ ',
              style: TextStyle(
                color: Colors.grey[400],
              ),
              children: [
                TextSpan(
                  text: '点击此处建立',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      var result = await widget.context
                          .forward('/portlet/chat/friends') as List<String>;
                      if (result == null || result.isEmpty) {
                        return;
                      }
                      _createChatroom(result).then((v) {
                        setState(() {});
                      });
                    },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      var index = 0;
      content = ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
        ),
        children: _models.map((_ChatRoomModel model) {
          index++;
          return _ChatroomItem(
            context: widget.context,
            model: model,
            isBottom: index == _models.length,
            notify: _notifyStreamController.stream,
            onDelete: () {
              _removeChatRoom(model.chatRoom).then((v) {
                _models.removeWhere((m) {
                  return m.chatRoom.id == model.chatRoom.id;
                });
                if (mounted) {
                  setState(() {});
                }
              });
            },
          );
        }).toList(),
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 10,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text('平聊'),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  var result = await widget.context
                      .forward('/portlet/chat/friends') as List<String>;
                  if (result == null || result.isEmpty) {
                    return;
                  }
                  _createChatroom(result).then((v) {
                    setState(() {});
                  });
                },
                child: Icon(
                  Icons.add_circle_outline,
                  size: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          content,
        ],
      ),
    );
  }
}

class _ChatroomItem extends StatefulWidget {
  PageContext context;
  _ChatRoomModel model;
  Stream notify;
  Function() onDelete;
  bool isBottom;

  _ChatroomItem(
      {this.context, this.model, this.notify, this.onDelete, this.isBottom});

  @override
  __ChatroomItemState createState() => __ChatroomItemState();
}

class __ChatroomItemState extends State<_ChatroomItem> {
  double _percentage = 0.0;
  _ChatroomItemStateBar _stateBar;
  StreamSubscription<dynamic> _streamSubscription;

  @override
  void initState() {
    _stateBar = _ChatroomItemStateBar();
    widget.notify.listen((command) {
      print(command);
      if (mounted) {
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
  void didUpdateWidget(_ChatroomItem oldWidget) {
    if (oldWidget.model != widget.model) {
      oldWidget.model = widget.model;
      oldWidget.isBottom = widget.isBottom;
      oldWidget.onDelete = widget.onDelete;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var imgSrc = widget.model.leading(widget.context.principal.accessToken);

    var item = Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: 15,
              left: 10,
              right: 10,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: _stateBar.isShow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      //如果不是自己的管道则不能改图标
                      if (widget.context.principal.person !=
                          widget.model.chatRoom.creator) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('不可修改图标！原因：不是您创建的感知器'),
                          ),
                        );
                        return;
                      }
                      widget.context
                          .forward(
                        '/widgets/avatar',
                      )
                          .then((path) {
                        if (StringUtil.isEmpty(path)) {
                          return;
                        }
//                        widget.model.leading = path;
//                        setState(() {});
//                        _updateLeading();
                      });
                    },
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: imgSrc,
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -3,
                          child: !_stateBar.isShow
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Badge(
                                  position: BadgePosition.topRight(
                                    right: -3,
                                    top: 3,
                                  ),
                                  elevation: 0,
                                  showBadge: (_stateBar.count ?? 0) != 0,
                                  badgeContent: Text(
                                    '',
                                  ),
                                  child: null,
                                ),
                        ),
                        _percentage > 0 && _percentage < 1.0
                            ? Positioned(
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  value: _percentage,
                                ),
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: widget.model.displayRoomTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      !_stateBar.isShow
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.start,
                                spacing: 5,
                                runSpacing: 3,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      text: '[${_stateBar.brackets}]',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ',
                                        ),
                                        TextSpan(
                                          text: _stateBar.tips,
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _stateBar?.atime != null
                                        ? '${TimelineUtil.format(
                                            _stateBar?.atime,
                                            locale: 'zh',
                                            dayFormat: DayFormat.Simple,
                                          )}'
                                        : '',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          widget.isBottom
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Divider(
                  height: 1,
                  indent: 60,
                ),
        ],
      ),
    );
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '删除',
          foregroundColor: Colors.grey[500],
          icon: Icons.delete,
          onTap: () {
            if (widget.onDelete != null) {
              widget.onDelete();
            }
          },
        ),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          //打开聊天室
        },
        child: item,
      ),
    );
  }
}

class _ChatroomItemStateBar {
  String brackets; //括号
  String tips; //提示栏
  int atime; //时间
  int count = 0; //消息数提示，0表示无提示
  bool isShow = false; //是否显示提供
  _ChatroomItemStateBar(
      {this.brackets, this.tips, this.atime, this.count, this.isShow = false});

  Future<void> update(String command, dynamic args) async {}
}

class _ChatRoomModel {
  ChatRoom chatRoom;
  List<Friend> members;
  ChatMessage unreadMessage;
  int unreadMsgCount = 0;

  _ChatRoomModel(
      {this.chatRoom, this.members, this.unreadMessage, this.unreadMsgCount});

  ///创建者添加的成员,当聊天室无标题和头像时根据创建者添加的成员生成它
  String get displayRoomTitle {
    if (!StringUtil.isEmpty(chatRoom.title)) {
      return chatRoom.title;
    }
    if (members == null || members.isEmpty) {
      return "";
    }
    String name = '';
    for (int i = 0; i < members.length; i++) {
      var f = members[i];
      name += '${f.nickName ?? f.accountName},';
      if (i >= 6) {
        break;
      }
    }
    if (name.endsWith(',')) {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }

  Widget leading(String accessToken) {
    if (!StringUtil.isEmpty(this.chatRoom.leading)) {
      if (this.chatRoom.leading.startsWith('/')) {
        return Image.file(
          File(this.chatRoom.leading),
          width: 40,
          height: 40,
        );
      }
      return Image.network(
        this.chatRoom.leading,
        height: 40,
        width: 40,
      );
    }
    //九宫格
    var list = <String>[];
    for (var i = 0; i < members.length; i++) {
      if (i >= 9) {
        break;
      }
      var m = members[i];
      if (m.avatar.startsWith('/')) {
        list.add(m.avatar);
      } else {
        list.add('${m.avatar}?accessToken=$accessToken');
      }
    }
    return NineOldWidget(list);
  }
}
