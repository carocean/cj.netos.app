import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class Mine extends StatefulWidget {
  PageContext context;

  Mine({this.context});

  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onload() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/profile/editor').then((v) {});
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 30,
                top: 40,
                bottom: 30,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      child: Image.file(
                        File(
                          widget.context.principal.avatarOnLocal,
                        ),
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  Wrap(
                    direction: Axis.vertical,
                    spacing: 8,
                    children: <Widget>[
                      Text(
                        '${widget.context.principal.nickName}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '公号:',
                          children: [
                            TextSpan(
                              text: '${widget.context.principal.person}',
                            ),
                          ],
                        ),
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: CardItem(
                        title: '地商营业执照',
                        paddingLeft: 15,
                        paddingRight: 15,
                        onItemTap: () {},
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      child: CardItem(
                        title: '我的企业',
                        paddingLeft: 15,
                        paddingRight: 15,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      child: CardItem(
                        title: '所属运营商',
                        paddingLeft: 15,
                        paddingRight: 15,
                        onItemTap: () {},
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward('/public/login', scene: '/');
                      },
                      child: Text(
                        '切换登录账号',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
