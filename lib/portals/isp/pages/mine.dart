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
            onTap: (){
              widget.context.forward('/profile/editor', scene: 'gbera');
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
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: CardItem(
                        title: '钱包',
                        leading: Icon(
                          Icons.account_balance_wallet,
                        ),
                        paddingLeft: 15,
                        paddingRight: 15,
                        onItemTap: () {
                          widget.context.forward(
                            '/wallet',
                            scene: 'gbera',
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: CardItem(
                              title: '用户与账号',
                              leading: Icon(
                                Icons.note,
                              ),
                              paddingLeft: 15,
                              paddingRight: 15,
                              onItemTap: () {
                                widget.context
                                    .forward('/users/list', scene: 'gbera');
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                            child: Divider(
                              height: 1,
                              indent: 50,
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: CardItem(
                              title: '系统设置',
                              leading: Icon(
                                Icons.public,
                              ),
                              paddingLeft: 15,
                              paddingRight: 15,
                              onItemTap: () {
                                widget.context.forward('/system/settings',
                                    scene: 'gbera');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward('/public/login', scene: '/');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF4511E),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xFF4511E),
                                offset: Offset(-4.0, 3.0), //阴影xy轴偏移量
                                blurRadius: 8.0, //阴影模糊程度
                                spreadRadius: 1.0 //阴影扩散程度
                            ),
                          ],
                        ),
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Text(
                          '切换登录账号',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
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
