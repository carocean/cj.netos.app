import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChannelQrcode extends StatelessWidget {
  PageContext context;
  var qrcodeKey = GlobalKey();

  ChannelQrcode({this.context});

  @override
  Widget build(BuildContext context) {
    Channel _channel = this.context.parameters['channel'];
    var bb = this.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: Container(
        alignment: Alignment.center,
        child: RepaintBoundary(
          key: qrcodeKey,
          child: QrImage(
            ///二维码数据
            data: "1234567890",
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
            embeddedImage: FileImage(
              File(
                _channel.leading,
              ),
            ),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(40, 40),
            ),
          ),
        ),
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        this.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
