import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class ChangeDetails extends StatefulWidget {
  PageContext context;

  ChangeDetails({this.context});

  @override
  _ChangeDetailsState createState() => _ChangeDetailsState();
}

class _ChangeDetailsState extends State<ChangeDetails> {
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
            child: Text(
              '提现',
              style: widget.context
                  .style('/wallet/change/detail/header/title.text'),
            ),
          ),
          Text(
            '-10000.00',
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
                    '类型',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text('提现'),
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
                    '时间',
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
                    '交易单号',
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
                    '剩余零钱',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥60.00',
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
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    '备注',
                    style: widget.context
                        .style('/wallet/change/detail/body/label.text'),
                  ),
                  width: 80,
                ),
                Expanded(
                  child: Text(
                    '金证提现',
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
        centerTitle: true,
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
