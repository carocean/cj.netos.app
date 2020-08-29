import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';

import 'content_item.dart';

///两个参数：pool 流量池标识, towncode 乡镇代码
class TrafficPoolsPage extends StatefulWidget {
  PageContext context;

  TrafficPoolsPage({this.context});

  @override
  _TrafficPoolsPageState createState() => _TrafficPoolsPageState();
}

class _TrafficPoolsPageState extends State<TrafficPoolsPage> {
  TrafficPool _currentPool;

  int _countContentProvider;
  StreamController<TrafficPool> _controller;

  @override
  void initState() {
    _controller = StreamController.broadcast();
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(TrafficPoolsPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');

    var poolId = widget.context.parameters['pool'];
    if (StringUtil.isEmpty(poolId)) {
      var towncode = widget.context.parameters['towncode'];
      if (!StringUtil.isEmpty(towncode)) {
        _currentPool = await recommender.getTownTrafficPool(towncode);
      }
      if (_currentPool == null) {
        _currentPool = await recommender.getCountryPool();
      }
    } else {
      _currentPool = await recommender.getTrafficPool(poolId);
    }
    await _countContentProvidersOfPool();
  }

  Future<void> _countContentProvidersOfPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _countContentProvider =
        await recommender.countContentProvidersOfPool(_currentPool.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPool == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              '加载中...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

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
                    child: _currentPoolSite(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: _PoolNavigationPanel(
                    context: widget.context,
                    pool: _currentPool,
                    onSelected: (pool) async {
                      _currentPool = pool;
                      await _countContentProvidersOfPool();
                      _controller.add(pool);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ];
            return slivers;
          },
          body: _RenderContentItemsPanel(
            context: widget.context,
            onChangeCurrentPool: _controller.stream,
            initPool: _currentPool,
          ),
        ),
      ),
    );
  }

  Widget _currentPoolSite() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            StringUtil.isEmpty(_currentPool.icon)
                ? Icon(
                    Icons.pool,
                    size: 30,
                    color: Colors.grey,
                  )
                : Image.network(
                    '${_currentPool.icon}?accessToken=${widget.context.principal.accessToken}',
                    width: 30,
                    height: 30,
                  ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: ()async {
                IChasechainRecommenderRemote recommender =
                widget.context.site.getService('/remote/chasechain/recommender');
                var pool=await recommender.getTrafficPool(_currentPool.id);
                widget.context.forward('/chasechain/pool/view',
                    arguments: {'pool': pool});
              },
              child: Text(
                '${_currentPool.title}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
//            SizedBox(
//              width: 5,
//            ),
//            Text(
//              '${parseInt((_countContentProvider ?? 0), 2)}个内容提供者',
//              style: TextStyle(
//                fontSize: 10,
//                color: Colors.grey[400],
//              ),
//            ),
          ],
        ),
        IconButton(
          onPressed: () {
            widget.context.backward();
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
  Stream<TrafficPool> onChangeCurrentPool;
  TrafficPool initPool;

  _RenderContentItemsPanel(
      {this.context, this.onChangeCurrentPool, this.initPool});

  @override
  __RenderContentItemsPanelState createState() =>
      __RenderContentItemsPanelState();
}

class __RenderContentItemsPanelState extends State<_RenderContentItemsPanel> {
  EasyRefreshController _controller;
  List<ContentItemOR> _items = [];
  int _limit = 20, _offset = 0;
  TrafficPool _currentPool;
  bool _isLoading = false;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _currentPool = widget.initPool;
    _controller = EasyRefreshController();
    _streamSubscription = widget.onChangeCurrentPool.listen((event) async {
      _currentPool = event;
//      await _refreshContentItems();
      if (mounted) {
        setState(() {});
      }
    });
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_RenderContentItemsPanel oldWidget) {
    if (oldWidget.initPool.id != widget.initPool.id) {
      oldWidget.initPool = widget.initPool;
      _currentPool = widget.initPool;
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

  Future<void> _loadContentItems() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    List<ContentItemOR> items =
        await recommender.pageContentItem(_currentPool.id, _limit, _offset);
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

class _PoolNavigationPanel extends StatefulWidget {
  PageContext context;
  TrafficPool pool;
  void Function(TrafficPool selected) onSelected;

  _PoolNavigationPanel({this.context, this.pool, this.onSelected});

  @override
  __PoolNavigationPanelState createState() => __PoolNavigationPanelState();
}

class __PoolNavigationPanelState extends State<_PoolNavigationPanel> {
  TrafficPool _townPool;
  TrafficPool _upstreamPool;

  @override
  void initState() {
    _load().then((value) {
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

  @override
  void didUpdateWidget(_PoolNavigationPanel oldWidget) {
    if (oldWidget.pool.id != widget.pool.id ||
        oldWidget.onSelected != widget.onSelected) {
      oldWidget.pool = widget.pool;
      oldWidget.onSelected = widget.onSelected;
      _loadUpstreamPool().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    await _loadTownPool();
    await _loadUpstreamPool();
  }

  Future<void> _loadTownPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var towncode = widget.context.parameters['towncode'];
    if (StringUtil.isEmpty(towncode)) {
      return;
    }
    _townPool = await recommender.getTownTrafficPool(towncode);
  }

  Future<void> _goUpstreamPool() async {
    await _loadUpstreamPool();
    if (widget.onSelected != null) {
      widget.onSelected(_upstreamPool);
    }
  }

  Future<void> _loadUpstreamPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var parent = widget.pool;
    _upstreamPool = await recommender.getTrafficPool(parent.parent);
  }

  Future<void> _goCountryPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var pool = await recommender.getCountryPool();
    if (widget.onSelected != null) {
      widget.onSelected(pool);
    }
  }

  Future<void> _goCurrentTownPool() async {
    if (widget.onSelected != null) {
      widget.onSelected(_townPool);
    }
  }

  @override
  Widget build(BuildContext context) {
    var layout = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          widget.pool.level == 0
              ? SizedBox(
                  height: 0,
                  width: 0,
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _goUpstreamPool();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.keyboard_arrow_up,
                        size: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        '${_upstreamPool?.title ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
          widget.pool.level == 0
              ? SizedBox(
                  height: 0,
                  width: 0,
                )
              : SizedBox(
                  width: 15,
                ),
          _townPool == null || _townPool.id == widget.pool.id
              ? SizedBox(
                  height: 0,
                  width: 0,
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _goCurrentTownPool();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        '${_townPool.title}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
          _townPool == null || _townPool.id == widget.pool.id
              ? SizedBox(
                  height: 0,
                  width: 0,
                )
              : SizedBox(
                  width: 15,
                ),
          widget.pool.level == 0 || _upstreamPool?.level == 0
              ? SizedBox(
                  height: 0,
                  width: 0,
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _goCountryPool();
                  },
                  child: Text(
                    '中国',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
        ],
      ),
    ];
    layout.add(
      SizedBox(
        height: 15,
      ),
    );
    layout.add(
      _ChildPoolPanel(
        context: widget.context,
        parent: widget.pool,
        whenCountryShowNormal: false,
        onSelected: (pool) {
          if (widget.onSelected != null) {
            widget.onSelected(pool);
          }
        },
      ),
    );
    if (widget.pool.level == 0) {
      //如果是全国才打常规
      layout.add(
        _ChildPoolPanel(
          context: widget.context,
          parent: widget.pool,
          whenCountryShowNormal: true,
          onSelected: (pool) {
            if (widget.onSelected != null) {
              widget.onSelected(pool);
            }
          },
        ),
      );
    }
    layout.add(
      SizedBox(
        height: 15,
      ),
    );
    return Column(
      children: layout,
    );
  }
}

class _ChildPoolPanel extends StatefulWidget {
  PageContext context;
  TrafficPool parent;
  bool whenCountryShowNormal;
  void Function(TrafficPool selected) onSelected;

  _ChildPoolPanel(
      {this.context, this.parent, this.whenCountryShowNormal, this.onSelected});

  @override
  __ChildPoolPanelState createState() => __ChildPoolPanelState();
}

class __ChildPoolPanelState extends State<_ChildPoolPanel> {
  List<TrafficPool> _childs = [];
  int _limit = 10, _offset = 0;
  EasyRefreshController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _offset = 0;
    _childs.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ChildPoolPanel oldWidget) {
    if (oldWidget.parent.id != widget.parent.id ||
        oldWidget.whenCountryShowNormal != widget.whenCountryShowNormal ||
        oldWidget.onSelected != widget.onSelected) {
      oldWidget.parent = widget.parent;
      oldWidget.whenCountryShowNormal = widget.whenCountryShowNormal;
      oldWidget.onSelected = widget.onSelected;
      _childs.clear();
      _offset = 0;
      //注意：如果第一次打开本页，由于initState中调用了加载，而此时正好要更新，也调用加载，则会同时进入load方法，导致从远程取得的同样的数据被添加两份,因此需要在此判断是否正在加载中
      if (!_isLoading) {
        _load();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _refresh() async {
    _offset = 0;
    _childs.clear();
    await _load();
  }

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    var parent = widget.parent;
    if (parent.level == 0) {
      if (widget.whenCountryShowNormal) {
        await _loadNormalPools(parent);
      } else {
        await _loadProvincePools(parent);
      }
    } else {
      await _loadChildPools(parent);
    }
    _isLoading = false;
  }

  Future<void> _loadChildPools(TrafficPool parent) async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var childs = await recommender.pageChildrenPool(parent.id, _limit, _offset);
    if (childs.isEmpty) {
      _controller.finishLoad(
        success: true,
        noMore: true,
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _childs.addAll(childs);
    _offset += childs.length;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadNormalPools(TrafficPool parent) async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var childs = await recommender.pageChildrenPoolByLevel(
        parent.id, -1, _limit, _offset);
    if (childs.isEmpty) {
      _controller.finishLoad(
        success: true,
        noMore: true,
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _childs.addAll(childs);
    _offset += childs.length;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProvincePools(TrafficPool parent) async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var childs = await recommender.pageChildrenPoolByLevel(
        parent.id, 1, _limit, _offset);
    if (childs.isEmpty) {
      _controller.finishLoad(
        success: true,
        noMore: true,
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _childs.addAll(childs);
    _offset += childs.length;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var pools = <Widget>[];
    for (var i = 0; i < _childs.length; i++) {
      var pool = _childs[i];
      pools.add(
        SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.onSelected != null) {
                widget.onSelected(pool);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              child: Text(
                '${pool.title}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      );
      if (i < _childs.length - 1) {
        pools.add(
          SliverToBoxAdapter(
            child: SizedBox(
              width: 20,
              child: VerticalDivider(
                width: 1,
                indent: 8,
                endIndent: 8,
              ),
            ),
          ),
        );
      }
    }
    return Padding(
      padding: EdgeInsets.only(
        left: 5,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(
          height: 28,
        ),
        child: EasyRefresh.custom(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          onRefresh: _refresh,
          onLoad: _load,
          shrinkWrap: true,
          slivers: pools,
        ),
      ),
    );
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
