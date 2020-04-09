import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/local_principals.dart' as lp;

class AccountViewer extends StatefulWidget {
  PageContext context;

  AccountViewer({this.context});

  @override
  _AccountViewerState createState() => _AccountViewerState();
}

class _AccountViewerState extends State<AccountViewer> {
  String _buttonLabel = '删除账户';

  Future<void> _doDelete() async {
    _buttonLabel = '删除中...';
    setState(() {});
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'removePerson',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      onsucceed: ({rc, response}) {},
      onerror: ({e, stack}) {
        print(e);
        _buttonLabel = '删除账户';
        setState(() {});
      },
    );
    //删除本地历史
    lp.IPlatformLocalPrincipalManager manager =
        widget.context.site.getService('/local/principals');
    var account = widget.context.parameters['account'];
    await manager.remove(account['person']);
    widget.context.forward('/public/entrypoint');
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
    var item_change_pwd = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Text(
              '修改密码',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
    var item_switch_login = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Text(
              '以该账户登录',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
    var item_del = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: Text(
        _buttonLabel,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.blueGrey,
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
                if (account['person'] == widget.context.principal.person)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/users/accounts/editPassword',
                          arguments: {'account': account});
                    },
                    child: item_change_pwd,
                  ),
                if (account['person'] == widget.context.principal.person)
                  Divider(
                    height: 1,
                    indent: 20,
                  ),
                if (account['person'] != widget.context.principal.person)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/users/accounts/login',
                        arguments: {'account': account});
                  },
                  child: item_switch_login,
                ),
              ],
            ),
            if (account['person'] == widget.context.principal.person)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _doDelete,
                child: item_del,
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
