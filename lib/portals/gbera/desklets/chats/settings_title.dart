import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ChatroomSetTitle extends StatefulWidget {
  PageContext context;

  ChatroomSetTitle({this.context});

  @override
  _ChatroomSetTitleState createState() => _ChatroomSetTitleState();
}

class _ChatroomSetTitleState extends State<ChatroomSetTitle> {
  TextEditingController _controller;
  bool _enableDone = false;
  ChatRoom _chatRoom;

  @override
  void initState() {
    _chatRoom = widget.context.parameters['chatroom'];
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _chatRoom = null;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateChatroomTitle() async {
    var value = _controller.text;
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.updateRoomTitle(
      _chatRoom.id,
      value,
    );
    _chatRoom.title = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('名称设置'),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            child: Text(
              '完成',
              style: TextStyle(
                color: _enableDone ? Colors.green : null,
              ),
            ),
            onPressed: !_enableDone
                ? null
                : () {
                    _updateChatroomTitle().then((v) {
                      widget.context.backward(result: _controller.text);
                    });
                  },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 20,
        ),
        constraints: BoxConstraints.expand(),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onChanged: (v) {
            _enableDone = !StringUtil.isEmpty(v);
            setState(() {});
          },
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            hintText: '输入名称',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
