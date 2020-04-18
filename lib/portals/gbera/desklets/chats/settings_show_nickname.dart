import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class ChatroomShowNickName extends StatefulWidget {
  PageContext context;

  ChatroomShowNickName({this.context});
  @override
  _ChatroomShowNickNameState createState() => _ChatroomShowNickNameState();
}

class _ChatroomShowNickNameState extends State<ChatroomShowNickName> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('显示昵称'),
      ),
      body: Container(),
    );
  }
}
