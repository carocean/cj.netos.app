import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/nodepower/remote/uc_remote.dart';

class ColleagueViewer extends StatefulWidget {
  PageContext context;

  ColleagueViewer({this.context});

  @override
  _ColleagueViewerState createState() => _ColleagueViewerState();
}

class _ColleagueViewerState extends State<ColleagueViewer> {
  EasyRefreshController _controller;
  AppAcountOL _acountOL;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _acountOL = widget.context.parameters['account'];
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
    if (_acountOL == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Container(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 30,
              bottom: 30,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: StringUtil.isEmpty(_acountOL.avatar)
                      ? SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                            'lib/portals/gbera/images/default_avatar.png',
                            fit: BoxFit.fill,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: FadeInImage.assetNetwork(
                            placeholder:
                                'lib/portals/gbera/images/default_watting.gif',
                            image:
                                '${_acountOL.avatar}?accessToken=${widget.context.principal.accessToken}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,
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
                            text: '${_acountOL.accountId}',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: '个人签名:',
                        children: [
                          TextSpan(
                            text: '${_acountOL.signature??''}',
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
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: CardItem(
                    title: '项1',
                    leading: Icon(
                      Icons.account_balance_wallet,
                    ),
                    paddingLeft: 15,
                    paddingRight: 15,
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
                          title: '项2',
                          leading: Icon(
                            Icons.note,
                          ),
                          paddingLeft: 15,
                          paddingRight: 15,
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
                          title: '项3',
                          leading: Icon(
                            Icons.public,
                          ),
                          paddingLeft: 15,
                          paddingRight: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                                bottom: 20,
                              ),
                              child: Wrap(
                                direction: Axis.horizontal,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 10,
                                children: <Widget>[
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  Text(
                                    '发消息',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                            ),
                          ],
                        ),
                      ],
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
