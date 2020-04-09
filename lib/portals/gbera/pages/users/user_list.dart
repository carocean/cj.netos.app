import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/local_principals.dart' as lp;

class UserAndAccountList extends StatelessWidget {
  PageContext context;

  UserAndAccountList({this.context});

  @override
  Widget build(BuildContext context) {
    var card_1 = Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Image.file(
                    File(
                      this.context.principal.avatarOnLocal,
                    ),
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 5,
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${this.context.principal.nickName}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 5,
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                    text: '用户号:',
                                  ),
                                  TextSpan(
                                    text: '${this.context.principal.uid}',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 5,
                              bottom: 2,
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                    text: '登录账号:',
                                  ),
                                  TextSpan(
                                    text:
                                        '${this.context.principal.accountCode}',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    var card_role = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                this.context.findPage('/users/roles')?.icon,
                size: 25,
                color: Colors.grey[500],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  this.context.findPage('/users/roles')?.title,
                  style: this.context.style('/profile/list/item-title.text'),
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
    var card_account = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                this.context.findPage('/users/accounts')?.icon,
                size: 25,
                color: Colors.grey[500],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  this.context.findPage('/users/accounts')?.title,
                  style: this.context.style('/profile/list/item-title.text'),
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
    var card_exitapp = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
              lp.IPlatformLocalPrincipalManager manager=this.context.site.getService('/local/principals');
              manager.emptyRefreshToken().then((v){
                this.context.forward('/public/entrypoint',scene: '/',clearHistoryByPagePath: '/');
              });

            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: Text(
                '退出登录',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        margin: EdgeInsets.only(
          top: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: card_1,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: card_account,
                    onTap: () {
                      this.context.forward('/users/accounts');
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: card_role,
                    onTap: () {
                      this.context.forward('/users/roles');
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: card_exitapp,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
