import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class StockWenyAccount extends StatefulWidget {
  PageContext context;

  StockWenyAccount({this.context});

  @override
  _StockWenyAccountState createState() => _StockWenyAccountState();
}

class _StockWenyAccountState extends State<StockWenyAccount> {
  WenyBank _bank;

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
              '我的纹银',
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
                  '₩',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_bank?.stock ?? '-'}',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 25,
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
                debugPrint('查看明细');
                widget.context.forward('/wybank/bill/stock',arguments: {'bank':_bank});
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
