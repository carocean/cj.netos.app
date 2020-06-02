import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TabPageView {
  String title;
  Widget view;

  TabPageView({
    this.title,
    this.view,
  });
}

class NewsPageView extends StatefulWidget {
  @override
  _NewsPageViewState createState() => _NewsPageViewState();
}

class _NewsPageViewState extends State<NewsPageView> {
  List<TimeLife> timelifeList;

  @override
  void initState() {
    super.initState();
    timelifeList = _allTimelifes();
  }

  @override
  void dispose() {
    super.dispose();
    timelifeList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: timelifeList.map((life) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 4,
                  top: 10,
                ),
                child: Text(
                  life.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: life.newsList.map((news) {
                  return Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      top: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[100],
                        style: BorderStyle.solid,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                          ),
                          child: Text(
                            news.title,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: news.time,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextSpan(text: '   '),
                              TextSpan(
                                text: news.source,
                                style: TextStyle(
                                  color: Colors.grey[600],
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
            ],
          );
        }).toList(),
      ),
    );
  }

  List<TimeLife> _allTimelifes() {
    return [
      TimeLife(
        title: '今天',
        newsList: [
          News(
            title: '防为主 录求期指比值套利机会',
            source: '期货日报',
            time: '22:49',
          ),
          News(
            title: '股指：量缩价稳股指延续观望',
            source: '期货日报',
            time: '16:12',
          ),
        ],
      ),
      TimeLife(
        title: '一周内',
        newsList: [
          News(
            title: '股指：官媒缓虑 股指观望',
            source: '我的钢铁网',
            time: '12:02',
          ),
          News(
            title: '德宝投资爱之餐饮集团',
            source: '德宝新闻',
            time: '10:34',
          ),
          News(
            title: '股指：官媒缓虑 股指观望',
            source: '我的钢铁网',
            time: '12:02',
          ),
          News(
            title: '德宝投资爱之餐饮集团',
            source: '德宝新闻',
            time: '10:34',
          ),
        ],
      ),
      TimeLife(
        title: '一周内',
        newsList: [
          News(
            title: '股指：官媒缓虑 股指观望',
            source: '我的钢铁网',
            time: '12:02',
          ),
          News(
            title: '德宝投资爱之餐饮集团',
            source: '德宝新闻',
            time: '10:34',
          ),
          News(
            title: '股指：官媒缓虑 股指观望',
            source: '我的钢铁网',
            time: '12:02',
          ),
          News(
            title: '德宝投资爱之餐饮集团',
            source: '德宝新闻',
            time: '10:34',
          ),
        ],
      ),
      TimeLife(
        title: '一周内',
        newsList: [
          News(
            title: '股指：官媒缓虑 股指观望',
            source: '我的钢铁网',
            time: '12:02',
          ),
          News(
            title: '德宝投资爱之餐饮集团',
            source: '德宝新闻',
            time: '10:34',
          ),
          News(
            title: '股指：官媒缓虑 股指观望',
            source: '我的钢铁网',
            time: '12:02',
          ),
          News(
            title: '德宝投资爱之餐饮集团',
            source: '德宝新闻',
            time: '10:34',
          ),
        ],
      ),
    ];
  }
}

class News {
  String title;
  String time;
  String source;

  News({this.title, this.time, this.source});
}

class TimeLife {
  String title;
  List<News> newsList;

  TimeLife({this.newsList, this.title});
}

class TzClosingDetailsPageView extends StatefulWidget {
  @override
  _TzClosingDetailsPageViewState createState() => _TzClosingDetailsPageViewState();
}

class _TzClosingDetailsPageViewState extends State<TzClosingDetailsPageView> {
  List<_Closing> _closingDetails;
  double timeWidth = 70;
  double nowHandWidth = 50;
  double largerWidth = 50;
  double actionWidth = 50;
  @override
  void initState() {
    super.initState();
    _closingDetails = _allClosingDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _closingDetails.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                SizedBox(
                  width: timeWidth,
                  child: Text(
                    '时间',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '价格',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  width: nowHandWidth,
                  child: Text(
                    '现手',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  width: largerWidth,
                  child: Text(
                    '增仓',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  width: actionWidth,
                  child: Text(
                    '开平',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Divider(
              height: 1,
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: 10,
              ),
              children: _closingDetails.map((item) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: _ClosingDetailsView(
                    closing: item,
                    actionWidth: actionWidth,
                    largerWidth: largerWidth,
                    nowHandWidth: nowHandWidth,
                    timeWidth: timeWidth,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_Closing> _allClosingDetails() {
    return [
      _Closing(
        time: '15:00:00',
        price: 3880.0,
        nowhand: 9,
        larger: -1,
        action: '空平',
      ),
      _Closing(
        time: '14:59:59',
        price: 3879.8,
        nowhand: 7,
        larger: 5,
        action: '空开',
      ),
      _Closing(
        time: '14:59:59',
        price: 3880.0,
        nowhand: 12,
        larger: 3,
        action: '多开',
      ),
      _Closing(
        time: '14:59:58',
        price: 3879.2,
        nowhand: 17,
        larger: 8,
        action: '空开',
      ),
      _Closing(
        time: '14:59:56',
        price: 3880.0,
        nowhand: 5,
        larger: 0,
        action: '空换',
      ),
    ];
  }
}

class _Closing {
  String time;
  double price;
  int nowhand; //现手
  int larger; //增仓
  String action; //开平操作

  _Closing({
    this.time,
    this.price,
    this.nowhand,
    this.larger,
    this.action,
  });
}

class _ClosingDetailsView extends StatefulWidget {
  double timeWidth = 70;
  double nowHandWidth = 50;
  double largerWidth = 50;
  double actionWidth = 50;
  _Closing closing;

  _ClosingDetailsView({this.timeWidth, this.nowHandWidth, this.largerWidth,this.actionWidth, this.closing});

  @override
  _ClosingDetailsViewState createState() => _ClosingDetailsViewState();
}

class _ClosingDetailsViewState extends State<_ClosingDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              SizedBox(
                width: widget.timeWidth,
                child: Text.rich(
                  TextSpan(
                    text: '${widget.closing.time ?? ''}',
                    style: TextStyle(),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child:
                          Text(widget.closing.price.toStringAsFixed(2) ?? ''),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: widget.nowHandWidth,
                child: Text(
                  '${widget.closing.nowhand.toStringAsFixed(0) ?? ''}',
                  style: TextStyle(),
                ),
              ),
              SizedBox(
                width: widget.largerWidth,
                child: Text(
                  '${widget.closing.larger.toStringAsFixed(2)}',
                  style: TextStyle(),
                ),
              ),
              SizedBox(
                width: widget.actionWidth,
                child: Text(
                  '${widget.closing.action}',
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: Divider(
            height: 1,
            indent: 10,
            endIndent: 10,
            color: Colors.black12,
          ),
        ),
      ],
    );
  }
}

///盘口
class TzPositionPageView extends StatefulWidget {
  @override
  _TzPositionPageViewState createState() => _TzPositionPageViewState();
}

class _TzPositionPageViewState extends State<TzPositionPageView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '外盘',
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
                                '30730',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '内盘',
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
                                '30578',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '昨结',
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
                                '3846.2',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '开盘',
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
                                '3842.2',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '日增仓',
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
                                '-6023',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '持仓量',
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
                                '81764',
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
            Container(
              height: 20,
              child: Divider(
                height: 1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '振幅',
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
                                '0.67%',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '均价',
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
                                '3743.4',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '总手',
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
                                '61308',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '今结',
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
                                '3747.6',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '委比',
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
                                '-33.33%',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '量比',
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
                                '0.91',
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
            Container(
              height: 20,
              child: Divider(
                height: 1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '最高',
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
                                '4230.8',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '最低',
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
                                '3461.5',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: Text(
                                      '期现差',
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
                                      '2.6',
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///合约简介
class TzContractDescPageView extends StatefulWidget {
  @override
  _TzContractDescPageViewState createState() => _TzContractDescPageViewState();
}

class _TzContractDescPageViewState extends State<TzContractDescPageView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: new NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            _ContractItemView(
              label: '合约标的',
              value: '元丰交易所-德胜股指期货',
              onTap: () {},
            ),
            _ContractItemView(
              label: '合约乘数',
              value: '300',
            ),
            _ContractItemView(
              label: '报价单位',
              value: '指数点',
            ),
            _ContractItemView(
              label: '交易时间',
              value: '24h',
            ),
            _ContractItemView(
              label: '合约保证金标准',
              value: '10.00%',
            ),
            _ContractItemView(
              label: '合约保证金标准',
              value: '10.00%',
            ),
            _ContractItemView(
              label: '清算规则',
              value: '每日23:59分',
            ),
            _ContractItemView(
              label: '清算方式',
              value: '现金',
            ),
            _ContractItemView(
              label: '上市交易所',
              value: '东方之珠 广东帑指交易所',
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractItemView extends StatefulWidget {
  String label;
  String value;
  Function() onTap;

  _ContractItemView({this.label, this.value, this.onTap});

  @override
  __ContractItemViewState createState() => __ContractItemViewState();
}

class __ContractItemViewState extends State<_ContractItemView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey[100],
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(
              widget.label,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: widget.value,
                style: widget.onTap == null
                    ? null
                    : TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                recognizer: TapGestureRecognizer()..onTap = widget.onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


///盘口
class TyPositionPageView extends StatefulWidget {
  @override
  _TyPositionPageViewState createState() => _TyPositionPageViewState();
}

class _TyPositionPageViewState extends State<TyPositionPageView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '最高',
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
                                '5.34',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '最低',
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
                                '5.32',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '均价',
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
                                '5.34',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '总手',
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
                                '20475',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '金额',
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
                                '1093.4万',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '换手率',
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
                                '0.38%',
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
            Container(
              height: 20,
              child: Divider(
                height: 1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '流通帑',
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
                                '5.38亿',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '市盈率',
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
                                '36.16',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '流通值',
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
                                '28.74亿',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '总帑本',
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
                                '5.45亿',
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '总市值',
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
                                '29.08亿',
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '市净率',
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
                                '2.84',
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
          ],
        ),
      ),
    );
  }
}



class TyClosingDetailsPageView extends StatefulWidget {
  @override
  _TyClosingDetailsPageViewState createState() => _TyClosingDetailsPageViewState();
}

class _TyClosingDetailsPageViewState extends State<TyClosingDetailsPageView> {
  List<_TyClosing> _closingDetails;
  double timeWidth = 70;
  double nowHandWidth = 50;
  double largerWidth = 50;
  double actionWidth = 50;
  @override
  void initState() {
    super.initState();
    _closingDetails = _allClosingDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _closingDetails.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                SizedBox(
                  width: timeWidth,
                  child: Text(
                    '时间',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '价格',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  width: nowHandWidth,
                  child: Text(
                    '现手',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  width: actionWidth,
                  child: Text(
                    '',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Divider(
              height: 1,
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: 10,
              ),
              children: _closingDetails.map((item) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: _TyClosingDetailsView(
                    closing: item,
                    actionWidth: actionWidth,
                    largerWidth: largerWidth,
                    nowHandWidth: nowHandWidth,
                    timeWidth: timeWidth,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_TyClosing> _allClosingDetails() {
    return [
      _TyClosing(
        time: '15:00:00',
        price: 5.32,
        nowhand: 9,
        action: '卖',
      ),
      _TyClosing(
        time: '14:59:59',
        price: 5.33,
        nowhand: 7,
        action: '买',
      ),
      _TyClosing(
        time: '14:59:59',
        price: 5.35,
        nowhand: 12,
        action: '买',
      ),
      _TyClosing(
        time: '14:59:58',
        price: 5.31,
        nowhand: 17,
        action: '卖',
      ),
      _TyClosing(
        time: '14:59:56',
        price: 5.33,
        nowhand: 5,
        action: '买',
      ),
    ];
  }
}

class _TyClosing {
  String time;
  double price;
  int nowhand; //现手
  String action; //方向

  _TyClosing({
    this.time,
    this.price,
    this.nowhand,
    this.action,
  });
}

class _TyClosingDetailsView extends StatefulWidget {
  double timeWidth = 70;
  double nowHandWidth = 50;
  double largerWidth = 50;
  double actionWidth = 50;
  _TyClosing closing;

  _TyClosingDetailsView({this.timeWidth, this.nowHandWidth, this.largerWidth,this.actionWidth, this.closing});

  @override
  _TyClosingDetailsViewState createState() => _TyClosingDetailsViewState();
}

class _TyClosingDetailsViewState extends State<_TyClosingDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              SizedBox(
                width: widget.timeWidth,
                child: Text.rich(
                  TextSpan(
                    text: '${widget.closing.time ?? ''}',
                    style: TextStyle(),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child:
                      Text(widget.closing.price.toStringAsFixed(2) ?? ''),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: widget.nowHandWidth,
                child: Text(
                  '${widget.closing.nowhand.toStringAsFixed(0) ?? ''}',
                  style: TextStyle(),
                ),
              ),
              SizedBox(
                width: widget.actionWidth,
                child: Text(
                  '${widget.closing.action}',
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: Divider(
            height: 1,
            indent: 10,
            endIndent: 10,
            color: Colors.black12,
          ),
        ),
      ],
    );
  }
}