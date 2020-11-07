import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/wpopup_menu/w_popup_menu.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/netflow/article_entities.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

///感知器范围内的历史活动
class GeosphereHistories extends StatefulWidget {
  PageContext context;

  GeosphereHistories({this.context});

  @override
  _GeosphereHistoriesState createState() => _GeosphereHistoriesState();
}

class _GeosphereHistoriesState extends State<GeosphereHistories> {
  List<ChannelMessage> messages = [];
  ReceptorInfo _receptorInfo;
  EasyRefreshController _refreshController;
  GeoCategoryOL _category;
  bool _isLoaded = false;
  int _limit = 15, _offset = 0;
  List<_GeosphereMessageWrapper> _messageList = [];
  bool _isLoadedMessages = false;
  String _selectedGeoType;

  @override
  void initState() {
    _receptorInfo = widget.context.parameters['receptor'];
    _refreshController = EasyRefreshController();
    _loadCategory().then((v) {
      _isLoaded = true;
      if(mounted) {
        setState(() {});
      }
    });
    _onloadMessages().then((v) {
      _isLoadedMessages = true;
     if(mounted) {
       setState(() {});
     }
    });
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('geosphere.receptors');
    _messageList.clear();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    IGeoCategoryLocal categoryLocal =
        widget.context.site.getService('/geosphere/categories');
    _category = await categoryLocal.get(_receptorInfo.category);
  }

  //只装载消息体，交互区域信息可能非常长，因此采用独立的滥加载模式
  Future<void> _onloadMessages() async {
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');

    List<GeoPOD> messages = await receptorRemote.searchAroundDocuments(
        category: _receptorInfo.category,
        receptor: _receptorInfo.id,
        geoType: _selectedGeoType,
        limit: _limit,
        offset: _offset);
    if (messages.isEmpty) {
      _refreshController.finishLoad(success: true, noMore: true);
      return;
    }
    _offset += messages.length;
    List<_GeosphereMessageWrapper> wrappers = [];
    for (var message in messages) {
      await _fillMessageWrapper(message, wrappers);
    }
    _messageList.addAll(wrappers);
  }

  Future<void> _fillMessageWrapper(GeoPOD pod, wrappers) async {
    IGeosphereMediaService mediaService =
        widget.context.site.getService('/geosphere/receptor/messages/medias');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var message = pod.message;
    List<GeosphereMediaOL> medias =
        await mediaService.listMedia(message.receptor, message.id);
    Person creator =
        await personService.getPerson(message.creator, isDownloadAvatar: true);
    Person upstreamPerson;
    if (!StringUtil.isEmpty(message.upstreamPerson)) {
      upstreamPerson = await personService.getPerson(message.creator,
          isDownloadAvatar: true);
    }
    List<MediaSrc> _medias = [];
    for (GeosphereMediaOL mediaOL in medias) {
      _medias.add(mediaOL.toMedia());
    }

    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var purchaseOR = await purchaserRemote.getPurchaseRecordPerson(
        message.creator, message.purchaseSn);

    wrappers.add(
      _GeosphereMessageWrapper(
        creator: creator,
        medias: _medias,
        message: message,
        upstreamPerson: upstreamPerson,
        distance: pod.distance,
        purchaseOR: purchaseOR,
      ),
    );
  }

  _deleteMessage(_GeosphereMessageWrapper wrapper) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.removeMessage(
        _receptorInfo.category, wrapper.message.receptor, wrapper.message.id);
    _messageList.removeWhere((e) {
      return e.message.id == wrapper.message.id;
    });
    setState(() {});
  }

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
            expandedHeight:
                _receptorInfo.backgroundMode != BackgroundMode.horizontal
                    ? 0
                    : 200,
            background:
                _receptorInfo.backgroundMode != BackgroundMode.horizontal
                    ? null
                    : !StringUtil.isEmpty(_receptorInfo.background)
                        ? FileImage(
                            File(_receptorInfo.background),
                          )
                        : NetworkImage(
                            'http://47.105.165.186:7100/public/geosphere/wallpapers/e27df176176b9a03bfe72ee5b05f87e4.jpg?accessToken=${widget.context.principal.accessToken}',
                          ),
            onRenderAppBar: (appBar, RenderStateAppBar state) {
              switch (state) {
                case RenderStateAppBar.origin:
                  if (_receptorInfo.backgroundMode != BackgroundMode.none) {
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
            isShowWhite: _receptorInfo.foregroundMode == ForegroundMode.white,
            categoryOL: _category,
            filterMessages: (category) async {
              _offset = 0;
              _messageList.clear();
              if (category != null) {
                _selectedGeoType = category['category'];
              } else {
                _selectedGeoType = null;
              }
              await _onloadMessages();
              setState(() {});
            },
            refresh: () async {
              _offset = 0;
              _messageList.clear();
              await _onloadMessages();
              setState(() {});
            },
          ),
        ),
      );
    }
    slivers.addAll(
      _getMessageCards(),
    );
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: _receptorInfo.backgroundMode != BackgroundMode.vertical
            ? null
            : BoxDecoration(
                image: DecorationImage(
                  image: !StringUtil.isEmpty(_receptorInfo.background)
                      ? FileImage(File(_receptorInfo.background))
                      : NetworkImage(
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
    appBar.title = Text(
      _receptorInfo.title,
      style: TextStyle(
        color: Colors.white,
      ),
    );

    appBar.iconTheme = IconThemeData(
      color: Colors.white,
    );
    appBar.actions = _getActions(Colors.white);
  }

  void _showBlackAppBar(
    GberaPersistentHeaderDelegate appBar, {
    bool showTitle = true,
  }) {
    appBar.title = Text(
      _receptorInfo.title,
      style: TextStyle(
        color: null,
      ),
    );
    appBar.iconTheme = IconThemeData(
      color: null,
    );
    appBar.actions = _getActions(null);
  }

  List<Widget> _getMessageCards() {
    List<Widget> list = [];
    if (_messageList.isEmpty) {
      if (!_isLoadedMessages) {
        list.add(
          SliverToBoxAdapter(
            child: Center(
              child: Text('加载中...'),
            ),
          ),
        );
      } else {
        list.add(
          SliverFillRemaining(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  '没有消息',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return list;
    }
    for (var msg in _messageList) {
      list.add(
        SliverToBoxAdapter(
          child: rendTimelineListRow(
            paddingLeft: 12,
            paddingContentLeft: 42,
            content: _MessageCard(
              context: widget.context,
              receptor: _receptorInfo,
              messageWrapper: msg,
              onDeleted: _deleteMessage,
            ),
            title: Container(
              child: Wrap(
                direction: Axis.vertical,
                spacing: 2,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 0,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: '距中心${getFriendlyDistance(msg.distance)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _receptorInfo.backgroundMode ==
                                  BackgroundMode.vertical
                              ? Colors.white
                              : Colors.grey,
                        ),
                        children: [
                          TextSpan(text: '  '),
                          TextSpan(
                              text: '${TimelineUtil.format(
                            msg.message.ctime,
                            locale: 'zh',
                            dayFormat: DayFormat.Full,
                          )}'),
                          TextSpan(text: '  '),
                          TextSpan(
                            text:
                                '¥${((msg.purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                IWyBankPurchaserRemote purchaserRemote = widget
                                    .context.site
                                    .getService('/remote/purchaser');
                                WenyBank bank = await purchaserRemote
                                    .getWenyBank(msg.purchaseOR.bankid);
                                widget.context.forward(
                                  '/wybank/purchase/details',
                                  arguments: {
                                    'purch': msg.purchaseOR,
                                    'bank': bank
                                  },
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '',
                            style: TextStyle(
                              fontSize: 12,
                              color: _receptorInfo.backgroundMode ==
                                      BackgroundMode.vertical
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            children: msg.distanceLabel == null
                                ? []
                                : [
                                    TextSpan(text: ' '),
                                    TextSpan(
                                      text: '距${msg.distanceLabel}',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            lineColor: _receptorInfo.backgroundMode == BackgroundMode.vertical
                ? Colors.white
                : Colors.grey,
          ),
        ),
      );
    }
    return list;
  }

  List<Widget> _getActions(Color color) {
    return <Widget>[
      PopupMenuButton<String>(
        offset: Offset(
          0,
          50,
        ),
        icon: Icon(
          Icons.more_vert,
          color: color,
        ),
        onSelected: (value) async {
          if (value == null) return;
          var arguments = <String, Object>{};
          switch (value) {
            case '/geosphere/portal/aboat':
              break;
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: '/geosphere/portal/aboat',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    Icons.account_box,
                    color: Colors.grey[500],
                    size: 15,
                  ),
                ),
                Text(
                  '关于',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
//          PopupMenuDivider(),
        ],
      ),
    ];
  }
}

class _HeaderWidget extends StatefulWidget {
  PageContext context;
  Function() refresh;
  ReceptorInfo receptorInfo;
  Function(Map category) filterMessages;
  bool isShowWhite;
  GeoCategoryOL categoryOL;

  _HeaderWidget({
    this.context,
    this.refresh,
    this.receptorInfo,
    this.filterMessages,
    this.isShowWhite,
    this.categoryOL,
  });

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<_HeaderWidget> {
  var _workingChannel;
  String _poiTitle;
  LatLng _currentLatLng;
  List<GeoCategoryAppOR> _apps = [];
  Map<String, String> _selectCategory;

  @override
  void initState() {
    _loadLocation().then((v) {
      setState(() {});
    });
    geoLocation.listen('receptor.header',
        (widget.receptorInfo.uDistance ?? 10) * 1.0, _updateLocation);
//    _workingChannel = widget.context.parameters['workingChannel'];
//    _workingChannel.onRefreshChannelState = (command, args) {
//      _arrivedMessageCount++;
//      setState(() {});
//    };
    _loadCategoryAllApps().then((v) {
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
    super.dispose();
  }

  @override
  void didUpdateWidget(_HeaderWidget oldWidget) {
    if (oldWidget.categoryOL != widget.categoryOL) {
      oldWidget.categoryOL = widget.categoryOL;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadCategoryAllApps() async {
    if (widget.categoryOL == null) {
      return;
    }
    IGeoCategoryRemote categoryRemote =
        widget.context.site.getService('/remote/geo/categories');
    var on =
        widget.categoryOL.moveMode == 'moveableSelf' ? 'onserved' : 'onservice';
    _apps = await categoryRemote.getApps(widget.categoryOL.id, on);
  }

  Future<void> _loadAppsOfCategory(categroyMap) async {
    _selectCategory = categroyMap.cast<String, String>();
    IGeoCategoryRemote categoryRemote =
        widget.context.site.getService('/remote/geo/categories');
    var on = 'onserved';
    _apps = await categoryRemote.getApps(categroyMap['category'], on);
    await _filterMessages(categroyMap);
  }

  Future<void> _clearSelectCategory() async {
    _selectCategory = null;
    await _loadCategoryAllApps();
    _filterMessages(null);
  }

  Future<void> _filterMessages(categroyMap) async {
    await widget.filterMessages(categroyMap);
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
        size: 50,
        color: Colors.grey[500],
      );
    } else if (widget.receptorInfo.leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(widget.receptorInfo.leading),
        width: 50,
        height: 50,
      );
    } else {
      imgSrc = Image.network(
        widget.receptorInfo.leading,
        width: 50,
        height: 50,
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
                            Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '${widget.categoryOL?.title ?? ''}',
                                    style: TextStyle(
                                      fontSize: 14,
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 1,
                    left: 5,
                  ),
                  child: Text(
                    '本地',
                    style: TextStyle(
                      color: widget.receptorInfo.backgroundMode ==
                              BackgroundMode.vertical
                          ? Colors.white
                          : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return widget.context.part(
                              '/geosphere/filter', context,
                              arguments: {'category': widget.categoryOL});
                        }).then((v) {
                      if (v == null) {
                        return;
                      }
                      if (v is String && v == 'clear') {
                        _clearSelectCategory().then((v) {
                          setState(() {});
                        });
                        return;
                      }
                      var map = v as Map;
                      if (widget.categoryOL.moveMode == 'moveableSelf') {
                        _loadAppsOfCategory(map).then((v) {
                          setState(() {});
                        });
                      } else {
                        _filterMessages(map).then((v) {
                          setState(() {});
                        });
                      }
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 2,
                        ),
                        child: Text(
                          '筛选',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.isShowWhite
                                ? Colors.white70
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      widget.categoryOL?.moveMode == 'moveableSelf'
                          ? Icon(
                              Icons.apps,
                              size: 18,
                              color: widget.isShowWhite
                                  ? Colors.white70
                                  : Colors.black54,
                            )
                          : Icon(
                              FontAwesomeIcons.filter,
                              size: 13,
                              color: widget.isShowWhite
                                  ? Colors.white70
                                  : Colors.grey[500],
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
                width: 35,
                height: 35,
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
  _GeosphereMessageWrapper messageWrapper;
  void Function(_GeosphereMessageWrapper message) onDeleted;
  ReceptorInfo receptor;

  _MessageCard({
    this.context,
    this.messageWrapper,
    this.onDeleted,
    this.receptor,
  });

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  int maxLines = 4;
  _InteractiveRegionRefreshAdapter _interactiveRegionRefreshAdapter;
  GeoReceptor _receptor;
  String _titleLabel;
  String _leading;
  bool _isMine = false;

  @override
  void initState() {
    _interactiveRegionRefreshAdapter = _InteractiveRegionRefreshAdapter();
    _loadUpstreamReceptor().then((v) {
      //检查该状态类是否已释放，如果挂在树上则可用
      _setTitleLabel();
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(_MessageCard oldWidget) {
    if (oldWidget.messageWrapper != widget.messageWrapper) {
      oldWidget.receptor = widget.receptor;
      oldWidget.messageWrapper = widget.messageWrapper;
      _loadUpstreamReceptor().then((v) {
        //检查该状态类是否已释放，如果挂在树上则可用
        _setTitleLabel();
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  _setTitleLabel() {
    if (_receptor != null) {
      _titleLabel = _receptor.title;
      _leading = _receptor.leading;
    } else {
      _titleLabel = widget.receptor.title;
      _leading = widget.receptor.leading;
    }
    _isMine = widget.context.principal?.person ==
        widget.messageWrapper.creator.official;
  }

  _loadUpstreamReceptor() async {
    var msg = widget.messageWrapper.message;
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    _receptor = await receptorService.get(msg.category, msg.receptor);
    if (_receptor == null) {
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      _receptor = await receptorRemote.getReceptor(msg.category, msg.receptor);
    }
//    _upstreamPerson = widget.messageWrapper.creator;
  }

  @override
  Widget build(BuildContext context) {
    AmapPoi poi = widget.messageWrapper.poi;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: 15,
        left: 0,
        right: 5,
      ),
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
                if (!_isMine) {
                  widget.context.forward(
                    '/geosphere/view/receptor',
                    arguments: {
                      'receptor': ReceptorInfo.create(_receptor),
                    },
                  );
                  return;
                }
                widget.context.forward(
                  '/geosphere/portal.owner',
                  arguments: {
                    'receptor': widget.receptor,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: 5, right: 5),
                child: ClipOval(
                  child: _getleadingImg(),
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
                          if (!_isMine) {
                            widget.context.forward(
                              '/geosphere/view/receptor',
                              arguments: {
                                'receptor': ReceptorInfo.create(_receptor),
                              },
                            );
                            return;
                          }
                          widget.context.forward(
                            '/geosphere/portal.owner',
                            arguments: {
                              'receptor': widget.receptor,
                            },
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          '${_titleLabel ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      widget.messageWrapper.message.category == 'mobiles' ||
                              _isMine
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : SizedBox(
                              height: 20,
                              width: 20,
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return widget.context.part(
                                            '/netflow/channel/serviceMenu',
                                            context);
                                      }).then((value) {
                                    print('-----$value');
                                    if (value == null) return;
                                    widget.context.forward('/micro/app',
                                        arguments: value);
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
                        text: '${widget.messageWrapper.message.text}',
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
                  MediaWidget(
                    widget.messageWrapper.medias,
                    widget.context,
                  ),
                  Row(
                    //内容坠
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _MessageOperatesPopupMenu(
                        messageWrapper: widget.messageWrapper,
                        context: widget.context,
                        onDeleted: () {
                          if (widget.onDeleted != null) {
                            widget.onDeleted(widget.messageWrapper);
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
                    messageWrapper: widget.messageWrapper,
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

  _getleadingImg() {
    var leadingImg;
    if (StringUtil.isEmpty(_leading)) {
      leadingImg = Image(
        image: AssetImage(
          'lib/portals/gbera/images/netflow.png',
        ),
        height: 35,
        width: 35,
        fit: BoxFit.fill,
      );
    } else {
      if (_leading.startsWith("/")) {
        leadingImg = Image(
          image: FileImage(
            File(
              _leading,
            ),
          ),
          height: 35,
          width: 35,
          fit: BoxFit.fill,
        );
      } else {
        leadingImg = Image(
          image: NetworkImage(
            '${_leading}?accessToken=${widget.context.principal.accessToken}',
          ),
          height: 35,
          width: 35,
          fit: BoxFit.fill,
        );
      }
    }
    return leadingImg;
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
  _GeosphereMessageWrapper messageWrapper;
  PageContext context;
  void Function() onDeleted;
  void Function() onComment;
  void Function() onliked;
  void Function() onUnliked;

  _MessageOperatesPopupMenu({
    this.messageWrapper,
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
      'canDelete': widget.messageWrapper.creator.official ==
          widget.context.principal.person,
    };
  }

  Future<bool> _isLiked() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    return await geoMessageService.isLiked(
        widget.messageWrapper.message.receptor,
        widget.messageWrapper.message.id,
        widget.context.principal.person);
  }

  Future<void> _like() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    GeosphereLikePersonOL likePerson = GeosphereLikePersonOL(
      '${Uuid().v1()}',
      widget.context.principal.person,
      widget.context.principal.avatarOnRemote,
      widget.messageWrapper.message.id,
      DateTime.now().millisecondsSinceEpoch,
      widget.context.principal.nickName ?? widget.context.principal.accountCode,
      widget.messageWrapper.message.receptor,
      widget.context.principal.person,
    );
    await geoMessageService.like(likePerson);
  }

  Future<void> _unlike() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.unlike(widget.messageWrapper.message.receptor,
        widget.messageWrapper.message.id, widget.context.principal.person);
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
                  if (widget.onDeleted != null) {
                    widget.onDeleted();
                  }
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
  _GeosphereMessageWrapper messageWrapper;
  PageContext context;
  _InteractiveRegionRefreshAdapter interactiveRegionRefreshAdapter;

  _InteractiveRegion({
    this.messageWrapper,
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
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    List<GeosphereLikePersonOL> likes = await geoMessageService.pageLikePersons(
        widget.messageWrapper.message.receptor,
        widget.messageWrapper.message.id,
        10,
        0);
    List<GeosphereCommentOL> comments = await geoMessageService.pageComments(
        widget.messageWrapper.message.receptor,
        widget.messageWrapper.message.id,
        20,
        0);
    return <String, List<dynamic>>{"likePersons": likes, "comments": comments};
  }

  _appendComment(String content) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.addComment(
      GeosphereCommentOL(
        '${Uuid().v1()}',
        widget.context.principal.person,
        widget.context.principal.avatarOnRemote,
        widget.messageWrapper.message.id,
        content,
        DateTime.now().millisecondsSinceEpoch,
        widget.context.principal.nickName ??
            widget.context.principal.accountCode,
        widget.messageWrapper.message.receptor,
        widget.context.principal.person,
      ),
    );
  }

  _deleteComment(GeosphereCommentOL comment) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.removeComment(
        widget.messageWrapper.message.receptor, comment.msgid, comment.id);
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
        for (GeosphereCommentOL comment in comments) {
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
                  TextSpan(
                    text: '\t${comment.ctime != null ? TimelineUtil.format(
                        comment.ctime,
                        locale: 'zh',
                        dayFormat: DayFormat.Simple,
                      ) : ''}\t',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
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
}

class _InteractiveRegionRefreshAdapter {
  void Function(String cause) handler;

  void refresh(String cause) {
    if (handler != null) {
      handler(cause);
    }
  }
}

class _GeosphereMessageWrapper {
  GeosphereMessageOR message;
  List<MediaSrc> medias;
  Person creator;
  Person upstreamPerson;
  String _distanceLabel;
  AmapPoi poi;
  double distance;
  PurchaseOR purchaseOR;

  _GeosphereMessageWrapper({
    this.message,
    this.medias,
    this.creator,
    this.upstreamPerson,
    this.poi,
    this.distance,
    this.purchaseOR,
  });

  Person get sender {
    return upstreamPerson == null ? creator : upstreamPerson;
  }

  set distanceLabel(String distanceLabel) {
    _distanceLabel = distanceLabel;
  }

  String get distanceLabel {
    return _distanceLabel;
  }
}
