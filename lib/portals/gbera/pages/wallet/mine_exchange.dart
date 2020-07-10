import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:intl/intl.dart' as intl;
class MineExchanges extends StatefulWidget {
  PageContext context;
  WenyBank bank;

  MineExchanges({
    this.context,
    this.bank,
  });

  @override
  _MineExchangesState createState() => _MineExchangesState();
}

class _MineExchangesState extends State<MineExchanges> {
  List<ExchangeOR> _exchanges = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> _onRefresh()async{
    _offset=0;
    _exchanges.clear();
    await _onload();
  }
  Future<void> _onload() async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService("/wallet/records");
    var exchanges = await recordRemote.pageExchange(widget.bank.bank,_limit, _offset);
    if (exchanges.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
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
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: EasyRefresh.custom(
        controller: _controller,
        onRefresh: _onRefresh,
        onLoad: _onload,
        slivers: _exchanges.map((exchange) {
          return SliverToBoxAdapter(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward(
                  '/wybank/exchange/details',
                  arguments: {'exchange': exchange, 'bank': widget.bank},
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.monetization_on,
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
                                        '${exchange.sn}',
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
                                          '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(exchange.ctime))}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            text: '状态: ',
                                            children: [
                                              TextSpan(
                                                  text: '${exchange.status}'),
                                              TextSpan(text: '  '),
                                              TextSpan(
                                                  text: '${exchange.message}'),
                                            ],
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                            fontSize: 12,
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '申购金额:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${(exchange.purchAmount / 100.0).toStringAsFixed(2)}',
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
                                          '获得金额:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${((exchange.amount??0) / 100.0).toStringAsFixed(2)}',
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
                                          '最终收益:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${((exchange.profit??0) / 100.0).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: (exchange.profit??0) > 0
                                                ? Colors.red
                                                : (exchange.profit??0) < 0
                                                    ? Colors.green
                                                    : null,
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '承兑价格:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${(exchange.price??0.00).toStringAsFixed(14)}',
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
                                          '承兑纹银:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${exchange.stock}',
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
    );
  }
}
