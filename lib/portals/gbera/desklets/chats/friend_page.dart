import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class FriendPage extends StatefulWidget {
  PageContext context;

  FriendPage({this.context});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  String _query;
  TextEditingController _controller;
  List<String> _selected_friends;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
    _selected_friends = [];
  }

  @override
  void dispose() {
    _controller.dispose();
    _query = '';
    _selected_friends.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: TextField(
          controller: _controller,
          onChanged: (v) {
            _query = v;
            setState(() {});
          },
          onSubmitted: (v) {
            _query = v;
            setState(() {});
          },
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            hintText: '朋友',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _controller.clear();
              _query = '';
              setState(() {});
            },
            icon: Icon(
              Icons.clear_all,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.group_add,
            ),
            onPressed: () {
              widget.context.forward('/portlet/chat/add_friend').then((v) {
                _query = '';
                _selected_friends.clear();
                setState(() {});
              });
            },
          ),
          IconButton(
            onPressed: () {
              widget.context.backward(result: _selected_friends);
            },
            icon: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: FriendList(
          query: _query,
          context: widget.context,
          selectedFriends: _selected_friends,
        ),
      ),
    );
  }
}

class FriendList extends StatefulWidget {
  String query;
  PageContext context;
  List<String> selectedFriends;

  FriendList({this.query, this.context, this.selectedFriends});

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  List<Friend> _friends;
  int _limit = 20;
  int _offset = 0;
  EasyRefreshController _controller;

  @override
  void initState() {
    _friends = [];
    _controller = EasyRefreshController();
    _onLoad().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didUpdateWidget(FriendList oldWidget) {
    if (oldWidget.query != widget.query) {
      _offset = 0;
      _friends.clear();
      _onLoad().then((v) {
        setState(() {});
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _offset = 0;
    _friends.clear();
    _controller.dispose();
    super.dispose();
  }

  Future<List<Friend>> _onLoad() async {
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    List<Friend> friends;
    if (StringUtil.isEmpty(widget.query)) {
      friends = await friendService.pageFriend(_limit, _offset);
    } else {
      List<String> officials = [];
      friends = await friendService.pageFriendLikeName(
          '${widget.query}%', officials, _limit, _offset);
    }
    if (friends.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      return _friends;
    }
    _offset += friends.length;
    _friends.addAll(friends);
    return _friends;
  }

  Future<void> _removeFriend(Friend friend) async {
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    friendService.removeFriendById(friend.id);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          padding: EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 0,
            right: 15,
          ),
          alignment: Alignment.center,
          child: Text(
            '长按朋友选中',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
        EasyRefresh.custom(
          onLoad: _onLoad,
          shrinkWrap: true,
          controller: _controller,
          slivers: _friends.map((friend) {
            var _avatar = friend.avatar;
            var avatarImage;
            if (StringUtil.isEmpty(_avatar)) {
              avatarImage = Image.asset(
                'lib/portals/gbera/images/avatar.png',
                width: 35,
                height: 35,
              );
            } else if (_avatar.startsWith("/")) {
              avatarImage = Image.file(
                File(_avatar),
                width: 35,
                height: 35,
              );
            } else {
              avatarImage = Image.network(
                '${friend.avatar}',
                fit: BoxFit.cover,
                width: 35,
                height: 35,
              );
            }
            var official = PersonUtil.officialBy(friend);
            return SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          icon: Icons.delete,
                          onTap: () {
                            _removeFriend(friend).then((v) {
                              _friends.remove(friend);
                              widget.selectedFriends.remove(friend.official);
                              setState(() {});
                            });
                          },
                        ),
                      ],
                      child: CardItem(
                        title: friend.nickName ?? friend.accountName,
                        paddingLeft: 15,
                        paddingRight: 15,
                        paddingBottom: 10,
                        paddingTop: 10,
                        leading: ClipRRect(
                          child: avatarImage,
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        onItemTap: () {
                          widget.context.forward('/site/friend',
                              arguments: {'friend': friend});
                        },
                        tipsIconData: widget.selectedFriends.contains(official)
                            ? Icons.check
                            : IconData(
                                0x00,
                              ),
                        onItemLongPress: () {
                          if (widget.selectedFriends.contains(official)) {
                            widget.selectedFriends.remove(official);
                          } else {
                            widget.selectedFriends.add(official);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    Divider(height: 1, indent: 60),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
