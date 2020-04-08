import 'dart:io';

import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
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
  @override
  void initState() {
    if (!widget.context.isListening(matchPath: '/chat/room/message')) {
      widget.context.listenNetwork(_onmessage, matchPath: '/chat/room/message');
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.context.unlistenNetwork(matchPath: '/chat/room/message');
    super.dispose();
  }

  Future<void> _onmessage(Frame frame) {
    print(frame);
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

  Future<List<_ChatRoomModel>> _loadChatroom() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    List<ChatRoom> rooms = await chatRoomService.listChatRoom();
    List<_ChatRoomModel> models = [];
    for (var room in rooms) {
      List<Friend> friends =
          await chatRoomService.listWhoAddMember(room.id, room.creator);
      models.add(
        _ChatRoomModel(
          chatRoom: room,
          members: friends,
        ),
      );
    }
    return models;
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
    return FutureBuilder<List<_ChatRoomModel>>(
      future: _loadChatroom(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error}',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }
        List<_ChatRoomModel> topFives;
        List<_ChatRoomModel> expandRooms;
        if (snapshot.data.length > 5) {
          topFives = snapshot.data.sublist(0, 5);
          expandRooms = snapshot.data.sublist(5, snapshot.data.length);
        } else {
          topFives = snapshot.data;
          expandRooms = [];
        }
        return ConstrainedBox(
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: Card(
            margin: EdgeInsets.only(
              bottom: 10,
              left: 0,
              right: 0,
              top: 0,
            ),
            elevation: 0,
            child: ListView(
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 10,
                    right: 15,
                    bottom: 10,
                  ),
                  child: Row(
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
                ),
                topFives.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: 20,
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
                                              .forward('/portlet/chat/friends')
                                          as List<String>;
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
                      )
                    : ListView(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: topFives.map((model) {
                          return _ChatRoomItem(
                            isBottomItem: false,
                            context: widget.context,
                            title: model.displayRoomTitle,
                            leading: model.leading,
                            time: model.unreadMessage == null
                                ? ''
                                : TimelineUtil.format(
                                    model.unreadMessage.atime,
                                    dayFormat: DayFormat.Simple,
                                  ),
                            unreadMsgCount: model.unreadMsgCount ?? 0,
                            showNewest: model.unreadMsgCount ?? 0 > 0,
                            subtitle: '${model.unreadMessage?.content ?? ''}',
                            who: '',
                            onOpenRoom: () {
                              widget.context
                                  .forward('/portlet/chat/talk', arguments: {
                                'chatRoom': model.chatRoom,
                                'displayRoomTitle': model.displayRoomTitle,
                              });
                            },
                            onOpenAvatar: () {
                              widget.context
                                  .forward(
                                '/portlet/chat/room/avatar',
                              )
                                  .then((v) {
                                if (v == null) {
                                  return;
                                }
                                var result = v as Map<String, Object>;
                                if (StringUtil.isEmpty(result['image'])) {
                                  return;
                                }
                                String fileName = result['image'];
                                _updateRoomLeading(model.chatRoom.id, fileName)
                                    .then((v) {
                                  setState(() {});
                                });
                              });
                            },
                            onRemoveAction: () {
                              _removeChatRoom(model.chatRoom).then((v) {
                                snapshot.data.remove(model);
                                setState(() {});
                              });
                            },
                          );
                        }).toList(),
                      ),
                if (!expandRooms.isEmpty)
                  _MessagesExpansionPanel(
                    updateRoomLeading: _updateRoomLeading,
                    context: widget.context,
                    expandRooms: expandRooms,
                    onRemoveChatRoom: (ChatRoom room) {
                      _removeChatRoom(room).then((v) {
                        snapshot.data.remove(room);
                        setState(() {});
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessagesExpansionPanel extends StatefulWidget {
  PageContext context;
  List<_ChatRoomModel> expandRooms;
  Function(ChatRoom) onRemoveChatRoom;
  Function(String, String) updateRoomLeading;

  _MessagesExpansionPanel({
    this.context,
    this.expandRooms,
    this.onRemoveChatRoom,
    this.updateRoomLeading,
  });

  @override
  __MessagesExpansionPanelState createState() =>
      __MessagesExpansionPanelState();
}

class __MessagesExpansionPanelState extends State<_MessagesExpansionPanel> {
  bool _isExpaned = false;

  @override
  Widget build(BuildContext context) {
    List<_ChatRoomModel> topTwo = [];
    for (var i = 0; i < widget.expandRooms.length; i++) {
      var model = widget.expandRooms[i];
      if (StringUtil.isEmpty(model.unreadMessage?.content)) {
        continue;
      }
      if (topTwo.length > 2) {
        break;
      }
      topTwo.add(model);
    }
    int _expandRoomsIndex = 0;
    return ListView(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _isExpaned
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _isExpaned = false;
                  setState(() {});
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    right: 10,
                    top: 10,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.grey[500],
                  ),
                ),
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _isExpaned = true;
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: topTwo.map((model) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 10,
                              top: 1,
                              bottom: 1,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: '李修缘:',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: TimelineUtil.format(
                                      model.unreadMessage?.atime,
                                      dayFormat: DayFormat.Simple,
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${model.unreadMessage?.content ?? ''}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Badge(
                      position: BadgePosition.topLeft(
                        left: 19,
                        top: 2,
                      ),
                      elevation: 0,
                      showBadge: true,
                      badgeContent: Text(
                        '',
                      ),
                      child: IconButton(
                        onPressed: () {
                          _isExpaned = true;
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.more_horiz,
                          size: 24,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        !_isExpaned
            ? Container(
                width: 0,
                height: 0,
              )
            : Column(
                children: widget.expandRooms.map((model) {
                  _expandRoomsIndex++;
                  return _ChatRoomItem(
                    isBottomItem:
                        _expandRoomsIndex >= widget.expandRooms.length,
                    context: widget.context,
                    title: model.displayRoomTitle,
                    leading: model.leading,
                    time: model.unreadMessage == null
                        ? ''
                        : TimelineUtil.format(
                            model.unreadMessage?.atime,
                            dayFormat: DayFormat.Simple,
                          ),
                    unreadMsgCount: model.unreadMsgCount ?? 0,
                    showNewest: model.unreadMsgCount ?? 0 > 0,
                    subtitle: '${model.unreadMessage?.content ?? ''}',
                    who: '',
                    onOpenRoom: () {
                      widget.context.forward('/portlet/chat/talk', arguments: {
                        'chatRoom': model.chatRoom,
                        'displayRoomTitle': model.displayRoomTitle,
                      });
                    },
                    onOpenAvatar: () {
                      widget.context
                          .forward(
                        '/portlet/chat/room/avatar',
                      )
                          .then((v) {
                        if (v == null) {
                          return;
                        }
                        var result = v as Map<String, Object>;
                        if (StringUtil.isEmpty(result['image'])) {
                          return;
                        }
                        String fileName = result['image'];
                        widget
                            .updateRoomLeading(model.chatRoom.id, fileName)
                            .then((v) {
                          setState(() {});
                        });
                      });
                    },
                    onRemoveAction: () {
                      if (widget.onRemoveChatRoom == null) {
                        return;
                      }
                      widget.onRemoveChatRoom(model.chatRoom).then((v) {
                        widget.expandRooms.remove(model);
                        setState(() {});
                      });
                    },
                  );
                }).toList(),
              ),
        !_isExpaned
            ? Container(
                width: 0,
                height: 0,
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _isExpaned = false;
                  setState(() {});
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    bottom: 10,
                    right: 10,
                    top: 10,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 24,
                    color: Colors.grey[500],
                  ),
                ),
              ),
      ],
    );
  }
}

class _ChatRoomItem extends StatefulWidget {
  PageContext context;
  Widget leading;
  String title;
  String who;
  String subtitle;
  String time;
  bool showNewest;
  int unreadMsgCount;
  Function() onOpenRoom;
  Function() onRemoveAction;
  Function() onOpenAvatar;
  bool isBottomItem;

  _ChatRoomItem({
    this.context,
    this.leading,
    this.title,
    this.who,
    this.subtitle,
    this.unreadMsgCount,
    this.time,
    this.showNewest,
    this.onOpenRoom,
    this.onRemoveAction,
    this.onOpenAvatar,
    this.isBottomItem,
  });

  @override
  State createState() {
    return __ChatRoomItem();
  }
}

class __ChatRoomItem extends State<_ChatRoomItem> {
  @override
  Widget build(BuildContext context) {
    Widget imgSrc = widget.leading;
//    if (widget.leading == null) {
//      imgSrc = Icon(
//        IconData(
//          0xe606,
//          fontFamily: 'netflow',
//        ),
//        size: 32,
//        color: Colors.grey[500],
//      );
//    } else {
//      imgSrc = widget.leading;
//    }
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
              crossAxisAlignment: widget.showNewest
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
                      if (widget.onOpenAvatar != null) {
                        widget.onOpenAvatar();
                      }
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
                          child: Badge(
                            position: BadgePosition.topRight(
                              right: -3,
                              top: 3,
                            ),
                            elevation: 0,
                            showBadge: widget.unreadMsgCount != 0,
                            badgeContent: Text(
                              '',
                            ),
                            child: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (widget.onOpenRoom != null) {
                        widget.onOpenRoom();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: widget.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                '${widget.time}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.showNewest)
                          Padding(
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
                                    text: '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    children: [
                                      if (widget.unreadMsgCount > 0)
                                        TextSpan(
                                            text:
                                                '[${widget.unreadMsgCount != 0 ? widget.unreadMsgCount : ''}条]'),
                                      TextSpan(
                                        text: ' ',
                                      ),
//                                      TextSpan(
//                                        text: '${this.who}: ',
//                                      ),
                                      TextSpan(
                                        text: '${widget.subtitle}',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isBottomItem)
            Divider(
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
            if (widget.onRemoveAction != null) {
              widget.onRemoveAction();
            }
          },
        ),
      ],
      child: item,
    );
  }
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

  Widget get leading {
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
      list.add(m.avatar);
    }
    return NineOldWidget(list);
  }
}
