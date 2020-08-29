import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

import 'content_item.dart';

class ContentProviderPage extends StatefulWidget {
  PageContext context;

  ContentProviderPage({this.context});

  @override
  _ContentProviderPageState createState() => _ContentProviderPageState();
}

class _ContentProviderPageState extends State<ContentProviderPage> {
  Person _contentProvider;

  @override
  void initState() {
    _loadContentProvder().then((value) {
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

  Future<void> _loadContentProvder() async {
    var provider = widget.context.parameters['provider'];
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _contentProvider = await personService.getPerson(provider);
  }

  @override
  Widget build(BuildContext context) {
//    ContentBoxOR box = widget.context.parameters['box'];

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
                    child: _contentProvider == null
                        ? SizedBox(
                            width: 0,
                            height: 53,
                          )
                        : _BoxHeader(
                            contentProvider: _contentProvider,
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
          body: _contentProvider == null
              ? Column(
                  children: <Widget>[
                    Text(
                      '加载中...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                )
              : _RenderContentItemsPanel(
                  context: widget.context,
                  contentProvider: _contentProvider,
                ),
        ),
      ),
    );
  }
}

class _BoxHeader extends StatelessWidget {
  Person contentProvider;
  PageContext context;

  _BoxHeader({
    this.contentProvider,
    this.context,
  });

  _goView() async {
    var poolId = this.context.parameters['pool'];
    IChasechainRecommenderRemote recommender =
        this.context.site.getService('/remote/chasechain/recommender');
    var pool = await recommender.getTrafficPool(poolId);
    this.context.forward('/chasechain/provider/view',
        arguments: {'pool': pool, 'provider': this.contentProvider});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              this.contentProvider.avatar.startsWith('/')
                  ? Image.file(
                      File(this.contentProvider.avatar),
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    )
                  : FadeInImage.assetNetwork(
                      placeholder:
                          'lib/portals/gbera/images/default_watting.gif',
                      image:
                          '${this.contentProvider.avatar}?accessToken=${this.context.principal.accessToken}',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _goView();
                  },
                  child: Text(
                    '${contentProvider.nickName}',
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
  Person contentProvider;

  _RenderContentItemsPanel({
    this.context,
    this.contentProvider,
  });

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
    if (oldWidget.contentProvider.official != widget.contentProvider.official) {
      oldWidget.contentProvider = widget.contentProvider;
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
//    IChasechainRecommenderRemote recommender =
//        widget.context.site.getService('/remote/chasechain/recommender');
//    var pool = widget.context.parameters['pool'];
//    var _onPool = await recommender.getTrafficPool(pool);
  }

  Future<void> _loadContentItems() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var pool = widget.context.parameters['pool'];
    List<ContentItemOR> items = await recommender.pageContentItemOfProvider(
        pool, widget.contentProvider, _limit, _offset);
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

class _BoxPointerRealObject {
  String icon;
  String title;
  String id;
  String type;

  _BoxPointerRealObject({this.icon, this.title, this.id, this.type});
}
