import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';

class PurchaseDetails extends StatefulWidget {
  PageContext context;

  PurchaseDetails({this.context});

  @override
  _PurchaseDetailsState createState() => _PurchaseDetailsState();
}

class _PurchaseDetailsState extends State<PurchaseDetails> {
  List<PurchaseActivityOR> _purchaseActivities = [];
  int _exchangeState = 0; //0为未开始；1为正在承兑；2为已承兑
  Timer _timer;
  PurchaseOR _purch;
  WenyBank _bank;

  @override
  void initState() {
    _purch = widget.context.parameters['purch'];
    _bank = widget.context.parameters['bank'];
    _exchangeState = _purch.exchangeState;
    if (mounted) {
      setState(() {});
    }
    _loadActivities().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _purchaseActivities?.clear();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService("/wallet/records");
    _purchaseActivities = await recordRemote.getPurchaseActivies(_purch.sn);
  }

  Future<void> _doExchange() async {
    _exchangeState = 1;
    if (mounted) {
      setState(() {});
    }
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService("/wallet/trades");
    IWalletRecordRemote recordRemote =
        widget.context.site.getService("/wallet/records");

    ExchangeResult result;
    try {
      result = await tradeRemote.exchange(_purch.sn);
    } catch (e) {
      _exchangeState = 2;
      _purch.exchangeState = _exchangeState;
      if (mounted) {
        setState(() {});
      }
      throw e;
    }
    _timer = Timer.periodic(
        Duration(
          seconds: 1,
        ), (timer) async {
      if (_exchangeState > 1) {
        return;
      }
      var record = await recordRemote.getExchangeRecord(result.sn);
      if (record.state == 1) {
        timer.cancel();
        _exchangeState = 2;
        _purch.exchangeState = _exchangeState;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PurchaseOR purch = _purch;
    WenyBank bank = _bank;
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

  Widget _AmountCard(PurchaseOR purch, WenyBank bank) {
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
              '现值:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(
            child: Text(
              '¥${((purch.stock ?? 0) * bank.price) / 100.00}',
              style: TextStyle(
                fontSize: 30,
                color: ((purch.stock ?? 0) * bank.price) < purch.purchAmount
                    ? Colors.green
                    : ((purch.stock ?? 0) * bank.price) > purch.purchAmount
                        ? Colors.red
                        : null,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: _renderExchangeOperator(purch, bank),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DetailsCard(PurchaseOR purch, WenyBank bank) {
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
                  child: Text('${bank.info.title}'),
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
                  child: Text('₩${(purch.stock ?? 0.00).toStringAsFixed(14)}'),
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
                      '¥${(purch.purchAmount / 100.00).toStringAsFixed(2)}'),
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
                  child: Text('¥${(purch.price ?? 0).toStringAsFixed(14)}'),
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
                  child: Text(
                      '¥${((purch.serviceFee ?? 0) / 100.00).toStringAsFixed(2)}'),
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
                    '冻结金额:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text:
                          '¥${((purch.principalAmount ?? 0) / 100.00).toStringAsFixed(2)}',
                      children: [
                        TextSpan(
                          text: ' (在${purch.personName}的冻结账户余额中，成功承兑后自动解冻并转入${purch.personName}的收益金账户中)',
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
                      '${purch.state == 0 ? '申购中' : purch.state == 1 ? '已完成' : ''}  ${purch.status} ${purch.message}'),
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
                    '承兑状态:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${purch.exchangeState == 0 ? '未承兑' : purch.exchangeState == 1 ? '承兑中' : purch.exchangeState == 2 ? '已承兑' : ''}'),
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
                  child: Text('${TimelineUtil.formatByDateTime(
                    parseStrTime(purch.ctime),
                    locale: 'zh',
                    dayFormat: DayFormat.Full,
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
              '处理过程:',
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
              children: _purchaseActivities.map((activity) {
                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 50,
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                    right: 10,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[500],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Text(
                                    '${activity.activityNo}',
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
                                        '${activity.activityName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 10,
                                        children: <Widget>[
                                          Text(
                                            '${activity.status}',
                                          ),
                                          Text(
                                            '${activity.message}',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Text(
                              '${TimelineUtil.formatByDateTime(parseStrTime(activity.ctime), dayFormat: DayFormat.Full)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
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

  _renderExchangeOperator(PurchaseOR purch, WenyBank bank) {
    if (widget.context.principal.person != purch.person) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    switch (_exchangeState) {
      case 0:
        return FlatButton(
          color: Colors.green,
          onPressed: () {
            _doExchange().then((v) {
              if (mounted) {
                setState(() {});
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            child: Text(
              '承兑',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      case 1:
        return SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        );
      case 2:
        return Text(
          '已承兑',
          style: TextStyle(
            color: Colors.grey[500],
          ),
        );
    }
  }
}
