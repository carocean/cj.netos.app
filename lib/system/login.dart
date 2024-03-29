import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_app_keypair.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/system/local/local_principals.dart';
import 'package:netos_app/system/system.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  PageContext context;

  LoginPage({this.context});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginMethod _loginMethod = _LoginMethod.password;
  List<Principal> _localPrincipals = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    IPlatformLocalPrincipalManager _localPrincipalManager =
        widget.context.site.getService('/local/principals');
    List<String> list = _localPrincipalManager.list();
    for (String person in list) {
      _localPrincipals.add(_localPrincipalManager.get(person));
    }
    if (!_localPrincipals.isEmpty && _localPrincipals[0].accessToken != null) {
      _loginMethod = _LoginMethod.existsAccount;
    }

    weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
      if (res is WeChatAuthResponse) {
        //返回的res.code就是授权code
        _doWechatAuthLogin(res);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _doWechatAuthLogin(WeChatAuthResponse res) async {
    if(res.errCode!=0) {
      forwardError('验证失败');
      return;
    }
    AppKeyPair appKeyPair = widget.context.site.getService('@.appKeyPair');
    var _appid = 'gbera.netos';
    if (StringUtil.isEmpty(_appid)) {
      _appid = widget.context.site.getService('@.prop.entrypoint.app');
    }
    appKeyPair = await appKeyPair.getAppKeyPair(_appid, widget.context.site);
    var nonce =
        MD5Util.MD5('${Uuid().v1()}${DateTime.now().millisecondsSinceEpoch}');
    await widget.context.ports.callback(
      'post ${widget.context.site.getService('@.prop.ports.uc.auth')} http/1.1',
      restCommand: 'authByWeChat',
      headers: {
        'app-id': appKeyPair.appid,
        'app-key': appKeyPair.appKey,
        'app-nonce': nonce,
        'app-sign': appKeyPair.appSign(nonce),
      },
      content: {
        "code": res.code,
        "state": res.state,
        "device": appKeyPair.device,
      },
      onsucceed: ({dynamic rc, dynamic response}) {
        forwardOK(rc);
      },
      onerror: ({e, stack}) {
        forwardError(e);
      },
      onReceiveProgress: (i, j) {
        print('$i-$j');
      },
    );
  }

  void forwardOK(rc) async {
    var map = jsonDecode(rc['dataText']);

    Map<String, dynamic> subject = map['subject'];
    Map<String, dynamic> token = map['token'];

    IPlatformLocalPrincipalManager manager =
        widget.context.site.getService('/local/principals');
    var list = subject['roles'];
    var roles = <String>[];
    for (var r in list) {
      roles.add(r);
    }
    Dio dio = widget.context.site.getService('@.http');
    String localAvatarFile = await downloadPersonAvatar(
        dio: dio,
        avatarUrl: '${subject['avatar']}?accessToken=${token['accessToken']}');
    await manager.add(
      subject['person'],
      ltime: DateTime.now().millisecondsSinceEpoch,
      expiretime: token['expireTime'],
      pubtime: token['pubTime'],
      signature: subject['signature'],
      remoteAvatar: '${subject['avatar']}',
      localAvatar: localAvatarFile,
      refreshToken: token['refreshToken'],
      accessToken: token['accessToken'],
      roles: roles,
      appid: subject['appid'],
      nickName: subject['nickName'],
      accountCode: subject['accountCode'],
      uid: subject['uid'],
      portal: map['portal'],
      device: token['device'],
    );
    await manager.setCurrent(subject['person']);
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    //下面调用的作用是：将登录号声明为公众的第一个用户缓冲起来
    if (!(await personService.existsPerson(subject['person']))) {
      await personService.addPerson(Person(
        subject['person'],
        subject['uid'],
        subject['accountCode'],
        subject['appid'],
        localAvatarFile,
        null,
        subject['nickName'],
        subject['signature'],
        PinyinHelper.getPinyin(subject['nickName']),
        subject['person'],
      ));
    }
    widget.context.forward("/",
        clearHistoryByPagePath: '/', scene: map['portal'] ?? 'gbera');
  }

  void forwardError(e) {
    widget.context.forward(
      "/error",
      arguments: {
        'error': e,
      },
      clearHistoryByPagePath: '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    var method;

    ///检测本地存有头像和账号则按第3种模式显示（_LoginMethod.existsAccount)
    switch (_loginMethod) {
      case _LoginMethod.password:
        method = _PasswordPanel(
          context: widget.context,
          onSwitchToVerifyCode: () {
            _loginMethod = _LoginMethod.verifyCode;
            setState(() {});
          },
          onSwitchToWechat: () {
            sendWeChatAuth(
              scope: "snsapi_userinfo",
              state: "${Uuid().v1()}",
            );
            _loginMethod = _LoginMethod.wechat;
            setState(() {});
          },
        );
        break;
      case _LoginMethod.verifyCode:
        method = _VerifyCodePanel(
          context: widget.context,
          onSwitchToPassword: () {
            if (_localPrincipals.isEmpty) {
              _loginMethod = _LoginMethod.password;
            } else {
              _loginMethod = _LoginMethod.existsAccount;
            }
            setState(() {});
          },
        );
        break;
      case _LoginMethod.existsAccount:
        method = _ExistsAccountPanel(
          context: widget.context,
          principals: _localPrincipals,
          onSwitchToVerifyCode: () {
            _loginMethod = _LoginMethod.verifyCode;
            setState(() {});
          },
          onSwitchToWechat: () {
            sendWeChatAuth(
              scope: "snsapi_userinfo",
              state: "${Uuid().v1()}",
            );
            _loginMethod = _LoginMethod.wechat;
            setState(() {});
          },
        );
        break;
      case _LoginMethod.wechat:
        method = _WechatPanel();
        break;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      resizeToAvoidBottomPadding: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          method,
          Positioned(
            bottom: 0,
            left: 10,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Padding(
                //   padding: EdgeInsets.only(
                //     bottom: 10,
                //   ),
                //   child: Text.rich(
                //     TextSpan(
                //       text: '节点动力',
                //       style: TextStyle(
                //         color: Colors.blueGrey,
                //       ),
                //       recognizer: TapGestureRecognizer()
                //         ..onTap = () {
                //           widget.context.forward('/system/about');
                //         },
                //     ),
                //   ),
                // ),
                /*
                FlatButton(
                  child: Text('找回密码'),
                  textColor: Colors.blueGrey,
                  onPressed: () {},
                ),
                SizedBox(
                  height: 14,
                  child: VerticalDivider(
                    width: 1,
                    color: Colors.grey[500],
                  ),
                ),
                FlatButton(
                  child: Text('紧急冻结'),
                  textColor: Colors.blueGrey,
                  onPressed: () {},
                ),

                 */
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _LoginMethod {
  password,
  verifyCode,
  wechat,
  existsAccount,
}

class _WechatPanel extends StatefulWidget {
  @override
  __WechatPanelState createState() => __WechatPanelState();
}

class __WechatPanelState extends State<_WechatPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            '正在使用微信登录，请稍候...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordPanel extends StatefulWidget {
  Function() onSwitchToVerifyCode;
  Function() onSwitchToWechat;
  PageContext context;

  _PasswordPanel(
      {this.onSwitchToVerifyCode, this.onSwitchToWechat, this.context});

  @override
  __PasswordPanelState createState() => __PasswordPanelState();
}

class __PasswordPanelState extends State<_PasswordPanel> {
  TextEditingController _accountController;
  TextEditingController _passwordController;
  bool _buttonEnabled = false;
  bool _showPassword = false;
  String _loginLabel = '登录';

  @override
  void initState() {
    _accountController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _buttonEnabled = false;
    super.dispose();
  }

  bool _checkRegister() {
    return !StringUtil.isEmpty(_passwordController.text) &&
        !StringUtil.isEmpty(_accountController.text);
  }

  _doLogin() {
    _loginLabel = '登录中...';
    _buttonEnabled = false;
    setState(() {});
    var login = PasswordLoginAction(
        context: widget.context,
        pwd: _passwordController.text,
        user: _accountController.text);
    login.login(null, () {
      _loginLabel = '登录';
      _buttonEnabled = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left: 20,
          ),
          child: Text(
            '公号/手机号/用户号/邮箱登录',
            softWrap: true,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 70,
                child: Text(
                  '账号',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _accountController,
                  onChanged: (v) {
                    _buttonEnabled = _checkRegister();
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '请填写公号/手机号/用户号/邮箱',
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 70,
                child: Text(
                  '密码',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  onChanged: (v) {
                    _buttonEnabled = _checkRegister();
                    setState(() {});
                  },
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '请填写密码',
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.all(10),
                    suffix: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _showPassword = !_showPassword;
                        setState(() {});
                      },
                      child: Icon(
                        !_showPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        useSimpleLayout()?SizedBox.shrink():
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 5,
            top: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSwitchToWechat,
                  child: Text(
                    '以微信方式登录',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSwitchToVerifyCode,
                  child: Text(
                    '用短信验证码登录',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: !_buttonEnabled
              ? null
              : () {
                  _doLogin();
                },
          child: Container(
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _buttonEnabled ? Colors.green[300] : Colors.grey[300],
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              _loginLabel,
              style: TextStyle(
                fontSize: 18,
                color: _buttonEnabled ? Colors.white : Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifyCodePanel extends StatefulWidget {
  PageContext context;
  Function() onSwitchToPassword;

  _VerifyCodePanel({this.context, this.onSwitchToPassword});

  @override
  __VerifyCodePanelState createState() => __VerifyCodePanelState();
}

class __VerifyCodePanelState extends State<_VerifyCodePanel> {
  TextEditingController _phoneController;
  TextEditingController _codeController;
  bool _buttonEnabel = false;
  String _loginLabel = '登录';
  bool sendOk = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _buttonEnabel = false;
    super.dispose();
  }

  bool _checkButtonEnabel() {
    return !StringUtil.isEmpty(_codeController.text) &&
        !StringUtil.isEmpty(_phoneController.text) &&
        _codeController.text.length == 6 &&
        sendOk;
  }

  _doLogin() {
    _loginLabel = '登录中...';
    _buttonEnabel = false;
    setState(() {});
    PasswordLoginAction(
        context: widget.context,
        pwd: _codeController.text,
        user: _phoneController.text)
      ..login(null, () {
        _loginLabel = '登录中...';
        _buttonEnabel = false;
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left: 20,
          ),
          child: Text(
            '手机号登录',
            softWrap: true,
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 70,
                child: Text(
                  '手机号',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  onChanged: (v) {
                    _buttonEnabel = _checkButtonEnabel();
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '请填写手机号',
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 70,
                      child: Text(
                        '验证码',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        onChanged: (v) {
                          _buttonEnabel = _checkButtonEnabel();
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '请填写短信验证码',
                          hintStyle: TextStyle(
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _VerifyCodeButton(
                context: widget.context,
                phoneController: _phoneController,
                onerror: () {
                  sendOk = false;
                  _buttonEnabel = _checkButtonEnabel();
                  setState(() {});
                },
                onsussed: () {
                  sendOk = true;
                  _buttonEnabel = _checkButtonEnabel();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSwitchToPassword,
                  child: Text(
                    '用密码登录',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _doLogin,
          child: Container(
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _buttonEnabel ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              _loginLabel,
              style: TextStyle(
                fontSize: 18,
                color: _buttonEnabel ? Colors.white : Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExistsAccountPanel extends StatefulWidget {
  Function() onSwitchToVerifyCode;
  Function() onSwitchToWechat;
  PageContext context;
  List<Principal> principals;

  _ExistsAccountPanel(
      {this.onSwitchToVerifyCode,
      this.onSwitchToWechat,
      this.context,
      this.principals});

  @override
  __ExistsAccountPanelState createState() => __ExistsAccountPanelState();
}

class __ExistsAccountPanelState extends State<_ExistsAccountPanel> {
  TextEditingController _passwordController;
  bool _buttonEnabled = false;
  bool _showPassword = false;
  String _loginLabel = '登录';
  Principal _principal;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _principal = widget.principals[0];
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 30,
            top: 30,
          ),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
                child: Image.file(
                  File(_principal.lavatar),
                  width: 70,
                  height: 70,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  '${_principal.person}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Text(
                  '${_principal.nickName}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        widget.principals.length < 2
            ? SizedBox(
                height: 0,
                width: 0,
              )
            : Stack(
                fit: StackFit.passthrough,
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      left: 40,
                      right: 40,
                    ),
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 10,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Wrap(
                      runSpacing: 12,
                      children: widget.principals.map((e) {
                        if (e.person == _principal.person) {
                          return SizedBox(
                            width: 0,
                            height: 0,
                          );
                        }
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _principal = e;
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              right: 5,
                            ),
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: <Widget>[
                                Image.file(
                                  File(e.lavatar),
                                  width: 16,
                                  height: 16,
                                ),
                                Text(
                                  '${e.nickName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: -14,
                    child: Text(
                      '其它公号',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 20,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 70,
                child: Text(
                  '密码',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  onChanged: (v) {
                    _buttonEnabled = !StringUtil.isEmpty(v);
                    setState(() {});
                  },
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '请填写密码',
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.all(10),
                    suffix: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _showPassword = !_showPassword;
                        setState(() {});
                      },
                      child: Icon(
                        !_showPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        useSimpleLayout()?SizedBox.shrink():
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 5,
            top: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSwitchToWechat,
                  child: Text(
                    '以微信方式登录',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSwitchToVerifyCode,
                  child: Text(
                    '用短信验证码登录',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: !_buttonEnabled
              ? null
              : () {
                  _doLogin(_principal);
                },
          child: Container(
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _buttonEnabled ? Colors.green[300] : Colors.grey[300],
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              _loginLabel,
              style: TextStyle(
                fontSize: 18,
                color: _buttonEnabled ? Colors.white : Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _doLogin(Principal principal) async {
    _loginLabel = '登录中...';
    _buttonEnabled = false;
    setState(() {});
    var login = PasswordLoginAction(
      context: widget.context,
      pwd: _passwordController.text,
      user: principal.accountCode,
    );
    login.login(principal.appid, () {
      _loginLabel = '登录';
      _buttonEnabled = true;
      setState(() {});
    });
  }
}

class PasswordLoginAction {
  final String user;
  final String pwd;
  final PageContext context;

  const PasswordLoginAction({this.user, this.pwd, this.context});

  login(String appid, [callback]) async {
    int pos = user.lastIndexOf("@");
    var account = '';
    if (pos < 0) {
      account = user;
    } else {
      account = user.substring(0, pos);
    }
    AppKeyPair appKeyPair = this.context.site.getService('@.appKeyPair');
    var _appid = appid;
    if (StringUtil.isEmpty(_appid)) {
      _appid = this.context.site.getService('@.prop.entrypoint.app');
    }
    appKeyPair = await appKeyPair.getAppKeyPair(_appid, this.context.site);
    var nonce =
        MD5Util.MD5('${Uuid().v1()}${DateTime.now().millisecondsSinceEpoch}');
    await context.ports.callback(
      'get ${context.site.getService('@.prop.ports.uc.auth')} http/1.1',
      restCommand: 'auth',
      headers: {
        'app-id': appKeyPair.appid,
        'app-key': appKeyPair.appKey,
        'app-nonce': nonce,
        'app-sign': appKeyPair.appSign(nonce),
      },
      parameters: {
        "accountCode": account,
        "password": pwd,
        "device": appKeyPair.device,
      },
      onsucceed: ({dynamic rc, dynamic response}) {
        forwardOK(rc);
      },
      onerror: ({e, stack}) {
        if (callback != null) {
          callback();
        }
        forwardError(e);
      },
      onReceiveProgress: (i, j) {
        print('$i-$j');
      },
    );
  }

  void forwardOK(rc) async {
    var map = jsonDecode(rc['dataText']);

    Map<String, dynamic> subject = map['subject'];
    Map<String, dynamic> token = map['token'];

    IPlatformLocalPrincipalManager manager =
        context.site.getService('/local/principals');
    var list = subject['roles'];
    var roles = <String>[];
    for (var r in list) {
      roles.add(r);
    }
    Dio dio = context.site.getService('@.http');
    String localAvatarFile = await downloadPersonAvatar(
        dio: dio,
        avatarUrl: '${subject['avatar']}?accessToken=${token['accessToken']}');
    await manager.add(
      subject['person'],
      ltime: DateTime.now().millisecondsSinceEpoch,
      expiretime: token['expireTime'],
      pubtime: token['pubTime'],
      signature: subject['signature'],
      remoteAvatar: '${subject['avatar']}',
      localAvatar: localAvatarFile,
      refreshToken: token['refreshToken'],
      accessToken: token['accessToken'],
      roles: roles,
      appid: subject['appid'],
      nickName: subject['nickName'],
      accountCode: subject['accountCode'],
      uid: subject['uid'],
      portal: map['portal'],
      device: token['device'],
    );
    await manager.setCurrent(subject['person']);
    IPersonService personService =
        this.context.site.getService('/gbera/persons');
    //下面调用的作用是：将登录号声明为公众的第一个用户缓冲起来
    if (!(await personService.existsPerson(subject['person']))) {
      await personService.addPerson(Person(
        subject['person'],
        subject['uid'],
        subject['accountCode'],
        subject['appid'],
        localAvatarFile,
        null,
        subject['nickName'],
        subject['signature'],
        PinyinHelper.getPinyin(subject['nickName']),
        subject['person'],
      ));
    }
    context.forward("/",
        clearHistoryByPagePath: '/', scene: map['portal'] ?? 'gbera');
  }

  void forwardError(e) {
    context.forward(
      "/error",
      arguments: {
        'error': e,
      },
    );
  }
}

class _VerifyCodeButton extends StatefulWidget {
  PageContext context;
  TextEditingController phoneController;
  Function() onsussed;
  Function onerror;

  _VerifyCodeButton(
      {this.context, this.phoneController, this.onerror, this.onsussed});

  @override
  __VerifyCodeButtonState createState() => __VerifyCodeButtonState();
}

class __VerifyCodeButtonState extends State<_VerifyCodeButton> {
  String _fetchCodeLabel = '获取验证码';
  bool _fetchButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.phoneController.addListener(() {
      _fetchButtonEnabled = !StringUtil.isEmpty(widget.phoneController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _requestCode() async {
    _fetchCodeLabel = '获取中...';
    _fetchButtonEnabled = false;
    setState(() {});
    AppKeyPair appKeyPair = widget.context.site.getService('@.appKeyPair');
    var appid = widget.context.principal.appid;
    if (appid == null) {
      appid = 'gbera.netos';
    }
    appKeyPair = await appKeyPair.getAppKeyPair(appid, widget.context.site);
    var nonce = MD5Util.MD5(Uuid().v1());
    await widget.context.ports.callback(
      'get ${widget.context.site.getService('@.prop.ports.uc.auth')} http/1.1',
      restCommand: 'sendVerifyCode',
      headers: {
        'app-id': appKeyPair.appid,
        'app-key': appKeyPair.appKey,
        'app-nonce': nonce,
        'app-sign': appKeyPair.appSign(nonce),
      },
      parameters: {
        "phone": widget.phoneController.text,
      },
      onsucceed: ({dynamic rc, dynamic response}) {
        print(rc);
        _fetchCodeLabel = '获取成功';
        if (widget.onsussed != null) {
          widget.onsussed();
        }
        var times = 60;
        Timer.periodic(Duration(milliseconds: 1000), (t) {
          if (times == 0) {
            t.cancel();
            _fetchCodeLabel = '重新获取';
            _fetchButtonEnabled = true;
            if (super.mounted) {
              setState(() {});
            }
            return;
          }
          _fetchCodeLabel = '等待..${times}s';
          times--;
          if (super.mounted) {
            setState(() {});
          }
        });
      },
      onerror: ({e, stack}) {
        print(e);
        _fetchCodeLabel = '重新获取';
        _fetchButtonEnabled = true;
        if (widget.onerror != null) {
          widget.onerror();
        }
        setState(() {});
      },
      onReceiveProgress: (i, j) {
        print('$i-$j');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: !_fetchButtonEnabled ? null : _requestCode,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 7,
          bottom: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Text(
          _fetchCodeLabel,
          style: TextStyle(
            color: !_fetchButtonEnabled ? Colors.grey[400] : Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
