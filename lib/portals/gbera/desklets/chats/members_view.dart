import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/load_indicator.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ChatMemberViewPage extends StatefulWidget {
  PageContext context;

  ChatMemberViewPage({this.context});

  @override
  _ChatMemberViewPageState createState() => _ChatMemberViewPageState();
}

class _ChatMemberViewPageState extends State<ChatMemberViewPage> {
  List<_MemberModel> _memberModels = [];
  TextEditingController _controller;
  String _query;
  FocusNode _focusNode;
  int _limit = 50, _offset = 0;
  ChatRoom _chatRoom;
  bool _isLoading = true;

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
    _load().then((value) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
    _memberModels.clear();
    await _load();
    var parentRefresh = widget.context.parameters['refresh'];
    if (parentRefresh != null) {
      parentRefresh();
    }
  }

  Future<void> _load() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<RoomMember> members;
    if (StringUtil.isEmpty(_query)) {
      members = await chatRoomService.pageMember(_chatRoom.id, _limit, _offset);
    } else {
      members = await chatRoomService.pageMemberLike(
          '%$_query%', _chatRoom.id, _limit, _offset);
    }
    if (members.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += members.length;
    for (RoomMember member in members) {
      var person = await personService.getPerson(member.person);
      _memberModels.add(_MemberModel(person: person, member: member));
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addMembers(members) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    for (var official in members) {
      if (await chatRoomService.existsMember(_chatRoom.id, official)) {
        continue;
      }
      var person =
          await personService.getPerson(official, isDownloadAvatar: false);
      await chatRoomService.addMemberToOwner(
        _chatRoom.creator,
        RoomMember(
          _chatRoom.id,
          official,
          person?.nickName,
          'false',
          null,
          'person',
          DateTime.now().millisecondsSinceEpoch,
          widget.context.principal.person,
        ),
      );
    }
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
            hintText: _focusNode.hasFocus ? '输入好友名、电话、手机号' : '群成员',
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
        titleSpacing: 0,
        centerTitle: true,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: _rendBody(),
      ),
    );
  }

  Widget _rendBody() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '正在加载...',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
    if (_memberModels.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Text(
            '没有成员',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
    var items = <Widget>[];
    for (var model in _memberModels) {
      var member = model.member;
      var leading;
      var title;
      if (member.type == 'wybank') {
        leading = member.leading;
        title = member.nickName;
      } else {
        var person = model.person;
        leading = person.avatar;
        title = person.nickName;
      }
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (member.type == 'wybank') {
              widget.context
                  .forward('/portlet/chat/room/view_licence', arguments: {
                'bankid': member.person,
              });
              return;
            }
            widget.context
                .forward('/person/view', arguments: {'person': model.person});
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 50,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: getAvatarWidget(leading, widget.context),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            '${title}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    items.add(
      _renderPlusMemberButton(),
    );
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: LoadIndicator(
        child: Center(
          child: Wrap(
            children: items,
          ),
        ),
        load: () async {
          await _load();
        },
      ),
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
            padding: EdgeInsets.all(10),
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
