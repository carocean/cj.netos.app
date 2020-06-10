import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';

class Golink extends StatefulWidget {
  PageContext context;

  Golink({this.context});

  @override
  _GolinkState createState() => _GolinkState();
}

class _GolinkState extends State<Golink> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    print('----_onRefresh');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          context: context,
          child: AppBar(
            title: Text('追链'),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            toolbarOpacity: 1,
            actions: <Widget>[],
          ),
        ),
        Expanded(
          child: EasyRefresh.custom(
            controller: _controller,
            onRefresh: _onRefresh,
            firstRefresh: true,
            slivers: [
              SliverToBoxAdapter(
                child: _ContentBottom(
                  context: widget.context,
                  timeLine: '刚刚',
                  channel: '新华社',
                  content:
                      '涉港国安立法决定公布后 “港独”头目潜逃。据香港《文汇报》报道，正在保释候审期间的“港独”组织“学生独立联盟”召集人陈家驹于本月初弃保潜逃，目前可能已在欧洲荷兰匿藏。',
                  medias: [
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'http://47.105.165.186:7100/public/geosphere/wallpapers/4e44f8df7a5fc91dc1d17fcc7b570ce2.jpg',
                    ),
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'http://47.105.165.186:7100/app/74dced30-7313-11ea-b0fb-e5204c5d851f.jpg',
                    ),
                    MediaSrc(
                      text: '',
                      type: 'video',
                      src:
                          'http://47.105.165.186:7100/app/geosphere/cd664500-7570-11ea-98bc-cb66652ca54c.mp4',
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _ContentRight(
                  content:
                      '据澎湃新闻报道，2019年9月卸任四川省人大常委会原副主任一职的副部级官员侯晓春，于近日被披露已经落马。其卸任的实质原因，是其涉嫌严重违纪违法，因此受到了纪委监委的纪律审查和监察调查。尽管侯晓春的实际被查时间是在2019年，相关消息却直到近期才得到披露，在纪检监察工作中，这种现象显得十分不同寻常，而这也意味着：侯晓春这只“老虎”的问题恐怕并不简单。',
                  context: widget.context,
                  channel: '澎湃新闻',
                  timeLine: '20分钟前',
                  medias: [
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'http://47.105.165.186:7100/app/geosphere/caaa4750-9fb7-11ea-e1e4-e5ecd21f65cb.jpg',
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _ContentBottom(
                  context: widget.context,
                  timeLine: '刚刚',
                  channel: '观察者网',
                  content:
                      '任正非一句“杀出一条血路”，外媒翻译不及格。美国现如今对华歇斯底里，无端将华为公司视为“国土安全危机”，肆意打压。',
                  medias: [
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'https://n.sinaimg.cn/spider2020610/60/w687h173/20200610/e750-iuvaazn8020326.jpg',
                    ),
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'https://n.sinaimg.cn/spider2020610/249/w680h369/20200610/e846-iuvaazn8020473.jpg',
                    ),
                    MediaSrc(
                      text: '超级',
                      type: 'image',
                      src:
                          'https://n.sinaimg.cn/spider2020610/84/w680h204/20200610/6af1-iuvaazn8020472.jpg',
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _ContentLeft(
                  content: '美国务院：中美紧要关头 美国外交人员返华至关重要',
                  context: widget.context,
                  channel: '澎湃新闻',
                  timeLine: '20分钟前',
                  medias: [
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'https://n.sinaimg.cn/sinakd2020610s/533/w800h533/20200610/c61a-iuvaazn7893940.png',
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _ContentTop(
                  context: widget.context,
                  timeLine: '刚刚',
                  channel: '三元会社',
                  content:
                      '6月9日，广东省纪委监委发布消息，汕尾市委常委、陆丰市委书记邬郁敏涉嫌严重违纪违法，目前正接受广东省纪委监委纪律审查和监察调查。',
                  medias: [
                    MediaSrc(
                      text: '',
                      type: 'image',
                      src:
                          'https://n.sinaimg.cn/news/crawl/190/w550h440/20200610/43fb-iuvaazn6831520.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentBottom extends StatelessWidget {
  PageContext context;
  List<MediaSrc> medias;
  String content;
  String timeLine;
  String channel;

  _ContentBottom({
    this.medias,
    this.context,
    this.content,
    this.channel,
    this.timeLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              content ?? '',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.4,
                wordSpacing: 1.4,
                height: 1.4,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 200,
            child: MediaWidget(
              medias,
              this.context,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Wrap(
              spacing: 5,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  this.timeLine ?? '',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  this.channel ?? '',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Divider(
              height: 1,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentTop extends StatelessWidget {
  PageContext context;
  List<MediaSrc> medias;
  String content;
  String timeLine;
  String channel;

  _ContentTop({
    this.medias,
    this.context,
    this.content,
    this.channel,
    this.timeLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 200,
            child: MediaWidget(
              medias,
              this.context,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Text(
              content ?? '',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.4,
                wordSpacing: 1.4,
                height: 1.4,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Wrap(
              spacing: 5,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  this.timeLine ?? '',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  this.channel ?? '',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Divider(
              height: 1,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentRight extends StatelessWidget {
  PageContext context;
  List<MediaSrc> medias;
  String content;
  String timeLine;
  String channel;

  _ContentRight({
    this.medias,
    this.context,
    this.content,
    this.channel,
    this.timeLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Text(
                    content ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.4,
                      wordSpacing: 1.4,
                      height: 1.4,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 100,
                child: MediaWidget(
                  medias,
                  this.context,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Wrap(
              spacing: 5,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  this.timeLine ?? '',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  this.channel ?? '',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Divider(
              height: 1,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentLeft extends StatelessWidget {
  PageContext context;
  List<MediaSrc> medias;
  String content;
  String timeLine;
  String channel;

  _ContentLeft({
    this.medias,
    this.context,
    this.content,
    this.channel,
    this.timeLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 100,
                child: MediaWidget(
                  medias,
                  this.context,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    content ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.4,
                      wordSpacing: 1.4,
                      height: 1.4,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Wrap(
              spacing: 5,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  this.timeLine ?? '',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  this.channel ?? '',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Divider(
              height: 1,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
