import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class FissionMfRechargePage extends StatefulWidget {
  PageContext context;

  FissionMfRechargePage({this.context});

  @override
  _FissionMfRechargePageState createState() => _FissionMfRechargePageState();
}

class _FissionMfRechargePageState extends State<FissionMfRechargePage> {
  int _amount = 100;
  MyWallet _myWallet;
  StreamController _rechargeController;
  StreamSubscription _rechargeHandler;
  bool _isLoading = true;
  Person _agent;
  var _data = [
    100,
    299900,
    399900,
    499900,
    599900,
    699900,
    799900,
    899900,
    999900,
    1999900,
    2999900,
    3999900,
    4999900,
    5999900,
    7999900,
    10000000,
    20000000,
    50000000,
  ];
  List<BusinessIncomeRatioOR> _ratios = [];
  double _selectedRatio;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _rechargeHandler?.cancel();
    _rechargeController?.close();
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    _ratios = await cashierRemote.listBusinessIncomeRatio();
    await _loadAgent();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAgent() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var cashier = await cashierRemote.getCashier();
    var salesman = cashier.salesman;
    if (StringUtil.isEmpty(salesman)) {
      return;
    }
    salesman = '$salesman@gbera.netos';
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _agent = await personService.getPerson(salesman);
    if (mounted) {
      setState(() {});
    }
  }

  bool _demandRecharge() {
    return _myWallet.change < _amount;
  }

  Future<void> _recharge() async {
    if (_rechargeController == null) {
      _rechargeController = StreamController();
      _rechargeHandler = _rechargeController.stream.listen((event) async {
        // print('---充值返回---$event');
        IWyBankPurchaserRemote purchaserRemote =
            widget.context.site.getService('/remote/purchaser');
        var location = await geoLocation.location;
        var _districtCode = location.adCode;
        var purchaseInfo = await purchaserRemote.getPurchaseInfo(_districtCode);
        if (purchaseInfo.bankInfo == null) {
          return;
        }
        if (purchaseInfo.myWallet.change >= _amount) {
          _amount = purchaseInfo.myWallet.change;
          _myWallet.change = purchaseInfo.myWallet.change;
          _myWallet.total = purchaseInfo.myWallet.total;
          if (mounted) {
            setState(() {});
          }
          return;
        }
      });
    }
    widget.context.forward('/wallet/change/deposit', arguments: {
      'changeController': _rechargeController,
      'initAmount': (_amount - _myWallet.change)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('充钱到红包'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: _demandRecharge()
                ? null
                : () {
                    widget.context.backward(result: {'amount': _amount});
                  },
            child: Text(
              '完成',
              style: TextStyle(
                color: _demandRecharge() ? null : Colors.green,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 30,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._renderPanel(),
                ],
              ),
            ),
          ),
          _selectedRatio == null
              ? SizedBox.shrink()
              : Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '红包',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '¥${((_amount * (1 - _selectedRatio)) / 100.00).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '服务费',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '¥${((_amount * _selectedRatio) / 100.00).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '费率',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${(_selectedRatio * 100.00).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _renderAmountPanel(),
                  SizedBox(
                    height: 20,
                  ),
                  CardItem(
                    title: '代理人',
                    tipsText:
                        '${_agent == null ? '指定代理人以获取优惠' : _agent.nickName}',
                    onItemTap: () async {
                      if (_agent == null) {
                        await showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              return Container(
                                height: 260,
                                child: _AgentOptionsDialog(
                                  context: widget.context,
                                ),
                              );
                            });
                        _loadAgent();
                      } else {
                        widget.context.forward('/person/view',
                            arguments: {'person': _agent});
                      }
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Column(
                      children: [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _findRatio(int amount) {
    double result = 0.2000;
    for (var ratio in _ratios) {
      if (amount >= ratio.minAmountEdge && amount < ratio.maxAmountEdge) {
        result = ratio.ratio;
        break;
      }
    }
    return result;
  }

  Widget _renderAmountPanel() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          alignment: Alignment.center,
          child: Text(
            '正在加载...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      for (var e in _data) {
        var ratio = _findRatio(e);
        items.add(
          InkWell(
            onTap: () {
              _amount = e;
              _selectedRatio = ratio;
              if (mounted) {
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.grey[200],
                  width: 1,
                ),
              ),
              padding: EdgeInsets.only(
                left: 4,
                right: 4,
                top: 2,
                bottom: 2,
              ),
              child: Column(
                children: [
                  Text(
                    '¥${(e / 100.00).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                    child: Divider(
                      height: 1,
                    ),
                    width: 100,
                  ),
                  Text.rich(
                    TextSpan(
                      text: '费率 ',
                      children: [
                        TextSpan(
                          text: '${(ratio * 100.00).toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      items.add(
        InkWell(
          onTap: () async {
            var amount = await showDialog(
              context: context,
              child: _InputAmountDialog(
                context: widget.context,
                initAmount: _data[0],
              ),
            );
            _amount = amount;
            _selectedRatio = _findRatio(_amount);
            if (mounted) {
              setState(() {});
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey[300],
                width: 1,
              ),
              color: Colors.grey[300],
            ),
            padding: EdgeInsets.only(
              left: 4,
              right: 4,
              top: 2,
              bottom: 2,
            ),
            child: SizedBox(
              height: 33,
              width: 100,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '自定...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              '选择金额',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items,
        )
      ],
    );
  }

  List<Widget> _renderPanel() {
    var items = <Widget>[];
    if (!_demandRecharge()) {
      items.addAll(
        <Widget>[
          Text(
            '金额',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: '¥',
                  children: [
                    TextSpan(
                      text: '${((_amount) / 100.00).toStringAsFixed(2)}',
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
              ),
            ],
          ),
        ],
      );
    } else {
      //充值
      items.add(
        RaisedButton(
          onPressed: () {
            _recharge();
          },
          color: Colors.green,
          textColor: Colors.white,
          disabledTextColor: Colors.white54,
          child: Text(
            '请充值',
          ),
        ),
      );
    }
    return items;
  }
}

class _AgentOptionsDialog extends StatefulWidget {
  PageContext context;

  _AgentOptionsDialog({this.context});

  @override
  __AgentOptionsDialogState createState() => __AgentOptionsDialogState();
}

class __AgentOptionsDialogState extends State<_AgentOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  CardItem(
                    title: '指定代理人',
                    tipsText: '如果你认识代理人',
                    onItemTap: () async {
                      await widget.context.forward('/wallet/fission/mf/agent');
                      widget.context.backward();
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                  CardItem(
                    title: '平台推荐',
                    tipsText: '如果你不认识代理人',
                    onItemTap: () async {
                      await widget.context
                          .forward('/wallet/fission/mf/contact');
                      widget.context.backward();
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              widget.context.backward();
            },
            child: Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              color: Colors.white,
              alignment: Alignment.center,
              child: Text('不需要代理人'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputAmountDialog extends StatefulWidget {
  PageContext context;
  int initAmount;

  _InputAmountDialog({this.context, this.initAmount});

  @override
  __InputAmountDialogState createState() => __InputAmountDialogState();
}

class __InputAmountDialogState extends State<_InputAmountDialog> {
  TextEditingController _amountController;
  String _errorText;

  @override
  void initState() {
    var initAmount = widget.initAmount;
    var text = '';
    if (initAmount != null) {
      text = (initAmount / 100.00).toStringAsFixed(2);
    }
    _amountController = TextEditingController(text: text);
    super.initState();
  }

  @override
  void dispose() {
    _amountController?.dispose();
    super.dispose();
  }

  bool _isValid() {
    try {
      var amount = double.parse(_amountController.text);
      if (amount * 100 >= widget.initAmount) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('自定'),
        elevation: 0,
        actions: [
          FlatButton(
            onPressed: !_isValid()
                ? null
                : () {
                    try {
                      var amount = double.parse(_amountController.text);
                      widget.context.backward(result: (amount * 100).floor());
                    } catch (e) {}
                  },
            textColor: Colors.green,
            child: Text(
              '确定',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 40,
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: '金额',
                labelStyle: TextStyle(
                  fontSize: 18,
                ),
                hintText: '输入金额...',
                hintStyle: TextStyle(
                  fontSize: 18,
                ),
                prefix: Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                    top: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.yenSign,
                    size: 40,
                  ),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[100],
                  ),
                ),
                errorText: _errorText,
              ),
              style: TextStyle(
                fontSize: 30,
              ),
              onChanged: (v) {
                if (!StringUtil.isEmpty(v)) {
                  _errorText = null;
                  if (!v.endsWith('.')) {
                    try {
                      double amount = double.parse(v);
                      if (amount * 100 < widget.initAmount) {
                        _errorText =
                            '充值金额不能少于${(widget.initAmount / 100.00).toStringAsFixed(2)}元';
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
        ],
      ),
    );
  }
}
