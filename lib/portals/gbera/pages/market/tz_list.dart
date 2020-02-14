import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:framework/framework.dart';

class TZList extends StatefulWidget {
  PageContext context;

  TZList({this.context});

  @override
  _TZListState createState() => _TZListState();
}

class _TZListState extends State<TZList> {
  double zxWidth = 70;
  double zfWidth = 60;
  double zdWidth = 50;
  List<_TZMarket> _marketList = [];

  @override
  void initState() {
    super.initState();
    _marketList = _allMarkets();
  }

  @override
  void dispose() {
    super.dispose();
    _marketList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          widget.context.page.title,
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () {
            widget.context.backward();
          },
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (v) {},
            offset: Offset.fromDirection(
              40,
              60,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('我的持仓'),
                ),
                PopupMenuItem(
                  child: Text('我关注的'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 45),
                      child: Text(
                        '交易所',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: zfWidth,
                    child: Text(
                      '换手率',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: zfWidth,
                    child: Text(
                      '成交量',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: zdWidth,
                    child: Text(
                      '持仓量',
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
                padding: EdgeInsets.only(
                  top: 10,
                ),
                children: _marketList.map((item) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/market/exchange/tz');
                    },
                    child: _TYMarketRowView(
                      zdWidth: zdWidth,
                      zfWidth: zfWidth,
                      zxWidth: zxWidth,
                      tzMarket: item,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TZMarket> _allMarkets() {
    return [
      _TZMarket(
        title: '东方之珠',
        avatar:
            'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2873093951,318547924&fm=26&gp=0.jpg',
        subtitle: '广东·帑指交易所',
        tzMarketTurnoverRate: 0.21,
        tzMarketOpenInterest: 1383,
        tzMarketVolume: 2885,
        tzMarketName: '元丰',
      ),
      _TZMarket(
        title: '卓玛',
        avatar:
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574586017963&di=93ba1695e47be69c6aaf6d83359f05de&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
        subtitle: '北京·帑指交易所',
        tzMarketTurnoverRate: 0.83,
        tzMarketOpenInterest: 2382,
        tzMarketVolume: 2897,
        tzMarketName: '马恩河谷',
      ),
      _TZMarket(
        title: '谷元春',
        avatar:
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574586324784&di=fd32ca70cc438a9f5814b4ee6fdaee70&imgtype=0&src=http%3A%2F%2Fpic31.nipic.com%2F20130710%2F12886433_124405333000_2.jpg',
        subtitle: '湖南·帑指交易所',
        tzMarketTurnoverRate: 0.34,
        tzMarketOpenInterest: 2844,
        tzMarketVolume: 1923,
        tzMarketName: '德怀天下',
      ),
    ];
  }
}

class _TZMarket {
  String title;
  String subtitle;
  String avatar;
  String tzMarketName;
  int tzMarketOpenInterest;
  int tzMarketVolume;
  double tzMarketTurnoverRate;

  _TZMarket(
      {this.title,
      this.subtitle,
      this.avatar,
      this.tzMarketName,
      this.tzMarketTurnoverRate,
      this.tzMarketOpenInterest,
      this.tzMarketVolume});
}

class _TYMarketRowView extends StatefulWidget {
  double zxWidth = 70;
  double zfWidth = 70;
  double zdWidth = 70;
  _TZMarket tzMarket;

  _TYMarketRowView({this.zxWidth, this.zfWidth, this.zdWidth, this.tzMarket});

  @override
  _TYMarketRowViewState createState() => _TYMarketRowViewState();
}

class _TYMarketRowViewState extends State<_TYMarketRowView> {
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
              Expanded(
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.network(
                            widget.tzMarket.avatar,
                            fit: BoxFit.fitWidth,
                          ),
                        )),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: widget.tzMarket.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: '\r\n'),
                            TextSpan(
                              text: widget.tzMarket.subtitle,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: widget.zfWidth,
                child: Text(
                  '${widget.tzMarket.tzMarketTurnoverRate}',
                  style: TextStyle(),
                ),
              ),
              SizedBox(
                width: widget.zfWidth,
                child: Text(
                  '${widget.tzMarket.tzMarketVolume}',
                  style: TextStyle(),
                ),
              ),
              SizedBox(
                width: widget.zdWidth,
                child: Text(
                  '${widget.tzMarket.tzMarketOpenInterest}',
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
            indent: 45,
            color: Colors.black12,
          ),
        ),
      ],
    );
  }
}
