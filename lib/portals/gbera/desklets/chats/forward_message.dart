import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

import 'chat_rooms.dart';
import 'chattalk_opener.dart';
import 'media_card.dart';

class ForwardMessagePage extends StatefulWidget {
  PageContext context;

  ForwardMessagePage({this.context});

  @override
  _ForwardMessagePageState createState() => _ForwardMessagePageState();
}

class _ForwardMessagePageState extends State<ForwardMessagePage> {
  ChatMessage _message;
  List<ChatRoomModel> _roomList = [];
  bool _isLoading = true;
  _ObjectSelector _selector;

  @override
  void initState() {
    _message = widget.context.partArgs['message'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    _isLoading = true;
    await _loadChatrooms();
    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadChatrooms() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    List<ChatRoom> rooms = await chatRoomService.listChatRoom();
    for (var room in rooms) {
      List<RoomMember> members = await chatRoomService.listMember(room.id);
      List<Friend> friends = [];
      for (var member in members) {
        if (!StringUtil.isEmpty(member.type) && member.type != 'person') {
          continue;
        }
        var f = await friendService.getFriend(member.person);
        if (f == null) {
          continue;
        }
        friends.add(f);
      }
      _roomList.add(
        ChatRoomModel(
          chatRoom: room,
          members: friends,
        ),
      );
    }
  }

  Future<void> _doSelectFriends(List<String> friends) async {
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    var list = <Friend>[];
    for (var official in friends) {
      var f = await friendService.getFriend(official);
      if (f != null) {
        list.add(f);
      }
    }
    _selector = _ObjectSelector(type: 'friends', selected: list);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _publish() async {
    switch (_selector.type) {
      case 'chatroom':
        ChatRoomModel model = _selector.selected;
        messageSender.openOnly(widget.context, roomId: model.chatRoom.id,
            callback: (isNewRoom, model) async {
          //新建的发送消息
          await _sendMessage(model);
          await widget.context.forward('/portlet/chat/talk',
              clearHistoryByPagePath: '.',
              arguments: {
                'model': model,
              });
          widget.context.backward();
        });
        break;
      case 'friends':
        var members = <String>[];
        for (Friend friend in _selector.selected) {
          members.add(friend.official);
        }
        messageSender.open(widget.context, members: members,
            callback: (isNewRoom, model) async {
          //新建的发送消息
          await _sendMessage(model);
          await widget.context.forward('/portlet/chat/talk',
              clearHistoryByPagePath: '.',
              arguments: {
                'model': model,
              });
          widget.context.backward();
        });
        break;
    }
  }

  Future<void> _sendMessage(ChatRoomModel model) async {
    await messageSender.sendNormalMessage(
      widget.context,
      model.chatRoom.creator,
      model.chatRoom.id,
      _message.contentType,
      _message.content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('转发'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            onTap: _selector == null
                ? null
                : () {
                    _publish();
                  },
            child: Container(
              color: _selector == null ? Colors.grey[500] : Colors.green,
              margin: EdgeInsets.only(
                right: 15,
                top: 12,
                bottom: 12,
              ),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              alignment: Alignment.center,
              child: Text(
                '转发',
                style: TextStyle(
                  color: _selector == null ? Colors.white70 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _renderDisplay(),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '分享给',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: _renderSelected(),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        widget.context
                            .forward('/contacts/friend/selector')
                            .then((value) {
                          if (value == null) {
                            return;
                          }
                          _doSelectFriends(value);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 15,
                          bottom: 15,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '其他好友',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(height: 20,child: Divider(
                    //   height: 1,
                    //   indent: 20,
                    // ),),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                '最近聊天',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _renderChatrooms(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderChatrooms() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Container(
          height: 60,
          alignment: Alignment.center,
          child: Text('正在加载...'),
        ),
      );
      return items;
    }
    if (_roomList.isEmpty) {
      items.add(
        Container(
          height: 60,
          alignment: Alignment.center,
          child: Text('没有聊天室'),
        ),
      );
      return items;
    }
    for (var room in _roomList) {
      if (room.chatRoom.title == '招财猫') {
        continue;
      }
      var imgSrc = room.leading(widget.context.principal);
      items.add(
        InkWell(
          onTap: () {
            _selector = _ObjectSelector(
              type: 'chatroom',
              selected: room,
            );
            if (mounted) {
              setState(() {});
            }
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: imgSrc,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.displayRoomTitle(widget.context.principal),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                (_selector != null &&
                        _selector.type == 'chatroom' &&
                        _selector.selected.chatRoom.id == room.chatRoom.id)
                    ? Icon(
                        Icons.check,
                        color: Colors.red,
                        size: 18,
                      )
                    : SizedBox(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 40,
        ),
      );
    }
    return items;
  }

  List<Widget> _renderSelected() {
    var items = <Widget>[];
    if (_selector == null) {
      return items;
    }
    switch (_selector.type) {
      case 'chatroom':
        var room = _selector.selected;
        var imgSrc = room.leading(widget.context.principal);
        items.add(
          Column(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: imgSrc,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  room.displayRoomTitle(widget.context.principal),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
        break;
      case 'friends':
        for (Friend friend in _selector.selected) {
          items.add(
            Column(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: getAvatarWidget(friend.avatar, widget.context),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '${friend.nickName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }
        break;
    }
    return items;
  }

  Widget _renderDisplay() {
    var type = _message.contentType;
    var content = _message.content;
    Widget display;
    switch (type) {
      case 'text':
        display = Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left: 20,right: 20),
          decoration: BoxDecoration(
            color: Color(0xFFF5f5f5),
            borderRadius: BorderRadius.circular(4),
          ),
          constraints: BoxConstraints.tightForFinite(width: double.maxFinite),
          alignment: Alignment.topLeft,
          child: Text(
            '$content',
            style: TextStyle(
              fontSize: 15,
            ),),
        );
        break;
      case 'image':
        var json = content;
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
            room: _message.room,
            pageContext: widget.context,
          ),
        );
        break;
      case 'share':
        var json = content;
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
        display=Padding(padding: EdgeInsets.only(left: 20,right: 20,),child: display,);
        break;
      case 'audio':
        var map = jsonDecode(content);
        String path = map['path'];
        display = MediaCard(
          media: RoomMessageMedia(
            src: path,
            type: 'audio',
            args: map['timelength'],
          ),
          room: _message.room,
          pageContext: widget.context,
        );
        display=Container(
          width: 250,
          alignment: Alignment.topCenter,
          child: display,
        );
        break;
      case 'video':
        var json = content;
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
            room: _message.room,
            pageContext: widget.context,
          ),
        );
        break;
      default:
        display = SizedBox.shrink();
        break;
    }
    return display;
  }
}

class _ObjectSelector {
  String type; //聊天室chatroom；好友集合friends
  dynamic selected;

  _ObjectSelector({this.type, this.selected});
}
