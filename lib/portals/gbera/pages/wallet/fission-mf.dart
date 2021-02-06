import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_trades.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class FissionMFCashierPage extends StatefulWidget {
  PageContext context;

  FissionMFCashierPage({this.context});

  @override
  _FissionMFCashierPageState createState() => _FissionMFCashierPageState();
}

class _FissionMFCashierPageState extends State<FissionMFCashierPage> {
  bool _isOpening = false;
  MyWallet _myWallet;
  bool _isRecharging = false;
  CashierOR _cashierOR;
  int _assessCacCount = 0;

  bool _isLoading = true;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    _cashierOR = await cashierRemote.getCashier();
    _isOpening = _cashierOR.state == 0;
    _assessCacCount = await cashierRemote.assessCacCount();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _withdraw() async {
    var result = await showDialog(
      context: context,
      child: _WithdrawPopupWidget(context: widget.context, wallet: _myWallet),
    );
    if (result == null) {
      return;
    }
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var amount = result as int;
    await cashierRemote.withdraw(amount);

    Future.delayed(
        Duration(
          seconds: 1,
        ), () async {
      var balance = await cashierRemote.getCashierBalance();
      _myWallet.fissionMf = balance.balance;
      _myWallet.change += amount;
      _assessCacCount = await cashierRemote.assessCacCount();
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _recharge(int amount) async {
    if (mounted) {
      setState(() {
        _isRecharging = true;
      });
    }
    IFissionMFCashierRemote cashier =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashier.recharge(amount);

    if (mounted) {
      setState(() {
        _isRecharging = false;
      });
    }
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    Future.delayed(
        Duration(
          seconds: 1,
        ), () async {
      var balance = await cashierRemote.getCashierBalance();
      _myWallet.fissionMf = balance.balance;
      _myWallet.change -= amount;
      _assessCacCount = await cashierRemote.assessCacCount();
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _updateState() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    if (_isOpening) {
      await cashierRemote.startCashier();
    } else {
      await cashierRemote.stopCashier('主动停止营业');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出纳柜台'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {},
            child: Text(
              '收益及明细',
            ),
          ),
        ],
      ),
      body: _rendBody(),
    );
  }

  Widget _rendBody() {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '加载中...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '今日收益',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '¥23.83',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          '今日获客',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '128人',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Column(
            children: [
              Text(
                '红包余额',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text.rich(
                TextSpan(
                  text: '¥',
                  children: [
                    TextSpan(
                      text: '${_myWallet.fissionMFYan ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '营业状态：${_isOpening ? '营业中' : '已停业'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Column(
            children: [
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '营业状态',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '营业中状态表示系统会将你推荐给其他用户，用户通过点你头像，从而会消耗你的红包余额；停止营业则不会扣费，系统也不会向其他用户推荐你',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${_isOpening ? '营业中' : '已停业'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isOpening,
                          onChanged: (v) {
                            setState(() {
                              _isOpening = v;
                            });
                            _updateState();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    !_isOpening
                        ? SizedBox(
                            width: 0,
                            height: 0,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '营业参数:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '¥${(_cashierOR.cacAverage / 100.00).toStringAsFixed(2)}元/客',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '预估可获取$_assessCacCount人',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '设置',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 0,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '充钱到红包',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  '${_isRecharging ? '正在充钱，请稍候...' : '从钱包零钱划扣'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(
                                  width: _isRecharging ? 0 : 10,
                                ),
                                _isRecharging
                                    ? SizedBox.shrink()
                                    : Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                              ],
                            ),
                            onTap: _isRecharging
                                ? null
                                : () async {
                                    var v = await widget.context.forward(
                                        '/wallet/fission/mf/recharge',
                                        arguments: {'wallet': _myWallet});
                                    if (v == null) {
                                      return;
                                    }
                                    var args = v as Map;
                                    var amount = args['amount'];
                                    _recharge(amount as int);
                                  },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Divider(
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '退款到零钱',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () {
                              _withdraw();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  '将从当前红包余额转入零钱',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /*
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '自动充值策略',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '想拉新就要正确定义你的推广策略。系统会按你的定义从你的地微钱包零钱中划扣，并充钱到红包余额',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '扣费策略',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                '每日',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '¥500.00',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                 */
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawPopupWidget extends StatefulWidget {
  PageContext context;
  MyWallet wallet;

  _WithdrawPopupWidget({this.context, this.wallet});

  @override
  __WithdrawPopupWidgetState createState() => __WithdrawPopupWidgetState();
}

class __WithdrawPopupWidgetState extends State<_WithdrawPopupWidget> {
  TextEditingController _amountController = TextEditingController();
  MyWallet _myWallet;
  String _errorText;

  @override
  void initState() {
    _myWallet = widget.wallet;
    _amountController.text =
        '${(_myWallet.fissionMf / 100.00).toStringAsFixed(2)}';
    super.initState();
  }

  @override
  void dispose() {
    _amountController?.dispose();
    super.dispose();
  }

  bool _isValid() {
    var v = _amountController.text;
    if (!StringUtil.isEmpty(v)) {
      try {
        var amount = double.parse(v);
        if (amount * 100 <= _myWallet.fissionMf) {
          return true;
        }
      } catch (e) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提取到零钱'),
        actions: [
          FlatButton(
            onPressed: !_isValid()
                ? null
                : () {
                    var v = _amountController.text;
                    var amount = double.parse(v);
                    int result = (amount * 100).floor();
                    widget.context.backward(result: result);
                  },
            child: Text(
              '确认',
              style: TextStyle(
                color: !_isValid() ? Colors.grey[400] : Colors.green,
              ),
            ),
          ),
        ],
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 40,
        ),
        child: TextField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: '提取金额',
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
            errorText: _errorText,
          ),
          onChanged: (v) {
            if (!StringUtil.isEmpty(v)) {
              _errorText = null;
              if (!v.endsWith('.')) {
                try {
                  double amount = double.parse(v);
                  if (amount * 100 > _myWallet.fissionMf) {
                    _errorText = '超出余额';
                    _amountController.text = '';
                  }
                } catch (e) {
                  _errorText = '不是合法的输入值';
                  _amountController.text = '';
                }
              }
            }
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
