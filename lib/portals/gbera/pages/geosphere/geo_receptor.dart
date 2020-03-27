import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/wpopup_menu/w_popup_menu.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/netflow/article_entities.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class GeoReceptorWidget extends StatefulWidget {
  PageContext context;

  GeoReceptorWidget({this.context});

  @override
  _GeoReceptorWidgetState createState() => _GeoReceptorWidgetState();
}

class _GeoReceptorWidgetState extends State<GeoReceptorWidget> {
  List<ChannelMessage> messages = [];
  ReceptorInfo _receptorInfo;
  bool _isShowWallPaper = false;
  bool _isShowBanner = true;
  EasyRefreshController _refreshController;
  GeoCategoryOL _category;
  bool _isLoaded = false;

  @override
  void initState() {
    _receptorInfo = widget.context.parameters['receptor'];
    _refreshController = EasyRefreshController();
    _loadCategory().then((v) {
      _isLoaded = true;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    IGeoCategoryLocal categoryLocal =
        widget.context.site.getService('/geosphere/categories');
    _category = await categoryLocal.get(_receptorInfo.category);
  }

  Future<void> _onloadMessages() async {}

  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[
      SliverPersistentHeader(
        floating: false,
        pinned: true,
        delegate: GberaPersistentHeaderDelegate(
            automaticallyImplyLeading: true,
            elevation: 0,
            centerTitle: true,
            expandedHeight: !_isShowBanner ? 0 : 200,
            background: !_isShowBanner
                ? null
                : NetworkImage(
                    'http://47.105.165.186:7100/public/geosphere/wallpapers/e27df176176b9a03bfe72ee5b05f87e4.jpg?accessToken=${widget.context.principal.accessToken}',
                  ),
            onRenderAppBar: (appBar, RenderStateAppBar state) {
              switch (state) {
                case RenderStateAppBar.origin:
                  if (_isShowBanner || _isShowWallPaper) {
                    _showWhiteAppBar(appBar, showTitle: false);
                  } else {
                    _showBlackAppBar(appBar, showTitle: false);
                  }
                  return;
                case RenderStateAppBar.showAppBar:
                  _showBlackAppBar(appBar);
                  return;
                case RenderStateAppBar.expaned:
                  _showWhiteAppBar(appBar);
                  return;
              }
            }),
      ),
    ];
    if (_isLoaded) {
      slivers.add(
        SliverToBoxAdapter(
          child: _HeaderWidget(
            context: widget.context,
            receptorInfo: _receptorInfo,
            isShowWhite: _isShowWallPaper,
            categoryOL: _category,
            refresh: () {},
          ),
        ),
      );
    }
    slivers.addAll(
      _getMessageCards(),
    );
    return Scaffold(
      floatingActionButton: VoiceFloatingButton(
        onStartRecord: () {},
        onStopRecord: (a, b, c, d) {},
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: !_isShowWallPaper
            ? null
            : BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'http://47.105.165.186:7100/public/geosphere/wallpapers/f0a313238a3fa420bef974e62167881b.jpg?accessToken=${widget.context.principal.accessToken}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
        child: EasyRefresh.custom(
          controller: _refreshController,
          onLoad: _onloadMessages,
          slivers: slivers,
        ),
      ),
    );
  }

  void _showWhiteAppBar(GberaPersistentHeaderDelegate appBar,
      {bool showTitle = true}) {
    if (showTitle) {
      appBar.title = Text(
        _receptorInfo.title,
        style: TextStyle(
          color: Colors.white,
        ),
      );
    } else {
      appBar.title = null;
    }

    appBar.iconTheme = IconThemeData(
      color: Colors.white,
    );
    appBar.actions = _getActions(Colors.white);
  }

  void _showBlackAppBar(
    GberaPersistentHeaderDelegate appBar, {
    bool showTitle = true,
  }) {
    if (showTitle) {
      appBar.title = Text(
        _receptorInfo.title,
        style: TextStyle(
          color: null,
        ),
      );
    } else {
      appBar.title = null;
    }
    appBar.iconTheme = IconThemeData(
      color: null,
    );
    appBar.actions = _getActions(null);
  }

  List<Widget> _getMessageCards() {
    List<Widget> list = [];
    for (int i = 0; i < 40; i++) {
      list.add(
        SliverToBoxAdapter(
          child: _MessageCard(
            context: widget.context,
            message: ChannelMessage(
              '0000',
              'cj@gbera.netos',
              null,
              null,
              '039393993',
              'cj@gbera.netos',
              DateTime.now().millisecondsSinceEpoch,
              null,
              null,
              null,
              'arrived',
              '被报道“向中方请求医疗物资援助后，又向美国出口大量口罩”，泰国驻华使馆说明泰王国驻华大使馆就中国多家媒体报道“泰国向中方请求医疗物资援助后，又向美国出口大量口罩”一事的声明：            　　就中国多家媒体报道“泰国向中方请求医疗物资援助后，又向美国出口大量口罩”一事的声明就中国多家线上媒体报道称“泰国向中方请求医疗物资援助后又向美国出口大量口罩”以致在中国网络环境中广泛引发读者误解一事，泰王国驻华大使馆就事实真相作以下说明：            　　1。新闻报道的内容存在差异，且未指出部分事实：（1）在中国表示中方有能力给予帮助的基础上，泰国政府接受了中国的医疗物资援助；（2）在中国遭受新冠肺炎疫情严重影响期间，泰国向中国捐赠了资金及包括口罩在内的医疗物资和设备，以援助医护人员和受新冠肺炎影响的人民，不过在那段期间，其实泰国也已开始面临医疗物资尤其是口罩短缺的情况，但泰国依然基于中泰紧密关系和人道主义精神对中国施以援助。          ',
              10.00,
              null,
              widget.context.principal.person,
            ),
          ),
        ),
      );
    }
    return list;
  }

  List<Widget> _getActions(Color color) {
    return <Widget>[
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () {
//          widget.context.forward('/netflow/channel/publish_article',
//              arguments: <String, dynamic>{
//                'type': 'text',
//                'channel': _channel,
//                'refreshMessages': _refreshMessages
//              });
        },
        child: IconButton(
          icon: Icon(
            Icons.camera_enhance,
            size: 20,
            color: color,
          ),
          onPressed: () {
            showDialog<Map<String, Object>>(
              context: context,
              builder: (BuildContext context) => SimpleDialog(
                title: Text('请选择'),
                children: <Widget>[
                  DialogItem(
                    text: '文本',
                    subtext: '注：长按窗口右上角按钮便可不弹出该对话框直接发文',
                    icon: Icons.font_download,
                    color: Colors.grey[500],
                    onPressed: () {
                      widget.context
                          .backward(result: <String, dynamic>{'type': 'text'});
                    },
                  ),
                  DialogItem(
                    text: '从相册选择',
                    icon: Icons.image,
                    color: Colors.grey[500],
                    onPressed: () async {
                      var image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      widget.context.backward(result: <String, dynamic>{
                        'type': 'gallery',
                        'mediaFile':
                            MediaFile(type: MediaFileType.image, src: image),
                      });
                    },
                  ),
                ],
              ),
            ).then<void>((value) {
              // The value passed to Navigator.pop() or null.
              if (value != null) {
//                value['channel'] = _channel;
//                value['refreshMessages'] = _refreshMessages;
//                widget.context.forward('/netflow/channel/publish_article',
//                    arguments: value);
              }
            });
          },
        ),
      ),
    ];
  }
}

class _HeaderWidget extends StatefulWidget {
  PageContext context;
  Function() refresh;
  ReceptorInfo receptorInfo;
  bool isShowWhite;
  GeoCategoryOL categoryOL;

  _HeaderWidget({
    this.context,
    this.refresh,
    this.receptorInfo,
    this.isShowWhite,
    this.categoryOL,
  });

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<_HeaderWidget> {
  int _arrivedMessageCount = 5;
  String _arrivedMessageTips = '';
  var _workingChannel;
  String _poiTitle;
  LatLng _currentLatLng;
  List<GeoCategoryAppOR> _apps = [];

  @override
  void initState() {
    _loadLocation().then((v) {
      setState(() {});
    });
    geoLocation.listen('receptor.header', 5, _updateLocation);
//    _workingChannel = widget.context.parameters['workingChannel'];
//    _workingChannel.onRefreshChannelState = (command, args) {
//      _arrivedMessageCount++;
//      setState(() {});
//    };
    _loadCategoryApps().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('receptor.header');
    if (_workingChannel != null) {
      _workingChannel.onRefreshChannelState = null;
    }
    _arrivedMessageCount = 0;
    super.dispose();
  }

  @override
  void didUpdateWidget(_HeaderWidget oldWidget) {
    if (oldWidget.categoryOL != widget.categoryOL) {
      oldWidget.categoryOL = widget.categoryOL;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadCategoryApps() async {
    if (widget.categoryOL == null) {
      return;
    }
    IGeoCategoryRemote categoryRemote =
        widget.context.site.getService('/remote/geo/categories');
    var on =
        widget.categoryOL.moveMode == 'moveableSelf' ? 'onserved' : 'onservice';
    _apps = await categoryRemote.getApps(widget.categoryOL.id, on);
  }

  Future<void> _loadLocation() async {
    _currentLatLng = widget.receptorInfo.latLng;
    var list = await AmapSearch.searchAround(_currentLatLng,
        radius: 2000, type: amapPOIType);
    if (list == null || list.isEmpty) {
      return;
    }
    _poiTitle = await list[0].title;
  }

  _updateLocation(Location location) async {
    if (widget.categoryOL == null) {
      return;
    }
    if (widget.categoryOL.moveMode == 'unmoveable') {
      _currentLatLng = await location.latLng;
      setState(() {});
      return;
    }
    _currentLatLng = await location.latLng;
    _poiTitle = await location.poiName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget imgSrc = null;
    if (StringUtil.isEmpty(widget.receptorInfo.leading)) {
      imgSrc = Icon(
        IconData(
          0xe604,
          fontFamily: 'netflow2',
        ),
        size: 20,
        color: Colors.grey[500],
      );
    } else if (widget.receptorInfo.leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(widget.receptorInfo.leading),
        width: 20,
        height: 20,
      );
    } else {
      imgSrc = Image.network(
        widget.receptorInfo.leading,
        width: 20,
        height: 20,
      );
    }

    return Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(
        top: 10,
        left: 15,
        bottom: 10,
        right: 15,
      ),
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return widget.context.part(
                                '/geosphere/settings', context, arguments: {
                              'receptor': widget.receptorInfo,
                              'moveMode': widget.categoryOL?.moveMode
                            });
                          }).then((v) {
                        print('----$v');
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: imgSrc,
                          padding: EdgeInsets.only(
                            right: 10,
                            top: 3,
                          ),
                        ),
                        Flex(
                          direction: Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text.rich(
                              TextSpan(
                                text: '${widget.receptorInfo.title}',
                                children: [],
                              ),
                              softWrap: true,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: widget.isShowWhite
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '${widget.categoryOL?.title ?? ''}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isShowWhite
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '${_poiTitle ?? ''}',
                                    children: [
                                      TextSpan(
                                        text: '  附近',
                                      ),
                                    ],
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.isShowWhite
                                        ? Colors.white70
                                        : Colors.grey[500],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text:
                                        '离你 ${getFriendlyDistance(getDistance(start: _currentLatLng, end: widget.receptorInfo.latLng))}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: widget.isShowWhite
                                          ? Colors.white70
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _apps.isEmpty
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(0),
                    children: _geoCategoryApps(),
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _arrivedMessageCount == 0
                    ? Container()
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10,
                              ),
                              child: Icon(
                                Icons.new_releases,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                            Container(
                              child: Text.rich(
                                TextSpan(
                                  text: '有$_arrivedMessageCount条新消息',
                                  style: TextStyle(
                                    color: widget.isShowWhite
                                        ? Colors.white
                                        : Colors.blueGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return widget.context
                              .part('/geosphere/discovery', context);
                        }).then((v) {
                      print('----$v');
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 2,
                        ),
                        child: Text(
                          '${widget.categoryOL?.moveMode == 'moveableSelf' ? '服务' : '筛选'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.isShowWhite
                                ? Colors.white70
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.apps,
                        size: 18,
                        color: widget.isShowWhite
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _geoCategoryApps() {
    List<Widget> apps = [];
    for (var i = 0; i < _apps.length; i++) {
      var app = _apps[i];
      apps.add(
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                '${app.leading}?accessToken=${widget.context.principal.accessToken}',
                width: 24,
                height: 24,
                color: widget.isShowWhite ? Colors.white : Colors.grey[600],
              ),
              Text(
                '${app.title}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: widget.isShowWhite ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return apps;
  }
}

class _MessageCard extends StatefulWidget {
  PageContext context;
  ChannelMessage message;
  void Function(ChannelMessage message) onDeleted;

  _MessageCard({
    this.context,
    this.message,
    this.onDeleted,
  });

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  int maxLines = 4;
  Future<Person> _future_getPerson;
  Future<List<Media>> _future_getMedias;
  _InteractiveRegionRefreshAdapter _interactiveRegionRefreshAdapter;

  @override
  void initState() {
    _future_getPerson = _getPerson();
    _future_getMedias = _getMedias();
    _interactiveRegionRefreshAdapter = _InteractiveRegionRefreshAdapter();
    super.initState();
  }

  @override
  void dispose() {
    _future_getPerson = null;
    _future_getMedias = null;
    _interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Border(),
      elevation: 0,
      margin: EdgeInsets.only(bottom: 15),
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/site/marchant');
              },
              child: Padding(
                padding: EdgeInsets.only(top: 5, right: 5),
                child: ClipOval(
                  child: Image(
                    image: NetworkImage(
                        'https://sjbz-fd.zol-img.com.cn/t_s208x312c5/g5/M00/01/06/ChMkJ1w3FnmIE9dUAADdYQl3C5IAAuTxAKv7x8AAN15869.jpg'),
                    height: 35,
                    width: 35,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          widget.context.forward('/site/marchant');
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          '${widget.message.creator}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return widget.context.part(
                                      '/netflow/channel/serviceMenu', context);
                                }).then((value) {
                              print('-----$value');
                              if (value == null) return;
                              widget.context
                                  .forward('/micro/app', arguments: value);
                            });
                          },
                          icon: Icon(
                            Icons.art_track,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    //内容区
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text.rich(
                      TextSpan(
                        text: '${widget.message.text}',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              if (maxLines == 4) {
                                maxLines = 100;
                              } else {
                                maxLines = 4;
                              }
                            });
                          },
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FutureBuilder<List<Media>>(
                    future: _getMedias(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                      if (snapshot.hasError) {
                        print('${snapshot.error}');
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                      if (snapshot.data.isEmpty) {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                      return DefaultTabController(
                        length: snapshot.data.length,
                        child: PageSelector(
                          medias: snapshot.data,
                          onMediaLongTap: (media) {
                            widget.context.forward(
                              '/images/viewer',
                              arguments: {
                                'media': media,
                                'others': snapshot.data,
                                'autoPlay': true,
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Row(
                    //内容坠
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: FutureBuilder<Person>(
                            future: _future_getPerson,
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              }
                              if (snapshot.hasError) {
                                print('${snapshot.error}');
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              }
                              return Text.rich(
                                TextSpan(
                                  text: '${TimelineUtil.format(
                                    widget.message.ctime,
                                    dayFormat: DayFormat.Simple,
                                  )}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  children: [
                                    TextSpan(text: '  '),
                                    TextSpan(
                                        text:
                                            '¥${(widget.message.wy * 0.001).toStringAsFixed(2)}'),
                                    TextSpan(text: '\r\n'),
                                    TextSpan(
                                      text:
                                          '${widget.context.principal?.uid == snapshot.data.uid ? '创建自 ' : '来自 '}',
                                      children: [
                                        TextSpan(
                                          text:
                                              '${widget.context.principal?.uid == snapshot.data.uid ? '我' : snapshot.data.accountCode}',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              widget.context.forward(
                                                  "/site/personal",
                                                  arguments: {
                                                    'person': snapshot.data,
                                                  });
                                            },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                softWrap: true,
                              );
                            }),
                      ),
                      _MessageOperatesPopupMenu(
                        message: widget.message,
                        context: widget.context,
                        onDeleted: () {
                          if (widget.onDeleted != null) {
                            widget.onDeleted(widget.message);
                          }
                          setState(() {});
                        },
                        onComment: () {
                          _interactiveRegionRefreshAdapter.refresh('comment');
                        },
                        onliked: () {
                          _interactiveRegionRefreshAdapter.refresh('liked');
                        },
                        onUnliked: () {
                          _interactiveRegionRefreshAdapter.refresh('unliked');
                        },
                      ),
                    ],
                  ),
                  Container(
                    height: 7,
                  ),

                  ///相关交互区
                  _InteractiveRegion(
                    message: widget.message,
                    context: widget.context,
                    interactiveRegionRefreshAdapter:
                        _interactiveRegionRefreshAdapter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Person> _getPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var person = '';
    if (!StringUtil.isEmpty(widget.message.upstreamPerson)) {
      person = widget.message.upstreamPerson;
    }
    if (StringUtil.isEmpty(person)) {
      person = widget.message.creator;
    }
    if (StringUtil.isEmpty(person)) {
      return null;
    }
    return await personService.getPerson(person);
  }

  Future<List<Media>> _getMedias() async {
    IChannelMediaService channelMediaService =
        widget.context.site.getService('/channel/messages/medias');
    return await channelMediaService.getMedias(widget.message.id);
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

class _MessageOperatesPopupMenu extends StatefulWidget {
  ChannelMessage message;
  PageContext context;
  void Function() onDeleted;
  void Function() onComment;
  void Function() onliked;
  void Function() onUnliked;

  _MessageOperatesPopupMenu({
    this.message,
    this.context,
    this.onDeleted,
    this.onComment,
    this.onliked,
    this.onUnliked,
  });

  @override
  __MessageOperatesPopupMenuState createState() =>
      __MessageOperatesPopupMenuState();
}

class __MessageOperatesPopupMenuState extends State<_MessageOperatesPopupMenu> {
  Future<Map<String, bool>> _getOperatorRights() async {
    bool isLiked = await _isLiked();
    return {
      'isLiked': isLiked,
      'canComment': true,
      'canDelete': widget.message.creator == widget.context.principal.person,
    };
  }

  Future<bool> _isLiked() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    return await likeService.isLiked(
        widget.message.id, widget.context.principal.person);
  }

  Future<void> _like() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    LikePerson likePerson = LikePerson(
      '${Uuid().v1()}',
      widget.context.principal.person,
      widget.context.principal.avatarOnRemote,
      widget.message.id,
      DateTime.now().millisecondsSinceEpoch,
      widget.context.principal.nickName ?? widget.context.principal.accountCode,
      widget.message.onChannel,
      widget.context.principal.person,
    );
    await likeService.like(likePerson);
  }

  Future<void> _unlike() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    await likeService.unlike(
        widget.message.id, widget.context.principal.person);
  }

  Future<void> _deleteMessage() async {
    IChannelMessageService messageService =
        widget.context.site.getService('/channel/messages');
    messageService.removeMessage(widget.message.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getOperatorRights(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          print('${snapshot.error}');
        }
        var rights = snapshot.data;

        return Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
          ),
          child: WPopupMenu(
            child: Icon(
              IconData(
                0xe79d,
                fontFamily: 'ellipse',
              ),
              size: 22,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2,
                    ),
                    child: Icon(
                      FontAwesomeIcons.thumbsUp,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  Text(
                    rights['isLiked'] ? '取消点赞' : '点赞',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2,
                      top: 2,
                    ),
                    child: Icon(
                      Icons.comment,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  Text(
                    '评论',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              rights['canDelete']
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 2,
                            top: 1,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        Text(
                          '删除',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
            ],
            pressType: PressType.singleClick,
            onValueChanged: (index) {
              switch (index) {
                case 0: //点赞或取消
                  if (rights['isLiked']) {
                    _unlike().whenComplete(() {
                      setState(() {});
                      if (widget.onUnliked != null) {
                        widget.onUnliked();
                      }
                    });
                  } else {
                    _like().whenComplete(() {
                      setState(() {});
                      if (widget.onliked != null) {
                        widget.onliked();
                      }
                    });
                  }
                  break;
                case 1: //评论
                  if (widget.onComment != null) {
                    widget.onComment();
                  }
                  break;
                case 2: //删除
                  _deleteMessage().whenComplete(() {
                    if (widget.onDeleted != null) {
                      widget.onDeleted();
                    }
                  });
                  break;
              }
            },
          ),
        );
      },
    );
  }
}

class _InteractiveRegion extends StatefulWidget {
  ChannelMessage message;
  PageContext context;
  _InteractiveRegionRefreshAdapter interactiveRegionRefreshAdapter;

  _InteractiveRegion({
    this.message,
    this.context,
    this.interactiveRegionRefreshAdapter,
  });

  @override
  __InteractiveRegionState createState() => __InteractiveRegionState();
}

class __InteractiveRegionState extends State<_InteractiveRegion> {
  bool _isShowCommentEditor = false;

  @override
  void initState() {
    if (widget.interactiveRegionRefreshAdapter != null) {
      widget.interactiveRegionRefreshAdapter.handler = (cause) {
        print(cause);
        switch (cause) {
          case 'comment':
            _isShowCommentEditor = true;
            break;
        }
        setState(() {});
      };
    }
    super.initState();
  }

  @override
  void dispose() {
    _isShowCommentEditor = false;
    widget.interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  Future<Map<String, List<dynamic>>> _loadInteractiveRegion() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    List<LikePerson> likes =
        await likeService.pageLikePersons(widget.message.id, 10, 0);
    List<ChannelComment> comments =
        await commentService.pageComments(widget.message.id, 20, 0);
    return <String, List<dynamic>>{"likePersons": likes, "comments": comments};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List>>(
      future: _loadInteractiveRegion(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: 0,
            height: 0,
          );
        }
        if (snapshot.hasError) {
          print('${snapshot.error}');
          return Container(
            width: 0,
            height: 0,
          );
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Container(
            width: 0,
            height: 0,
          );
        }
        var comments = snapshot.data['comments'];
        var likePersons = snapshot.data['likePersons'];
        bool isHide =
            comments.isEmpty && likePersons.isEmpty && !_isShowCommentEditor;
        if (isHide) {
          return Container(
            width: 0,
            height: 0,
          );
        }
        var commentListWidgets = <Widget>[];
        for (ChannelComment comment in comments) {
          bool isMine = comment.person == widget.context.principal.person;
          commentListWidgets.add(Padding(
            padding: EdgeInsets.only(
              bottom: 5,
            ),
            child: Text.rich(
              //评论区
              TextSpan(
                text: '${comment.nickName ?? ''}:',
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    IPersonService personService =
                        widget.context.site.getService('/gbera/persons');
                    var person = await personService.getPerson(comment.person);
                    widget.context.forward("/site/personal",
                        arguments: {'person': person});
                  },
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
                children: [
                  TextSpan(
                    text: '${comment.text ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(text: '\t'),
                  isMine
                      ? TextSpan(
                          text: '删除',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await _deleteComment(comment);
                              setState(() {});
                            },
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        )
                      : TextSpan(text: ''),
                ],
              ),
              softWrap: true,
            ),
          ));
        }
        if (_isShowCommentEditor) {
          commentListWidgets.add(
            _CommentEditor(
              context: widget.context,
              onFinished: (content) async {
                await _appendComment(content);
                _isShowCommentEditor = false;
                setState(() {});
              },
              onCloseWin: () async {
                _isShowCommentEditor = false;
                setState(() {});
              },
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: Color(0xFFF5F5F5),
          ),
          padding: EdgeInsets.only(
            left: 10,
            right: 5,
            top: 5,
            bottom: 5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ///点赞区
              likePersons.isEmpty
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Icon(
                            FontAwesomeIcons.thumbsUp,
                            color: Colors.grey[500],
                            size: 12,
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: likePersons.map((like) {
                                return TextSpan(
                                  text: '${like.nickName}',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      IPersonService personService = widget
                                          .context.site
                                          .getService('/gbera/persons');
                                      var person = await personService
                                          .getPerson(like.official);
                                      widget.context.forward("/site/personal",
                                          arguments: {'person': person});
                                    },
                                  children: [
                                    TextSpan(
                                      text: ';  ',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
//                                maxLines: 4,
//                                overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
              likePersons.isEmpty || comments.isEmpty
                  ? Container(
                      width: 0,
                      height: 3,
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        bottom: 6,
                        top: 6,
                      ),
                      child: Divider(
                        height: 1,
                      ),
                    ),

              ///评论区
              ListView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: commentListWidgets,
              ),
            ],
          ),
        );
      },
    );
  }

  _appendComment(String content) async {
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    await commentService.addComment(
      ChannelComment(
        '${Uuid().v1()}',
        widget.context.principal.person,
        widget.context.principal.avatarOnRemote,
        widget.message.id,
        content,
        DateTime.now().millisecondsSinceEpoch,
        widget.context.principal.nickName ??
            widget.context.principal.accountCode,
        widget.message.onChannel,
        widget.context.principal.person,
      ),
    );
  }

  _deleteComment(ChannelComment comment) async {
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    await commentService.removeComment(comment.msgid, comment.id);
  }
}

class _InteractiveRegionRefreshAdapter {
  void Function(String cause) handler;

  void refresh(String cause) {
    if (handler != null) {
      handler(cause);
    }
  }
}
