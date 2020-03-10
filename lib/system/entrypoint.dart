import 'dart:async';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

import 'local/local_principals.dart';
import 'login.dart';

class EntryPoint extends StatefulWidget {
  PageContext context;

  EntryPoint({this.context});

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  IPlatformLocalPrincipalManager _localPrincipalManager;
  Future<void> _future_refreshToken;
  @override
  void initState() {
    super.initState();
    _localPrincipalManager =
        widget.context.site.getService('/local/principals');
    if(!_localPrincipalManager.isEmpty()) {
      _localPrincipalManager.setCurrent(_localPrincipalManager.list()[0]);
    }
  }

  @override
  void dispose() {
    _localPrincipalManager=null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var body;

    //没有本地登录历史则进去入口索引页
    if (_localPrincipalManager.isEmpty()) {
      //加载主入口部件（有登录和注册选项）
      body = _EntryPointIndex(
        context: widget.context,
      );
      return body;
    }
//    _localPrincipalManager.setCurrent(_localPrincipalManager.list()[0]);

    var localPrincipal =
        _localPrincipalManager.get(_localPrincipalManager.current()); //以此作为登录用户
    //如果刷新令牌为空则必须登录
    if (localPrincipal?.refreshToken == null) {
      body = LoginPage(
        context: widget.context,
      );
      return body;
    }
    if(_future_refreshToken==null) {
      _future_refreshToken=_refreshToken();
//      print('~~~~~~~~');
    }
    //有刷新令牌自动登录
    return FutureBuilder(
      future: _future_refreshToken,
      builder: (ctx, snapshot) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('lib/portals/gbera/images/entrypoint_bk.jpg'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshToken() async {
    await _localPrincipalManager.doRefreshToken((map) async {
      //失败则重新登录
      await _localPrincipalManager.emptyRefreshToken();
//      Future.delayed(
//          Duration(
//            milliseconds: 300,
//          ), () {
//        widget.context.forward('/entrypoint');
//      });
    }, (v) {
      //成功则到桌面
      WidgetsBinding.instance.addPostFrameCallback((d){
        widget.context.forward("/scaffold/withbottombar",
            clearHistoryByPagePath: '/',scene: 'gbera',);
      });
//      Future.delayed(
//          Duration(
//            milliseconds: 300,
//          ), () {
//        widget.context.forward("/scaffold/withbottombar",
//            clearHistoryByPagePath: '/',scene: 'gbera',);
//      });
    });
  }
}

class _EntryPointIndex extends StatelessWidget {
  PageContext context;

  _EntryPointIndex({this.context});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('lib/portals/gbera/images/entrypoint_bk.jpg'),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButton(
                color: Colors.green,
                hoverColor: Colors.grey[100],
                padding: EdgeInsets.only(
                  left: 45,
                  right: 45,
                  top: 12,
                  bottom: 12,
                ),
                child: Text(
                  '登录',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  this.context.forward('/login');
                },
              ),
              FlatButton(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 45,
                  right: 45,
                  top: 12,
                  bottom: 12,
                ),
                child: Text(
                  '注册',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
                onPressed: () {
                  this.context.forward('/register');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
