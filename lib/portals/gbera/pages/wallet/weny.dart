import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/desklets/desklets.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_purchases.dart';

import 'mine_exchange.dart';
import 'mine_purchase.dart';

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

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];

    this.tabPageViews = [
      TabPageView(
        title: '我的申购',
        view: MinePurchases(
          context: widget.context,
          bank: _bank,
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
                      '${((_bank?.stock ?? 0.0) * (_bank?.price ?? 0.0) / 100.00)}',
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

  _PriceCard({this.bank});

  @override
  _PriceCardState createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
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
                        '价    格: ',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${widget.bank?.price ?? '-'}',
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
                        '日成交: ',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '2323.23',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
                  child: CustomAxisTickFormatters.withSampleData(),
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

  _AccountsCard({this.bank});

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
          CardItem(
            title: '存量',
            tipsText: '${widget.bank?.stock ?? '-'}',
          ),
          Divider(
            height: 1,
          ),
          CardItem(
            title: '冻结',
            tipsText: '${widget.bank?.freezenYan ?? '-'}',
          ),
          Divider(
            height: 1,
          ),
          CardItem(
            title: '收益',
            tipsText: '${widget.bank?.profitYan ?? '-'}',
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
