import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
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
  RoomMember _member;
  List<_MemberModel> _memberModels = [];
  int _limit = 20, _offset = 0;
  ChatRoomNotice _newestNotice;
  bool _isForegroundWhite = false;

  var _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _model = widget.context.parameters['model'];
    _chatRoom = _model.chatRoom;
    _isForegroundWhite = _chatRoom.isForegoundWhite == 'true' ? true : false;
    _isRoomCreator = _chatRoom.creator == widget.context.principal.person;
    super.initState();
    _loadMembers().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    _reloadNickName().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    _loadNewestNotice().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _memberModels.clear();
    _chatRoom = null;
    super.dispose();
  }

  Future<void> _emptyMessages() async {
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    await messageService.empty(_chatRoom);
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

  Future<void> _reloadNickName() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    _member = await chatRoomService.getMember(_chatRoom.creator, _chatRoom.id);
    if (_member == null) {
      return;
    }
    _showNickName = _member.isShowNick == 'true';
  }

  Future<void> _setShowNick(showNick) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.switchNick(_chatRoom.creator, _chatRoom.id, showNick);
    _showNickName = showNick;
  }

  Future<void> _refresh() async {
    _offset = 0;
    _memberModels.clear();
    await _loadMembers();
  }

  Future<void> _loadMembers() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');

    List<RoomMember> members =
        await chatRoomService.pageMember(_chatRoom.id, _limit, _offset);
    if (members.isEmpty) {
      return;
    }
    _offset += members.length;
    for (RoomMember member in members) {
      // if (!StringUtil.isEmpty(member.type) && member.type != 'person') {
      //   continue;
      // }
      var person = await personService.getPerson(member.person);
      if (person != null && _chatRoom.creator == person.official) {
        _memberModels.insert(0, _MemberModel(person: person, member: member));
        continue;
      }
      _memberModels.add(_MemberModel(person: person, member: member));
    }
  }

  Future<void> _addMembers(members) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var error = '';
    for (var official in members) {
      if (await chatRoomService.existsMember(_chatRoom.id, official)) {
        continue;
      }
      var person =
          await personService.getPerson(official, isDownloadAvatar: false);
      try {
        if (_chatRoom.creator == widget.context.principal.person) {
          await chatRoomService.addMember(
            RoomMember(
              _chatRoom.id,
              official,
              person?.nickName,
              'false',
              person?.avatar,
              'person',
              DateTime.now().millisecondsSinceEpoch,
              widget.context.principal.person,
            ),
          );
        } else {
          await chatRoomService.addMemberToOwner(
            _chatRoom.creator,
            RoomMember(
              _chatRoom.id,
              official,
              person?.nickName,
              'false',
              person?.avatar,
              'person',
              DateTime.now().millisecondsSinceEpoch,
              widget.context.principal.person,
            ),
          );
        }
      } catch (e) {
        String err = e.message;
        if (err.startsWith('10004')) {
          error += '${person.nickName}(已退出聊天室，你无权拉入)；';
        } else {
          error += '${person.nickName}(已在聊天室)；';
        }
      }
    }
    if (!StringUtil.isEmpty(error)) {
      _globalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            '提示\r\n已忽略以下成员：$error',
          ),
        ),
      );
    }
  }

  Future<void> _removeMember(member) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.removeMember(_chatRoom.id, member.official);
  }

  Future<void> _removeMembers(list) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    for (var item in list) {
      await chatRoomService.removeMember(_chatRoom.id, item);
    }
  }

  Future<void> _setBackground(path) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.updateRoomBackground(_chatRoom, path);
    _chatRoom.p2pBackground = path;
  }

  Future<void> _removeChatRoom() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.removeChatRoom(_chatRoom.id);
  }

  Future<void> _loadNewestNotice() async {
    IChatRoomRemote chatRoomRemote =
        widget.context.site.getService('/remote/chat/rooms');
    _newestNotice = await chatRoomRemote.getNewestNotice(_model.chatRoom);
  }

  Future<void> _setForebround() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.updateRoomForeground(_chatRoom, _isForegroundWhite);
    _chatRoom.isForegoundWhite = _isForegroundWhite == true ? 'true' : 'false';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
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
              child: _getMemberWidgets(),
            ),
          ),
//          SliverToBoxAdapter(
//            child: Container(
//              padding: EdgeInsets.only(
//                left: 10,
//                bottom: 2,
//              ),
//              child: Text(
//                '成员',
//                style: TextStyle(
//                  color: Colors.grey[500],
//                  fontWeight: FontWeight.w500,
//                ),
//              ),
//            ),
//          ),
//          SliverToBoxAdapter(
//            child: Container(
//              color: Colors.white,
//              margin: EdgeInsets.only(
//                bottom: 10,
//              ),
//              padding: EdgeInsets.all(10),
//              child: GridView(
//                padding: EdgeInsets.all(0),
//                shrinkWrap: true,
//                physics: NeverScrollableScrollPhysics(),
//                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//                  maxCrossAxisExtent: 70,
//                  crossAxisSpacing: 5,
//                  mainAxisSpacing: 5,
//                ),
//                children: [],
//              ),
//            ),
//          ),
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
                      ).then((args) {
                        if (StringUtil.isEmpty(args)) {
                          return;
                        }
                        _reloadNickName().then((v) async {
                          if (_showNickName) {
                            _memberModels.clear();
                            _offset = 0;
                            await _loadMembers();
                          }
                          setState(() {});
                        });
                      });
                    },
                    tipsText: '${_member?.nickName ?? '未设置'}',
                  ),
                  Divider(
                    height: 1,
                    indent: 15,
                  ),
                  CardItem(
                    paddingLeft: 15,
                    paddingRight: 15,
                    title: '是否显示为昵称',
                    onItemTap: () {
                      _setShowNick(!_showNickName).then((v) async {
                        _refresh().then((value) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      });
                    },
                    tail: SizedBox(
                      height: 25,
                      child: Switch.adaptive(
                        value: _showNickName,
                        onChanged: (showNickName) {
                          _setShowNick(showNickName).then((v) {
                            _refresh().then((value) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          !_isRoomCreator
              ? SliverToBoxAdapter(
                  child: Container(
                    width: 0,
                    height: 0,
                  ),
                )
              : SliverToBoxAdapter(
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
                          tail: Row(
                            children: <Widget>[
                              StringUtil.isEmpty(_chatRoom.p2pBackground)
                                  ? Container(
                                      width: 0,
                                      height: 0,
                                    )
                                  : _chatRoom.p2pBackground.startsWith("/")
                                      ? Image.file(
                                          File(_chatRoom.p2pBackground),
                                          fit: BoxFit.fitHeight,
                                          height: 40,
                                        )
                                      : Image.network(
                                          _chatRoom.p2pBackground,
                                          height: 40,
                                          fit: BoxFit.fitHeight,
                                        ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            ],
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/widgets/avatar',
                              arguments: {
                                'aspectRatio': -1.0,
                                'file': _chatRoom.p2pBackground,
                              },
                            ).then((path) {
                              _setBackground(path).then((v) {
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            });
                          },
                        ),
                        Divider(
                          height: 1,
                        ),
                        CardItem(
                          paddingLeft: 15,
                          paddingRight: 15,
                          title: '聊天室前景色',
                          tipsText: '是否设为白色',
                          tail: Switch.adaptive(
                              value: _isForegroundWhite,
                              onChanged: (v) {
                                _isForegroundWhite = v;
                                _setForebround().then((v) {
                                  _chatRoom.isForegoundWhite =
                                      _isForegroundWhite ? 'true' : 'false';
                                  if (mounted) {
                                    setState(() {});
                                  }
                                });
                              }),
                          onItemTap: () {
                            _isForegroundWhite = !_isForegroundWhite;
                            _setForebround().then((v) {
                              _chatRoom.isForegoundWhite =
                                  _isForegroundWhite ? 'true' : 'false';
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
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
                      _emptyMessages().then((v) {
                        widget.context.backward(
                          result: 'empty',
                        );
                      });
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
                      _removeChatRoom().then((v) {
                        widget.context.backward(result: 'remove');
                      });
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
        size: 18,
        color: Colors.grey[400],
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
    return SizedBox(
      width: 30,
      height: 30,
      child: getAvatarWidget(_chatRoom.leading, widget.context),
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
        onItemTap: () {
          widget.context.forward(
            '/portlet/chat/room/qrcode',
            arguments: {
              'model': _model,
            },
          );
        },
      ),
    );
    list.add(
      Divider(
        height: 1,
        indent: 15,
      ),
    );
    list.add(
      CardItem(
        paddingLeft: 15,
        paddingRight: 15,
        title: '公告',
        tipsOverflow: TextOverflow.ellipsis,
        hiddenSubTitle: true,
        tipsText: _newestNotice == null ? '无' : _newestNotice.notice ?? '无',
        onItemTap: _newestNotice == null && !isMineRoom
            ? null
            : () {
                widget.context.forward(
                  '/portlet/chat/room/settings/setNotice',
                  arguments: {
                    'model': _model,
                  },
                ).then((v) {
                  _loadNewestNotice().then((v) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                });
              },
      ),
    );

    return list;
  }

  Widget _getMemberWidgets() {
    var plusMemberButton = _renderPlusMemberButton();
    if (_memberModels.isEmpty) {
      return plusMemberButton;
    }
    List<Widget> items = [];
    for (var model in _memberModels) {
      var person = model.person;
      var member = model.member;
      bool isOwner = member.person == _chatRoom.creator;
      var title;
      if (member.type == 'wybank') {
        title = member.nickName;
      } else {
        title =
            '${(member.isShowNick == 'true') ? (member.nickName ?? person.nickName) : person.nickName}';
      }
      var avatar =
          StringUtil.isEmpty(member.leading) ? person?.avatar : member.leading;
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (member.type == 'wybank') {
              widget.context
                  .forward('/portlet/chat/room/view_licence', arguments: {
                'bankid': member.person,
              });
              return;
            }
            widget.context
                .forward('/person/view', arguments: {'person': person});
          },
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
              _removeMember(person).then((v) {
                if (mounted) {
                  setState(() {});
                }
              });
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                fit: StackFit.passthrough,
                overflow: Overflow.visible,
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
                        child: getAvatarWidget(avatar, widget.context),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -6,
                    bottom: -2,
                    child: isOwner
                        ? Icon(
                            Icons.settings,
                            size: 12,
                            color: Colors.redAccent,
                          )
                        : Container(
                            width: 0,
                            height: 0,
                          ),
                  ),
                ],
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    items.add(plusMemberButton);
    if (_isManager()) {
      items.add(_renderRemoveMemberButton());
    }
    items.add(_renderViewMemberButton());
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
  }

  bool _isManager() {
    return _chatRoom.creator == widget.context.principal.person;
  }

  Widget _renderRemoveMemberButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            var result = await widget.context
                .forward('/contacts/friend/removeMembers', arguments: {
              'chatroom': _chatRoom,
            }) as List<String>;
            if (result == null || result.isEmpty) {
              return;
            }
            await _removeMembers(result);
            _offset = 0;
            _memberModels.clear();
            await _loadMembers();
            if (mounted) setState(() {});
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
                    Icons.remove,
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
  }

  Widget _renderViewMemberButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            var refresh = () {
              _refresh().then((value) {
                if (mounted) setState(() {});
              });
            };
            await widget.context.forward('/contacts/friend/viewMembers',
                arguments: {'chatroom': _chatRoom, 'refresh': refresh});
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
                    Icons.arrow_forward_ios,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        _SyncMemberPanel(
          context: widget.context,
          chatRoom: _chatRoom,
        ),
      ],
    );
  }

  Widget _renderPlusMemberButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            var result = await widget.context
                .forward('/contacts/friend/addMembers', arguments: {
              'chatroom': _chatRoom,
            }) as List<String>;
            if (result == null || result.isEmpty) {
              return;
            }
            _addMembers(result).then((v) async {
              await _refresh();
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
  }
}

class _MemberModel {
  Person person;
  RoomMember member;

  _MemberModel({this.person, this.member});
}

class _SyncMemberPanel extends StatefulWidget {
  PageContext context;
  ChatRoom chatRoom;

  _SyncMemberPanel({this.context, this.chatRoom});

  @override
  __SyncMemberPanelState createState() => __SyncMemberPanelState();
}

class __SyncMemberPanelState extends State<_SyncMemberPanel> {
  int _memberCountRemote = 0, _memberCountLocal = 0;
  ChatRoom _chatRoom;
  String _progress;
  int _limit = 100, _offset = 0;

  @override
  void initState() {
    _chatRoom = widget.chatRoom;
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    _progress = '正在统计成员...';
    setState(() {});
    await _totalMembers();
    if (_memberCountRemote != _memberCountLocal) {
      if (mounted) {
        setState(() {
          _progress = '有新成员,同步中...';
        });
      }
      await _syncMembers();
      await _totalMembers();
    }
    if (mounted) {
      setState(() {
        _progress = '$_memberCountLocal/$_memberCountRemote';
      });
    }
  }

  Future<void> _totalMembers() async {
    IChatRoomService chatRoomService = widget.context.site.getService(
      '/chat/rooms',
    );
    IChatRoomRemote chatRoomRemote =
        widget.context.site.getService('/remote/chat/rooms');
    _memberCountLocal = await chatRoomService.totalMembers(_chatRoom.id);
    _memberCountRemote =
        await chatRoomRemote.totalMember(_chatRoom.creator, _chatRoom.id);
  }

  Future<void> _syncMembers() async {
    IChatRoomService chatRoomService = widget.context.site.getService(
      '/chat/rooms',
    );
    IChatRoomRemote chatRoomRemote =
        widget.context.site.getService('/remote/chat/rooms');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var list = await chatRoomRemote.listFlagRoomMember(
        _chatRoom.creator, _chatRoom.id);
    await chatRoomService.removeChatMembersOnLocal(_chatRoom.id, list);
    var members = await chatRoomRemote.pageRoomMember(
        _chatRoom.creator, _chatRoom.id, _limit, _offset);
    for (var m in members) {
      var exists = await chatRoomService.existsMember(m.room, m.person);
      if (exists) {
        continue;
      }
      var person =
          await personService.getPerson(m.person, isDownloadAvatar: true);
      var nickName = person?.nickName ?? m.nickName;
      await chatRoomService.addMember(
          RoomMember(
            m.room,
            m.person,
            nickName,
            m.isShowNick ? 'true' : 'false',
            person?.avatar,
            'person',
            m.atime,
            widget.context.principal.person,
          ),
          isOnlySaveLocal: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_progress',
      style: TextStyle(
        fontSize: 12,
        color: Colors.black54,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
