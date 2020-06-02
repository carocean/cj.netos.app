import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class Absorb extends StatefulWidget {
  PageContext context;

  Absorb({this.context});

  @override
  _AbsorbState createState() => _AbsorbState();
}

class _AbsorbState extends State<Absorb> {
  MyWallet _myWallet;
  @override
  void initState() {
    _myWallet=widget.context.parameters['wallet'];
    super.initState();
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
                '${_myWallet?.absorbYan??'0.00'}',
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
                debugPrint('提取到零钱');
//                widget.context.forward('/wallet/change/deposit');
              },
              textColor: widget.context.style('/wallet/change/deposit.textColor'),
              color: widget.context.style('/wallet/change/deposit.color'),
              highlightColor:
              widget.context.style('/wallet/change/deposit.highlightColor'),
              child: Text('提取到零钱'),
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
              widget.context.forward('/wallet/change/bill');
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

