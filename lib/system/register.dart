import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/local_principals.dart' as lp;
import 'package:netos_app/system/system.dart';
import 'package:uuid/uuid.dart';

import 'local/entities.dart';
import 'local/local_principals.dart';

class RegisterPage extends StatefulWidget {
  PageContext context;

  RegisterPage({this.context});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agree = false;
  TextEditingController _nickNameController;
  TextEditingController _phoneController;
  TextEditingController _passwordController;
  String _avatarRemoteFile;
  String _localAvatarFile;
  bool _buttonEnabled = false;
  bool _showPassword = false;
  String _anonymousAccessToken;
  String _registerLabel = '注册';
  GlobalKey<ScaffoldState> _globalKey=GlobalKey();
  @override
  void initState() {
    super.initState();
    _nickNameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _anonymous().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
      if (res is WeChatAuthResponse) {
        //返回的res.code就是授权code
        _doWechatAuthLogin(res);
      }
    });
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

  Future<void> _anonymous() async {
    AppKeyPair appKeyPair = widget.context.site.getService('@.appKeyPair');
    var nonce = MD5Util.MD5(Uuid().v1()).toUpperCase();
    String sign = appKeyPair.appSign(nonce);
    await widget.context.ports.callback(
      'get ${widget.context.site.getService('@.prop.ports.uc.auth')} http/1.1',
      restCommand: 'auth',
      headers: {
        'App-Id': appKeyPair.appid,
        'App-Key': appKeyPair.appKey,
        'App-Nonce': nonce,
        'App-Sign': sign,
      },
      parameters: {
        'device': appKeyPair.device,
        'password': '*_anonymous',
        'accountCode': '#_anonymous',
      },
      onerror: ({e, stack}) {
        print('-----$e');
      },
      onsucceed: ({rc, response}) {
        var json = rc['dataText'];
        Map<String, Object> map = jsonDecode(json);
        _anonymousAccessToken =
            (map['token'] as Map<String, dynamic>)['accessToken'];
      },
    );
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _buttonEnabled = false;
    _showPassword = false;
    super.dispose();
  }
  var _showed=<String,bool>{};
  void _showSnack(text){
    if(_showed.containsKey(text)){
      return;
    }
    _showed[text]=true;
    _globalKey.currentState.showSnackBar(SnackBar(content: Text('$text'),backgroundColor: Colors.red,),);
  }
  bool _checkRegister() {
    if(!StringUtil.isEmpty(_nickNameController.text) &&
        !StringUtil.isEmpty(_phoneController.text) &&
        !StringUtil.isEmpty(_passwordController.text)){
      if(!_agree&&StringUtil.isEmpty(_avatarRemoteFile)){
        _showSnack('请勾选已同意，并且设置头像');
        _showed.remove('请勾选已同意');
        _showed.remove('请设置头像');
      }else if(!_agree){
        _showSnack('请勾选已同意');
        _showed.remove('请勾选已同意，并且设置头像');
      }else if(StringUtil.isEmpty(_avatarRemoteFile)){
        _showSnack('请设置头像');
        _showed.remove('请勾选已同意，并且设置头像');
      }
    }
    var v=!StringUtil.isEmpty(_avatarRemoteFile) &&
        !StringUtil.isEmpty(_nickNameController.text) &&
        !StringUtil.isEmpty(_phoneController.text) &&
        !StringUtil.isEmpty(_passwordController.text) &&
        _agree;
    if(v){
      _showed.clear();
    }
    return v;
  }

  Future<void> _doRegister() async {
    setState(() {
      _buttonEnabled = false;
      _registerLabel = '注册中...';
    });
    AppKeyPair appKeyPair = widget.context.site.getService('@.appKeyPair');
    var defaultApp = widget.context.site.getService('@.prop.entrypoint.app');
    appKeyPair =
        await appKeyPair.getAppKeyPair(defaultApp, widget.context.site);
    var nonce =
        MD5Util.MD5('${Uuid().v1()}${DateTime.now().millisecondsSinceEpoch}');
    await widget.context.ports.callback(
      'post ${widget.context.site.getService('@.prop.ports.uc.register')} http/1.1',
      restCommand: 'registerByIphone',
      headers: {
        'app-id': appKeyPair.appid,
        'app-key': appKeyPair.appKey,
        'app-nonce': nonce,
        'app-sign': appKeyPair.appSign(nonce),
      },
      parameters: {
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'nickName': _nickNameController.text,
        'avatar': _avatarRemoteFile,
        'signature':'',
      },
      onerror: ({e, stack}) {
        widget.context.ports.deleteFile(_avatarRemoteFile);
        print('-----$e');
        _buttonEnabled = true;
        _registerLabel = '注册';
        setState(() {});
      },
      onsucceed: ({rc, response}) async {
        print('-----$response');
        var json = rc['dataText'];
        Map<String, dynamic> map = jsonDecode(json);
        lp.IPlatformLocalPrincipalManager manager =
            widget.context.site.getService('/local/principals');
        await manager.add(
          '${_phoneController.text}@${appKeyPair.appid}',
          uid: map['userId'],
          accountCode: _phoneController.text,
          nickName: _nickNameController.text,
          appid: appKeyPair.appid,
          roles: <String>[],
          accessToken: _anonymousAccessToken,
          refreshToken: null,
          remoteAvatar: _avatarRemoteFile,
          localAvatar: _localAvatarFile,
          signature: null,
          ltime: 0,
          pubtime: 0,
          expiretime: 0,
          device: appKeyPair.device,
        );
        widget.context.forward('/public/login');
        _buttonEnabled = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (StringUtil.isEmpty(_anonymousAccessToken)) {
      return Container(
        width: 0,
        height: 0,
      );
    }
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        elevation: 0,
      ),
      body: ListView(
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
              '手机号注册',
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
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 70,
                        child: Text(
                          '昵称',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _nickNameController,
                          onChanged: (v) {
                            _buttonEnabled = _checkRegister();
                            setState(() {});
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '例如：天空之城',
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
                _AvatarRegion(
                  context: widget.context,
                  onAfterUpload: (removeAvatarFile, localAvatarFile) {
                    _avatarRemoteFile = removeAvatarFile;
                    _localAvatarFile = localAvatarFile;
                    _buttonEnabled = _checkRegister();
                    if(mounted) {
                      setState(() {});
                    }
                  },
                  anonymousAccessToken: _anonymousAccessToken,
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
                      _buttonEnabled = _checkRegister();
                      setState(() {});
                    },
                    keyboardType: TextInputType.phone,
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
                    keyboardType: TextInputType.text,
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
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
              top: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Checkbox(
                  value: _agree,
                  onChanged: (v) {
                    _agree = v;
                    _buttonEnabled = _checkRegister();
                    setState(() {});
                  },
                ),
                Expanded(child: Text.rich(
                  TextSpan(
                    text: '已阅读并同意',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    children: [
                      TextSpan(
                        text: '《地微用户协议》',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.context.forward('/system/user/contract');
                          },
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '《地微隐私政策》',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.context.forward('/system/privacy');
                          },
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),),
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
              _doRegister();
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
                _registerLabel,
                style: TextStyle(
                  fontSize: 18,
                  color: _buttonEnabled ? Colors.white : Colors.grey[500],
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          useSimpleLayout()?SizedBox.shrink():
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap:() {
              sendWeChatAuth(
                scope: "snsapi_userinfo",
                state: "${Uuid().v1()}",
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green ,
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              child: Text(
                '无需注册，直接以微信登录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRegion extends StatefulWidget {
  PageContext context;
  String anonymousAccessToken;
  Function(String removeAvatarFile, String localAvatarFile) onAfterUpload;

  _AvatarRegion({this.onAfterUpload, this.context, this.anonymousAccessToken});

  @override
  __AvatarRegionState createState() => __AvatarRegionState();
}

class __AvatarRegionState extends State<_AvatarRegion> {
  String _avatarFile;
  String _per;

  Future<String> _doUploadAvatar(String avatarFile) async {
    var dir = '/avatars';
    var map = await widget.context.ports.upload(dir, <String>[avatarFile],
        accessToken: widget.anonymousAccessToken, onSendProgress: (i, j) {
      _per = '${((i * 1.0 / j) * 100.00).toStringAsFixed(0)}%';
      setState(() {});
    });
    if (map == null || map.isEmpty) {
      return null;
    }
    return map[avatarFile];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        Container(
          color: Colors.grey[300],
          child: IconButton(
            padding: EdgeInsets.all(!StringUtil.isEmpty(_avatarFile) ? 0 : 20),
            iconSize: !StringUtil.isEmpty(_avatarFile) ? 40 : 20,
            splashColor: Colors.grey[400],
            hoverColor: Colors.transparent,
            color: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: !StringUtil.isEmpty(_avatarFile)
                ? Image.file(
                    File(_avatarFile),
                  )
                : Icon(
                    Icons.camera_alt,
                    color: Colors.grey[500],
                  ),
            onPressed: () {
              widget.context.forward('/widgets/avatar').then((avatar) async {
                if (StringUtil.isEmpty(avatar)) {
                  return;
                }
                _avatarFile = avatar;
                setState(() {});
                var remoteAvatar = await _doUploadAvatar(avatar);
                if (widget.onAfterUpload != null) {
                  widget.onAfterUpload(remoteAvatar, _avatarFile);
                }
              });
            },
          ),
        ),
        _per == null
            ? Container(
                width: 0,
                height: 0,
              )
            : Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Align(
                  child: Text(
                    '$_per',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              ),
      ],
    );
  }
}
