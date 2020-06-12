import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class LandagentEventDetails extends StatefulWidget {
  PageContext context;

  LandagentEventDetails({this.context});

  @override
  _LandagentEventDetailsState createState() => _LandagentEventDetailsState();
}

class _LandagentEventDetailsState extends State<LandagentEventDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '平台通知',
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(
                  left: 50,
                  right: 50,
                ),
                constraints: BoxConstraints(
                  maxHeight: 200,
                ),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  child: Text(
                    '请签账比变更协议！请签账比变更协议！请签账比变更协议！请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n请签账比变更协议！\r\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            alignment: Alignment.center,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            color: Colors.white,
            child: FlatButton(
              onPressed: () {},
              child: Text(
                '同意',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
