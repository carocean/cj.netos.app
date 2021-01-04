import 'dart:io';

import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

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
  int _contentProviderCount = 0;
  int _itemCount = 0;

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
    _contentProviderCount =
        await recommender.countContentProvidersOfPool(_pool.id);
    _itemCount = await recommender.countContentItemOfPool(_pool.id);
  }

  Future<void> _goMap() async {
    var geocodeList = await AmapSearch.instance.searchGeocode(
      _pool.geoTitle,
    );
    if (geocodeList.isEmpty) {
      return;
    }
    var first = geocodeList[0];
    var location = first.latLng;
    widget.context.forward('/chasechain/pool/location',
        arguments: {'pool': _pool, 'location': location});
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
                                          '${parseInt(_itemCount, 2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '内容',
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
                                          '${parseInt(_contentProviderCount, 2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '提供商',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                    height: 20,
                                    child: VerticalDivider(
                                      width: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${parseInt(_dashboard?.innerRecommends, 2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
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
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
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
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
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
                                          '${_dashboard.innerRecommendRatio.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '平均推荐',
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
                                          '${_dashboard.innerLikeRatio.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '平均点赞',
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
                                          '${_dashboard.innerCommentRatio.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '平均评论',
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
                                                          '${_dashboard.innateRecommends ?? 0}',
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
                                                  text: '平均推荐',
                                                  children: [
                                                    TextSpan(text: ' '),
                                                    TextSpan(
                                                      text:
                                                          '${_dashboard.innateRecommendsRatio.toStringAsFixed(2)}',
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
                                                          '${_dashboard.innateLikeRatio.toStringAsFixed(2)}',
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
                                                          '${_dashboard.innateCommentRatio.toStringAsFixed(2)}',
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
                      title: '类型',
//                      onItemTap: () {
//                        _goMap();
//                      },
                      tipsText: '${_pool.isGeosphere ? '地理流量池' : '常规流量池'}',
                      tail: SizedBox(
                        width: 0,
                        height: 0,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      child: Divider(
                        height: 1,
                      ),
                    ),
                    CardItem(
                      title: '等级',
                      tipsText: '${_getLevelName()}',
                      tail: SizedBox(
                        width: 0,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _DemoHeader(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _index = 0;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 5,
                                bottom: 5,
                              ),
                              color: _index == 0 ? Colors.white : null,
                              child: Text(
                                '内容提供者',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _index == 0 ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _index = 1;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 5,
                                bottom: 5,
                              ),
                              color: _index == 1 ? Colors.white : null,
                              child: Text(
                                '内容盒',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _index == 1 ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
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
          constraints: BoxConstraints.expand(),
          child: IndexedStack(
            index: _index,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: _ContentProviderListPanel(
                  context: widget.context,
                  pool: _pool,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: _ContentBoxListPanel(
                  context: widget.context,
                  pool: _pool,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getLevelName() {
    var name;
    switch (_pool.level) {
      case -1:
        name = '常规';
        break;
      case 0:
        name = '全国';
        break;
      case 1:
        name = '省';
        break;
      case 2:
        name = '市';
        break;
      case 3:
        name = '区、县';
        break;
      case 4:
        name = '乡镇、街道';
        break;
      default:
        name = '';
        break;
    }
    return name;
  }
}

class _ContentProviderListPanel extends StatefulWidget {
  PageContext context;
  TrafficPool pool;

  _ContentProviderListPanel({this.context, this.pool});

  @override
  __ContentProviderListPanelState createState() =>
      __ContentProviderListPanelState();
}

class __ContentProviderListPanelState extends State<_ContentProviderListPanel> {
  int _limit = 10, _offset = 0;
  TrafficPool _pool;
  bool _isLoading = false;
  List<Person> _providers = [];
  EasyRefreshController _controller;

  @override
  void initState() {
    _pool = widget.pool;
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ContentProviderListPanel oldWidget) {
    if (oldWidget.pool.id != widget.pool.id) {
      oldWidget.pool = widget.pool;
      _offset = 0;
      _providers.clear();
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<String> providers =
        await recommender.pageContentProvider(_pool.id, _limit, _offset);
    if (providers.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += providers.length;
    for (var provider in providers) {
      var person = await personService.getPerson(provider);
      _providers.add(person);
    }
    if (mounted) {
      setState(() {});
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      shrinkWrap: true,
      header: easyRefreshHeader(),
      footer: easyRefreshFooter(),
      controller: _controller,
      onLoad: _load,
      slivers: _providers.map((provider) {
        if(provider==null){
          return SliverToBoxAdapter(child: SizedBox(height: 0,width: 0,),);
        }
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.context.forward('/chasechain/provider', arguments: {
                    'provider': provider.official,
                    'pool': widget.pool.id,
                  });
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      provider.avatar.startsWith('/')
                          ? Image.file(
                              File(provider.avatar),
                              width: 40,
                              height: 40,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder:
                                  'lib/portals/gbera/images/default_watting.gif',
                              image:
                                  '${provider.avatar}?accessToken=${widget.context.principal.accessToken}',
                              width: 40,
                              height: 40,
                            ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          '${provider.nickName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
                child: Divider(
                  height: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ContentBoxListPanel extends StatefulWidget {
  PageContext context;
  TrafficPool pool;

  _ContentBoxListPanel({this.context, this.pool});

  @override
  __ContentBoxListPanelState createState() => __ContentBoxListPanelState();
}

class __ContentBoxListPanelState extends State<_ContentBoxListPanel> {
  int _limit = 10, _offset = 0;
  TrafficPool _pool;
  bool _isLoading = false;
  List<ContentBoxOR> _boxList = [];
  EasyRefreshController _controller;

  @override
  void initState() {
    _pool = widget.pool;
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ContentBoxListPanel oldWidget) {
    if (oldWidget.pool.id != widget.pool.id) {
      oldWidget.pool = widget.pool;
      _offset = 0;
      _boxList.clear();
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    List<ContentBoxOR> boxList =
        await recommender.pageContentBox(_pool.id, _limit, _offset);
    if (boxList.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += boxList.length;
    _boxList.addAll(boxList);
    if (mounted) {
      setState(() {});
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      shrinkWrap: true,
      header: easyRefreshHeader(),
      footer: easyRefreshFooter(),
      controller: _controller,
      onLoad: _load,
      slivers: _boxList.map((box) {
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.context.forward(
                    '/chasechain/box',
                    arguments: {'box': box, 'pool': widget.pool.id},
                  );
                },
                child: Padding(
                  padding:
                  EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      StringUtil.isEmpty(box.pointer.leading)
                          ? Image.asset(
                        'lib/portals/gbera/images/netflow.png',
                        width: 40,
                        height: 40,
                      )
                          : FadeInImage.assetNetwork(
                        placeholder:
                        'lib/portals/gbera/images/default_watting.gif',
                        image:
                        '${box.pointer.leading}?accessToken=${widget.context.principal.accessToken}',
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${box.pointer.title}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              '${box.pointer.type.startsWith('geo.receptor') ? '地理感知器' : '网流管道'}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 15,
                child: Divider(
                  height: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;
  double height = 40;

  _DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      alignment: Alignment.bottomCenter,
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
