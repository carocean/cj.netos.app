import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/framework.dart';

class EditPassword extends StatefulWidget {
  PageContext context;

  EditPassword({this.context});

  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  TextEditingController _oldPasswordController;
  TextEditingController _newPasswordController;
  String _buttonLabel = '确定';
  bool _buttonEnable = false;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _buttonLabel = '确定';
    _buttonEnable = false;
    super.dispose();
  }

  bool _checkButtonEnabled() {
    return !StringUtil.isEmpty(_oldPasswordController.text) &&
        !StringUtil.isEmpty(_newPasswordController.text);
  }

  Future<void> _updatePassword() async {
    _buttonLabel = '更新中...';
    _buttonEnable = false;
    setState(() {});
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.portsCB(
      headline,
      restCommand: 'updatePersonPassword',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'oldpwd': _oldPasswordController.text,
        'newpwd': _newPasswordController.text,
      },
      onsucceed: ({rc, response}) {
        _buttonLabel = '确定';
        _buttonEnable = false;
        widget.context.backward();
      },
      onerror: ({e, stack}) {
        print(e);
        _buttonLabel = '更新失败，请重试';
        _buttonEnable = true;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var card_face = Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Image.file(
              File(
                widget.context.principal.avatarOnLocal,
              ),
              fit: BoxFit.contain,
              width: 70,
              height: 70,
            ),
          ),
          Text('${widget.context.principal.accountCode}'),
        ],
      ),
    );
    var item_old_pwd = Container(
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
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
          controller: _oldPasswordController,
          keyboardType: TextInputType.text,
          autofocus: true,
          obscureText: true,
          onChanged: (v) {
            _buttonEnable = _checkButtonEnabled();
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: '原密码',
            hintText: '输入原密码',
            border: InputBorder.none,
          ),
        ),
      ),
    );

    var item_new_pwd = Container(
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
          controller: _newPasswordController,
          keyboardType: TextInputType.text,
          autofocus: true,
          obscureText: true,
          onChanged: (v) {
            _buttonEnable = _checkButtonEnabled();
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: '新密码',
            hintText: '输入新密码',
            border: InputBorder.none,
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
                item_old_pwd,
                Divider(
                  height: 1,
                ),
                item_new_pwd,
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _updatePassword();
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
