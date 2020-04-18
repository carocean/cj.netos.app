import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class ChatroomSetNotice extends StatefulWidget {
  PageContext context;

  ChatroomSetNotice({this.context});
  @override
  _ChatroomSetNoticeState createState() => _ChatroomSetNoticeState();
}

class _ChatroomSetNoticeState extends State<ChatroomSetNotice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发布公告'),
      ),
      body: Container(),
    );
  }
}
