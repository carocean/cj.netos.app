import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_k_chart/entity/k_line_entity.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:flutter_k_chart/k_chart_widget.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/desklets/desklets.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_prices.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'mine_exchange.dart';
import 'mine_purchase.dart';
import 'package:intl/intl.dart' as intl;

class Weny extends StatefulWidget {
  PageContext context;

  Weny({this.context});

  @override
  _WenyState createState() => _WenyState();
}

class _WenyState extends State<Weny> with SingleTickerProviderStateMixin {
  WenyBank _bank;
  TabController tabController;
  List<TabPageView> tabPageViews;
  StreamController<double> _newPriceNotifyController;
  double _newPrice;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _newPrice = _bank.price;
    _newPriceNotifyController = StreamController.broadcast();
    _streamSubscription = _newPriceNotifyController.stream.listen((price) {
      _newPrice = price;
      if (mounted) {
        setState(() {});
      }
    });
    this.tabPageViews = [
      TabPageView(
        title: '我的申购',
        view: MinePurchases(
          context: widget.context,
          bank: _bank,
          newPriceNotify: _newPriceNotifyController.stream,
        ),
      ),
      TabPageView(
        title: '我的承兑',
        view: MineExchanges(
          context: widget.context,
          bank: _bank,
        ),
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _newPriceNotifyController?.close();
    tabController.dispose();
    tabPageViews.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
//            backgroundColor: Colors.white,
              pinned: true,
              titleSpacing: 0,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    height: 30,
                    child: Icon(
                      Icons.threed_rotation,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '${_bank?.info?.title ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      children: [
                        TextSpan(text: '\r\n'),
                        TextSpan(
                          text: '${_bank?.bank ?? ''}',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _PriceCard(
                bank: _bank,
                context: widget.context,
                newPriceNotifyController: _newPriceNotifyController,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                  bottom: 5,
                ),
                child: Text(
                  '我的账户',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  bottom: 10,
                  top: 20,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '¥${((_bank?.stock ?? 0.0) * (_newPrice) / 100.00).toStringAsFixed(14)}',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 2,
                      ),
                      child: Text(
                        '现值',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _AccountsCard(
                bank: _bank,
                context: widget.context,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: StickyTabBarDelegate(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.black,
                  controller: this.tabController,
                  tabs: tabPageViews.map((v) {
                    return Tab(
                      text: v.title,
                    );
                  }).toList(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: this.tabController,
          children: tabPageViews.map((v) {
            if (v.view == null) {
              return Container(
                width: 0,
                height: 0,
              );
            }
            return v.view;
          }).toList(),
        ),
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  WenyBank bank;
  PageContext context;
  StreamController<double> newPriceNotifyController;

  _PriceCard({this.bank, this.context, this.newPriceNotifyController});

  @override
  _PriceCardState createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  int _limit = 400, _offset = 0;
  List<KLineEntity> _klineEntities = [];
  int _purchaseFundOfDay = 0;
  int _exchangeFundOfDay = 0;
  double _newPrice;
  ///最后一个价格，向服务器拉取该时间后的价格列表
  Timer _timer;

  @override
  void initState() {
    _newPrice = widget.bank.price;
    _pagePrices(DateTime.now()).then((v) async {
      await _updateNewPrice();
      if (mounted) {
        setState(() {});
      }
    });
    _loadIndex(DateTime.now()).then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
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
          await _updateNewPrice();
          if (mounted) {
            setState(() {});
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _klineEntities.clear();
    super.dispose();
  }

  Future<void> _refreshWenyAccount() async {
    IWalletAccountRemote walletAccountService =
        widget.context.site.getService('/wallet/accounts');
    WenyBank bank =
        await walletAccountService.getWenyBankAcount(widget.bank.bank);
    WenyBank old = widget.bank;
    old.profit = bank.profit;
    old.freezen = bank.freezen;
    old.stock = bank.stock;
    old.board=bank.board;
  }

  Future<void> _updateNewPrice() async {
    _newPrice = _klineEntities.isNotEmpty
        ? _klineEntities[_klineEntities.length - 1].amount
        : _newPrice;
    if (!widget.newPriceNotifyController.isClosed) {
      widget.newPriceNotifyController.add(_newPrice);
    }
    widget.bank.price = _newPrice;
    await _refreshWenyAccount();
    await _loadIndex(DateTime.now());
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
        await priceRemote.getAfterTimePrices(widget.bank.bank, timeStr);
    var entities = <KLineEntity>[];
    for (var price in list) {
      var time = parseStrTime(price.ctime, len: 14);
      var id = (time.millisecondsSinceEpoch / 1000).floor();
      if(id==sec) {//如果先前的最后一个价格的时间id等于取出的最后一个id则排除
        continue;
      }
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

  ///加载指标
  Future<void> _loadIndex(DateTime dateTime) async {
    IPriceRemote priceRemote =
        widget.context.site.getService('/wybank/bill/prices');
    _purchaseFundOfDay = await priceRemote.totalPurchaseFundOfDay(
      widget.bank.bank,
      dateTime.year,
      dateTime.month - 1,
      dateTime.day,
    );
    _exchangeFundOfDay = await priceRemote.totalExchangeFundOfDay(
      widget.bank.bank,
      dateTime.year,
      dateTime.month - 1,
      dateTime.day,
    );
  }

  Future<void> _pagePrices(DateTime dateTime) async {
    IPriceRemote priceRemote =
        widget.context.site.getService('/wybank/bill/prices');
    List<PriceOR> list = await priceRemote.page(
      offset: _offset,
      limit: _limit,
      wenyBankID: widget.bank?.bank,
    );
    if (list.isEmpty) {
      return;
    }
    _offset += list.length;
    for (var price in list) {
      var time = parseStrTime(price.ctime, len: 14);
      var id = (time.millisecondsSinceEpoch / 1000).floor();
      _klineEntities.insert(
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
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '最新: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '¥${(_newPrice ?? 0).toStringAsFixed(14)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: widget.bank.change > 0
                                  ? Colors.red
                                  : widget.bank.change < 0 ? Colors.green : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '涨跌: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '¥${( widget.bank.change ?? 0.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: widget.bank.change > 0
                                  ? Colors.red
                                  : widget.bank.change < 0 ? Colors.green : null,
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
                            '今日申购量: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '¥${(_purchaseFundOfDay / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
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
                            '今日承兑量: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '¥${(_exchangeFundOfDay / 100.00).abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
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
                              _pagePrices(DateTime.now()).then((v) {
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
}

class _AccountsCard extends StatefulWidget {
  WenyBank bank;
  PageContext context;

  _AccountsCard({this.bank, this.context});

  @override
  __AccountsCardState createState() => __AccountsCardState();
}

class __AccountsCardState extends State<_AccountsCard> {
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
            title: '存量',
            tips: '₩${(widget.bank?.stock ?? 0).toStringAsFixed(14)}',
            onTap: () {
              widget.context.forward('/wybank/account/stock', arguments: {
                'bank': widget.bank,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '冻结',
            tips: '¥${widget.bank?.freezenYan ?? '-'}',
            onTap: () {
              widget.context.forward('/wybank/account/freezen', arguments: {
                'bank': widget.bank,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '收益',
            tips:  '¥${widget.bank?.profitYan ?? '-'}',
            color:  widget.bank.profit < 0
                ? Colors.green
                : widget.bank.profit > 0 ? Colors.redAccent : null,
            onTap: () {
              widget.context.forward('/wybank/account/profit', arguments: {
                'bank': widget.bank,
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
