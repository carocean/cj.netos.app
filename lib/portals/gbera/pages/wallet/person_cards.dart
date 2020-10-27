import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class PersonCardPage extends StatefulWidget {
  PageContext context;

  PersonCardPage({this.context});

  @override
  _PersonCardPageState createState() => _PersonCardPageState();
}

class _PersonCardPageState extends State<PersonCardPage> {
  List<PersonCardOR> _cards = [];

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    var list = await payChannelRemote.pagePersonCard(1000, 0);
    _cards.addAll(list);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = _renderItems();
    return Scaffold(
      appBar: AppBar(
        title: Text('公众卡'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: items,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                bottom: 20,
                left: 10,
                right: 10,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.context.forward('/wallet/addCard');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 24,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '添加银行卡',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    for (var i = 0; i < _cards.length; i++) {
      var card = _cards[i];
      items.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.red[200],
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${card.cardPubBank}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          '${_getCardType(card)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${card.cardSn ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      );
      if (i < _cards.length - 1) {
        items.add(
          SizedBox(
            height: 10,
          ),
        );
      }
    }
    return items;
  }

  _getCardType(PersonCardOR card) {
    switch (card.cardType) {
      case 0:
        return '储蓄卡';
      case 1:
        return '信用卡';
      case 2:
        return '积分卡';
      default:
        return '其它';
    }
  }
}
