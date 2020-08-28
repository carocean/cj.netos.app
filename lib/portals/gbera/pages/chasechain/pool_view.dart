import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';

class PoolViewPage extends StatefulWidget {
  PageContext context;

  PoolViewPage({this.context});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolViewPage> {
  TrafficPool _pool;
  int _index = 0;
  bool _isLoading = true;
  TrafficDashboard _dashboard;
  bool _isExpendedInnate = false;

  @override
  void initState() {
    _pool = widget.context.parameters['pool'];
    _load().then((value) {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _dashboard = await recommender.getTrafficDashboard(_pool.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, index) {
          var slivers = <Widget>[
            SliverAppBar(
              elevation: 0,
              title: Text('流量池'),
              pinned: true,
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                ),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    StringUtil.isEmpty(_pool.icon)
                        ? Icon(
                            Icons.pool,
                            size: 20,
                            color: Colors.grey,
                          )
                        : Image.network(
                            '${_pool.icon}?accessToken=${widget.context.principal.accessToken}',
                            width: 20,
                            height: 20,
                          ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${_pool.title}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    _isLoading
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Text(
                            '${parseInt(_dashboard?.itemCount, 2)}条内容',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _isLoading
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : Column(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                            left: 40,
                            right: 40,
                            top: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            children: <Widget>[
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 15,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${parseInt(_dashboard?.innerRecommends, 2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '推荐',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${parseInt(_dashboard?.innerLikes, 2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '点赞',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${parseInt(_dashboard?.innerComments, 2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '评论',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 15,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${_dashboard.innerRecommendRatio.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '每条平均推荐量',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${_dashboard.innerLikeRatio.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '每条平均点赞量',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${_dashboard.innerComments.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '每条平均评论量',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            right: 15,
                            bottom: 10,
                            left: 15,
                          ),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _isExpendedInnate = !_isExpendedInnate;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      '基本行为',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueGrey,
                                          decoration: TextDecoration.underline),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                              !_isExpendedInnate
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 2,
                                        bottom: 2,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Wrap(
                                            children: <Widget>[
                                              Text.rich(
                                                TextSpan(
                                                  text: '推荐',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateRecommends}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  text: '点赞',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateLikes}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  text: '评论',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateComments}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                            spacing: 10,
                                          ),
                                          SizedBox(
                                            height: 6,
                                            child: Divider(
                                              height: 1,
                                            ),
                                          ),
                                          Wrap(
                                            children: <Widget>[
                                              Text.rich(
                                                TextSpan(
                                                  text: '平均推荐量',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateRecommendsRatio.toStringAsFixed(4)}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  text: '平均点赞',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateLikeRatio.toStringAsFixed(4)}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  text: '平均评论',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateCommentRatio.toStringAsFixed(4)}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                            spacing: 10,
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
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    CardItem(
                      title: '位置',
                    ),
                    SizedBox(
                      height: 10,
                      child: Divider(
                        height: 1,
                      ),
                    ),
                    CardItem(
                      title: '等级',
                      tipsText: '乡镇或街道',
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _DemoHeader(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 5,
                          bottom: 5,
                        ),
                        color: Colors.white,
                        child: Text(
                          '内容提供者',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 5,
                          bottom: 5,
                        ),
//                        color: Colors.white,
                        child: Text(
                          '内容盒',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
          return slivers;
        },
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              IndexedStack(
                index: _index,
                children: <Widget>[
                  _ContentProviderListPanel(),
                  _ContentBoxListPanel(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentProviderListPanel extends StatefulWidget {
  @override
  __ContentProviderListPanelState createState() =>
      __ContentProviderListPanelState();
}

class __ContentProviderListPanelState extends State<_ContentProviderListPanel> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ContentBoxListPanel extends StatefulWidget {
  @override
  __ContentBoxListPanelState createState() => __ContentBoxListPanelState();
}

class __ContentBoxListPanelState extends State<_ContentBoxListPanel> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;
  double height = 30;

  _DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: child,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return height;
  } // 最大高度

  @override
  double get minExtent => height; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}
