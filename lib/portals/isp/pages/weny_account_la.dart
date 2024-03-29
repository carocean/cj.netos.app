import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

class LaWenyAccount extends StatefulWidget {
  PageContext context;

  LaWenyAccount({this.context});

  @override
  _LaWenyAccountState createState() => _LaWenyAccountState();
}

class _LaWenyAccountState extends State<LaWenyAccount> {
  BankInfo _bank;
  ShuntBuckets _shuntBuckets;
  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _shuntBuckets=widget.context.parameters['shuntBuckets'];
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
              '地商账金',
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
                '${((_shuntBuckets?.laAmount ?? 0.0) / 100.00).toStringAsFixed(2)}',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
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
              onPressed: () {
                widget.context.forward(
                  '/weny/bill/shunt',
                  arguments: {'bank': _bank,'shunter':'la'},
                );
              },
              textColor: Colors.white,
              color: Colors.green,
              highlightColor: Colors.green[600],
              child: Text('查看明细'),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
//        title: Text(
//          widget.context.page?.title,
//        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
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
}
