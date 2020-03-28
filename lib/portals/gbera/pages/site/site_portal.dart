import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/system/local/entities.dart';

class SitePortal extends StatefulWidget {
  PageContext context;

  SitePortal({this.context});

  @override
  _SitePortalState createState() => _SitePortalState();
}

class _SitePortalState extends State<SitePortal> {
  _SitePortalState()
      : _controller = ScrollController(initialScrollOffset: 0.0),
        showAppBar = false {
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  _scrollListener() {
    var sub = Adapt.screenH() / 3 - 90;
    if (_controller.offset > sub) {
      if (!showAppBar) {
        setState(() {
          showAppBar = true;
        });
      }
      return;
    }
    if (_controller.offset < sub) {
      if (showAppBar) {
        setState(() {
          showAppBar = false;
        });
      }
      return;
    }
  }

  ScrollController _controller;
  bool showAppBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          _getAppBar(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
          SliverToBoxAdapter(
            child: _Body(
              context: widget.context,
            ),
          ),
        ],
      ),
    );
  }

  _getAppBar() {
    return SliverAppBar(
      titleSpacing: 0,
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      expandedHeight: Adapt.screenH() / 3,
      backgroundColor: showAppBar ? Theme.of(context).appBarTheme.color : null,
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: showAppBar ? Text('中国邮政') : null,
      flexibleSpace: _Header(
        showAppBar: showAppBar,
      ),
    );
  }
}

class _Header extends StatefulWidget {
  bool showAppBar;

  _Header({this.showAppBar});

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return Container(
      height: Adapt.screenH() / 3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3041958106,557182480&fm=26&gp=0.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            bottom: -40,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        right: 10,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Image.network(
                          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573752021369&di=29710e18090404bf7e89a71c89996c0b&imgtype=0&src=http%3A%2F%2Fi1.ymfile.com%2Fuploads%2Fproduct%2F08%2F27%2Fx1_1.1377571169_489_142_14295.jpg',
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '提供贴心服务',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                  ),
                  child: Text(
                    '中国邮政',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
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

class _Body extends StatefulWidget {
  PageContext context;

  _Body({this.context});

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _ListRegion(
        context: widget.context,
      ),
    );
  }
}

class _ListRegion extends StatefulWidget {
  PageContext context;

  _ListRegion({this.context});

  @override
  __ListRegionState createState() => __ListRegionState();
}

class __ListRegionState extends State<_ListRegion> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _MessageCard(
            context: widget.context,
          ),
          _MessageCard(
            context: widget.context,
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  PageContext context;

  _MessageCard({this.context});

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  int _maxLines = 4;

  @override
  Widget build(BuildContext context) {
    var images = [
      Media(
        null,
        'image',
        'https://img11.360buyimg.com/n1/s450x450_jfs/t21856/309/486959023/285536/3356dc82/5b0fc33cN898ac257.png',
        null,
        null,
        null,
        null,
        widget.context.principal.person,
      ).toMediaSrc(),
    ];
    return Card(
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide.none,
      ),
      elevation: 2,
      borderOnForeground: true,
      semanticContainer: false,
      margin: EdgeInsets.only(
        bottom: 15,
        left: 10,
        right: 10,
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          widget.context.forward('/site/marchant');
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          '昨天 8:51',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[900],
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Container(
                    //内容区
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text.rich(
                      TextSpan(
                        text:
                            '11月11日晚，在全系统“双11”旺季生产运行的关键时点，集团公司党组书记、董事长刘爱力，副总经理张荣林一行来到北京邮件综合处理中心，了解邮政“双11”生产运行情况，慰问一线干部员工，强调要充分认识做好“双11”服务保障工作的重要意义，按照“争市场、强重点、重体验、保稳定”的总体要求和集团公司的部署安排，坚定信心、铆足干劲，精心组织、全网联动，全力打赢“双11”旺季生产运行攻坚战。',
                        children: [],
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('xxxxx');
                            if (_maxLines <= 4) {
                              setState(() {
                                _maxLines = 1000;
                              });
                            } else {
                              setState(() {
                                _maxLines = 4;
                              });
                            }
                          },
                      ),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      maxLines: _maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DefaultTabController(
                    length: images.length,
                    child: PageSelector(
                      medias: images,
                      onMediaLongTap: (media) {
                        widget.context.forward(
                          '/images/viewer',
                          arguments: {
                            'media': media,
                            'text': images,
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    //内容坠
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.linear_scale,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        offset: Offset(
                          0,
                          35,
                        ),
                        onSelected: (value) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Container(
                              child: Text('$value'),
                            ),
                          ));
                        },
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'like',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.thumbsUp,
                                    color: Colors.grey[500],
                                    size: 15,
                                  ),
                                ),
                                Text(
                                  '点赞',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'comment',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.comment,
                                    color: Colors.grey[500],
                                    size: 15,
                                  ),
                                ),
                                Text(
                                  '评论',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
//                          PopupMenuDivider(),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Color(0xFFF5F5F5),
                    ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 5,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //相关操作区
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                FontAwesomeIcons.thumbsUp,
                                color: Colors.grey[500],
                                size: 16,
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '吉儿',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          widget.context
                                              .forward("/site/personal");
                                        },
                                    ),
                                    TextSpan(text: ';  '),
                                    TextSpan(
                                      text: '布谷鸟',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          widget.context
                                              .forward("/site/personal");
                                        },
                                    ),
                                    TextSpan(text: ';  '),
                                    TextSpan(
                                      text: '大飞果果',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          widget.context
                                              .forward("/site/personal");
                                        },
                                    ),
                                    TextSpan(text: ';  '),
                                    TextSpan(
                                      text: '中国好味道',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          widget.context
                                              .forward("/site/personal");
                                        },
                                    ),
                                    TextSpan(text: ';  '),
                                  ],
                                ),
//                                maxLines: 4,
//                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 6,
                            top: 6,
                          ),
                          child: Divider(
                            height: 1,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Text.rich(
                                //评论区
                                TextSpan(
                                  text: '天空:',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.context.forward("/site/personal");
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '按照“争市场、强重点、重体验、保稳定”的总体要求和集团公司的部署安排，坚定信心、铆足干劲，精心组织、全网联动，全力打赢“双11”旺季生产运行攻坚战',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                softWrap: true,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Text.rich(
                                //评论区
                                TextSpan(
                                  text: '郑泉轩:',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.context.forward("/site/personal");
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '中邮证券有限责任公司内蒙古分公司举行开业仪式。中国邮政集团公司副总经理康宁、内蒙古自治区地方金融监督管理局局长助理吴光飙出席并讲话。',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
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
    );
  }
}
