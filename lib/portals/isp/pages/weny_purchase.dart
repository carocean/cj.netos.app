import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/records.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:intl/intl.dart' as intl;

class WenyPurchases extends StatefulWidget {
  PageContext context;
  BankInfo bank;
  Stream<dynamic> stream;
  Stream datePicker;
  DateTime defaultDate;

  WenyPurchases({
    this.context,
    this.bank,
    this.stream,
    this.datePicker,
    this.defaultDate,
  });

  @override
  _WenyPurchasesState createState() => _WenyPurchasesState();
}

class _WenyPurchasesState extends State<WenyPurchases> {
  List<PurchaseOR> _purchases = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  DateTime _selectedDateTime;

  //-1申购失败
//  0申购中
//  1申购成功
//  2承兑中
//  3已承兑
  int _tabPurchasesFilter = 1;
  StreamSubscription _streamSubscription;
  StreamSubscription _date_picker_streamSubscription;
  double _nowPrice = 0.00;

  @override
  void initState() {
    _selectedDateTime = widget.defaultDate;
    _controller = EasyRefreshController();
    _date_picker_streamSubscription = widget.datePicker.listen((event)async {
      _selectedDateTime = event['date'];
      await _onRefresh();
      if (mounted) {
        setState(() {});
      }
    });
    _streamSubscription = widget.stream.listen((event) {
      BankInfo bank = event['bank'];
      if (bank.id != widget.bank.id) {
        return;
      }
      BusinessBuckets businessBuckets = event['businessBuckets'];
      _nowPrice = businessBuckets.price;
      if (mounted) {
        setState(() {});
      }
    });

    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _date_picker_streamSubscription?.cancel();
    _controller.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
  Future<void> _onRefresh()async{
    _offset=0;
    _purchases.clear();
    await _onload();
  }
  Future<void> _onload() async {
    IWyBankRecordRemote recordRemote =
        widget.context.site.getService("/wybank/records");
    var purchases = await recordRemote.pagePurchase(
        widget.bank.id,_selectedDateTime, _tabPurchasesFilter, _limit, _offset);
    if (purchases.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _purchases.addAll(purchases);
    _offset += purchases.length;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
            ),
            margin: EdgeInsets.only(
              bottom: 10,
            ),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _purchases.clear();
                    _offset = 0;
                    _tabPurchasesFilter = 1;
                    _onload();
                  },
                  child: Container(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: _tabPurchasesFilter == 1 ? '| ' : '',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: '未承兑',
                          ),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      right: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _purchases.clear();
                    _offset = 0;
                    _tabPurchasesFilter = 3;
                    _onload();
                  },
                  child: Container(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: _tabPurchasesFilter == 3 ? '| ' : '',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: '已承兑',
                          ),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      right: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _purchases.clear();
                    _offset = 0;
                    _tabPurchasesFilter = -1;
                    _onload();
                  },
                  child: Container(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: _tabPurchasesFilter == -1 ? '| ' : '',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: '失败',
                          ),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      right: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: EasyRefresh.custom(
              controller: _controller,
              onLoad: _onload,
              slivers: _purchases.map((purch) {
                return SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward(
                        '/weny/details/purchase',
                        arguments: {'purch': purch, 'bank': widget.bank,'nowPrice':_nowPrice},
                      ).then((value) {
//                        if (purch.exchangeState == 0) {
//                          return;
//                        }
//                        _purchases.removeWhere((p) {
//                          return purch.sn == p.sn;
//                        });
//                        if (mounted) {
//                          setState(() {});
//                        }
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Icon(
                            FontAwesomeIcons.buysellads,
                            color: Colors.grey[800],
                            size: 35,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '${purch.sn}',
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          child: Wrap(
                                            spacing: 5,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(purch.ptime, len: 14))}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    '状态: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[500],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${purch.state == 1 ? '已完成' : purch.state == 3 ? '已承兑' : purch.state == -1 ? '已失败' : ''}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[500],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    '${purch.status}  ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${purch.message}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          child: Wrap(
                                            spacing: 5,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                '金额:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${((purch.amount ?? 0.0) / 100.0).toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          child: Wrap(
                                            spacing: 5,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                '买价:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${(purch.price ?? 0.0).toStringAsFixed(14)}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          child: Wrap(
                                            spacing: 5,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                '纹银:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${(purch.stock ?? 0.0).toStringAsFixed(14)}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          child: Wrap(
                                            spacing: 5,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                '市盈:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${(purch.ttm).toStringAsFixed(4)}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        purch.state == 1
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                ),
                                                child: Wrap(
                                                  spacing: 5,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                      '现值:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '¥${((purch.stock * _nowPrice) / 100).toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: purch.stock *
                                                                    _nowPrice >
                                                                purch.amount
                                                            ? Colors.red
                                                            : purch.stock *
                                                                        _nowPrice ==
                                                                    purch.amount
                                                                ? null
                                                                : Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              ),
                              Container(
                                height: 20,
                                child: Divider(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
