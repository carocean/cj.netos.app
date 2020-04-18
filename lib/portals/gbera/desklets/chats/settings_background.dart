import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class ChatroomSetBackground extends StatefulWidget {
  PageContext context;

  ChatroomSetBackground({this.context});

  @override
  _ChatroomSetBackgroundState createState() => _ChatroomSetBackgroundState();
}

class _ChatroomSetBackgroundState extends State<ChatroomSetBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置背景'),
      ),
      body: Container(),
    );
  }
}
