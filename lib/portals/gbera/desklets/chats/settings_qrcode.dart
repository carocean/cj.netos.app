import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class ChatroomQrcode extends StatefulWidget {
  PageContext context;

  ChatroomQrcode({this.context});
  @override
  _ChatroomQrcodeState createState() => _ChatroomQrcodeState();
}

class _ChatroomQrcodeState extends State<ChatroomQrcode> {
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
