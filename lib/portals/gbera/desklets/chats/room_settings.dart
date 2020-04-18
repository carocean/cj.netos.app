import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

import 'chat_rooms.dart';

class ChatRoomSettings extends StatefulWidget {
  PageContext context;

  ChatRoomSettings({this.context});

  @override
  _ChatRoomSettingsState createState() => _ChatRoomSettingsState();
}

class _ChatRoomSettingsState extends State<ChatRoomSettings> {
  bool _showNickName = false;
  ChatRoom _chatRoom;
  ChatRoomModel _model;
  bool _isRoomCreator = false;

  @override
  void initState() {
    _model = widget.context.parameters['model'];
    _chatRoom = _model.chatRoom;
    _isRoomCreator = _chatRoom.creator == widget.context.principal.person;
    super.initState();
    _loadTop20Members().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _chatRoom = null;
    super.dispose();
  }

  Future<void> _updateRoomLeading(String file) async {
    IChatRoomService chatRoomService = widget.context.site.getService(
      '/chat/rooms',
    );
    await chatRoomService.updateRoomLeading(
      _chatRoom.id,
      file,
    );
  }
  Future<void> _reloadNickName(){

  }
  Future<List<Person>> _loadTop20Members() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<RoomMember> members = await chatRoomService.top20Members(_chatRoom.id);
    List<Person> persons = [];
    for (RoomMember member in members) {
      var person = await personService.getPerson(member.person);
      persons.add(person);
    }
    return persons;
  }

  Future<void> _addMembers(members) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    for (var official in members) {
      if (await chatRoomService.existsMember(_chatRoom.id, official)) {
        continue;
      }
      await chatRoomService.addMember(
        RoomMember(
          _chatRoom.id,
          official,
          null,
          DateTime.now().millisecondsSinceEpoch,
          widget.context.principal.person,
        ),
      );
    }
  }

  Future<void> _removeMember(member) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.removeMember(_chatRoom.id, member.official);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              '聊天室',
            ),
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            pinned: true,
            floating: false,
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              padding: EdgeInsets.all(10),
              child: FutureBuilder<List<Person>>(
                future: _loadTop20Members(),
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
                  var members = snapshot.data;
                  var plusMemberButton = Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          var result = await widget.context
                              .forward('/portlet/chat/friends') as List<String>;
                          if (result == null || result.isEmpty) {
                            return;
                          }
                          _addMembers(result).then((v) {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 2,
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey[300],
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                  if (members == null || members.isEmpty) {
                    return plusMemberButton;
                  }
                  List<Widget> items = [];
                  var _items = snapshot.data.map((member) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      onLongPress: () {
                        showDialog(
                          context: context,
//                          child: Text('xx'),
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('是否删除？'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    '删除',
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.context.backward(result: 'delete');
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.context.backward(result: 'cancel');
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((action) {
                          if (action != 'delete') {
                            return;
                          }
                          _removeMember(member).then((v) {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 2,
                            ),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                child: member.avatar.startsWith("/")
                                    ? Image.file(
                                        File(member.avatar),
                                        fit: BoxFit.cover,
                                      )
                                    : FadeInImage.assetNetwork(
                                        placeholder: 'lib/portals/gbera/images/default_avatar.png',
                                        image:
                                            '${member.avatar}?accessToken=${widget.context.principal.accessToken}',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          Text(
                            member.nickName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList();
                  items.addAll(_items);
                  items.add(plusMemberButton);
                  return GridView(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 70,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    children: items,
                  );
                },
              ),
            ),
          ),
          /*
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                bottom: 2,
              ),
              child: Text(
                '成员',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              padding: EdgeInsets.all(10),
              child: GridView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 70,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                children: contacts_members.map((c) {
                  return c;
                }).toList(),
              ),
            ),
          ),

           */
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              child: Column(
                children: _mainSettings(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              child: Column(
                children: <Widget>[
                  !_isRoomCreator
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Divider(
                          height: 1,
                          indent: 15,
                        ),
                  CardItem(
                    paddingLeft: 15,
                    paddingRight: 15,
                    title: '我在本聊天室的昵称',
                    onItemTap: () {
                      widget.context.forward(
                        '/portlet/chat/room/setNickName',
                        arguments: {
                          'chatroom': _chatRoom,
                        },
                      ).then((args) {});
                    },
                    tipsText: 'cj',
                  ),
                  Divider(
                    height: 1,
                    indent: 15,
                  ),
                  CardItem(
                    paddingLeft: 15,
                    paddingRight: 15,
                    title: '成员显示为昵称',
                    tail: SizedBox(
                      height: 25,
                      child: Switch.adaptive(
                        value: _showNickName,
                        onChanged: (showNickName) {
                          setState(() {
                            _showNickName = showNickName;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              child: Column(
                children: <Widget>[
                  CardItem(
                    paddingLeft: 15,
                    paddingRight: 15,
                    title: '聊天室背景',
                    tipsText: '',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('empty--');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                      ),
                      child: Center(
                        child: Text(
                          '清空聊天记录',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('remove--');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                      ),
                      child: Center(
                        child: Text(
                          '删除',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
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

  _getTailWidget() {
    if (StringUtil.isEmpty(_chatRoom.leading)) {
      return Icon(
        Icons.arrow_forward_ios,
        size: 30,
        color: Colors.grey[500],
      );
    }
    if (_chatRoom.leading.startsWith('/')) {
      return Image.file(
        File(_chatRoom.leading),
        width: 30,
        height: 30,
        fit: BoxFit.fill,
      );
    }
    return FadeInImage.assetNetwork(
      placeholder: null,
      image: _chatRoom.leading,
      width: 30,
      height: 30,
      fit: BoxFit.fill,
    );
  }

  List<Widget> _mainSettings() {
    var list = <Widget>[];
    var isMineRoom = widget.context.principal.person == _chatRoom.creator;
    if (isMineRoom) {
      list.add(
        CardItem(
          paddingLeft: 15,
          paddingRight: 15,
          onItemTap: () {
            widget.context.forward(
              '/portlet/chat/room/settings/setTitle',
              arguments: {
                'chatroom': _chatRoom,
              },
            ).then((args) {});
          },
          title: '名称',
          tipsText: _chatRoom?.title ?? '未命名',
        ),
      );
      list.add(
        Divider(
          height: 1,
          indent: 15,
        ),
      );
    }
    if (isMineRoom) {
      list.add(
        CardItem(
          paddingLeft: 15,
          paddingRight: 15,
          title: '图标',
          tail: _getTailWidget(),
          onItemTap: () {
            widget.context.forward(
              '/widgets/avatar',
              arguments: {'file': _chatRoom.leading},
            ).then((path) {
              if (StringUtil.isEmpty(path)) {
                return;
              }
              _chatRoom.leading = path;
              setState(() {});
              _updateRoomLeading(path);
            });
          },
        ),
      );
    }
    list.add(
      CardItem(
        paddingLeft: 15,
        paddingRight: 15,
        title: '二维码',
        tipsIconData: FontAwesomeIcons.qrcode,
      ),
    );
    list.add(
      Divider(
        height: 1,
        indent: 15,
      ),
    );
    if (isMineRoom) {
      list.add(
        CardItem(
          paddingLeft: 15,
          paddingRight: 15,
          title: '公告',
          tipsText: '未设置',
        ),
      );
    }

    return list;
  }
}
