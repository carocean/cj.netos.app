import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class ProfitWenyAccount extends StatefulWidget {
  PageContext context;

  ProfitWenyAccount({this.context});

  @override
  _ProfitWenyAccountState createState() => _ProfitWenyAccountState();
}

class _ProfitWenyAccountState extends State<ProfitWenyAccount> {
  WenyBank _bank;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
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
              '我的收益',
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
              onPressed:() {
                widget.context.forward(
                  '/wybank/bill/profit',
                  arguments: {'bank': _bank},
                );
                    },
              textColor: Colors.white,
              color: Colors.green,
              disabledColor: Colors.grey[300],
              disabledTextColor: Colors.grey[400],
              highlightColor: Colors.green[600],
              child: Text('查看明细'),
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
}
