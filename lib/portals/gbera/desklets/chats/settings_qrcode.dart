import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chat_rooms.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChatroomQrcode extends StatefulWidget {
  PageContext context;

  ChatroomQrcode({this.context});

  @override
  _ChatroomQrcodeState createState() => _ChatroomQrcodeState();
}

class _ChatroomQrcodeState extends State<ChatroomQrcode> {
  ChatRoomModel _model;
  var qrcodeKey = GlobalKey();

  @override
  void initState() {
    _model = widget.context.parameters['model'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('二维码'),
        elevation: 0.0,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          bottom: 40,
        ),
        child: RepaintBoundary(
          key: qrcodeKey,
          child: QrImage(
            ///二维码数据
            data: jsonEncode({
              'itis': 'chatroom',
              'data': '${_model.chatRoom.creator}/${_model.chatRoom.id}',
            }),
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
//            embeddedImage: FileImage(
//              File(
//                _model.leading(widget.context.principal),
//              ),
//            ),
//            embeddedImageStyle: QrEmbeddedImageStyle(
//              size: Size(40, 40),
//            ),
          ),
        ),
      ),
    );
  }
}
