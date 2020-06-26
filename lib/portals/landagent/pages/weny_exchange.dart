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

class WenyExchanges extends StatefulWidget {
  PageContext context;
  BankInfo bank;
  Stream datePicker;
  DateTime defaultDate;
  Stream stream;
  WenyExchanges({
    this.context,
    this.bank,
    this.datePicker,
    this.defaultDate,
    this.stream,
  });

  @override
  _WenyExchangesState createState() => _WenyExchangesState();
}

class _WenyExchangesState extends State<WenyExchanges> {
  List<ExchangeOR> _exchanges = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  DateTime _selectedDateTime;
  double _nowPrice=0;
//  -1失败
//  0承兑中
//  1完成
  int _tabFilter = 1;
  StreamSubscription _date_picker_streamSubscription;
  StreamSubscription _streamSubscription;
  @override
  void initState() {
    _selectedDateTime = widget.defaultDate;
    _controller = EasyRefreshController();
    _date_picker_streamSubscription = widget.datePicker.listen((event) async {
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
    _streamSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _exchanges.clear();
    await _onload();
  }

  Future<void> _onload() async {
    IWyBankRecordRemote recordRemote =
        widget.context.site.getService("/wybank/records");
    var exchanges = await recordRemote.pageExchange(
        widget.bank.id, _selectedDateTime, _tabFilter, _limit, _offset);
    if (exchanges.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _exchanges.addAll(exchanges);
    _offset += exchanges.length;
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
                    _exchanges.clear();
                    _offset = 0;
                    _tabFilter = 1;
                    _onload();
                  },
                  child: Container(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: _tabFilter == 1 ? '| ' : '',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: '成功',
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
                    _exchanges.clear();
                    _offset = 0;
                    _tabFilter = -1;
                    _onload();
                  },
                  child: Container(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: _tabFilter == -1 ? '| ' : '',
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
              slivers: _exchanges.map((exch) {
                return SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward(
                        '/weny/details/exchange',
                        arguments: {'exchange': exch, 'bank': widget.bank,'nowPrice':_nowPrice},
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
                                              '${exch.sn}',
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
                                                '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(exch.ctime, len: 14))}',
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
                                                    '${exch.state == 1 ? '已完成' : exch.state == 3 ? '已承兑' : exch.state == -1 ? '已失败' : ''}',
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
                                                    '${exch.status}  ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${exch.message}',
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
                                                '${((exch.amount ?? 0.0) / 100.0).toStringAsFixed(2)}',
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
                                                '${(exch.price ?? 0.0).toStringAsFixed(14)}',
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
                                                '${(exch.stock ?? 0.0).toStringAsFixed(14)}',
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
                                                '收益:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${(exch.profit / 100.0).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: exch.profit > 0
                                                      ? Colors.red
                                                      : exch.profit == 0
                                                          ? null
                                                          : Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
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
