import 'dart:io';

import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ContentProviderViewPage extends StatefulWidget {
  PageContext context;

  ContentProviderViewPage({this.context});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<ContentProviderViewPage> {
  TrafficPool _pool;
  Person _provider;

  @override
  void initState() {
    _pool =widget.context.parameters['pool'];
    _provider=widget.context.parameters['provider'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _goMap() async {
    var geocodeList = await AmapSearch.searchGeocode(
      _pool.geoTitle,
    );
    if (geocodeList.isEmpty) {
      return;
    }
    var first = geocodeList[0];
    var location = await first.latLng;
    widget.context.forward('/chasechain/pool/location',
        arguments: {'pool': _pool, 'location': location});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('${_provider?.nickName ?? ''}'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<String>(
            offset: Offset(
              0,
              50,
            ),
            tooltip: '设置',
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  break;
                default:
                  print('不支持的菜单');
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 10,
                      ),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: _provider.avatar.startsWith('/')
                            ? Image.file(File(_provider.avatar))
                            : FadeInImage.assetNetwork(
                                placeholder:
                                    'lib/portals/gbera/images/default_watting.gif',
                                image:
                                    '${_provider.avatar}?accessToken=${widget.context.principal.accessToken}',
                              ),
                      ),
                    ),
                    Text(
                      '${_provider.nickName}的基本资料',
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
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 15,
                bottom: 2,
              ),
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  text: '${_pool.title}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '的内容盒',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                color: Colors.white,
                child: _ContentBoxListPanel(
                  context: widget.context,
                  pool: _pool,
                ),
              ),
            ),
          ],
        ),
      ),
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
  Person _provider;

  @override
  void initState() {
    _provider = widget.context.parameters['provider'];
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
    List<ContentBoxOR> boxList = await recommender.pageContentBoxOfProvider(
        _pool.id, _provider.official, _limit, _offset);
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
      controller: _controller,
      onLoad: _load,
      slivers: _boxList.map((box) {
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              CardItem(
                title: '${box.pointer.title}',
                subtitle: Text(
                  '${box.pointer.type.startsWith('geo.receptor') ? '地理感知器' : '网流管道'}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                paddingLeft: 15,
                paddingRight: 15,
                onItemTap: () {
                  widget.context.forward(
                    '/chasechain/box',
                    arguments: {'box': box, 'pool': widget.pool.id},
                  );
                },
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
