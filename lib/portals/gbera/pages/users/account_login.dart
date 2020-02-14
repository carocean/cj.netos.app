import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/login.dart';


class AccountLogin extends StatefulWidget {
  PageContext context;

  AccountLogin({this.context});

  @override
  _AccountLoginState createState() => _AccountLoginState();
}

class _AccountLoginState extends State<AccountLogin> {
  bool _buttonEnable = false;
  String _buttonLabel = '登录';
  TextEditingController _passwordController;

  @override
  void initState() {
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _buttonEnable = false;
    _buttonLabel = '登录';
    super.dispose();
  }

  Future<void> _doLogin(account) async {
    _buttonLabel = '登录中...';
    setState(() {});
    PasswordLoginAction(
      user: account['accountCode'],
      pwd: _passwordController.text,
      context: widget.context,
    ).login(account['appId'],() {
      _buttonLabel = '登录失败，请重新登录';
      _buttonEnable = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var account = widget.context.parameters['account'];
    print(account);
    var avatar =
        '${account['avatar']}?accessToken=${widget.context.principal.accessToken}';
    var card_face = Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Image.network(
              avatar,
              fit: BoxFit.contain,
              width: 70,
              height: 70,
            ),
          ),
          Text(account['accountCode']),
        ],
      ),
    );
    var item_appid = Container(
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 4,
      ),
      child: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Text(
          '用户号:${account['uid']}',
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    var item_pwd = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: TextField(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          autofocus: true,
          obscureText: true,
          onChanged: (v) {
            _buttonEnable = !StringUtil.isEmpty(_passwordController.text);
            setState(() {});
          },
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
      color: _buttonEnable ? Colors.green : Colors.grey[300],
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: 15,
      ),
      child: Text(
        _buttonLabel,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: _buttonEnable ? Colors.white : Colors.grey[400],
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
                  child: item_appid,
                ),
                Divider(
                  height: 1,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/users/accounts/login');
                  },
                  child: item_pwd,
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _doLogin(account);
              },
              child: item_ok,
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
