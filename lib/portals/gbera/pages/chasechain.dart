import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:toast/toast.dart';

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
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    geoLocation.unlisten('/chasechain');
    geoLocation.stop();
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
    Toast.show('已推荐${items.length}个', context,
        gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    if (mounted) {
      setState(() {});
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
            actions: <Widget>[],
          ),
        ),
        Expanded(
          child: EasyRefresh.custom(
            controller: _controller,
            onRefresh: _onRefresh,
            onLoad: _load,
            firstRefresh: true,
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
          child: _ContentItemPannel(
            context: widget.context,
            item: item,
          ),
        ),
      );
      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 20,
          ),
        ),
      );
    }
    return slivers;
  }
}

class _ContentItemPannel extends StatefulWidget {
  PageContext context;
  ContentItemOR item;

  _ContentItemPannel({
    this.context,
    this.item,
  });

  @override
  _ContentItemPannelState createState() => _ContentItemPannelState();
}

class _ContentItemPannelState extends State<_ContentItemPannel> {
  int _maxLines = 2;
  RecommenderDocument _doc;

  @override
  void initState() {
    _loadDocumentContent().then((value) {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDocumentContent() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _doc = await recommender.getDocument(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    if (_doc == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }

    var layout = <Widget>[];
    switch (_doc.message.layout) {
      case 0: //上文下图
        layout.add(
          _renderContent(),
        );

        if (_doc.medias.isNotEmpty) {
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
          layout.add(
            _renderMedias(),
          );
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
        }

        break;
      case 1: //左文右图
        var rows = <Widget>[
          Expanded(
            child: _renderContent(),
          ),
        ];
        if (_doc.medias.isNotEmpty) {
          rows.add(
            SizedBox(
              width: 150,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: _renderMedias(),
              ),
            ),
          );
        }
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: rows,
          ),
        );

        break;
      case 2: //左图右文
        var rows = <Widget>[];
        if (_doc.medias.isNotEmpty) {
          rows.add(
            SizedBox(
              width: 150,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: _renderMedias(),
              ),
            ),
          );
        }
        rows.add(
          Expanded(
            child: _renderContent(),
          ),
        );
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: rows,
          ),
        );
        break;
    }
    layout.add(
      SizedBox(
        height: 20,
        child: Divider(
          height: 1,
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: layout,
      ),
    );
  }

  Widget _renderContent() {
    return Container(
      child: Text(
        '${_doc.message.content ?? ''}',
        maxLines: _maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
          wordSpacing: 1.4,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _renderMedias() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: RecommenderMediaWidget(
        _doc.medias,
        widget.context,
      ),
    );
  }
}
