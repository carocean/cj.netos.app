import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:toast/toast.dart';

import 'chasechain/content_item.dart';

class Chasechain extends StatefulWidget {
  PageContext context;

  Chasechain({this.context});

  @override
  _ChasechainState createState() => _ChasechainState();
}

class _ChasechainState extends State<Chasechain> {
  EasyRefreshController _controller;
  String _towncode;
  String _country;
  List<ContentItemOR> _items = [];
  int _limit = 20;
  int _offset = 0;
  bool _isLoading=true;
  bool _isFirstRecommenderDone=false;//是否首次推荐已完成

  @override
  void initState() {
    _controller = EasyRefreshController();
    () async {
      await _load();
      if(mounted){
        setState(() {
          _isLoading=false;
        });
      }
      var location = await geoLocation.location;
      var latLng = location.latLng;
      var recode = await AmapSearch.instance.searchReGeocode(latLng, radius: 200.0);
      _towncode = recode.townCode;
      _country= recode.country;
      await _onRefresh();
      if(mounted){
        setState(() {
        });
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
//    geoLocation.stop();
    super.dispose();
  }

  Future<void> _load() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var items = await recommender.loadItemsFromSandbox(_limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += items.length;
    _items.addAll(items);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    if (StringUtil.isEmpty(_towncode)) {
      return;
    }
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var items = await recommender.pullItem(_towncode);
    _items.insertAll(0, items);
    _offset += items.length;
    if (mounted) {
      Toast.show('已推荐${items.length}个', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      setState(() {
        _isFirstRecommenderDone=true;
      });
    }
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
            actions: <Widget>[
              PopupMenuButton<String>(
                offset: Offset(
                  0,
                  50,
                ),
                tooltip: '追链',
                onSelected: (value) async {
                  switch (value) {
                    case 'pools':
                      widget.context
                          .forward('/chasechain/traffic/pools', arguments: {
                        'towncode': _towncode,
                      });
                      break;
                    case 'profiles':
                      widget.context.forward('/chasechain/recommender/profile',
                          arguments: {});
                      break;
                    default:
                      print('不支持的菜单');
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: 'pools',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            Icons.pool,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '流量中国',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'profiles',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '偏好设置',
                          style: TextStyle(
                            fontSize: 14,
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
        Expanded(child: _renderContentPanel(),),
      ],
    );
  }

  Widget _renderContentPanel() {
    if (_isLoading) {
      return Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        child: Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            backgroundColor: Colors.green,
          ),
        ),
      );
    }

    return EasyRefresh.custom(
      controller: _controller,
      onRefresh: _onRefresh,
      onLoad: _load,
      header: easyRefreshHeader(),
      footer: easyRefreshFooter(),
      slivers: _getSlivers(),
    );
  }

  List<Widget> _getSlivers() {
    var slivers = <Widget>[];
    if(_items.isEmpty&&_isFirstRecommenderDone) {
      var isIosAndNotChina=Platform.isIOS&&_country!='中国';
      slivers.add(SliverToBoxAdapter(child: Container(
        alignment: Alignment.center,
        height: Adapt.screenH()-150,
        constraints: BoxConstraints.tightForFinite(width: double.maxFinite,),
        child: Text('没有推荐内容，${isIosAndNotChina?'请尝试下拉刷新，如果仍没有内容，或许是你不在追链支持地区':'请尝试下拉刷新'}',style: TextStyle(fontSize: 12,color: Colors.grey,),),
      ),),);
      return slivers;
    }
    for (var item in _items) {
      slivers.add(
        SliverToBoxAdapter(
          child: ContentItemPanel(
            context: widget.context,
            item: item,
            towncode: _towncode,
          ),
        ),
      );
    }
    return slivers;
  }
}
