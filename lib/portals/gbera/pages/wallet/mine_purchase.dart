import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:intl/intl.dart' as intl;
class MinePurchases extends StatefulWidget {
  PageContext context;
  WenyBank bank;
  Stream<double> newPriceNotify;

  MinePurchases({
    this.context,
    this.bank,
    this.newPriceNotify,
  });

  @override
  _MinePurchasesState createState() => _MinePurchasesState();
}

class _MinePurchasesState extends State<MinePurchases> {
  List<PurchaseOR> _purchases = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  double _newPrice;
  StreamSubscription _streamSubscription;
  int _tabPurchasesFilter = 0; //0为未承兑；1为已承兑；2为all
  @override
  void initState() {
    _newPrice = widget.bank.price;
    _streamSubscription = widget.newPriceNotify.listen((price) {
      _newPrice = price;
      if (mounted) {
        setState(() {});
      }
    });
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
  Future<void> _onRefresh()async{
    _offset=0;
    _purchases.clear();
    await _onload();
  }
  Future<void> _onload() async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService("/wallet/records");
    var purchases;
    switch (_tabPurchasesFilter) {
      case 0:
        purchases = await recordRemote.pagePurchaseUnExchange(
            widget.bank.bank, _limit, _offset);
        break;
      case 1:
        purchases = await recordRemote.pagePurchaseExchanged(
            widget.bank.bank, _limit, _offset);
        break;
      case 2:
        purchases =
            await recordRemote.pagePurchase(widget.bank.bank, _limit, _offset);
        break;
      default:
        throw FlutterError('不支持');
    }
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
                    _tabPurchasesFilter = 0;
                    _onload();
                  },
                  child: Container(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: _tabPurchasesFilter == 0 ? '| ' : '',
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
              ],
            ),
          ),
          Expanded(
            child: EasyRefresh.custom(
              controller: _controller,
              onRefresh: _onRefresh,
              onLoad: _onload,
              slivers: _purchases.map((purch) {
                return SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward(
                        '/wybank/purchase/details',
                        arguments: {'purch': purch, 'bank': widget.bank},
                      ).then((value) {
                        if (purch.exchangeState == 0) {
                          return;
                        }
                        _purchases.removeWhere((p) {
                          return purch.sn == p.sn;
                        });
                        if (mounted) {
                          setState(() {});
                        }
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
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(purch.ctime))}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 5,
                                                  bottom: 5,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                      '${purch.state == 1 ? '已完成' : '申购中'}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                  Expanded(
                                                    child: Text(
                                                      '${purch.message}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                        color: Colors.grey[400],
                                                      ),
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
                                                '${((purch.purchAmount ?? 0.0) / 100.0).toStringAsFixed(2)}',
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
                                        _tabPurchasesFilter==1?SizedBox(height: 0,width: 0,):
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
                                                '现值:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${((purch.stock ?? 0.00) * _newPrice) / 100.00}',
                                                style: TextStyle(
                                                  color: (purch.stock ?? 0) *
                                                              widget
                                                                  .bank.price <
                                                          purch.purchAmount
                                                      ? Colors.green
                                                      : (purch.stock ?? 0) *
                                                                  widget.bank
                                                                      .price >
                                                              purch.purchAmount
                                                          ? Colors.redAccent
                                                          : null,
                                                  fontWeight: FontWeight.w500,
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
