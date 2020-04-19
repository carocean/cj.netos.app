import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';

import 'chat_rooms.dart';

class PublishNotice extends StatefulWidget {
  PageContext context;

  PublishNotice({this.context});

  @override
  _PublishNoticeState createState() => _PublishNoticeState();
}

class _PublishNoticeState extends State<PublishNotice> {
  TextEditingController _controller;
  ChatRoomModel _model;
  bool _enableButton = false;

  @override
  void initState() {
    _model = widget.context.parameters['model'];
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publishNotice() async {
    IChatRoomRemote chatRoomRemote =
        widget.context.site.getService('/remote/chat/rooms');
    await chatRoomRemote.publishNotice(
      _model.chatRoom,
      _controller.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发布公告'),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            onPressed: !_enableButton
                ? null
                : () {
                    _enableButton = false;
                    setState(() {});
                    _publishNotice().then((v) {
                      widget.context.backward();
                    });
                  },
            child: Text(
              '发表',
              style: TextStyle(
                color: _enableButton ? Colors.green : null,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        child: TextField(
          controller: _controller,
          minLines: 1,
          maxLines: 10,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (v) {
            _enableButton = !StringUtil.isEmpty(v);
            setState(() {});
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            hintText: '输入文本...',
            fillColor: Colors.yellowAccent,
            filled: true,
          ),
        ),
      ),
    );
  }
}
