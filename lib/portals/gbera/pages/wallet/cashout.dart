import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:tobias/tobias.dart' as tobias;

class Cashout extends StatefulWidget {
  PageContext context;

  Cashout({this.context});

  @override
  _CashoutState createState() => _CashoutState();
}

class _CashoutState extends State<Cashout> {
  TextEditingController _amountController;
  int _limit = 100, _offset = 0;
  List<PayChannel> _payChannels = [];
  PayChannel _selected;
  bool _isLoading = false;
  GlobalKey<ScaffoldState> _globalKey;
  MyWallet _myWallet;
  String _errorTips;
  StreamSubscription _streamSubscription;
  bool _isCashing = false;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _globalKey = GlobalKey<ScaffoldState>();
    _amountController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _amountController?.dispose();
    _streamSubscription?.cancel();
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

  Future<void> _cashout() async {
    if (mounted) {
      setState(() {
        _isCashing = true;
      });
    }
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    int amount = (double.parse(_amountController.text) * 100).floor();
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    PersonCardOR personCardOR =
        await payChannelRemote.getPersonCard(_selected.code);
    if (personCardOR == null) {
      //没有公众卡，则发起绑卡流程，对于微信、支付宝为唤起app以获取auth_code，对于银联等第三方则绑银行卡
      personCardOR = await _discoveryAndBindCard(payChannelRemote);
      if (personCardOR == null) {
        _errorTips = '不能提现，没有公众卡';
        if (mounted) {
          setState(() {});
        }
        return;
      }
    }
    var record = await tradeRemote.withdraw(amount, personCardOR.id, null);
    //结束！提现不用轮询记录状态，虽然是实时到账，但许多支付系统为兼容非实时到账，均不做提示，而是让用户自己去查。
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    _streamSubscription = Stream.periodic(Duration(seconds: 1), (count) async {
      return await recordRemote.getWithdrawRecord(record.sn);
    }).listen((event) {
      event.then((value) {
        if (value == null) {
          _streamSubscription?.cancel();
          return;
        }
        if (value.state == 1) {
          _streamSubscription?.cancel();
          StreamController changeController =
              widget.context.parameters['changeController'];
          if (changeController != null && !changeController.isClosed) {
            changeController?.add({});
          }
          var msg = value.status == 200
              ? '提现成功，金额: ¥${(value.realAmount / 100.00).toStringAsFixed(2)}'
              : '提现失败: ${value.message}';
          widget.context.forward('/wallet/withdrawResult',
              arguments: {'record_sn': value.sn, 'message': msg},
              clearHistoryByPagePath: '/wallet/change/');
        }
      });
    });
  }

  Future<PersonCardOR> _discoveryAndBindCard(
      IPayChannelRemote payChannelRemote) async {
    switch (_selected.code) {
      case 'alipay':
        //唤起提现方的支付宝，并获取auth_code,然后向后台传入auth_code创建公众卡，并返回
        var text =
            'apiname=com.alipay.account.auth&app_id=2021001198622080&app_name=m&auth_type=AUTHACCOUNT&biz_type=openservice&method=alipay.open.auth.sdk.code.get&pid=2088831336090722&product_id=APP_FAST_LOGIN&scope=kuaijie&target_id=2014122542424';
        var map = await tobias.aliPayAuth(text);
        // print('----$map');
        var status = map['resultStatus'];
        if (status != '9000') {
          //出错
          return null;
        }
        var result = map['result'];
        var params = parseUrlParams(result);
        var authCode = params['auth_code'];
        // var userId = params['user_id'];
        return await payChannelRemote.createPersonCardByAuthCode(
          _selected.code,
          authCode,
        );
      default:
        print('暂不支持渠道：${_selected.name}');
        break;
    }
  }

  bool _isValidButton() {
    _errorTips = null;
    if (_isCashing) {
      return false;
    }
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
    int amount = (double.parse(text) * 100).floor();
    if (amount < 100) {
      //不能小于1元
      _errorTips = '不能小于1元';
      return false;
    }
    if (amount > _myWallet.change) {
      _errorTips = '余额不足';
      return false;
    }
    return true;
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
                      '提现方式',
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
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: '提现金额',
                hintText: '输入金额...',
                errorText: _errorTips,
                prefixIcon: Icon(
                  FontAwesomeIcons.yenSign,
                  size: 40,
                  color: Colors.black,
                ),
                labelStyle: TextStyle(
                  fontSize: 14,
                ),
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[100],
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 30,
              ),
              onChanged: (v) {
                if (mounted) {
                  setState(() {});
                }
              },
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
                    '零钱余额¥${_myWallet?.changeYan ?? '0.00'}，',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _amountController.text =
                        '${_myWallet?.changeYan ?? '0.00'}';
                    _amountController.selection = TextSelection.fromPosition(
                      TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: _amountController.text?.length ?? 0),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
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
                onPressed: !_isValidButton()
                    ? null
                    : () {
                        _cashout();
                      },
                textColor: !_isValidButton()
                    ? Colors.grey[500]
                    : widget.context.style('/wallet/change/deposit.textColor'),
                color: !_isValidButton()
                    ? Colors.grey[400]
                    : widget.context.style('/wallet/change/deposit.color'),
                highlightColor: widget.context
                    .style('/wallet/change/deposit.highlightColor'),
                child: Text(
                  _isCashing ? '提现中...' : '提现',
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
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
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
              card_method,
              card_body,
            ],
          ),
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
                    onTap:e.code=='wechatpay'?null: () {
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

  _rendPayChannel(PayChannel e) {
    dynamic panel = Container(
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
                        '单日交易限额：无',
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
    if (e.code == 'wechatpay') {
      panel = Stack(
        children: [
          panel,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Container(
              color: Colors.white70,
              alignment: Alignment.center,
              child: Container(
                color: Colors.red,
                constraints: BoxConstraints.tightFor(),
                padding: EdgeInsets.only(left: 4,right: 4,bottom: 1,top: 1,),
                child: Text(
                  '暂不支持提现到微信，开通时间预计在今年6、7月份',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return panel;
  }
}

getPayChannelIcon(PayChannel selected) {
  switch (selected.code) {
    case 'alipay':
      return Icon(
        FontAwesomeIcons.alipay,
        size: 35,
        color: Colors.blueAccent,
      );
    case 'wechatpay':
      return Icon(
        FontAwesomeIcons.weixin,
        size: 35,
        color: Colors.green,
      );
    default:
      return SizedBox(
        height: 0,
        width: 0,
      );
  }
}
