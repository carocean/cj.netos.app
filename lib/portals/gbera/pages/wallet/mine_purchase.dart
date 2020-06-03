import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_purchases.dart';

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
  @override
  void initState() {
    _newPrice = widget.bank.price;
    _streamSubscription= widget.newPriceNotify.listen((price) {
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

  Future<void> _onload() async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService("/wallet/records");
    var purchases = await recordRemote.pagePurchase(_limit, _offset);
    if (purchases.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
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
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: EasyRefresh.custom(
        controller: _controller,
        onLoad: _onload,
        slivers: _purchases.map((purch) {
          return SliverToBoxAdapter(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '${TimelineUtil.formatByDateTime(
                                          parseStrTime(purch.ctime),
                                          dayFormat: DayFormat.Full,
                                        )}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '金额:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${(purch.purchAmount / 100.0).toStringAsFixed(2)}',
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
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '买价:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${purch.price}',
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
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '纹银:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${purch.stock}',
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
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '现值:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${((purch.stock * _newPrice) / 100)}',
                                        style: TextStyle(
                                          color: purch.stock *
                                                      widget.bank.price <
                                                  purch.purchAmount
                                              ? Colors.green
                                              : purch.stock *
                                                          widget.bank.price >
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
          );
        }).toList(),
      ),
    );
  }
}
