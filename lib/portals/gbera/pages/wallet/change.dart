import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class Change extends StatefulWidget {
  PageContext context;

  Change({this.context});

  @override
  _ChangeState createState() => _ChangeState();
}

class _ChangeState extends State<Change> {
  MyWallet _myWallet;
  StreamController _changeStreamController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _changeStreamController = StreamController.broadcast();
    _myWallet = widget.context.parameters['wallet'];
    _streamSubscription = _changeStreamController.stream.listen((event) {
      _reloadMyWallet();
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _changeStreamController?.close();
    super.dispose();
  }

  Future<void> _reloadMyWallet() async {
    IWalletAccountRemote walletAccountService =
        widget.context.site.getService('/wallet/accounts');
    var myWallet = await walletAccountService.getAllAcounts();
    _myWallet.change = myWallet.change;
    _myWallet.absorb = myWallet.absorb;
    _myWallet.total = myWallet.total;
    if (mounted) {
      setState(() {});
    }
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
              '我的零钱',
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
                '${_myWallet?.changeYan ?? '0.00'}',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: widget.context.style('/wallet/change/money.text'),
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
              onPressed: () {
                widget.context.forward('/wallet/change/deposit',
                    arguments: {'changeController': _changeStreamController});
              },
              textColor:
                  widget.context.style('/wallet/change/deposit.textColor'),
              color: widget.context.style('/wallet/change/deposit.color'),
              highlightColor:
                  widget.context.style('/wallet/change/deposit.highlightColor'),
              child: Text('充值'),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 10,
          ),
          child: SizedBox(
            width: 160,
            height: 36,
            child: RaisedButton(
              onPressed: () {
                debugPrint('提现');
                widget.context.forward('/wallet/change/cashout');
              },
              textColor:
                  widget.context.style('/wallet/change/cashout.textColor'),
              color: widget.context.style('/wallet/change/cashout.color'),
              highlightColor:
                  widget.context.style('/wallet/change/cashout.highlightColor'),
              child: Text('提现'),
            ),
          ),
        ),
      ],
    );

    var bb = widget.context.parameters['back_button'];

    return Scaffold(
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
              widget.context.forward('/wallet/change/bill',
                  arguments: {'wallet': _myWallet});
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
