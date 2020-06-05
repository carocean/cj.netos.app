import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class Onorder extends StatefulWidget {
  PageContext context;

  Onorder({this.context});

  @override
  _OnorderState createState() => _OnorderState();
}

class _OnorderState extends State<Onorder> {
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
              '在订单',
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
                '${_myWallet?.onorderYan??'0.00'}',
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
                widget.context.forward('/wallet/onorder/bill',arguments: {'wallet':_myWallet,});
              },
              textColor: widget.context.style('/wallet/change/deposit.textColor'),
              color: widget.context.style('/wallet/change/deposit.color'),
              highlightColor:
              widget.context.style('/wallet/change/deposit.highlightColor'),
              child: Text('查看明细'),
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

