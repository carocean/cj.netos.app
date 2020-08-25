import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
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
  List<ContentItemOR> _items = [];
  int _limit = 20;
  int _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load();
    geoLocation.start();
    geoLocation.listen('/chasechain', 0, (location) async {
      var latLng = await location.latLng;
      var recode = await AmapSearch.searchReGeocode(latLng, radius: 0);
      _towncode = await recode.townCode;
      geoLocation.unlisten('/chasechain');
      if (mounted) {
        setState(() {});
      }

      await _onRefresh();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    geoLocation.unlisten('/chasechain');
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
      setState(() {});
    }
    Toast.show('已推荐${items.length}个', context,
        gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
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
            onLoad: _load,
            header: ClassicalHeader(),
            footer: ClassicalFooter(),
            slivers: _getSlivers(),
          ),
        ),
      ],
    );
  }

  List<Widget> _getSlivers() {
    var slivers = <Widget>[];
    for (var item in _items) {
      slivers.add(
        SliverToBoxAdapter(
          child: ContentItemPanel(
            context: widget.context,
            item: item,
          ),
        ),
      );
    }
    return slivers;
  }
}
