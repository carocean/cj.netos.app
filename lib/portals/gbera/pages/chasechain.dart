import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/wpopup_menu/w_popup_menu.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
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
          child: _ContentItemPannel(
            context: widget.context,
            item: item,
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
  Future<Person> _future_getPerson;
  Future<TrafficPool> _future_getPool;
  Future<ContentBoxOR> _future_getContentBox;

  @override
  void initState() {
    _loadDocumentContent();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(_ContentItemPannel oldWidget) {
    if (oldWidget.item.id != widget.item.id) {
      oldWidget.item = widget.item;
      _loadDocumentContent();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadDocumentContent() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _doc = await recommender.getDocument(widget.item);
    _future_getPerson = _getPerson();
    _future_getPool = _getPool();
    _future_getContentBox = _getContentBox();
    if (mounted) setState(() {});
  }

  Future<Person> _getPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(_doc.message.creator);
  }

  Future<TrafficPool> _getPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficPool(_doc.item.pool);
  }

  Future<ContentBoxOR> _getContentBox() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getContentBox(_doc.item.pool, _doc.item.box);
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
        if (!StringUtil.isEmpty(_doc.message.content)) {
          layout.add(
            _renderContent(),
          );
        }
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
        if (_doc.medias.isEmpty) {
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
        }
        layout.add(
          _renderFooter(),
        );
        break;
      case 1: //左文右图
        var rows = <Widget>[];
        if (!StringUtil.isEmpty(_doc.message.content)) {
          rows.add(
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _renderContent(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: _renderFooter(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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
        if (!StringUtil.isEmpty(_doc.message.content)) {
          rows.add(
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _renderContent(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: _renderFooter(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        );
        break;
      default:
        print('未知布局! 消息:${_doc.message.id} ${_doc.message.content}');
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
        left: 15,
        right: 15,
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _maxLines = _maxLines == 2 ? 10000 : 2;
          if (mounted) {
            setState(() {});
          }
        },
        child: Text(
          '${_doc.message.content ?? ''}',
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
//          letterSpacing: 1.4,
//          wordSpacing: 1.4,
//          height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _renderMedias() {
    return Container(
      height: 210,
      alignment: Alignment.center,
      child: RecommenderMediaWidget(
        _doc.medias,
        widget.context,
      ),
    );
  }

  Widget _renderFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '${TimelineUtil.format(
                _doc.message.ctime,
                dayFormat: DayFormat.Full,
              )}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            FutureBuilder<TrafficPool>(
              future: _future_getPool,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
                var pool = snapshot.data;
                if (pool == null) {
                  return SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
                return Wrap(
                  direction: Axis.horizontal,
                  spacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.pool,
                      size: 14,
                      color: pool.isGeosphere ? Colors.green : Colors.grey,
                    ),
                    Text(
                      '${pool.title}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  FutureBuilder<Person>(
                    future: _future_getPerson,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return SizedBox(
                          width: 0,
                          height: 0,
                        );
                      }
                      var person = snapshot.data;
                      if (person == null) {
                        return SizedBox(
                          width: 0,
                          height: 0,
                        );
                      }
                      return Text(
                        '${person?.nickName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FutureBuilder<ContentBoxOR>(
                    future: _future_getContentBox,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return SizedBox(
                          width: 0,
                          height: 0,
                        );
                      }
                      var box = snapshot.data;
                      if (box == null) {
                        return SizedBox(
                          width: 0,
                          height: 0,
                        );
                      }
                      return Wrap(
                        direction: Axis.horizontal,
                        spacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: <Widget>[
                          Icon(
                            _doc.message.type == 'netflow'
                                ? Icons.all_inclusive
                                : Icons.add_location,
                            size: 14,
                            color: Colors.grey,
                          ),
                          Text(
                            '${box.pointer.title}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: WPopupMenu(
                child: Icon(
                  IconData(
                    0xe79d,
                    fontFamily: 'ellipse',
                  ),
                  size: 22,
                ),
                actions: <Widget>[],
                onValueChanged: (index) {},
                pressType: PressType.singleClick,
              ),
            )
          ],
        ),
      ],
    );
  }
}
