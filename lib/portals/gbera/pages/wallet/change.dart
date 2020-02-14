import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class Change extends StatelessWidget {
  PageContext context;

  Change({this.context});

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
              style: this.context.style('/wallet/change/mychange.text'),
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
                  style: this.context.style('/wallet/change/money-sign.text'),
                ),
              ),
              Text(
                '4023.21',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: this.context.style('/wallet/change/money.text'),
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
                debugPrint('充值');
                this.context.forward('/wallet/change/deposit');
              },
              textColor: this.context.style('/wallet/change/deposit.textColor'),
              color: this.context.style('/wallet/change/deposit.color'),
              highlightColor:
                  this.context.style('/wallet/change/deposit.highlightColor'),
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
                this.context.forward('/wallet/change/cashout');
              },
              textColor: this.context.style('/wallet/change/cashout.textColor'),
              color: this.context.style('/wallet/change/cashout.color'),
              highlightColor:
                  this.context.style('/wallet/change/cashout.highlightColor'),
              child: Text('提现'),
            ),
          ),
        ),
      ],
    );

    var bb = this.context.parameters['back_button'];

    return Scaffold(
      appBar: AppBar(
//        title: Text(
//          this.context.page?.title,
//        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              this.context.forward('/wallet/change/bill');
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
        this.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
