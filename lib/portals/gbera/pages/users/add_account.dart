import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

class AddAccount extends StatefulWidget {
  PageContext context;

  AddAccount({this.context});

  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  String _selectType = 'password';
  TextEditingController _accountController;
  TextEditingController _passwordController;
  bool _buttonEnabled = false;
  String _addActionLabel = '确定';

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _checkButtonEnable() {
    return !StringUtil.isEmpty(_accountController.text) &&
        !StringUtil.isEmpty(_passwordController.text);
  }

  _doAddAccount() async {
    _addActionLabel = '添加中...';
    _buttonEnabled=false;
    setState(() {});
    var accountCode = _accountController.text;
    var password = _passwordController.text;
    var avatar = widget.context.principal.avatarOnRemote;
    var signture = widget.context.principal.signature;
    var nickName = widget.context.principal.nickName;
    var appid=widget.context.principal.appid;
    var app=widget.context.parameters['app'];
    if(app!=null) {
      appid=app['appid'];
    }
    var restcmd;
    dynamic params = {
      'password': password,
      'nickName': nickName,
      'avatar': avatar,
      'signature': signture,
      'appid':appid,
    };
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    switch (_selectType) {
      case 'password':
        restcmd = 'addByPassword';
        params['accountCode'] = accountCode;
        break;
      case 'phone':
        restcmd = 'addByIphone';
        params['phone'] = accountCode;
        break;
      case 'email':
        restcmd = 'addByEmail';
        params['email'] = accountCode;
        break;
    }
    await widget.context.ports.callback(
      headline,
      restCommand: restcmd,
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: params,
      onsucceed: ({rc, response}) {
        _addActionLabel = '确定';
        _buttonEnabled = false;
        widget.context.backward();
      },
      onerror: ({e, stack}) {
        print(e);
        _addActionLabel = '添加失败，请重试';
        _buttonEnabled = true;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var app = widget.context.parameters['app'];
    var appLogoUrl =
        '${app['appLogo']}?accessToken=${widget.context.principal.accessToken}';
    var card_face = Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: StringUtil.isEmpty(app['appLogo'])
                ? Image.asset(
                    'lib/portals/gbera/images/gbera.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    appLogoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Text('${app['appName']}'),
          ),
//          Padding(
//            padding: EdgeInsets.only(
//              bottom: 10,
//            ),
//            child: Text('gbera'),
//          ),
        ],
      ),
    );
    var _typeIcon;
    switch (_selectType) {
      case 'password':
        _typeIcon = Icon(
          Icons.verified_user,
          color: Colors.black54,
        );
        break;
      case 'phone':
        _typeIcon = Icon(
          Icons.phone,
          color: Colors.black54,
        );
        break;
      case 'email':
        _typeIcon = Icon(
          Icons.email,
          color: Colors.black54,
        );
        break;
    }
    var item_account_name = Container(
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: TextField(
          controller: _accountController,
          onChanged: ((v) {
            _buttonEnabled = _checkButtonEnable();
            setState(() {});
          }),
          keyboardType: TextInputType.text,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: _typeIcon,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 40,
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                              bottom: 15,
                            ),
                            child: Text(
                              '选择账号类型',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            children: <Widget>[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  widget.context
                                      .backward(result: {'type': 'password'});
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Icon(
                                          Icons.verified_user,
                                          size: 18,
                                        ),
                                      ),
                                      Text(
                                        '文本账号',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  widget.context
                                      .backward(result: {'type': 'phone'});
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Icon(
                                          FontAwesomeIcons.phone,
                                          size: 18,
                                        ),
                                      ),
                                      Text(
                                        '手机账号',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  widget.context
                                      .backward(result: {'type': 'email'});
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Icon(
                                          Icons.email,
                                          size: 18,
                                        ),
                                      ),
                                      Text(
                                        '邮箱账号',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ).then((v) {
                  if (v == null) {
                    return;
                  }
                  _selectType = v['type'];
                  setState(() {});
                });
              },
            ),
            hintText: '左边按钮选择账号类型',
          ),
        ),
      ),
    );

    var item_new_pwd = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: TextField(
          controller: _passwordController,
          onChanged: ((v) {
            _buttonEnabled = _checkButtonEnable();
            setState(() {});
          }),
          keyboardType: TextInputType.text,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: '密码',
            hintText: '输入密码',
          ),
        ),
      ),
    );
    var item_ok = Container(
      alignment: Alignment.center,
      color: _buttonEnabled ? Colors.green : Colors.grey[300],
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 10,
      ),
      child: Text(
        _addActionLabel,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: _buttonEnabled ? Colors.white : Colors.grey[400],
        ),
      ),
    );
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
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            card_face,
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/users/accounts/editPassword');
                  },
                  child: item_account_name,
                ),
                Divider(
                  height: 1,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/users/accounts/login');
                  },
                  child: item_new_pwd,
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: item_ok,
              onTap: !_buttonEnabled
                  ? null
                  : () {
                      _doAddAccount();
                    },
            ),
          ],
        ),
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
