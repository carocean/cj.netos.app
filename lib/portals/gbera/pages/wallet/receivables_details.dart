import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class ReceivablesDetails extends StatefulWidget {
  PageContext context;

  ReceivablesDetails({this.context});

  @override
  _ReceivablesDetailsState createState() => _ReceivablesDetailsState();
}

class _ReceivablesDetailsState extends State<ReceivablesDetails> {
  @override
  Widget build(BuildContext context) {
    var card_money = Container(
      padding: EdgeInsets.only(
        top: 40,
        bottom: 40,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Image.network(
                    'https://c-ssl.duitang.com/uploads/item/201802/25/20180225233117_yicii.thumb.700_0.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                Text('赵向彬'),
              ],
            ),
          ),
          Text(
            '¥10000.00',
            style:
                widget.context.style('/wallet/change/detail/header/money.text'),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
    var card_detail = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '当前状态',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text('已收款'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '收款时间',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text('2019-10-17 23:59:10'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '订单金额',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text('¥3720.00'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '收款单号',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text(
                    '1000039204058383382727740100291283929',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '商家订单号',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text(
                    '1000039204058383382727740100291283929',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '交易说明',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text(
                    '商品',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            card_money,
            Divider(
              height: 1,
            ),
            card_detail,
          ],
        ),
      ),
    );
  }
}
