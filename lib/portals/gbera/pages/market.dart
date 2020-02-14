import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/system/local/entities.dart';

class Market extends StatefulWidget {
  final PageContext context;

  Market({this.context});

  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          floating: false,
          pinned: true,
          delegate: GberaPersistentHeaderDelegate(
            title: Text('市场'),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
        ),
        SliverToBoxAdapter(
          child: _renderDealmarketRegion(),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 10,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            _shoppingMarket().toList(),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 10,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            _platformServices().toList(),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 10,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            _platformNewsDays().toList(),
          ),
        ),
      ],
    );
  }

  _renderDealmarketRegion() {
    return Container(
      padding: EdgeInsets.only(
        top: 30,
        bottom: 20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/market/tz_list');
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    IconData(0xe659, fontFamily: 'market'),
                    size: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Text(
                      '帑指期货',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/market/ty_list');
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    IconData(0xe52a, fontFamily: 'market'),
                    size: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Text(
                      '帑银交易',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _platformServices() {
    var services = <_PlatformService>[
      _PlatformService(
        name: '我要做商家',
        icon: Icon(
          Icons.shop,
          size: 30,
          color: Colors.grey[600],
        ),
      ),
      _PlatformService(
        name: '我要做地商',
        icon: Icon(
          IconData(0xe62d, fontFamily: 'geo_locations'),
          size: 30,
          color: Colors.grey[600],
        ),
      ),
      _PlatformService(
        name: '我要做市商',
        icon: Icon(
          IconData(0xe676, fontFamily: 'market_shishang'),
          size: 30,
          color: Colors.grey[600],
        ),
      ),
    ];

    return services.map((service) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
//          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: CardItem(
                title: service.name,
                leading: service.icon,
                onItemTap: service.onTap,
                paddingTop: 10,
                paddingBottom: 10,
              ),
            ),
            Container(
              child: Divider(
                height: 1,
                indent: 50,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _shoppingMarket() {
    var services = <_PlatformService>[
      _PlatformService(
        name: 'goGOGO',
        icon: Icon(
          Icons.shopping_basket,
          size: 30,
          color: Colors.grey[600],
        ),
        onTap: () {
          widget.context.forward('/market/goGOGO');
        },
      ),
    ];

    return services.map((service) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: CardItem(
                title: service.name,
                leading: service.icon,
                onItemTap: service.onTap,
                paddingBottom: 10,
                paddingTop: 10,
              ),
            ),
            Container(
              child: Divider(
                height: 1,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _platformNewsDays() {
    return [
      _PlatformNewsDay(
        timeTitle: '今天资讯',
        timeSubtitle: '12:30',
        context: widget.context,
        news: <_News>[
          _News(
              title: '佛山王先生开店3个月净赚500万！',
              images: [
                Media(
                  null,
                  'image',
                  'https://img20.360buyimg.com/vc/jfs/t9712/323/19330494/133477/712d7d6b/59c3894cN586c7217.jpg',
                  null,
                  null,
                  null,
                  null,
                  widget.context.principal.person,
                ),
                Media(
                  null,
                  'image',
                  'http://dingyue.nosdn.127.net/vvRjNcu9VBGgAevyEl5kQ0PO4ndOa4p3KJcED=yrAyXUP1529905129060compressflag.jpg',
                  null,
                  null,
                  null,
                  null,
                  widget.context.principal.person,
                ),
              ],
              Content:
                  '开始禅城区的地商李明找到我跟我说，快点接上帑指市场，未来10倍，20倍的利都有，我跟李明是多年的交情，想必也不会忽悠我，我就尝试着做了。没想到赚钱原来这么容易，小店现在一个月营业额是25万，发行帑银净赚60万'),
          _News(
            title: '到2025年苹果广告收入将达到每年110亿美元',
            Content:
                '金融界美股讯 摩根大通分析师周五表示，APPle TV+的推出及苹果进军数字服务领域，可能帮助该公司未来六年内广告收入增加逾五倍，达到每年110亿美元。分析师萨米克 查特吉（Samik Chatterjee）上调了苹果的股价目标，认为该公司可以利用每天搜索其应用商店和Safari浏览器的数百万用户来实现类似于Facebook和谷歌近年来强劲的广告增长。',
            images: [
              Media(
                null,
                'image',
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573935907335&di=7e2eb6de84a234ce122dd0d9c87dd33e&imgtype=0&src=http%3A%2F%2Fi0.hdslb.com%2Fbfs%2Farticle%2Ffdf4d59b8564a9435df039cf2764ee54136405c6.jpg',
                null,
                null,
                null,
                null,
                widget.context.principal.person,
              ),
            ],
          ),
          _News(
              title: '利用微信QQ传播淫秽视频 网络女主播被拘5个月',
              Content:
                  '为了非法牟利，有人铤而走险，通过网络直播平台结交异性，随后通过添加微信或者QQ的方式，传播、转发淫秽视频，以达到非法获取钱财的目的。'),
        ],
      ),
      _PlatformNewsDay(
        timeTitle: '星期二资讯',
        timeSubtitle: '2019年11月21日 8:45',
        context: widget.context,
        news: <_News>[
          _News(
              title: '佛山王先生开店3个月净赚500万！',
              Content:
                  '开始禅城区的地商李明找到我跟我说，快点接上帑指市场，未来10倍，20倍的利都有，我跟李明是多年的交情，想必也不会忽悠我，我就尝试着做了。没想到赚钱原来这么容易，小店现在一个月营业额是25万，发行帑银净赚60万'),
          _News(
              title: '到2025年苹果广告收入将达到每年110亿美元',
              Content:
                  '金融界美股讯 摩根大通分析师周五表示，APPle TV+的推出及苹果进军数字服务领域，可能帮助该公司未来六年内广告收入增加逾五倍，达到每年110亿美元。分析师萨米克 查特吉（Samik Chatterjee）上调了苹果的股价目标，认为该公司可以利用每天搜索其应用商店和Safari浏览器的数百万用户来实现类似于Facebook和谷歌近年来强劲的广告增长。'),
          _News(
              title: '利用微信QQ传播淫秽视频 网络女主播被拘5个月',
              Content:
                  '为了非法牟利，有人铤而走险，通过网络直播平台结交异性，随后通过添加微信或者QQ的方式，传播、转发淫秽视频，以达到非法获取钱财的目的。'),
        ],
      ),
    ];
  }
}

class _PlatformNewsDay extends StatefulWidget {
  String timeTitle;
  String timeSubtitle;
  List<_News> news;
  PageContext context;

  _PlatformNewsDay(
      {this.timeTitle, this.timeSubtitle, this.news, this.context});

  @override
  __PlatformNewsDayState createState() => __PlatformNewsDayState();
}

class __PlatformNewsDayState extends State<_PlatformNewsDay> {
  var maxLines = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 5,
            top: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 5,
                ),
                child: Text(
                  widget.timeTitle,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                widget.timeSubtitle,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Column(
          children: widget.news.map((news) {
            return Container(
              margin: EdgeInsets.only(
                bottom: 20,
                left: 10,
                right: 10,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(3.0, 3.0),
                      blurRadius: 5.0,
                      spreadRadius: 2.0),
                  BoxShadow(color: Colors.grey, offset: Offset(1.0, 1.0)),
                  BoxShadow(color: Colors.grey)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      news.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  news.images.length == 0
                      ? Container(
                          height: 0,
                          width: 0,
                        )
                      : DefaultTabController(
                          length: news.images.length,
                          child: PageSelector(
                            medias: news.images,
                            onMediaLongTap: (media) {
                              widget.context.forward(
                                '/images/viewer',
                                arguments: {
                                  'media': media,
                                  'others': news.images,
                                },
                              );
                            },
                            height: 200,
                            boxFit: BoxFit.fitHeight,
                          ),
                        ),
                  Container(
                    child: Text.rich(
                      TextSpan(
                        text: news.Content,
                        children: [],
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              if (maxLines == 4) {
                                maxLines = 100;
                              } else {
                                maxLines = 4;
                              }
                            });
                          },
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class _News {
  String title;
  String Content;
  List<Media> images;

  _News({this.title, this.Content, this.images}) {
    if (this.images == null) {
      this.images = <Media>[];
    }
  }
}

class _PlatformService {
  String name;
  Icon icon;
  Function() onTap;

  _PlatformService({this.name, this.icon, this.onTap});
}
