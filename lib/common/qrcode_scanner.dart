import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:qrscan/qrscan.dart' as scanner;

QrcodeScanner qrcodeScanner = QrcodeScanner(
  actions: {},
);

class QrcodeScanner {
  final Map<String, QrcodeAction> actions;

  const QrcodeScanner({this.actions});

  void close() {
    actions.clear();
  }

  Future<void> scan(BuildContext buildContext, PageContext pageContext) async {
    String cameraScanResult = await scanner.scan();
    if (StringUtil.isEmpty(cameraScanResult)) {
      return;
    }
    String itis;
    String data;
    if (cameraScanResult.startsWith('{')) {
      var map = jsonDecode(cameraScanResult);
      itis = map['itis'];
      data = map['data'];
    } else {
      data = cameraScanResult;
      itis = 'unknown';
    }
    QrcodeAction action = actions[itis];
    if (action == null) {
      print('未处理的二维码扫描策略:$itis');
      return;
    }
    QrcodeInfo info=await action.parse(itis,data);
    showDialog(
      context: buildContext,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(info.title),
          content: info.tips,
          actions: <Widget>[
            FlatButton(
              child: Text(
                '是',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(['yes', action]);
              },
            ),
            FlatButton(
              child: Text(
                '否',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(['no', action]);
              },
            ),
          ],
          elevation: 20,
          semanticLabel: '',
          // 设置成 圆角
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    ).then((v) {
      var selected = v[0];
      QrcodeAction action = v[1];
      switch (selected) {
        case 'yes':
          if(action.doit!=null) {
            action.doit(info);
          }
          break;
        case 'no':
          break;
      }
    });
  }
}

class QrcodeAction {
  Future<QrcodeInfo> Function(String itis, String data) parse;
  Future<void> Function(QrcodeInfo info) doit;

  QrcodeAction({this.parse, this.doit});
}

class QrcodeInfo {
  String title;
  String itis;
  Widget tips;
  Map<String,dynamic> props;
  QrcodeInfo({this.itis, this.title, this.tips,this.props});
}
