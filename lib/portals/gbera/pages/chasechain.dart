import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
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
  int _maxLines = 4;
  RecommenderDocument _doc;
  Future<TrafficPool> _future_getPool;
  bool _isCollapsibled = true;
  Future<Person> _future_getPerson;
  Future<ContentBoxOR> _future_getContentBox;
  Future<TrafficDashboard> _future_getTrafficDashboard;

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
    _future_getPool = _getPool();
    _future_getPerson = _getPerson();
    _future_getContentBox = _getContentBox();
    _future_getTrafficDashboard = _getTrafficDashboard();
    if (mounted) setState(() {});
  }

  Future<TrafficPool> _getPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficPool(_doc.item.pool);
  }

  Future<Person> _getPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(_doc.message.creator);
  }

  Future<ContentBoxOR> _getContentBox() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getContentBox(_doc.item.pool, _doc.item.box);
  }

  Future<TrafficDashboard> _getTrafficDashboard() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficDashboard(_doc.item.pool);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
          _maxLines = _maxLines == 4 ? 10000 : 4;
          if (mounted) {
            setState(() {});
          }
        },
        child: Text(
          '${_doc.message.content ?? ''}',
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
//            wordSpacing: 1.4,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _renderMedias() {
    return RecommenderMediaWidget(
      _doc.medias,
      widget.context,
    );
  }

  Widget _renderFooter() {
    var columns = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${TimelineUtil.format(
              _doc.message.ctime,
              dayFormat: DayFormat.Full,
            )}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Row(
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
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
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
                        size: 11,
                        color: Colors.grey,
                      ),
                      Text(
                        '${box.pointer.title}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FutureBuilder<TrafficDashboard>(
                future: _future_getTrafficDashboard,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.data == null) {
                    return SizedBox(
                      height: 0,
                      width: 0,
                    );
                  }
                  var dashboard = snapshot.data;
                  return Row(
                    children: <Widget>[
                      Text(
                        '${parseInt(dashboard.innerLikes, 2)}个赞',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${parseInt(dashboard.innerComments, 2)}个评',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                width: 5,
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
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _isCollapsibled = !_isCollapsibled;
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.pool,
                          size: 11,
                          color: pool.isGeosphere ? Colors.green : Colors.grey,
                        ),
                        Text(
                          '${pool.title}',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                _isCollapsibled ? Colors.grey : Colors.blueGrey,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ];
    if (!_isCollapsibled) {
      columns.add(
        SizedBox(
          height: 10,
        ),
      );
      columns.add(
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
            return _CollapsiblePanel(
              context: widget.context,
              doc: _doc,
              pool: pool,
            );
          },
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: columns,
    );
  }
}

class _CollapsiblePanel extends StatefulWidget {
  PageContext context;
  RecommenderDocument doc;
  TrafficPool pool;

  _CollapsiblePanel({this.context, this.doc, this.pool});

  @override
  __CollapsiblePanelState createState() => __CollapsiblePanelState();
}

class __CollapsiblePanelState extends State<_CollapsiblePanel> {
  bool _isShowCommentRegion = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(_CollapsiblePanel oldWidget) {
    if (oldWidget.doc.item.id != widget.doc.item.id) {
      oldWidget.doc = widget.doc;
    }
    if (oldWidget.pool.id != widget.pool.id) {
      oldWidget.pool = widget.pool;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        _getCurrentPoolPanel(),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            '来源',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _getSourcePanel(),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            '流径',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _getRoutePoolPanel(),
      ],
    );
  }

  Widget _getCurrentPoolPanel() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2,
                    ),
                    child: StringUtil.isEmpty(widget.pool.icon)
                        ? SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(
                              Icons.pool,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          )
                        : ClipRect(
                            child: Image.network(
                              '${widget.pool.icon}?accessToken=${widget.context.principal.accessToken}',
                              height: 20,
                              width: 20,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.pool.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _isShowCommentRegion = !_isShowCommentRegion;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 15,
                    ),
                    child: Icon(
                      Icons.add_comment,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                    ),
                    child: Icon(
                      FontAwesomeIcons.thumbsUp,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.remove_red_eye,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '已推荐给 ',
                        children: [
                          TextSpan(text: '34.56k 个人'),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 12,
//                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
//                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      FontAwesomeIcons.thumbsUp,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: _getLikeSpanList(),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                Icons.mode_comment,
                                size: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '12.3k个评论',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: _getCommentList(),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '入池 2020/2/14 22:20',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  List<TextSpan> _getLikeSpanList() {
    var spans = <TextSpan>[];
    for (var i = 0; i < 10; i++) {
      spans.add(
        TextSpan(
          text: '姓名$i',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ),
        ),
      );
      spans.add(
        TextSpan(
          text: '; ',
        ),
      );
    }
    spans.add(
      TextSpan(
        text: '等12.3k个人很赞',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          decoration: TextDecoration.underline,
        ),
      ),
    );
    return spans;
  }

  List<Widget> _getCommentList() {
    var commends = <Widget>[];
    for (var i = 0; i < 5; i++) {
      commends.add(
        Padding(
          padding: EdgeInsets.only(
            left: 18,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '姓名$i: ',
                    children: [
                      TextSpan(
                        text:
                            '最新的4.7.0版，收录了675个图标…如果你觉得本页图标太小。且需要在Photoshop等其他桌面应用中使用',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      commends.add(
        SizedBox(
          height: 6,
        ),
      );
    }
    commends.add(
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          '更多',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
    if (_isShowCommentRegion) {
      commends.add(
        SizedBox(
          height: 10,
        ),
      );
      commends.add(
        _CommentEditor(
          context: widget.context,
          onCloseWin: () {
            _isShowCommentRegion = false;
            if (mounted) {
              setState(() {});
            }
          },
          onFinished: (v) {},
        ),
      );
    }
    return commends;
  }

  Widget _getSourcePanel() {
    var columns = <Widget>[];
    columns.add(
      Padding(
        padding: EdgeInsets.only(
          left: 30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: Icon(
                Icons.picture_in_picture_alt,
                size: 20,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: <Widget>[
                Text(
                  '飞机票',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(width: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '1.23k个赞',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 5,),
                    Text(
                      '268k个评',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
      ),
      child: Column(
        children: columns,
      ),
    );
  }

  Widget _getRoutePoolPanel() {
    var columns = <Widget>[];
    for (var i = 0; i < 4; i++) {
      columns.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '12:32',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: Text(
                '发布到',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 2,
                      ),
                      child: StringUtil.isEmpty(widget.pool.icon)
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: Icon(
                                Icons.pool,
                                size: 20,
                              ),
                            )
                          : ClipRect(
                              child: Image.network(
                                '${widget.pool.icon}?accessToken=${widget.context.principal.accessToken}',
                                height: 20,
                                width: 20,
                              ),
                            ),
                    ),
                    Text(
                      '${widget.pool.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Text.rich(
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(text: ' '),
                      TextSpan(
                        text: '18.2k个荐',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: '12.23k个赞',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: '12.23k个评',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      if (i < 4 - 1) {
        columns.add(
          SizedBox(
            height: 10,
            child: Divider(
              height: 1,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
      ),
      child: Column(
        children: columns,
      ),
    );
  }
}

class _CommentEditor extends StatefulWidget {
  void Function(String content) onFinished;
  void Function() onCloseWin;
  PageContext context;

  _CommentEditor({this.context, this.onFinished, this.onCloseWin});

  @override
  __CommentEditorState createState() => __CommentEditorState();
}

class __CommentEditorState extends State<_CommentEditor> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            //解决了无法计算边界问题
            fit: FlexFit.tight,
            child: ExtendedTextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (v) {
                print(v);
              },
              onEditingComplete: () {
                print('----');
              },
              style: TextStyle(
                fontSize: 14,
              ),
              maxLines: 50,
              minLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixText: '说道>',
                prefixStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                labelText:
                    '${widget.context.principal.nickName ?? widget.context.principal.accountCode}',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
                fillColor: Colors.white,
                filled: true,
                hintText: '输入您的评论',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check,
                  size: 14,
                ),
                onPressed: () async {
                  if (widget.onFinished != null) {
                    await widget.onFinished(_controller.text);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 14,
                ),
                onPressed: () async {
                  _controller.text = '';
                  if (widget.onCloseWin != null) {
                    await widget.onCloseWin();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
