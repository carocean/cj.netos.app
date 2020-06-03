import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:framework/framework.dart';

import 'tab_page.dart';

class LandAgentFutrue extends StatefulWidget {
  PageContext context;

  LandAgentFutrue({this.context});

  @override
  _LandAgentFutrueState createState() => _LandAgentFutrueState();
}

class _LandAgentFutrueState extends State<LandAgentFutrue>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List<TabPageView> tabPageViews;

  @override
  void initState() {
    super.initState();
    this.tabPageViews = [
      TabPageView(
        title: '简介',
        view: TzContractDescPageView(),
      ),
      TabPageView(
        title: '盘口',
        view: TzPositionPageView(),
      ),
      TabPageView(
        title: '成交明细',
        view: TzClosingDetailsPageView(),
      ),
      TabPageView(
        title: '资讯',
        view: NewsPageView(),
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    this.tabController.dispose();
    this.tabPageViews.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
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
                  child: Image.network(
                    'http://47.105.165.186:7100/public/market/timg-3.jpeg?App-ID=${widget.context.principal.appid}&Access-Token=${widget.context.principal.accessToken}',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '德宝科技',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(text: '\r\n'),
                      TextSpan(
                        text: '东莞市·F00038',
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
            child: _HeaderCard(),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: _KChartCard(
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
          SliverFillRemaining(
            fillOverscroll: false,
            hasScrollBody: true,
            child: TabBarView(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('下单'),
        onPressed: () {},
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

class _HeaderCard extends StatefulWidget {
  @override
  __HeaderCardState createState() => __HeaderCardState();
}

class __HeaderCardState extends State<_HeaderCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Text(
                    '12355',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                      text: '-85',
                      children: [
                        TextSpan(
                          text: '   ',
                        ),
                        TextSpan(
                          text: '-0.68%',
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
              right: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '高',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '12415',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
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
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '低',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '12300',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '持仓',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '17.71万',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
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
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '成交',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '45158',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _KChartCard extends StatefulWidget {
  PageContext context;

  _KChartCard({this.context});

  @override
  _KChartCardState createState() => _KChartCardState();
}

class _KChartCardState extends State<_KChartCard> {
  List<KLineEntity> datas;
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  SecondaryState _secondaryState = SecondaryState.NONE;
  bool isSecondaryStateClosed = true;
  bool isLine = true;
  bool isShowDepthChart = false;
  List<DepthEntity> _bids, _asks;
  double _rightHeight = 400;

  @override
  void initState() {
    super.initState();
    getData('1day');
    rootBundle.loadString('lib/portals/gbera/data/depth.json').then((result) {
      final parseJson = json.decode(result);
      Map tick = parseJson['tick'];
      var bids = tick['bids']
          .map((item) => DepthEntity(item[0], item[1]))
          .toList()
          .cast<DepthEntity>();
      var asks = tick['asks']
          .map((item) => DepthEntity(item[0], item[1]))
          .toList()
          .cast<DepthEntity>();
      initDepth(bids, asks);
    });
  }

  void initDepth(List<DepthEntity> bids, List<DepthEntity> asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = List();
    _asks = List();
    double amount = 0.0;
    bids?.sort((left, right) => left.price.compareTo(right.price));
    //倒序循环 //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.amount;
      item.amount = amount;
      _bids.insert(0, item);
    });

    amount = 0.0;
    asks?.sort((left, right) => left.price.compareTo(right.price));
    //循环 //累加买入委托量
    asks?.forEach((item) {
      amount += item.amount;
      item.amount = amount;
      _asks.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isShowDepthChart == true) {
      _rightHeight += 212;
    } else {
      _rightHeight = 400;
    }
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLine = true;
                    _mainState = MainState.NONE;
                    isShowDepthChart = false;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '分时',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: DropdownButton(
                  value: _mainState,
                  onChanged: (value) {
                    isLine = false;
                    _mainState = value;
                    setState(() {});
                    return _mainState;
                  },
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  elevation: 0,
                  iconSize: 14,
                  isDense: true,
                  underline: Container(
                    width: 0,
                    height: 0,
                  ),
                  items: [
                    DropdownMenuItem(
                      child: Text('K线'),
                      value: MainState.NONE,
                    ),
                    DropdownMenuItem(
                      child: Text('MA'),
                      value: MainState.MA,
                    ),
                    DropdownMenuItem(
                      child: Text('BOLL'),
                      value: MainState.BOLL,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: DropdownButton(
                  value: isShowDepthChart,
                  onChanged: (value) {
                    isShowDepthChart = value;
                    setState(() {});
                    return isShowDepthChart;
                  },
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  elevation: 0,
                  iconSize: 14,
                  isDense: true,
                  underline: Container(
                    width: 0,
                    height: 0,
                  ),
                  items: [
                    DropdownMenuItem(
                      child: Text('深度'),
                      value: true,
                    ),
                    DropdownMenuItem(
                      child: Text('隐藏'),
                      value: false,
                    ),
                  ],
                ),
              ),
              Container(
                height: 14,
                child: VerticalDivider(
                  width: 1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSecondaryStateClosed = false;
                    _secondaryState = SecondaryState.MACD;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    'MACD',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSecondaryStateClosed = false;
                    _secondaryState = SecondaryState.KDJ;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    'KDJ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSecondaryStateClosed = false;
                    _secondaryState = SecondaryState.RSI;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    'RSI',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSecondaryStateClosed = false;
                    _secondaryState = SecondaryState.WR;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    'WR',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              isSecondaryStateClosed
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _secondaryState = SecondaryState.NONE;
                          isSecondaryStateClosed = !isSecondaryStateClosed;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 0,
                          bottom: 0,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      height: 400,
                      width: double.infinity,
                      child: KChartWidget(
                        datas,
                        isLine: isLine,
                        mainState: _mainState,
                        secondaryState: _secondaryState,
                        volState: VolState.VOL,
                        fractionDigits: 4,
                      ),
                    ),
                    if (showLoading)
                      Container(
                          width: double.infinity,
                          height: 400,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator()),
                  ]),
                  if (isShowDepthChart)
                    Container(
                      height: 230,
                      width: double.infinity,
                      child: DepthChart(_bids, _asks),
                    ),
                ],
              ),
            ),
            Container(
              width: 100,
              color: Colors.white,
              height: _rightHeight,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '卖价',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '12425',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '45',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '买价',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '12420',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '6',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 5,
                      top: 5,
                      left: 5,
                      right: 5,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '时间',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '价格',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '现手',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 5,
                      ),
                      children: <Widget>[
                        _BidsItemView(),
                        _BidsItemView(),
                        _BidsItemView(),
                        _BidsItemView(),
                        _BidsItemView(),
                        _BidsItemView(),
                        _BidsItemView(),
                        _BidsItemView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

//  Widget buildButtons() {
//    return Wrap(
//      alignment: WrapAlignment.spaceEvenly,
//      children: <Widget>[
//        button("分时", onPressed: () => isLine = true),
//        button("k线", onPressed: () => isLine = false),
//        button("MA", onPressed: () => _mainState = MainState.MA),
//        button("BOLL", onPressed: () => _mainState = MainState.BOLL),
//        button("隐藏", onPressed: () => _mainState = MainState.NONE),
//        button("MACD", onPressed: () => _secondaryState = SecondaryState.MACD),
//        button("KDJ", onPressed: () => _secondaryState = SecondaryState.KDJ),
//        button("RSI", onPressed: () => _secondaryState = SecondaryState.RSI),
//        button("WR", onPressed: () => _secondaryState = SecondaryState.WR),
//        button("隐藏副视图", onPressed: () => _secondaryState = SecondaryState.NONE),
//        button("update", onPressed: () {
//          //更新最后一条数据
//          datas.last.close += (Random().nextInt(100) - 50).toDouble();
//          datas.last.high = max(datas.last.high, datas.last.close);
//          datas.last.low = min(datas.last.low, datas.last.close);
//          DataUtil.updateLastData(datas);
//        }),
//        button("addData", onPressed: () {
//          //拷贝一个对象，修改数据
//          var kLineEntity = KLineEntity.fromJson(datas.last.toJson());
//          kLineEntity.id += 60 * 60 * 24;
//          kLineEntity.open = kLineEntity.close;
//          kLineEntity.close += (Random().nextInt(100) - 50).toDouble();
//          datas.last.high = max(datas.last.high, datas.last.close);
//          datas.last.low = min(datas.last.low, datas.last.close);
//          DataUtil.addLastData(datas, kLineEntity);
//        }),
//      ],
//    );
//  }
//
//  Widget button(String text, {VoidCallback onPressed}) {
//    return FlatButton(
//        onPressed: () {
//          if (onPressed != null) {
//            onPressed();
//            setState(() {});
//          }
//        },
//        child: Text("$text"),
//        color: Colors.blue);
//  }

  void getData(String period) async {
    String result;
    try {
      result = await rootBundle.loadString('lib/portals/gbera/data/kline.json');
    } catch (e) {
      print('获取数据失败,获取本地数据');
    } finally {
      Map parseJson = json.decode(result);
      List list = parseJson['data'];
      datas = list
          .map((item) => KLineEntity.fromJson(item))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      DataUtil.calculate(datas);
      showLoading = false;
      setState(() {});
    }
  }
}

class _BidsItemView extends StatefulWidget {
  @override
  _BidsItemViewState createState() => _BidsItemViewState();
}

class _BidsItemViewState extends State<_BidsItemView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text(
              '22:59',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                    left: 1,
                    right: 1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '12420',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '2',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.only(
                    left: 1,
                    right: 1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '空开',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '2',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
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
