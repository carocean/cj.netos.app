import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/load_indicator.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ChatMemberPlusPage extends StatefulWidget {
  PageContext context;

  ChatMemberPlusPage({this.context});

  @override
  _ChatMemberPlusPageState createState() => _ChatMemberPlusPageState();
}

class _ChatMemberPlusPageState extends State<ChatMemberPlusPage> {
  List<Friend> _friends = [];
  TextEditingController _controller;
  String _query;
  FocusNode _focusNode;
  List<String> _selectedFriends = [];
  ChatRoom _chatRoom;
  int _limit = 20, _offset = 0;

  @override
  void initState() {
    _chatRoom = widget.context.parameters['chatroom'];
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _controller = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _offset = 0;
    _friends.clear();
    await _load();
  }

  Future<void> _load() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IFriendService friendService =
        widget.context.site.getService('/gbera/friends');
    List<RoomMember> members = await chatRoomService.listMember(_chatRoom.id);
    List<String> officials = [];
    for (var m in members) {
      officials.add(m.person);
    }
    List<Friend> friends;
    if (StringUtil.isEmpty(_query)) {
      friends = await friendService.pageFriendNotIn(officials, _limit, _offset);
    } else {
      friends = await friendService.pageFriendLikeName(
          '%$_query%', officials, _limit, _offset);
    }
    if (members.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += members.length;
    _friends.addAll(friends);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _done() async {
    widget.context.backward(result: _selectedFriends);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: (v) {
            _query = v;
            _refresh();
          },
          onSubmitted: (v) {
            _query = v;
            _refresh();
          },
          focusNode: _focusNode,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          textAlign: _focusNode.hasFocus ? TextAlign.left : TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              right: 15,
            ),
            border: InputBorder.none,
            filled: true,
            fillColor: Theme.of(context).backgroundColor,
            hintText: _focusNode.hasFocus ? '输入好友名、电话、手机号' : '添加成员',
            hintStyle: _focusNode.hasFocus
                ? null
                : TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
            suffix: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _controller.clear();
                _query = '';
                _refresh().then((value) {
                  _focusNode.nextFocus();
                });
              },
              child: Icon(
                Icons.clear,
                color: Colors.grey,
                size: 14,
              ),
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          _selectedFriends.isEmpty
              ? SizedBox(
                  width: 0,
                  height: 0,
                )
              : Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    right: 15,
                  ),
                  child: RaisedButton(
                    onPressed: () {
                      _done();
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text(
                      '完成(${_selectedFriends.length})',
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          _renderSelected(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: LoadIndicator(
                load: _load,
                child: Column(
                  children: _renderMembers(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderMembers() {
    var items = <Widget>[];
    if (_friends.isEmpty) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 20,
          ),
          alignment: Alignment.center,
          child: Text(
            '没有成员',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var friend in _friends) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selectedFriends.contains(friend.official)) {
              _selectedFriends.remove(friend.official);
            } else {
              _selectedFriends.add(friend.official);
            }
            if (mounted) {
              setState(() {});
            }
          },
          child: Container(
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    margin: EdgeInsets.only(
                      left: 15,
                    ),
                    child: Center(
                      child: Radio(
                        value: _selectedFriends.contains(friend.official),
                        groupValue: true,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          if (v) {
                            _selectedFriends.add(friend.official);
                          } else {
                            _selectedFriends.remove(friend.official);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          child: getAvatarWidget(friend.avatar, widget.context),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            friend.nickName,
                            style: TextStyle(
                              fontSize: 16,
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
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 50,
        ),
      );
    }
    return items;
  }

  Widget _renderSelected() {
    var items = <Widget>[];
    if (_selectedFriends.isEmpty) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }

    for (var person in _selectedFriends) {
      var found;
      for (var friend in _friends) {
        if (friend.official == person) {
          found = friend;
          break;
        }
      }
      if (found == null) {
        continue;
      }
      items.add(
        Container(
          width: 40,
          height: 40,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/person/view',
                  arguments: {'person': found.toPerson()});
            },
            onLongPress: () {
              _selectedFriends.removeWhere((p) {
                return p == person;
              });
              setState(() {});
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: getAvatarWidget(found.avatar, widget.context),
            ),
          ),
        ),
      );
    }
    if (items.isNotEmpty) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/contacts/friend/selected',
                arguments: {'selected': _selectedFriends});
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 1,
                color: Colors.grey[400],
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}
