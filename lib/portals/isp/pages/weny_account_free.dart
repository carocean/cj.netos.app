import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';

class FreeWenyAccount extends StatefulWidget {
  PageContext context;

  FreeWenyAccount({this.context});

  @override
  _FreeWenyAccountState createState() => _FreeWenyAccountState();
}

class _FreeWenyAccountState extends State<FreeWenyAccount> {
  WenyBank _bank;
  bool _enableButton = false;
  String _buttonText = '提取到零钱';
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _enableButton = _bank.profit > 0;
    super.initState();
  }

  Future<void> _transProfit() async {
    _enableButton = false;
    _buttonText = '提取中...';
    if (mounted) {
      setState(() {});
    }
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    TransProfitResult result =
        await tradeRemote.transProfit(_bank.bank, _bank.profit, '');
    Timer.periodic(
        Duration(
          seconds: 1,
        ), (timer) async {
      TransProfitOR record;
      try {
        record = await recordRemote.getTransProfit(result.sn);
      } catch (ex) {
        timer.cancel();
        throw FlutterError(ex);
      }
      if (record.state == 1) {
        timer.cancel();
      }
      if (result.status < 300) {
        _bank.profit = 0;
        _buttonText = '成功';
      } else {
        _buttonText = '失败';
      }
      if (mounted) {
        setState(() {});
      }
      String _message = '${result.status} ${result.message}';

      _key.currentState.showSnackBar(SnackBar(
        content: Text('$_message'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    var card_main = Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              '我的账金',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 3,
                ),
                child: Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${((_bank?.profit ?? 0.0) / 100.00).toStringAsFixed(2)}',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _bank.profit < 0
                      ? Colors.green
                      : _bank.profit == 0 ? null : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    var card_actions = Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
          ),
          child: SizedBox(
            width: 160,
            height: 36,
            child: RaisedButton(
              onPressed: !_enableButton
                  ? null
                  : () {
                      _transProfit();
                    },
              textColor: Colors.white,
              color: Colors.green,
              disabledColor: Colors.grey[300],
              disabledTextColor: Colors.grey[400],
              highlightColor: Colors.green[600],
              child: Text(_buttonText),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      key: _key,
      appBar: AppBar(
//        title: Text(
//          widget.context.page?.title,
//        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              widget.context.forward(
                '/wybank/bill/profit',
                arguments: {'bank': _bank},
              );
            },
            child: Text('明细'),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
        ),
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  card_main,
                  card_actions,
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 15,
                bottom: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '其它账金账',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/wenybank/shunters');
                    },
                    child: Text(
                      '账比',
                      style: TextStyle(
                        color: Colors.blueGrey[500],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _CardOtherAccounts(
                context: widget.context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardOtherAccounts extends StatefulWidget {
  PageContext context;

  _CardOtherAccounts({this.context});

  @override
  __CardOtherAccountsState createState() => __CardOtherAccountsState();
}

class __CardOtherAccountsState extends State<_CardOtherAccounts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          _getCardItem(
            title: '平台',
            tips: '283.32',
            onTap: () {
              widget.context.forward('/wenybank/account/platform');
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '运营商',
            tips: '283.32',
            onTap: () {
              widget.context.forward('/wenybank/account/isp');
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '网络洇金',
            tips: '283.32',
            onTap: () {
              widget.context.forward('/wenybank/account/absorb');
            },
          ),
        ],
      ),
    );
  }
}

Widget _getCardItem(
    {String title, String tips, Color color, Function() onTap}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.only(
        top: 18,
        bottom: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${title ?? ''}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${tips ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color ?? Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
