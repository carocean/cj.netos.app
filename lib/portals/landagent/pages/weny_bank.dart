import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/entity/k_line_entity.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_prices.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

import 'weny_purchase.dart';

class WenyBankWidget extends StatefulWidget {
  PageContext context;

  WenyBankWidget({this.context});

  @override
  _WenyBankWidgetState createState() => _WenyBankWidgetState();
}

class _WenyBankWidgetState extends State<WenyBankWidget>
    with SingleTickerProviderStateMixin {
  BankInfo _bank;
  Stream _stream;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _stream = widget.context.parameters['stream'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null || _bank == null) {
      return Scaffold(
        body: Container(),
      );
    }
    return Scaffold(
      appBar: AppBar(
//            backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.only(
                right: 10,
              ),
              height: 30,
              child: FadeInImage.assetNetwork(
                placeholder: 'lib/portals/gbera/images/default_avatar.png',
                image:
                    '${_bank?.icon}?accessToken=${widget.context.principal.accessToken}',
                fit: BoxFit.cover,
              ),
            ),
            Text.rich(
              TextSpan(
                text: '${_bank?.title ?? ''}',
                style: TextStyle(
                  fontSize: 18,
                ),
                children: [
                  TextSpan(text: '\r\n'),
                  TextSpan(
                    text: '${_bank.id ?? ''}',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            offset: Offset(
              0,
              50,
            ),
            onSelected: (value) {
              if (value == null) {
                return;
              }
              switch (value) {
                case 'trades':
                  widget.context.forward('/weny/trades', arguments: {
                    'bank': _bank,
                    'stream': _stream,
                  });
                  break;
                case 'parameters':
                  widget.context
                      .forward('/weny/parameters', arguments: {'bank': _bank});
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'trades',
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 10,
                      ),
                      child: Icon(
                        Icons.assessment,
                        size: 20,
                      ),
                    ),
                    Text('交易明细'),
                  ],
                ),
              ),
              PopupMenuDivider(
                height: 1,
              ),
              PopupMenuItem(
                value: 'parameters',
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 10,
                      ),
                      child: Icon(
                        Icons.settings,
                        size: 20,
                      ),
                    ),
                    Text('经营参数'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _PriceCard(
            bank: _bank,
            context: widget.context,
            stream: _stream.asBroadcastStream(),
          ),
          Container(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              left: 10,
              bottom: 5,
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              '经营类余额',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(),
              child: SingleChildScrollView(
                child: _AccountsCard(
                  bank: _bank,
                  context: widget.context,
                  stream: _stream.asBroadcastStream(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  BankInfo bank;
  PageContext context;
  Stream stream;

  _PriceCard({this.bank, this.context, this.stream});

  @override
  _PriceCardState createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  int _limit = 400, _offset = 0;
  List<KLineEntity> _klineEntities = [];
  StreamSubscription _streamSubscription;
  BusinessBuckets _businessBuckets;
  ShuntBuckets _shuntBuckets;
  BulletinBoard _bulletinBoard;
  int _totalInFundOfMonth = 0,
      _totalInFundOfYear = 0,
      _totalOutFundOfMonth = 0,
      _totalOutFundOfYear = 0;

  ///获取涨跌
  Color _changeColor;

  @override
  void initState() {
    widget.stream.listen((event) async {
      BankInfo bank = event['bank'];
      if (bank.id != widget.bank.id) {
        return;
      }
      _businessBuckets = event['businessBuckets'];
      _shuntBuckets = event['shuntBuckets'];
      _bulletinBoard = event['board'];
      await _fetchIndexers();
      if (mounted) {
        setState(() {});
      }
      _loadAfterPricesUpdate().then((list) async {
        if (list.isEmpty) {
          return;
        }
        //怕内存溢出
        if (_klineEntities.length > 600) {
          _klineEntities.clear();
        }
        for (var entity in list) {
          _addLastData(entity);
          if (mounted) {
            setState(() {});
          }
        }
      });
    });
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _klineEntities.clear();
    super.dispose();
  }

  Future<void> _fetchIndexers() async {
    IWyBankRemote wyBankRemote =
        widget.context.site.getService('/wybank/remote');
    _totalInFundOfMonth =
        await wyBankRemote.totalInBillOfMonth(widget.bank.id, DateTime.now());
    _totalInFundOfYear = await wyBankRemote.totalInBillOfYear(widget.bank.id);
    _totalOutFundOfMonth =
        await wyBankRemote.totalOutBillOfMonth(widget.bank.id, DateTime.now());
    _totalOutFundOfYear = await wyBankRemote.totalOutBillOfYear(widget.bank.id);
  }

  Future<void> _load() async {
    await _pagePrices();
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<KLineEntity>> _loadAfterPricesUpdate() async {
    if (_klineEntities.isEmpty) {
      return <KLineEntity>[];
    }

    ///最后一个是最新的价格
    var sec = _klineEntities[_klineEntities.length - 1]?.id;
    var time = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
    var timeStr = DateUtil.formatDate(time, format: 'yyyyMMddHHmmss');

    IPriceRemote priceRemote =
        widget.context.site.getService('/wybank/bill/prices');
    List<PriceOR> list =
        await priceRemote.getAfterTimePrices(widget.bank.id, timeStr);
    var entities = <KLineEntity>[];
    for (var price in list) {
      var time = parseStrTime(price.ctime, len: price.ctime.length);
      var id = (time.millisecondsSinceEpoch / 1000).floor();
      entities.insert(
        0,
        KLineEntity(
          amount: price.price,
          id: id,
          count: _klineEntities.length,
          vol: price.price,
          close: price.price,
          high: price.price,
          low: price.price,
          open: price.price,
        ),
      );
    }
    return entities;
  }

  ///当新价格到时，跑价格，即增加最后一条数据让图走起来
  _addLastData(KLineEntity entity) async {
    DataUtil.addLastData(_klineEntities, entity);
  }

  Future<void> _pagePrices() async {
    IPriceRemote priceRemote =
        widget.context.site.getService('/wybank/bill/prices');
    List<PriceOR> list = await priceRemote.page(
      offset: _offset,
      limit: _limit,
      wenyBankID: widget.bank?.id,
    );
    if (list.isEmpty) {
      return;
    }
    _offset += list.length;
    PriceOR _prev;
    for (var price in list) {
      var time = parseStrTime(price.ctime, len: 14);
      var id = (time.millisecondsSinceEpoch / 1000).floor();
      //以下图表展示的不是天的量，而是按单
      _klineEntities.insert(
        0,
        KLineEntity(
          amount: price.price,
          id: id,
          count: _klineEntities.length,
          vol: price.price,
          close: price.price,
          open: price.price,
          high: price.price > (_prev?.price ?? 0.0)
              ? price.price
              : (_prev?.price ?? 0),
          low: price.price < (_prev?.price ?? 0.0)
              ? price.price
              : (_prev?.price ?? 0),
        ),
      );
      _prev = price;
    }
    DataUtil.calculate(_klineEntities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
//      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '价格: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '¥${(_businessBuckets?.price ?? 0).toStringAsFixed(14)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _changeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '涨跌: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_getChange().toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _changeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 16,
                  child: Divider(
                    height: 1,
                    color: Colors.grey[400],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '昨收: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '¥${(_bulletinBoard?.closePrice ?? 0.00).toStringAsFixed(14)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '今开: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '¥${(_bulletinBoard?.openPrice ?? 0.00).toStringAsFixed(14)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 16,
                  child: Divider(
                    height: 1,
                    color: Colors.grey[400],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '月进: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '¥${((_totalInFundOfMonth ?? 0) / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '月出: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '¥${((_totalOutFundOfMonth ?? 0) / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '年进: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '¥${((_totalInFundOfYear ?? 0) / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '年出: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '¥${((_totalOutFundOfYear ?? 0) / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Adapt.screenW() - Adapt.px(100),
                    maxHeight: 150,
                  ),
                  child: _klineEntities.isEmpty
                      ? Center(
                          child: Text('没有数据'),
                        )
                      : KChartWidget(
                          _klineEntities,
                          isLine: true,
                          fractionDigits: 14,
                          mainState: MainState.MA,
                          secondaryState: SecondaryState.NONE,
                          volState: VolState.NONE,
                          onLoadMore: (value) {
                            if (!value) {
                              _pagePrices().then((v) {
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getChange() {
    if (_bulletinBoard == null || _businessBuckets == null) {
      return 0.0;
    }
    double value = ((_businessBuckets.price - _bulletinBoard.closePrice) /
            _bulletinBoard.closePrice) *
        100.00;
    if (value > 0) {
      _changeColor = Colors.red;
    } else if (value == 0) {
      _changeColor = null;
    } else {
      _changeColor = Colors.green;
    }
    return value;
  }
}

class _AccountsCard extends StatefulWidget {
  BankInfo bank;
  PageContext context;
  Stream stream;

  _AccountsCard({this.bank, this.context, this.stream});

  @override
  __AccountsCardState createState() => __AccountsCardState();
}

class __AccountsCardState extends State<_AccountsCard> {
  StreamSubscription _streamSubscription;
  BusinessBuckets _businessBuckets;
  ShuntBuckets _shuntBuckets;
  BulletinBoard _bulletinBoard;

  @override
  void initState() {
    _streamSubscription = widget.stream.listen((event) {
      BankInfo bank = event['bank'];
      if (bank.id != widget.bank.id) {
        return;
      }
      _businessBuckets = event['businessBuckets'];
      _shuntBuckets = event['shuntBuckets'];
      _bulletinBoard = event['board'];
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _getCardItem(
            title: '纹银存量',
            tips: '₩${(_businessBuckets?.stock ?? 0.00).toStringAsFixed(14)}',
            onTap: () {
              if (_businessBuckets == null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('当前页还在加载中，等稍候再试.'),
                  ),
                );
                return;
              }
              widget.context.forward('/wenybank/account/stock', arguments: {
                'bank': widget.bank,
                'businessBuckets': _businessBuckets,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '资金现量',
            tips:
                '¥${((_businessBuckets?.fundAmount ?? 0.00) / 100).toStringAsFixed(2)}',
            onTap: () {
              if (_businessBuckets == null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('当前页还在加载中，等稍候再试.'),
                  ),
                );
                return;
              }
              widget.context.forward('/wenybank/account/fund', arguments: {
                'bank': widget.bank,
                'businessBuckets': _businessBuckets,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '冻结资金',
            tips:
                '¥${((_businessBuckets?.freezenAmount ?? 0.00) / 100).toStringAsFixed(2)}',
            onTap: () {
              if (_businessBuckets == null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('当前页还在加载中，等稍候再试.'),
                  ),
                );
                return;
              }
              widget.context.forward('/wenybank/account/freezen', arguments: {
                'bank': widget.bank,
                'businessBuckets': _businessBuckets,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '可分余额',
            tips:
                '¥${((_businessBuckets?.freeAmount ?? 0.00) / 100).toStringAsFixed(2)}',
            onTap: () {
              if (_businessBuckets == null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('当前页还在加载中，等稍候再试.'),
                  ),
                );
                return;
              }
              widget.context.forward('/wenybank/account/free', arguments: {
                'bank': widget.bank,
                'businessBuckets': _businessBuckets,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '账金账户',
            tips:
                '¥${((_shuntBuckets?.laAmount ?? 0.00) / 100).toStringAsFixed(2)}',
            onTap: () {
              if (_shuntBuckets == null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('当前页还在加载中，等稍候再试.'),
                  ),
                );
                return;
              }
              widget.context.forward('/wenybank/account/shunters', arguments: {
                'bank': widget.bank,
                'shuntBuckets': _shuntBuckets,
              });
            },
          ),
        ],
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final Color color;

  StickyTabBarDelegate({@required this.child, @required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: this.child,
      color: color,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

Widget _getCardItem(
    {String title, String tips, Color color, Function() onTap}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.only(
        top: 18,
        bottom: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${title ?? ''}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${tips ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color ?? Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
