import 'dart:async';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/records.dart';

class PlatformPurchaseRecordPage extends StatefulWidget {
  PageContext context;

  PlatformPurchaseRecordPage({this.context});

  @override
  _PlatformPurchaseRecordPageState createState() => _PlatformPurchaseRecordPageState();
}

class _PlatformPurchaseRecordPageState extends State<PlatformPurchaseRecordPage> {
  Timer _timer;
  String _recordSn;
  PurchaseOR _purch;
  BankInfo _bank;

  @override
  void initState() {
    _recordSn = widget.context.parameters['record_sn'];
    _bank = widget.context.parameters['bank'];
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    IWyBankRecordRemote recordRemote =
        widget.context.site.getService("/wybank/records");
    _purch = await recordRemote.getPurchaseRecord(_recordSn);
  }

  @override
  Widget build(BuildContext context) {
    PurchaseOR purch = _purch;
    BankInfo bank = _bank;
    if (purch == null || bank == null) {
      return Scaffold(
        body: Container(),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: true,
            title: Text('申购合约'),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: _AmountCard(purch, bank),
          ),
          SliverFillRemaining(
            child: _DetailsCard(purch, bank),
          ),
        ],
      ),
    );
  }

  Widget _AmountCard(PurchaseOR purch, BankInfo bank) {
    if (purch == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 60,
              bottom: 4,
            ),
            child: Text(
              '申购金额',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(
            child: Text(
              '¥${(_purch.amount / 100.00).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DetailsCard(PurchaseOR purch, BankInfo bank) {
    var minWidth = 70.00;
    return Container(
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '单号:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${purch.sn}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '申购行:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${bank.title}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '纹银:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('₩${purch.stock.toStringAsFixed(14)}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '申购价格:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('¥${(purch.price).toStringAsFixed(14)}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '服务费:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text:
                          '¥${(purch.serviceFee / 100.00).toStringAsFixed(2)}',
                      children: [
                        TextSpan(
                          text:
                              '(注：平台从收取的服务费中拔出一部分资金用于激励用户和合作伙伴，称为自由金。本合约服务费拔付的自由金金额是:',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        TextSpan(
                          text:
                              '¥${(purch.freeAmount / 100.00).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ')',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '冻结本金:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text:
                          '¥${(purch.principalAmount / 100.00).toStringAsFixed(2)}',
                      children: [
                        TextSpan(
                          text: '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '订单状态:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${_getRecordState()}  ${purch.status} ${purch.message}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '申购人:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${purch.purchaser}(${purch.personName})'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '申购时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(purch.ptime, len: 14))}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '协议内容:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '查看',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecordState() {
    var v = '';
    switch (_purch.state) {
      case -1:
        v = '失败';
        break;
      case 0:
        v = '申购中';
        break;
      case 1:
        v = '已申购';
        break;
      case 2:
        v = '承兑中';
        break;
      case 3:
        v = '已承兑';
        break;
    }
    return v;
  }
}

class PlatformExchangeRecordPage extends StatefulWidget {
  PageContext context;

  PlatformExchangeRecordPage({this.context});

  @override
  _PlatformExchangeRecordPageState createState() => _PlatformExchangeRecordPageState();
}

class _PlatformExchangeRecordPageState extends State<PlatformExchangeRecordPage> {
  Timer _timer;
  String _recordSn;
  ExchangeOR _exchange;
  BankInfo _bank;

  @override
  void initState() {
    _recordSn = widget.context.parameters['record_sn'];
    _bank = widget.context.parameters['bank'];
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    IWyBankRecordRemote recordRemote =
        widget.context.site.getService("/wybank/records");
    _exchange = await recordRemote.getExchangeRecord(_recordSn);
  }

  @override
  Widget build(BuildContext context) {
    ExchangeOR exchange = _exchange;
    BankInfo bank = _bank;
    if (exchange == null || bank == null) {
      return Scaffold(
        body: Container(),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: true,
            title: Text('承兑合约'),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: _AmountCard(exchange, bank),
          ),
          SliverFillRemaining(
            child: _DetailsCard(exchange, bank),
          ),
        ],
      ),
    );
  }

  Widget _AmountCard(ExchangeOR exchange, BankInfo bank) {
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 60,
              bottom: 4,
            ),
            child: Text(
              '最终获得:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(
            child: Text(
              '¥${((exchange.amount ?? 0) / 100.0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
                color: (exchange.profit ?? 0) > 0
                    ? Colors.red
                    : (exchange.profit ?? 0) < 0 ? Colors.green : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DetailsCard(ExchangeOR exchange, BankInfo bank) {
    var minWidth = 70.00;
    return Container(
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '单号:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${exchange.sn}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '承兑行:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${bank.title}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '纹银:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('₩${exchange.stock.toStringAsFixed(14)}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '申购金额:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '¥${(exchange.purchaseAmount / 100.00).toStringAsFixed(2)}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '承兑价格:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      Text('¥${(exchange.price ?? 0.00).toStringAsFixed(14)}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '市盈率:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥${_exchange.ttm.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: (exchange.profit ?? 0) > 0
                          ? Colors.red
                          : (exchange.profit ?? 0) < 0 ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '最终收益:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥${((exchange.profit ?? 0) / 100.00).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: (exchange.profit ?? 0) > 0
                          ? Colors.red
                          : (exchange.profit ?? 0) < 0 ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '结算盈率:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥${((_exchange.amount / _exchange.purchaseAmount)).toStringAsFixed(4)}',
                    style: TextStyle(
                      color: (exchange.profit ?? 0) > 0
                          ? Colors.red
                          : (exchange.profit ?? 0) < 0 ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '订单状态:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${_getState()}  ${exchange.status} ${exchange.message}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '承兑人:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${exchange.exchanger}(${exchange.personName})'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '承兑时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(
                    parseStrTime(exchange.ctime, len: 14),
                  )}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '申购合约:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      widget.context.forward(
                        '/weny/record/purchase',
                        arguments: {
                          'record_sn': _exchange.refPurchase,
                          'bank': _bank,
                        },
                      );
                    },
                    child: Text(
                      '查看',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '协议内容:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '查看',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getState() {
    String v = '';
    switch (_exchange.state) {
      case -1:
        v = '失败';
        break;
      case 0:
        v = '承兑中';
        break;
      case 1:
        v = '已承兑';
        break;
    }
    return v;
  }
}

class PlatformShuntRecordPage extends StatefulWidget {
  PageContext context;

  PlatformShuntRecordPage({this.context});

  @override
  _PlatformShuntRecordPageState createState() => _PlatformShuntRecordPageState();
}

class _PlatformShuntRecordPageState extends State<PlatformShuntRecordPage> {
  Timer _timer;
  String _recordSn;
  ShuntOR _shunt;
  BankInfo _bank;

  @override
  void initState() {
    _recordSn = widget.context.parameters['record_sn'];
    _bank = widget.context.parameters['bank'];
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    IWyBankRecordRemote recordRemote =
        widget.context.site.getService("/wybank/records");
    _shunt = await recordRemote.getShuntRecord(_recordSn);
  }

  @override
  Widget build(BuildContext context) {
    ShuntOR shunt = _shunt;
    BankInfo bank = _bank;
    if (shunt == null || bank == null) {
      return Scaffold(
        body: Container(),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: true,
            title: Text('分账合约'),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: _AmountCard(shunt, bank),
          ),
          SliverFillRemaining(
            child: _DetailsCard(shunt, bank),
          ),
        ],
      ),
    );
  }

  Widget _AmountCard(ShuntOR shunt, BankInfo bank) {
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 60,
              bottom: 4,
            ),
            child: Text(
              '分账总金额:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(
            child: Text(
              '¥${(shunt.realAmount / 100.0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DetailsCard(ShuntOR shunt, BankInfo bank) {
    var minWidth = 70.00;
    return Container(
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '单号:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${shunt.sn}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '分账行:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${bank.title}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '请求金额:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      Text('¥${(shunt.reqAmount / 100.00).toStringAsFixed(2)}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '外部单号:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${shunt.outTradeSn ?? ''}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '备注:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${shunt.note ?? ''}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '订单状态:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      Text('${_getState()}  ${shunt.status} ${shunt.message}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '操作人:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${shunt.operator}(${shunt.personName})'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '分账时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(
                    parseStrTime(shunt.ctime, len: shunt.ctime.length),
                  )}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '完成时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(
                    parseStrTime(shunt.dtime, len: shunt.dtime.length),
                  )}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '协议内容:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '查看',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
              top: 30,
              left: 15,
            ),
            child: Text(
              '账金:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Column(
              children: shunt.details.keys.map((key) {
                var details = shunt.details[key];
                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 30,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              right: 10,
                            ),
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.grey[500],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40))),
                            child: Text(
                              '${shunt.shunters[details.shunter]?.alias}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 5,
                              children: <Widget>[
                                Text(
                                  '账比: ${details.ratio.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '账金: ¥${(details.amount / 100.00).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  _getState() {
    String v = '';
    switch (_shunt.state) {
      case -1:
        v = '失败';
        break;
      case 0:
        v = '分账中';
        break;
      case 1:
        v = '已分账';
        break;
    }
    return v;
  }
}
