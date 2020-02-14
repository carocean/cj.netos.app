import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qrcode extends StatelessWidget {
  PageContext context;
  var qrcodeKey = GlobalKey();

  Qrcode({this.context});

  @override
  Widget build(BuildContext context) {
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
            data: "{'data':'${this.context.principal.person}','type':'person'}",
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
            embeddedImage: FileImage(
              File(
                this.context.principal.avatarOnLocal,
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
