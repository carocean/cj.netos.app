import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:tobias/tobias.dart' as tobias;

class Deposit extends StatefulWidget {
  PageContext context;

  Deposit({this.context});

  @override
  _DepositState createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  TextEditingController _amountController;
  int _limit = 100, _offset = 0;
  List<PayChannel> _payChannels = [];
  PayChannel _selected;
  bool _isLoading = false;
  GlobalKey<ScaffoldState> _globalKey;

  @override
  void initState() {
    _globalKey = GlobalKey<ScaffoldState>();
    _amountController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _amountController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    if (mounted) {
      setState(() {});
    }
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    var channels = await payChannelRemote.pagePayChannel(_limit, _offset);
    _payChannels.addAll(channels);
    _selected = _payChannels[0];
    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _recharge() async {
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    int amount = (double.parse(_amountController.text) * 100).floor();
    String result =
        await tradeRemote.recharge("CNY", amount, _selected.code, null);
    var map = await tobias.aliPay(result);
    print('-------$map');
    if (map == null) {
      _globalKey.currentState.showSnackBar(SnackBar(
        content: Container(
          child: Text('没有返回结果，请到钱包中心查看是否成功充值'),
        ),
      ));
      return;
    }
    switch (_selected.code) {
      case 'alipay':
        doResultAlipay(map);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic card_method;
    if (_isLoading) {
      card_method = Container(
        padding: EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: Text(
          '正在加载支付渠道...',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }
    if (_selected == null) {
      card_method = Container(
        padding: EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: Text(
          '没有支付渠道',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    } else {
      card_method = Container(
        padding: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: getPayChannelIcon(_selected),
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
                          '${_selected.name}',
                          style: widget.context.style(
                              '/wallet/change/deposit/method/title.text'),
                        ),
                      ),
                      Text(
                        '单日交易限额遵循支付宝政策',
                        style: widget.context.style(
                            '/wallet/change/deposit/method/subtitle.text'),
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
                      '充值方式',
                      style: widget.context.style(
                          '/wallet/change/deposit/method/arrow-label.text'),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 20,
                    color: widget.context
                        .style('/wallet/change/deposit/method/arrow.icon'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      card_method = GestureDetector(
        onTap: () {
          showModalBottomSheet(
                  context: context, builder: _builderModalBottomSheet)
              .then((value) {
            if (value == null) {
              return;
            }
            if (mounted) {
              _selected = value;
            }
          });
        },
        behavior: HitTestBehavior.opaque,
        child: card_method,
      );
    }
    var card_body = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Text('充值金额'),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '充值金额',
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
                  onChanged: (v) {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 30,
            child: RaisedButton(
              onPressed: !_showRechargeButton()
                  ? null
                  : () {
                      _recharge();
                    },
              textColor: !_showRechargeButton()
                  ? Colors.white
                  : widget.context.style('/wallet/change/deposit.textColor'),
              color: !_showRechargeButton()
                  ? Colors.grey
                  : widget.context.style('/wallet/change/deposit.color'),
              highlightColor:
                  widget.context.style('/wallet/change/deposit.highlightColor'),
              child: Text(
                '充值',
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            card_method,
            Expanded(
              child: card_body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _builderModalBottomSheet(BuildContext context) {
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
                '选择充值方式',
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
          Column(
            children: _payChannels.map((e) {
              return Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.backward(result: e);
                    },
                    child: _rendPayChannel(e),
                  ),
                  Divider(
                    height: 1,
                    indent: 40,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  _showRechargeButton() {
    var text = _amountController.text;
    if (StringUtil.isEmpty(text)) {
      return false;
    }
    if (text.endsWith('.')) {
      return false;
    }
    int pos = text.lastIndexOf('.');
    if (pos > 0) {
      if (text.length - pos > 3) {
        return false;
      }
    }
    return true;
  }

  _rendPayChannel(PayChannel e) {
    return Container(
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
                  child: getPayChannelIcon(e),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Text(
                          '${e.name}',
                          style: widget.context.style(
                              '/wallet/change/deposit/method/title.text'),
                        ),
                      ),
                      Text(
                        '单日交易限额 ¥ 10000.00',
                        style: widget.context.style(
                            '/wallet/change/deposit/method/subtitle.text'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  doResultAlipay(Map map) {
    var status = map['resultStatus'];
    var result = jsonDecode(map['result']);
    var response = result['alipay_trade_app_pay_response'];
    var message;
    switch (status) {
      case '9000':
        message = '订单支付成功。金额: ¥${double.parse(response['total_amount'])}';
        break;
      case '8000':
        message = '正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态';
        break;
      case '4000':
        message = '订单支付失败';
        break;
      case '5000':
        message = '重复请求';
        break;
      case '6001':
        message = '用户中途取消';
        break;
      case '6002':
        message = '网络连接出错';
        break;
      case '6004':
        message = '支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态';
        break;
      default:
        message = '其它支付错误';
        break;
    }
    widget.context.forward('/wallet/rechargeResult',
        arguments: {'record_sn': response['out_trade_no'], 'message': message},
        clearHistoryByPagePath: '/wallet/change/');
  }
}

getPayChannelIcon(PayChannel selected) {
  switch (selected.code) {
    case 'alipay':
      return Icon(
        FontAwesomeIcons.alipay,
        size: 25,
        color: Colors.blueAccent,
      );
    case 'wechat':
      return Icon(
        FontAwesomeIcons.weixin,
        size: 25,
        color: Colors.green,
      );
    default:
      return SizedBox(
        height: 0,
        width: 0,
      );
  }
}
