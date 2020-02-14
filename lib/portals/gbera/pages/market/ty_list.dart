import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:framework/framework.dart';

class TYList extends StatefulWidget {
  PageContext context;

  TYList({this.context});

  @override
  _TYListState createState() => _TYListState();
}

class _TYListState extends State<TYList> {
  double zxWidth = 70;
  double zfWidth = 60;
  double zdWidth = 50;
  List<_TYMarket> _marketList = [];

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
                    width: zxWidth,
                    child: Text(
                      '指数',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: zfWidth,
                    child: Text(
                      '涨幅',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: zdWidth,
                    child: Text(
                      '涨跌',
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
                      widget.context.forward('/market/exchange/ty');
                    },
                    child: _TYMarketRowView(
                      zdWidth: zdWidth,
                      zfWidth: zfWidth,
                      zxWidth: zxWidth,
                      tyMarket: item,
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

  List<_TYMarket> _allMarkets() {
    return [
      _TYMarket(
        title: '元丰',
        avatar:
            'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2873093951,318547924&fm=26&gp=0.jpg',
        subtitle: '广东·帑银交易所',
        zd: -18.35,
        zf: -0.63,
        zx: 2885.29,
      ),
      _TYMarket(
        title: '马恩河谷',
        avatar:
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574586017963&di=93ba1695e47be69c6aaf6d83359f05de&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
        subtitle: '北京·帑银交易所',
        zd: 16.88,
        zf: 0.98,
        zx: 2897.64,
      ),
      _TYMarket(
        title: '德怀天下',
        avatar:
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574586324784&di=fd32ca70cc438a9f5814b4ee6fdaee70&imgtype=0&src=http%3A%2F%2Fpic31.nipic.com%2F20130710%2F12886433_124405333000_2.jpg',
        subtitle: '湖南·帑银交易所',
        zd: 9.34,
        zf: 0.21,
        zx: 1923.11,
      ),
    ];
  }
}

class _TYMarket {
  String title;
  String subtitle;
  String avatar;
  double zx;
  double zf;
  double zd;

  _TYMarket(
      {this.title, this.subtitle, this.avatar, this.zx, this.zf, this.zd});
}

class _TYMarketRowView extends StatefulWidget {
  double zxWidth = 70;
  double zfWidth = 60;
  double zdWidth = 50;
  _TYMarket tyMarket;

  _TYMarketRowView({this.zxWidth, this.zfWidth, this.zdWidth, this.tyMarket});

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
                            widget.tyMarket.avatar,
                            fit: BoxFit.fitWidth,
                          ),
                        )),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: widget.tyMarket.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: '\r\n'),
                            TextSpan(
                              text: widget.tyMarket.subtitle,
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
                width: widget.zxWidth,
                child: Text(
                  '${widget.tyMarket.zx.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _getColor(),
                  ),
                ),
              ),
              SizedBox(
                width: widget.zfWidth,
                child: Text(
                  '${widget.tyMarket.zf.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: _getColor(),
                  ),
                ),
              ),
              SizedBox(
                width: widget.zdWidth,
                child: Text(
                  '${widget.tyMarket.zd.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _getColor(),
                  ),
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

  _getColor() {
    double zf = widget.tyMarket.zf;
    if (zf == 0) {
      return Colors.black;
    }
    if (zf < 0) {
      return Colors.green;
    }
    return Colors.red;
  }
}
