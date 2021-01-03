import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

class Accounts extends StatefulWidget {
  PageContext context;

  Accounts({this.context});

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  Map<String, dynamic> _currentApp = {};

  @override
  void initState() {
    super.initState();
    _load().then((v) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _currentApp.clear();
    super.dispose();
  }

  _load() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'getAppInfo',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      onsucceed: ({rc, response}) {
        String json = rc['dataText'];
        Map<String, dynamic> obj = jsonDecode(json);
        _currentApp.clear();
        _currentApp.addAll(obj);
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var bb = widget.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _CurrentAppCard(
            context: widget.context,
            app: _currentApp,
          ),
          _OtherAppCard(
            context: widget.context,
            app: _currentApp,
          ),
        ],
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        widget.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
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
      parameters: {'appid': widget.context.principal.appid},
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
                  widget.context.principal.person == account['person']
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.red[400],
                        )
                      : Container(
                          height: 0,
                          width: 0,
                        ),
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
                text: '',
                children: [
                  TextSpan(
                    text: widget.app['appName'],
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
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

class _OtherAppCard extends StatefulWidget {
  PageContext context;
  Map<String, dynamic> app;

  _OtherAppCard({this.context, this.app});

  @override
  __OtherAppCardState createState() => __OtherAppCardState();
}

class __OtherAppCardState extends State<_OtherAppCard> {
  List<dynamic> _applist = [];
  int _offset = 0;
  int _limit = 10;

  @override
  void initState() {
    super.initState();
    _load().then((v) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _applist.clear();
    super.dispose();
  }

  _load() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listAppInfo',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'offset': '$_offset',
        'limit': '$_limit',
      },
      onsucceed: ({rc, response}) {
        String json = rc['dataText'];
        List<dynamic> list = jsonDecode(json);
        _applist.addAll(list);
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var principal = widget.context.principal;
    List<dynamic> apps = _getRightsApps(principal);
    if (apps.isEmpty) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    var items = <Widget>[];
    for (var app in apps) {
      var appLogoUrl =
          '${app['appLogo']}?accessToken=${widget.context.principal.accessToken}';
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context
                .forward('/users/accounts/app', arguments: {'app': app});
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: StringUtil.isEmpty(app['appLogo'])
                            ? Image.asset(
                                'lib/portals/gbera/images/gbera.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                appLogoUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Text(
                                app['appName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 5,
                                  ),
                                  child: Text(
                                    '${app['appid']}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
//                              Expanded(
//                                child: Padding(
//                                  padding: EdgeInsets.only(
//                                    right: 5,
//                                  ),
//                                  child: Text.rich(
//                                    TextSpan(
//                                      text: '${app['tenantName']}',
//                                      style: TextStyle(
//                                        color: Colors.grey[500],
//                                      ),
//                                    ),
//                                    softWrap: true,
//                                  ),
//                                ),
//                              ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
      items.add(
        Divider(
          height: 1,
          indent: 35,
        ),
      );
    }
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
            child: Text(
              '其它应用账号',
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

  List _getRightsApps(UserPrincipal principal) {
    var apps = [];
    apps.addAll(_applist);
    print(principal.roles);
    apps.removeWhere((element) => element['appid'] == principal.appid);
    if (!principal.roles.contains('app:users@la.netos')) {
      apps.removeWhere((element) => element['appid'] == 'la.netos');
    }
    if (!principal.roles.contains('app:users@isp.netos')) {
      apps.removeWhere((element) => element['appid'] == 'isp.netos');
    }
    if (!principal.roles.contains('platform:administrators')) {
      apps.removeWhere((element) => element['appid'] == 'system.netos');
    }
    return apps;
  }
}
