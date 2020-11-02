import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/system/local/entities.dart';

import 'content_item.dart';

class ContentBoxPage extends StatefulWidget {
  PageContext context;

  ContentBoxPage({this.context});

  @override
  _ContentBoxPageState createState() => _ContentBoxPageState();
}

class _ContentBoxPageState extends State<ContentBoxPage> {
  BoxPointerRealObject _boxPointerRealObject;

  @override
  void initState() {
    _loadBoxPointerRealObject().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBoxPointerRealObject() async {
    ContentBoxOR box = widget.context.parameters['box'];
    if (box.pointer.type.startsWith('geo.receptor.')) {
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      var category = box.pointer.type;
      int pos = category.lastIndexOf('.');
      category = category.substring(pos + 1);
      var receptor = await receptorRemote.getReceptor(category, box.pointer.id);
      if (receptor == null) {
        return;
      }
      var locationJson = receptor.location;
      LatLng location;
      if (!StringUtil.isEmpty(locationJson)) {
        location = LatLng.fromJson(jsonDecode(locationJson));
      }
      _boxPointerRealObject = BoxPointerRealObject(
        type: 'receptor',
        title: receptor.title,
        id: receptor.id,
        icon: receptor.leading,
        location: location,
      );
      return;
    }
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    var channel = await channelRemote.findChannelOfPerson(
        box.pointer.id, box.pointer.type);
    _boxPointerRealObject = BoxPointerRealObject(
      type: 'channel',
      title: channel.name,
      id: channel.id,
      icon: channel.leading,
    );
  }

  @override
  Widget build(BuildContext context) {
    ContentBoxOR box = widget.context.parameters['box'];

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (ctx, index) {
            var slivers = <Widget>[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _DemoHeader(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 15,
                    ),
                    child: _boxPointerRealObject == null
                        ? SizedBox(
                            width: 0,
                            height: 53,
                          )
                        : _BoxHeader(
                            box: box,
                            boxPointerRealObject: _boxPointerRealObject,
                            context: widget.context,
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20,
                ),
              ),
            ];
            return slivers;
          },
          body: _RenderContentItemsPanel(
            context: widget.context,
            box: box,
          ),
        ),
      ),
    );
  }
}

class _BoxHeader extends StatelessWidget {
  ContentBoxOR box;
  BoxPointerRealObject boxPointerRealObject;
  PageContext context;

  _BoxHeader({this.box, this.boxPointerRealObject, this.context});

  _goView() async {
    var poolId = this.context.parameters['pool'];
    IChasechainRecommenderRemote recommender =
        this.context.site.getService('/remote/chasechain/recommender');
    var pool = await recommender.getTrafficPool(poolId);
    this.context.forward('/chasechain/box/view', arguments: {
      'pool': pool,
      'box': this.box,
      'boxRealObject': boxPointerRealObject
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              StringUtil.isEmpty(this.boxPointerRealObject?.icon)
                  ? Icon(
                      Icons.pool,
                      size: 30,
                      color: this.boxPointerRealObject.type == 'receptor'
                          ? Colors.green
                          : Colors.grey,
                    )
                  : FadeInImage.assetNetwork(
                      placeholder:
                          'lib/portals/gbera/images/default_watting.gif',
                      image:
                          '${this.boxPointerRealObject.icon}?accessToken=${this.context.principal.accessToken}',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _goView();
                  },
                  child: Text(
                    '${boxPointerRealObject.title}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            this.context.backward();
          },
          icon: Icon(
            Icons.backspace,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _RenderContentItemsPanel extends StatefulWidget {
  PageContext context;
  ContentBoxOR box;
  dynamic boxPointerRealObject;

  _RenderContentItemsPanel({this.context, this.box, this.boxPointerRealObject});

  @override
  __RenderContentItemsPanelState createState() =>
      __RenderContentItemsPanelState();
}

class __RenderContentItemsPanelState extends State<_RenderContentItemsPanel> {
  EasyRefreshController _controller;
  List<ContentItemOR> _items = [];
  int _limit = 20, _offset = 0;
  bool _isLoading = false;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_RenderContentItemsPanel oldWidget) {
    if (oldWidget.box.id != widget.box.id ||
        oldWidget.boxPointerRealObject != widget.boxPointerRealObject) {
      oldWidget.box = widget.box;
      oldWidget.boxPointerRealObject = widget.boxPointerRealObject;
      if (!_isLoading) {
        _offset = 0;
        _items.clear();
        _load().then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    await _loadOnPool();
    await _loadContentItems();
  }

  Future<void> _refreshContentItems() async {
    _offset = 0;
    _items.clear();
    await _loadContentItems();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadOnPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var pool = widget.context.parameters['pool'];
    var _onPool = await recommender.getTrafficPool(pool);
  }

  Future<void> _loadContentItems() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var pool = widget.context.parameters['pool'];
    List<ContentItemOR> items = await recommender.pageContentItemOfBox(
        pool, widget.box.id, _limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += items.length;
    _items.addAll(items);
    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      controller: _controller,
      onRefresh: _refreshContentItems,
      onLoad: _loadContentItems,
      header: ClassicalHeader(),
      footer: ClassicalFooter(),
      slivers: _getContentItemSlivers(),
    );
  }

  List<Widget> _getContentItemSlivers() {
    var slivers = <Widget>[];
    if (_items.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          child: Center(
            child: Text(
              '没有内容！',
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      );
    } else {
      String towncode = widget.context.parameters['towncode'];
      for (var i = 0; i < _items.length; i++) {
        var item = _items[i];
        slivers.add(
          SliverToBoxAdapter(
            child: ContentItemPanel(
              context: widget.context,
              item: item,
              towncode: towncode,
            ),
          ),
        );
      }
    }
    return slivers;
  }
}

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;
  double height = 53;

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

class BoxPointerRealObject {
  String icon;
  String title;
  String id;
  String type;
  LatLng location;

  BoxPointerRealObject({
    this.icon,
    this.title,
    this.id,
    this.type,
    this.location,
  });
}
