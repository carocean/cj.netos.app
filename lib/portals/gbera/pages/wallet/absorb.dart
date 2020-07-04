import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';

class Absorb extends StatefulWidget {
  PageContext context;

  Absorb({this.context});

  @override
  _AbsorbState createState() => _AbsorbState();
}

class _AbsorbState extends State<Absorb> {
  MyWallet _myWallet;
  bool _enableButton = false;
  String _buttonText = '提取到零钱';
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _enableButton = _myWallet.absorb.floor() > 0;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _transAbsorb() async {
    _enableButton = false;
    _buttonText = '提取中...';
    if (mounted) {
      setState(() {});
    }
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    TransAbsorbResult result =
        await tradeRemote.transAbsorb(_myWallet.absorb.floor(), '');
    Timer.periodic(
        Duration(
          seconds: 1,
        ), (timer) async {
      TransAbsorbOR record;
      try {
        record = await recordRemote.getTransAbsorb(result.sn);
      } catch (ex) {
        timer.cancel();
        throw FlutterError(ex);
      }
      if (record.state == 1) {
        timer.cancel();
      }
      if (result.status < 300) {
        _myWallet.absorb = 0;
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
              '我的洇金',
              style: widget.context.style('/wallet/change/mychange.text'),
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
                  style: widget.context.style('/wallet/change/money-sign.text'),
                ),
              ),
              Text(
                '${_myWallet?.absorbYan ?? '0.00'}',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
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
                      _transAbsorb();
                    },
              textColor:
                  widget.context.style('/wallet/change/deposit.textColor'),
              color: widget.context.style('/wallet/change/deposit.color'),
              highlightColor:
                  widget.context.style('/wallet/change/deposit.highlightColor'),
              child: Text(_buttonText),
            ),
          ),
        ),
      ],
    );

    var bb = widget.context.parameters['back_button'];

    return Scaffold(
      key: _key,
      appBar: AppBar(
//        title: Text(
//          widget.context.page?.title,
//        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              widget.context.forward('/wallet/absorb/bill', arguments: {
                'wallet': _myWallet,
              });
            },
            child: Text('明细'),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            card_main,
            card_actions,
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
