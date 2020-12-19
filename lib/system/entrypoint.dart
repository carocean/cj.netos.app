import 'dart:async';

import 'package:accept_share/accept_share.dart';
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
  int _entrymode = 0; //0为背景；1登录主页；2为登录密码页；3为进入桌面
  @override
  void initState() {

    _checkEntrypoint().then((v) {
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _entrymode = 0;
    super.dispose();
  }

  Future<void> _checkEntrypoint() async {
    IPlatformLocalPrincipalManager _localPrincipalManager =
        widget.context.site.getService('/local/principals');
    if (_localPrincipalManager.isEmpty()) {
      _entrymode = 1;
      return;
    }
    await _localPrincipalManager.setCurrent(_localPrincipalManager.list()[0]);
    var localPrincipal =
        _localPrincipalManager.get(_localPrincipalManager.current()); //以此作为登录用户
    if (localPrincipal?.refreshToken == null) {
      //如果刷新令牌为空则必须登录
      _entrymode = 2;
      return;
    }
    //有刷新令牌是否过期
    await _localPrincipalManager.doRefreshToken((map) async {
      //失败则重新登录
      await _localPrincipalManager.emptyRefreshToken();
      _entrymode = 2;
    }, (v) {
      _entrymode = 3;
    });

    if (_entrymode != 3) {
      return;
    }
    await _localPrincipalManager.online();
    //成功则到桌面
    WidgetsBinding.instance.addPostFrameCallback((d) {
      widget.context.forward(
        "/",
        clearHistoryByPagePath: '/public/',
        scene: widget.context.principal.portal??'gbera',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_entrymode) {
      case 1:
        return _EntryPointIndex(
          context: widget.context,
        );
      case 2:
        return LoginPage(
          context: widget.context,
        );
      default:
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('lib/portals/gbera/images/entrypoint_bk.jpg'),
            ),
          ),
        );
    }
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
                  this.context.forward('/public/login');
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
                  this.context.forward('/public/register');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
