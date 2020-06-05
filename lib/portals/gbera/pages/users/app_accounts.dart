import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class AppAccounts extends StatefulWidget {
  PageContext context;

  AppAccounts({this.context});

  @override
  _AppAccountsState createState() => _AppAccountsState();
}

class _AppAccountsState extends State<AppAccounts> {
  @override
  Widget build(BuildContext context) {
    var app = widget.context.parameters['app'];
    print(app);
    return Scaffold(
      appBar: AppBar(
        title: Text('${app['appName']}'),
        elevation: 0,
      ),
      body: _CurrentAppCard(
        context: widget.context,
        app: app,
      ),
    );
  }
}

class _CurrentAppCard extends StatefulWidget {
  PageContext context;
  Map<String, dynamic> app;

  _CurrentAppCard({this.context, this.app});

  @override
  __CurrentAppCardState createState() => __CurrentAppCardState();
}

class __CurrentAppCardState extends State<_CurrentAppCard> {
  List<dynamic> _myAccounts = [];

  @override
  void initState() {
    super.initState();
    _load().then((v) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _myAccounts.clear();
    super.dispose();
  }

  Future<void> _load() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listMyAccount',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {'appid': widget.app['appid']},
      onsucceed: ({rc, response}) {
        String json = rc['dataText'];
        List<dynamic> list = jsonDecode(json);
        _myAccounts.clear();
        _myAccounts.addAll(list);
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    for (var item in _myAccounts) {
      var account = item as Map<String, dynamic>;
      var _nameKindIcon;
      //0自定义；1为手机号；2为邮箱
      switch (account['nameKind']) {
        case 0:
          _nameKindIcon = Icon(
            Icons.verified_user,
            size: 14,
          );
          break;
        case 1:
          _nameKindIcon = Icon(
            Icons.phone,
            size: 14,
          );
          break;
        case 2:
          _nameKindIcon = Icon(
            Icons.email,
            size: 14,
          );
          break;
        default:
          print('暂不支持');
          break;
      }
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/users/accounts/viewer',
                arguments: {'account': account});
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Image.network(
                      '${account['avatar']}?accessToken=${widget.context.principal.accessToken}',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Text(
                          '${account['accountCode']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 5,
                            ),
                            child: _nameKindIcon,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 5,
                            ),
                            child: Text(
                              account['nickName'],
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  widget.context.principal.person == account['person']?
                    Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.red[400],
                    ):Container(width: 0,height: 0,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          child: Divider(
            height: 1,
            indent: 40,
          ),
        ),
      );
    }
    items.add(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.context.forward('/users/accounts/addAccount',
              arguments: {'app': widget.app}).then((v) {
            _myAccounts.clear();
            _load().then((v) {
              setState(() {});
            });
          });
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '添加新账号',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 5,
              left: 10,
              right: 10,
            ),
            child: Text.rich(
              TextSpan(
                text: '当前应用:',
                children: [
                  TextSpan(
                    text: widget.app['appid'],
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  TextSpan(text: '下的账号'),
                ],
              ),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 10,
              right: 10,
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}
