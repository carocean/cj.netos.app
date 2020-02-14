import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class TYExchange extends StatefulWidget {
  PageContext context;

  TYExchange({this.context});

  @override
  _TYExchangeState createState() => _TYExchangeState();
}

class _TYExchangeState extends State<TYExchange> {
  double zxWidth = 70;
  double zfWidth = 60;
  double zdWidth = 50;
  List<_LandAgent> _landAgentList = [];

  @override
  void initState() {
    super.initState();
    _landAgentList = _allLandAgents();
  }

  @override
  void dispose() {
    super.dispose();
    _landAgentList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.only(
                right: 10,
              ),
              height: 30,
              child: Image.network(
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574586324784&di=fd32ca70cc438a9f5814b4ee6fdaee70&imgtype=0&src=http%3A%2F%2Fpic31.nipic.com%2F20130710%2F12886433_124405333000_2.jpg',
                fit: BoxFit.fitHeight,
              ),
            ),
            Text.rich(
              TextSpan(
                text: '德怀天下',
                style: TextStyle(
                  fontSize: 18,
                ),
                children: [
                  TextSpan(text: '\r\n'),
                  TextSpan(
                    text: '广东·帑银交易所',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        titleSpacing: 0,
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
                      padding: EdgeInsets.only(
                        left: 45,
                      ),
                      child: Text(
                        '地商 | 券商',
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
                      '最新',
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
                children: _landAgentList.map((item) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/market/exchange/ty/land_agent');
                    },
                    child: _LandAgentView(
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

  List<_LandAgent> _allLandAgents() {
    return [
      _LandAgent(
        title: '晶贵',
        avatar:
            'http://47.105.165.186:7100/public/market/timg-2.jpeg?App-ID=${widget.context.principal.appid}&Access-Token=${widget.context.principal.accessToken}',
        subtitle: '广州市',
        zd: 24.12,
        zf: 0.84,
        nowprice: 6.28,
      ),
      _LandAgent(
        title: '中凯',
        avatar:
            'http://47.105.165.186:7100/public/market/timg-3.jpeg?App-ID=${widget.context.principal.appid}&Access-Token=${widget.context.principal.accessToken}',
        subtitle: '东莞市',
        zd: -11.31,
        zf: -0.64,
        nowprice: 5.23,
      ),
      _LandAgent(
        title: '亨同',
        avatar:
            'http://47.105.165.186:7100/public/market/timg.jpeg?App-ID=${widget.context.principal.appid}&Access-Token=${widget.context.principal.accessToken}',
        subtitle: '佛山市',
        zd: 2.98,
        zf: 0.37,
        nowprice: 13.85,
      ),
    ];
  }
}

class _LandAgent {
  String title;
  String subtitle;
  String avatar;
  double zf;
  double zd;
  double nowprice;

  _LandAgent(
      {this.title,
      this.subtitle,
      this.avatar,
      this.zf,
      this.zd,
      this.nowprice});
}

class _LandAgentView extends StatefulWidget {
  double zxWidth = 70;
  double zfWidth = 60;
  double zdWidth = 50;
  _LandAgent tzMarket;

  _LandAgentView({this.zxWidth, this.zfWidth, this.zdWidth, this.tzMarket});

  @override
  _LandAgentViewState createState() => _LandAgentViewState();
}

class _LandAgentViewState extends State<_LandAgentView> {
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
                width: widget.zxWidth,
                child: Text.rich(
                  TextSpan(
                    text: '${widget.tzMarket.nowprice}',
                    style: TextStyle(
                      color: _getColor(),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: widget.zfWidth,
                child: Text(
                  '${widget.tzMarket.zf.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: _getColor(),
                  ),
                ),
              ),
              SizedBox(
                width: widget.zdWidth,
                child: Text(
                  '${widget.tzMarket.zd.toStringAsFixed(2)}',
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
    double zf = widget.tzMarket.zf;
    if (zf == 0) {
      return Colors.black;
    }
    if (zf < 0) {
      return Colors.green;
    }
    return Colors.red;
  }
}
