import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

class Cashout extends StatelessWidget {
  PageContext context;

  Cashout({this.context});

  @override
  Widget build(BuildContext context) {
    var card_method = Container(
      color: Colors.grey[50],
      padding: EdgeInsets.only(
        bottom: 20,
        left: 10,
        right: 10,
        top: 20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Text('提现到:'),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 5,
                ),
                child: Icon(
                  FontAwesomeIcons.alipay,
                  size: 25,
                  color: Colors.blueAccent,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text(
                      '支付宝',
                      style: this
                          .context
                          .style('/wallet/change/deposit/method/title.text'),
                    ),
                  ),
                  Text(
                    '即时到账',
                    style: this
                        .context
                        .style('/wallet/change/deposit/method/subtitle.text'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 5,
                ),
                child: Text(
                  '提现方式',
                  style: this
                      .context
                      .style('/wallet/change/deposit/method/arrow-label.text'),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 20,
                color: this
                    .context
                    .style('/wallet/change/deposit/method/arrow.icon'),
              ),
            ],
          ),
        ],
      ),
    );
    var card_body = Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              '提现金额',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: '提现金额',
                hintText: '输入金额...',
                prefixIcon: Icon(
                  FontAwesomeIcons.yenSign,
                  size: 14,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[100],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                  child: Text(
                    '零钱余额¥28394.20，',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Text(
                    '全部提现',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 25,
              bottom: 15,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 160,
              height: 35,
              child: RaisedButton(
                onPressed: () {},
                textColor:
                    this.context.style('/wallet/change/deposit.textColor'),
                color: this.context.style('/wallet/change/deposit.color'),
                highlightColor:
                    this.context.style('/wallet/change/deposit.highlightColor'),
                child: Text(
                  '提现',
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            this.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 20,
          bottom: 20,
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: _builderModalBottomSheet);
                },
                behavior: HitTestBehavior.opaque,
                child: card_method,
              ),
              card_body,
            ],
          ),
        ),
      ),
    );
  }

  Widget _builderModalBottomSheet(BuildContext context) {
    var item_alipay = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.alipay,
                    size: 25,
                    color: Colors.blueAccent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        '支付宝',
                        style: this
                            .context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                    Text(
                      '单日交易限额 ¥ 50000.00',
                      style: this
                          .context
                          .style('/wallet/change/deposit/method/subtitle.text'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var item_weixin = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.weixin,
                    size: 25,
                    color: Colors.green,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        '微信',
                        style: this
                            .context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                    Text(
                      '单日交易限额 ¥ 50000.00',
                      style: this
                          .context
                          .style('/wallet/change/deposit/method/subtitle.text'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var item_goPayMethod = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.paypal,
                    size: 25,
                    color: Colors.redAccent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        '添加提现方式',
                        style: this
                            .context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                    Text(
                      '银行卡、交通卡、比特币等',
                      style: this
                          .context
                          .style('/wallet/change/deposit/method/subtitle.text'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 5,
              bottom: 15,
            ),
            child: Center(
              child: Text(
                '选择提现方式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
          item_alipay,
          Divider(
            height: 1,
            indent: 40,
          ),
          item_weixin,
          Divider(
            height: 1,
            indent: 40,
          ),
          item_goPayMethod,
        ],
      ),
    );
  }
}
