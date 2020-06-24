import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/entity/k_line_entity.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

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
  TabController tabController;
  List<TabPageView> tabPageViews;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _stream = widget.context.parameters['stream'];
    this.tabPageViews = [
      TabPageView(
        title: '申购',
        view: Container(),
//        view: MinePurchases(
//          context: widget.context,
//          bank: _bank,
//          newPriceNotify: _newPriceNotifyController.stream,
//        ),
      ),
      TabPageView(
        title: '承兑',
        view: Container(),
//        view: MineExchanges(
//          context: widget.context,
//          bank: _bank,
//        ),
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    tabPageViews.clear();
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
                    child: FadeInImage.assetNetwork(
                      placeholder:
                          'lib/portals/gbera/images/default_avatar.png',
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
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.bubble_chart,
                              size: 20,
                            ),
                          ),
                          Text('查看市盈率'),
                        ],
                      ),
                    ),
                    PopupMenuDivider(
                      height: 1,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.pie_chart_outlined,
                              size: 20,
                            ),
                          ),
                          Text('查看账比'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _PriceCard(
                bank: _bank,
                context: widget.context,
                stream: _stream.asBroadcastStream(),
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
                  '市场经营余额账户',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _AccountsCard(
                bank: _bank,
                context: widget.context,
                stream: _stream.asBroadcastStream(),
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
  int _purchaseFundOfDay = 0;
  int _exchangeFundOfDay = 0;
  StreamSubscription _streamSubscription;
  BusinessBuckets _businessBuckets;
  ShuntBuckets _shuntBuckets;

  @override
  void initState() {
    widget.stream.listen((event) {
      BankInfo bank = event['bank'];
      if (bank.id == widget.bank.id) {
        return;
      }
      var buckets = event['buckets'];
      if (buckets is BusinessBuckets) {
        _businessBuckets = buckets;
      }
      if (buckets is ShuntBuckets) {
        _shuntBuckets = buckets;
      }
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _klineEntities.clear();
    super.dispose();
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
                            '¥${(_purchaseFundOfDay / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
                            '¥0.00323838847547',
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
                            '¥0.00323838847582',
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
                            '¥${(_purchaseFundOfDay / 100.00).toStringAsFixed(2)}',
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
                            '¥${(_exchangeFundOfDay / 100.00).abs().toStringAsFixed(2)}',
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
                            '¥${(_purchaseFundOfDay / 100.00).toStringAsFixed(2)}',
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
                            '¥${(_exchangeFundOfDay / 100.00).abs().toStringAsFixed(2)}',
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
                          onLoadMore: (value) {},
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
  BankInfo bank;
  PageContext context;
  Stream stream;

  _AccountsCard({this.bank, this.context, this.stream});

  @override
  __AccountsCardState createState() => __AccountsCardState();
}

class __AccountsCardState extends State<_AccountsCard> {
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamSubscription = widget.stream.listen((event) {});
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
            tips: '₩',
            onTap: () {
              widget.context.forward('/wenybank/account/stock', arguments: {
                'bank': widget.bank,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '资金现量',
            tips: '¥38388.34',
            onTap: () {
              widget.context.forward('/wenybank/account/fund', arguments: {
                'bank': widget.bank,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '冻结资金',
            tips: '¥',
            onTap: () {
              widget.context.forward('/wenybank/account/freezen', arguments: {
                'bank': widget.bank,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '自由资金',
            tips: '¥',
            onTap: () {
              widget.context.forward('/wenybank/account/free', arguments: {
                'bank': widget.bank,
              });
            },
          ),
          Divider(
            height: 1,
          ),
          _getCardItem(
            title: '账金账户',
            tips: '¥939.23',
            onTap: () {
              widget.context.forward('/wenybank/account/free', arguments: {
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
