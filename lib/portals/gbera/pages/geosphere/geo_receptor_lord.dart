import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:common_utils/common_utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:fluwx/fluwx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/receptor_handler.dart';
import 'package:netos_app/portals/gbera/pages/netflow/article_entities.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/pages/system/tip_off_item.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/system/system.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

class GeoReceptorLordWidget extends StatefulWidget {
  PageContext context;

  GeoReceptorLordWidget({this.context});

  @override
  _GeoReceptorLordWidgetState createState() => _GeoReceptorLordWidgetState();
}

class _GeoReceptorLordWidgetState extends State<GeoReceptorLordWidget> {
  List<ChannelMessage> messages = [];
  ReceptorInfo _receptorInfo;
  EasyRefreshController _refreshController;
  GeoCategoryOL _category;
  bool _isLoaded = false;
  int _limit = 15, _offset = 0;
  List<_GeosphereMessageWrapper> _messageList = [];
  bool _isLoadedMessages = false;
  AmapPoi _currentPoi;
  String _filterCategory;
  StreamController _streamController;
  bool _isUpdateLocation = false;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _receptorInfo = widget.context.parameters['receptor'];
    _receptorInfo.onSettingsChanged = _onSettingChanged;
    geoLocation.listen('geosphere.receptors.lord', 0, _updateLocation);
    _refreshController = EasyRefreshController();
    _loadCategory().then((v) {
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    });
    _onloadMessages().then((v) {
      _isLoadedMessages = true;
      if (mounted) {
        setState(() {});
      }
    });
    _flagMessagesReaded();
    super.initState();
  }

  @override
  void dispose() {
    _streamController?.close();
    geoLocation.unlisten('geosphere.receptors.lord');
    _messageList.clear();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _flagMessagesReaded() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.flagMessagesReaded(_receptorInfo.id);
  }

  Future<void> _onSettingChanged(OnReceptorSettingsChangedEvent e) async {
    print(e.action);
    switch (e.action) {
      case 'setNoneBackground':
        _receptorInfo.origin.backgroundMode = 'none';
        _receptorInfo.origin.background = null;
        break;
      case 'setHorizontalBackground':
        _receptorInfo.origin.backgroundMode = 'horizontal';
        _receptorInfo.origin.background = e.args['file'];
        break;
      case 'setVerticalBackground':
        _receptorInfo.origin.backgroundMode = 'vertical';
        _receptorInfo.origin.background = e.args['file'];
        break;
      case 'setWhiteForeground':
        _receptorInfo.origin.foregroundMode = 'white';
        break;
      case 'setOriginalForeground':
        _receptorInfo.origin.foregroundMode = 'original';
        break;
      case 'scrollMessageMode':
        _receptorInfo.origin.isAutoScrollMessage =
            e.args['isAutoScrollMessage'] ? 'true' : 'false';
        break;
    }
  }

  Future<void> _updateLocation(Location location) async {
    var city = await location.city;
    if (StringUtil.isEmpty(city)) {
      return;
    }
    //计算文档离我的距离

    LatLng latLng = await location.latLng;
    if (latLng == null) {
      return;
    }

//    var radius = _receptorInfo.radius?.floor() ?? 5;
//    var poiList =
//        await AmapSearch.searchAround(latLng, radius: radius, type: amapPOIType);
//    if (poiList.isEmpty) {
//      return;
//    }
//    var amapPoi = poiList[0];
    var title = await location.poiName;
    var address = await location.address;
    var poiId = await location.adCode;
    if (StringUtil.isEmpty(address)) {
      return;
    }

    var distance = getDistance(start: latLng, end: _receptorInfo.latLng);
    if (distance == double.nan) {
      distance = 0;
    }
    _currentPoi = AmapPoi(
      distance: distance?.floor(),
      title: title,
      latLng: latLng,
      address: address,
      poiId: poiId,
    );
    if (distance < _receptorInfo.uDistance) {
      _streamController.add(_currentPoi);
      if (_isUpdateLocation) {
        return;
      }
      _isUpdateLocation = true;
    } else {
      _receptorInfo.latLng = latLng;
    }

    for (var msgwrapper in _messageList) {
      String loc = msgwrapper.message.location;
      if (StringUtil.isEmpty(loc)) {
        continue;
      }
      var msglatLng = LatLng.fromJson(jsonDecode(loc));
      var distanceLabel = getFriendlyDistance(
          getDistance(start: _currentPoi.latLng, end: msglatLng));
      msgwrapper.distanceLabel = distanceLabel;
      msgwrapper.poi = _currentPoi;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCategory() async {
    IGeoCategoryLocal categoryLocal =
        widget.context.site.getService('/geosphere/categories');
    _category = await categoryLocal.get(_receptorInfo.category);
  }

  //只装载消息体，交互区域信息可能非常长，因此采用独立的滥加载模式
  Future<void> _onloadMessages() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');

    List<GeosphereMessageOL> messages;
    if (StringUtil.isEmpty(_filterCategory)) {
      messages = await geoMessageService.pageMessage(
          _receptorInfo.id, _limit, _offset);
    } else {
      messages = await geoMessageService.pageFilterMessage(
          _receptorInfo.id, _filterCategory, _limit, _offset);
    }

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

  Future<void> _fillMessageWrapper(GeosphereMessageOL message, wrappers) async {
    IGeosphereMediaService mediaService =
        widget.context.site.getService('/geosphere/receptor/messages/medias');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    String receptor;
    if (StringUtil.isEmpty(message.upstreamReceptor)) {
      receptor = message.receptor;
    } else {
      receptor = message.upstreamReceptor;
    }
    List<GeosphereMediaOL> medias =
        await mediaService.listMedia(receptor, message.id);
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
        purchaseOR: purchaseOR,
      ),
    );
  }

  Future<void> _loadMessageAndPutTop(msgid) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    GeosphereMessageOL messageOL =
        await geoMessageService.getMessage(_receptorInfo.id, msgid);
    List<_GeosphereMessageWrapper> wrappers = [];
    await _fillMessageWrapper(messageOL, wrappers);
    _messageList.insertAll(0, wrappers);
  }

  _deleteMessage(_GeosphereMessageWrapper wrapper) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.removeMessage(
        wrapper.message.receptor, wrapper.message.id);
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
                  : 220,
          background: _receptorInfo.backgroundMode != BackgroundMode.horizontal
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
          },
        ),
      ),
    ];
    if (_isLoaded) {
      slivers.add(
        SliverToBoxAdapter(
          child: _HeaderWidget(
            context: widget.context,
            streamController: _streamController,
            receptorInfo: _receptorInfo,
            isShowWhite: _receptorInfo.foregroundMode == ForegroundMode.white,
            categoryOL: _category,
            filterMessages: (filter) async {
              _offset = 0;
              _messageList.clear();
              if (filter != null) {
                var category = filter[1];
                _filterCategory = category?.id;
              } else {
                _filterCategory = null;
              }
              await _onloadMessages();
              await _flagMessagesReaded();
              setState(() {});
            },
            refresh: () async {
              _offset = 0;
              _messageList.clear();
              await _onloadMessages();
              await _flagMessagesReaded();
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
          header: easyRefreshHeader(),
          footer: easyRefreshFooter(),
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
      appBar.title = Text(
        _receptorInfo.title,
        style: TextStyle(
          color: Colors.white,
        ),
      );
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
      appBar.title = Text(
        _receptorInfo.title,
        style: TextStyle(
          color: null,
        ),
      );
    }
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
          child: _MessageCard(
            context: widget.context,
            receptor: _receptorInfo,
            messageWrapper: msg,
            onDeleted: _deleteMessage,
          ),
        ),
      );
    }
    return list;
  }

  List<Widget> _getActions(Color color) {
    return <Widget>[
      useSimpleLayout()
          ? SizedBox.shrink()
          : _AbsorberAction(
              color: color,
              context: widget.context,
              receptorInfo: _receptorInfo,
            ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () {
          if (useSimpleLayout()) {
            widget.context.forward('/geosphere/publish_article/ios',
                arguments: <String, dynamic>{
                  'type': 'text',
                  'category': _category.id,
                  'receptor': _receptorInfo.id,
                }).then((v) {
              if (v == null) {
                return;
              }
              _loadMessageAndPutTop(v).then((s) {
                setState(() {});
              });
            });
            return;
          }
          widget.context.forward('/geosphere/publish_article',
              arguments: <String, dynamic>{
                'type': 'text',
                'category': _category.id,
                'receptor': _receptorInfo.id,
              }).then((v) {
            if (v == null) {
              return;
            }
            _loadMessageAndPutTop(v).then((s) {
              setState(() {});
            });
          });
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
                      widget.context.backward(result: <String, dynamic>{
                        'type': 'text',
                        'category': _category.id,
                        'receptor': _receptorInfo.id,
                      });
                    },
                  ),
                  DialogItem(
                    text: '从相册选择',
                    icon: Icons.image,
                    color: Colors.grey[500],
                    onPressed: () async {
                      var image = await ImagePicker().getImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxHeight: Adapt.screenH(),
                      );
                      if (image == null) {
                        return;
                      }
                      widget.context.backward(result: <String, dynamic>{
                        'type': 'gallery',
                        'category': _category.id,
                        'receptor': _receptorInfo.id,
                        'mediaFile': MediaFile(
                            type: MediaFileType.image, src: File(image.path)),
                      });
                    },
                  ),
                ],
              ),
            ).then<void>((value) {
              if (value == null) {
                return;
              }
              widget.context
                  .forward('/geosphere/publish_article', arguments: value)
                  .then((v) {
                if (v == null) {
                  return;
                }
                _loadMessageAndPutTop(v).then((s) {
                  setState(() {});
                });
              });
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
  Function(List filter) filterMessages;
  GeoCategoryOL categoryOL;
  StreamController streamController;

  _HeaderWidget({
    this.context,
    this.refresh,
    this.streamController,
    this.filterMessages,
    this.receptorInfo,
    this.isShowWhite,
    this.categoryOL,
  });

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<_HeaderWidget> {
  int _arrivedMessageCount = 0;
  var _workingChannel;
  List<GeoCategoryAppOR> _apps = [];
  Map<String, String> _selectCategory;
  StreamSubscription _streamSubscription;
  StreamSubscription _refreshSubscreption;
  AmapPoi _currentPoi;
  List _filter; //0为channel;1为category;2为brand
  @override
  void initState() {
    _refreshSubscreption = widget.streamController.stream.listen((e) {
      _currentPoi = e;
      if (mounted) {
        setState(() {});
      }
    });
    _loadCategoryAllApps().then((v) {
      setState(() {});
    });
    Stream _notify = receptorNotifyStreamController.stream;
    _streamSubscription = _notify.listen((cmd) async {
      GeosphereMessageOL message = cmd['message'];
      if (cmd['receptor'] != widget.receptorInfo.id) {
        return;
      }
      var sender = cmd['sender'];
      switch (cmd['command']) {
        case 'mediaDocumentCommand':
        case 'likeDocumentCommand':
        case 'unlikeDocumentCommand':
        case 'commentDocumentCommand':
        case 'uncommentDocumentCommand':
          if (widget.receptorInfo.isAutoScrollMessage) {
            if (widget.refresh != null) {
              await widget.refresh();
              _arrivedMessageCount = 0;
              setState(() {});
            }
          } else {
            _arrivedMessageCount += 1;
            setState(() {});
          }
          break;
        case 'pushDocumentCommand':
          if (widget.receptorInfo.isAutoScrollMessage) {
            if (widget.refresh != null) {
              await widget.refresh();
              _arrivedMessageCount = 0;
              setState(() {});
            }
          } else {
            _loadUnreadMessage().then((v) {
              setState(() {});
            });
          }
          break;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _refreshSubscreption?.cancel();
    _streamSubscription.cancel();
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

  Future<void> _loadUnreadMessage() async {
    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    _arrivedMessageCount =
        await messageService.countUnreadMessage(widget.receptorInfo.id);
  }

  Future<void> _loadCategoryAllApps() async {
    if (widget.categoryOL == null ||
        widget.receptorInfo.creator != widget.context.principal.person) {
      return;
    }
    IGeoCategoryRemote categoryRemote =
        widget.context.site.getService('/remote/geo/categories');
    var on;
    if (widget.categoryOL.moveMode == 'moveableSelf') {
      on = 'onserved';
    } else {
      on = 'onservice';
    }
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

  Future<void> _filterMessages(filter) async {
    await widget.filterMessages(filter);
  }

  String _getPositionLabel() {
    if (_currentPoi == null || _currentPoi.distance == null) {
      return '';
    }
    double distance = _currentPoi.distance * 1.0;
    double udistance = widget.receptorInfo.uDistance * 1.0;
    return '离开${getFriendlyDistance(distance)} ${getFriendlyDistance(udistance - distance)}后更新';
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
        '${widget.receptorInfo.leading}?accessToken=${widget.context.principal.accessToken}',
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
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return widget.context.part(
                                '/geosphere/settings.lord', context,
                                arguments: {
                                  'receptor': widget.receptorInfo,
                                  'moveMode': widget.categoryOL?.moveMode
                                });
                          }).then((v) {});
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
//                            Text.rich(
//                              TextSpan(
//                                text: '${widget.receptorInfo.title}',
//                                children: [],
//                              ),
//                              softWrap: true,
//                              textAlign: TextAlign.left,
//                              style: TextStyle(
//                                fontSize: 25,
//                                fontWeight: FontWeight.w500,
//                                color: widget.isShowWhite
//                                    ? Colors.white
//                                    : Colors.black,
//                              ),
//                            ),
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
                                    text: '${_currentPoi?.title ?? ''}',
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
                                    text: _getPositionLabel(),
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
//          _apps.isEmpty
//              ? Container(
//                  width: 0,
//                  height: 0,
//                )
//              : Container(
//                  height: 60,
//                  alignment: Alignment.center,
//                  child: ListView(
//                    shrinkWrap: true,
//                    scrollDirection: Axis.horizontal,
//                    padding: EdgeInsets.all(0),
//                    children: _geoCategoryApps(),
//                  ),
//                ),
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
                        onTap: () async {
                          if (widget.refresh != null) {
                            await widget.refresh();
                            _arrivedMessageCount = 0;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
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
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return widget.context.part(
                          '/geosphere/filter',
                          context,
                        );
                      },
                    ).then((v) {
                      if (v == null) {
                        return;
                      }
                      if (v is String && v == 'clear') {
                        _clearSelectCategory().then((v) {
                          setState(() {});
                        });
                        return;
                      }
                      var filter = v as List;
                      _filter = filter;
                      // if (widget.receptorInfo.isMobileReceptor) {
                      //   _loadAppsOfCategory(filter).then((v) {
                      //     setState(() {});
                      //   });
                      // } else {
                      _filterMessages(filter).then((v) {
                        setState(() {});
                      });
                      // }
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 2,
                        ),
                        child: Text(
                          '${_getCategoryTitile()}',
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

  _getCategoryTitile() {
    if (_filter == null) {
      return widget.receptorInfo.isMobileReceptor ? '服务' : '筛选';
    }
    if (_filter[2] != null) {
      return _filter[2].title;
    }
    return _filter[1].title;
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
  ReceptorInfo receptor;
  void Function(_GeosphereMessageWrapper message) onDeleted;

  _MessageCard({
    this.context,
    this.receptor,
    this.messageWrapper,
    this.onDeleted,
  });

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  int maxLines = 4;
  _InteractiveRegionRefreshAdapter _interactiveRegionRefreshAdapter;
  GeoReceptor _upstreamReceptor;
  Person _upstreamPerson;
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
    if (_upstreamReceptor != null) {
      if (_upstreamReceptor.id != widget.receptor.id) {
        _titleLabel = _upstreamReceptor.title;
        _leading = _upstreamReceptor.leading;
      } else {
        _titleLabel = widget.messageWrapper.creator.nickName;
        _leading = widget.messageWrapper.creator.avatar;
      }
    } else {
      _titleLabel = widget.receptor.title;
      _leading = widget.receptor.leading;
    }
    _isMine = widget.context.principal?.person ==
        widget.messageWrapper.creator.official;
  }

  _loadUpstreamReceptor() async {
    var upstreamReceptor = widget.messageWrapper.message.upstreamReceptor;
    var upstreamCategory = widget.messageWrapper.message.upstreamCategory;
    var upstreamPerson = widget.messageWrapper.message.upstreamPerson;
    if (StringUtil.isEmpty(upstreamReceptor)) {
      _upstreamReceptor = null;
      _upstreamPerson = null;
      return;
    }
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    _upstreamReceptor = await receptorService.get(upstreamReceptor);
    if (_upstreamReceptor == null) {
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      _upstreamReceptor = await receptorRemote.getReceptor(upstreamReceptor);
    }
    if (!StringUtil.isEmpty(upstreamPerson)) {
      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
//      _upstreamPerson = await personService.getPerson(
//        upstreamPerson,
//        isDownloadAvatar: true,
//      );
      _upstreamPerson = widget.messageWrapper.upstreamPerson;
    }
  }

  @override
  Widget build(BuildContext context) {
    AmapPoi poi = widget.messageWrapper.poi;

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 10,
      ),
      margin: EdgeInsets.only(
        bottom: 15,
//        left: 15,
//        right: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
//        borderRadius: BorderRadius.all(
//          Radius.circular(5),
//        ),
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
                    'receptor': ReceptorInfo.create(_upstreamReceptor),
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
                              'receptor':
                                  ReceptorInfo.create(_upstreamReceptor),
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
                    // widget.messageWrapper.message.upstreamCategory ==
                    //             'mobiles' ||
                    //         _isMine
                    //     ? Container(
                    //         width: 0,
                    //         height: 0,
                    //       )
                    //     : SizedBox(
                    //         height: 20,
                    //         width: 20,
                    //         child: IconButton(
                    //           padding: EdgeInsets.all(0),
                    //           onPressed: () {
                    //             showModalBottomSheet(
                    //                 context: context,
                    //                 builder: (context) {
                    //                   return widget.context.part(
                    //                       '/netflow/channel/serviceMenu',
                    //                       context);
                    //                 }).then((value) {
                    //               print('-----$value');
                    //               if (value == null) return;
                    //               widget.context
                    //                   .forward('/micro/app', arguments: value);
                    //             });
                    //           },
                    //           icon: Icon(
                    //             Icons.art_track,
                    //             size: 20,
                    //             color: Colors.grey[700],
                    //           ),
                    //         ),
                    //       ),
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
//                DefaultTabController(
//                  length: widget.messageWrapper.medias.length,
//                  child: PageSelector(
//                    medias: widget.messageWrapper.medias,
//                    context: widget.context,
//                    onMediaLongTap: (media) {
//                      widget.context.forward(
//                        '/images/viewer',
//                        arguments: {
//                          'media': media,
//                          'others': widget.messageWrapper.medias,
//                          'autoPlay': true,
//                        },
//                      );
//                    },
//                  ),
//                ),
                Container(
                  height: 7,
                ),
                Row(
                  //内容坠
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
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
                                text: '${TimelineUtil.format(
                                  widget.messageWrapper.message.ctime,
                                  locale: 'zh',
                                  dayFormat: DayFormat.Simple,
                                )}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                children: [
                                  TextSpan(text: '  '),
                                  (useSimpleLayout() ||
                                          widget.messageWrapper.purchaseOR
                                                  ?.principalAmount ==
                                              null)
                                      ? TextSpan(text: '')
                                      : TextSpan(
                                          text:
                                              '¥${((widget.messageWrapper.purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              if (widget.messageWrapper
                                                      .purchaseOR ==
                                                  null) {
                                                return;
                                              }
                                              IWyBankPurchaserRemote
                                                  purchaserRemote = widget
                                                      .context.site
                                                      .getService(
                                                          '/remote/purchaser');
                                              WenyBank bank =
                                                  await purchaserRemote
                                                      .getWenyBank(widget
                                                          .messageWrapper
                                                          .purchaseOR
                                                          .bankid);
                                              widget.context.forward(
                                                '/wybank/purchase/details',
                                                arguments: {
                                                  'purch': widget.messageWrapper
                                                      .purchaseOR,
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
//                                  Padding(
//                                    padding: EdgeInsets.only(
//                                      right: 2,
//                                    ),
//                                    child: Icon(
//                                      Icons.location_on,
//                                      size: 12,
//                                      color: Colors.grey[400],
//                                    ),
//                                  ),
                                Text.rich(
                                  TextSpan(
                                    text:
                                        '${poi == null ? '' : '${poi.title}附近'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                    children:
                                        widget.messageWrapper.distanceLabel ==
                                                null
                                            ? []
                                            : [
                                                TextSpan(text: ' '),
                                                TextSpan(
                                                  text:
                                                      '距${widget.messageWrapper.distanceLabel}',
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
                    _MessageOperatesPopupMenu(
                      titleLabel: _titleLabel,
                      leading: _leading,
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
                  receptor: widget.receptor,
                  interactiveRegionRefreshAdapter:
                      _interactiveRegionRefreshAdapter,
                ),
              ],
            ),
          ),
        ],
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
  String titleLabel;
  String leading;

  _MessageOperatesPopupMenu({
    this.messageWrapper,
    this.context,
    this.onDeleted,
    this.onComment,
    this.onliked,
    this.onUnliked,
    this.titleLabel,
    this.leading,
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

  Future<void> _tipoffItem() async {
    showDialog(
        context: context,
        child: widget.context.part('/system/tip_off/item', context, arguments: {
          'item': TipOffItemArgs(
            id: widget.messageWrapper.message.id,
            type: 'geosphere',
            desc: widget.messageWrapper.message.text,
          )
        })).then((value) {
      if (value == null) {
        return;
      }
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('举报事项已提交'),
        ),
      );
    });
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

        var actions = <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (rights['isLiked']) {
                _unlike().whenComplete(() {
                  if (mounted) {
                    setState(() {});
                  }
                  if (widget.onUnliked != null) {
                    widget.onUnliked();
                  }
                });
              } else {
                _like().whenComplete(() {
                  if (mounted) {
                    setState(() {});
                  }
                  if (widget.onliked != null) {
                    widget.onliked();
                  }
                });
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 2,
                    left: 2,
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
          ),
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mounted) {
                setState(() {});
              }
              if (widget.onComment != null) {
                widget.onComment();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 2,
                    left: 2,
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
          ),
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mounted) {
                setState(() {});
              }
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    var webshareSite = widget.context.site
                        .getService('@.prop.website.webshare.geosphere-viewer');
                    String imgSrc;
                    if(widget.messageWrapper.medias.isNotEmpty){
                      var img=widget.messageWrapper.medias[0];
                      if(img.type=='image'){
                        imgSrc=img.src;
                      }
                    }
                    if(StringUtil.isEmpty(imgSrc)) {
                      imgSrc=widget.leading;
                    }
                    return Container(
                      height: 100,
                      constraints: BoxConstraints.tightForFinite(
                        width: double.maxFinite,
                      ),
                      child: widget.context.part(
                        '/external/share',
                        context,
                        arguments: {
                          'title': widget.titleLabel,
                          'desc': widget.messageWrapper.message.text ?? '',
                          'imgSrc': imgSrc,
                          'link':
                              '$webshareSite?docid=${widget.messageWrapper.message.id}',
                        },
                      ),
                    );
                  });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 2, top: 5, bottom: 5),
                  child: Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                Text(
                  '分享',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ];
        actions.add(
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
        );
        if (rights['canDelete']) {
          actions.add(
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (mounted) {
                  setState(() {});
                }
                if (widget.onDeleted != null) {
                  widget.onDeleted();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2,
                      left: 2,
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
              ),
            ),
          );
          actions.add(
            SizedBox(
              width: 10,
              height: 14,
              child: VerticalDivider(
                color: Colors.white,
                width: 1,
              ),
            ),
          );
        }

        actions.add(GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (mounted) {
              setState(() {});
            }
            _tipoffItem();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 2,
                  left: 2,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              Text(
                '举报',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ));
        return Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
          ),
          child: SizedBox(
            height: 18,
            child: CustomPopupMenu(
              child: Icon(
                Icons.more_horiz,
                size: 18,
              ),
              menuBuilder: () {
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C4C4C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 15,
                    children: actions,
                  ),
                );
              },
              barrierColor: Colors.transparent,
              pressType: PressType.singleClick,
            ),
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
  ReceptorInfo receptor;

  _InteractiveRegion({
    this.messageWrapper,
    this.context,
    this.receptor,
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

  @override
  void didUpdateWidget(_InteractiveRegion oldWidget) {
    if (widget.messageWrapper != oldWidget.messageWrapper) {
      oldWidget.messageWrapper = widget.messageWrapper;
    }
    super.didUpdateWidget(oldWidget);
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
                    widget.context.forward('/person/view',
                        arguments: {'official': comment.person});
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
                                      widget.context.forward('/person/view',
                                          arguments: {'official': like.person});
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
  GeosphereMessageOL message;
  List<MediaSrc> medias;
  Person creator;
  Person upstreamPerson;
  String _distanceLabel;
  AmapPoi poi;
  PurchaseOR purchaseOR;

  _GeosphereMessageWrapper({
    this.message,
    this.medias,
    this.creator,
    this.upstreamPerson,
    this.poi,
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

class _AbsorberAction extends StatefulWidget {
  PageContext context;
  ReceptorInfo receptorInfo;
  Color color;

  _AbsorberAction({
    this.context,
    this.receptorInfo,
    this.color,
  });

  @override
  __AbsorberActionState createState() => __AbsorberActionState();
}

class __AbsorberActionState extends State<_AbsorberAction> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  bool _isLoaded = false, _isRefreshing = false;
  StreamController _streamController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _isLoaded = false;
    _load().then((value) {
      _isLoaded = true;
      if (mounted) setState(() {});
    });
    _streamSubscription = Stream.periodic(
        Duration(
          seconds: 5,
        ), (count) async {
      if (!_isRefreshing && mounted) {
        return await _refresh();
      }
    }).listen((event) async {
      var v = await event;
      if (v == null) {
        return;
      }
      if (v && !_streamController.isClosed) {
        _streamController
            .add({'absorber': _absorberResultOR, 'bulletin': _bulletin});
      }
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  Future<bool> _refresh() async {
    _isRefreshing = true;
    var diff = await _load();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
    return diff;
  }

  Future<bool> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var absorbabler = 'geo.receptor/${widget.receptorInfo.id}';
    var absorberResultOR =
        await robotRemote.getAbsorberByAbsorbabler(absorbabler);
    if (absorberResultOR == null) {
      return false;
    }
    var bulletin =
        await robotRemote.getDomainBucket(absorberResultOR.absorber.bankid);
    bool diff = (_absorberResultOR == null ||
        (_absorberResultOR.bucket.price != absorberResultOR.bucket.price) ||
        (_bulletin.bucket.waaPrice != bulletin.bucket.waaPrice));
    _bulletin = bulletin;
    _absorberResultOR = absorberResultOR;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }

    if (_absorberResultOR == null) {
      return IconButton(
        onPressed: () {
          var _receptorInfo = widget.receptorInfo;
          widget.context.forward(
            '/absorber/apply/geosphere',
            arguments: {
              'title': _receptorInfo.title,
              'location': _receptorInfo.latLng,
              'radius': _receptorInfo.radius,
              'usage': 1,
              'absorbabler': 'geo.receptor/${_receptorInfo.id}',
            },
          ).then((value) {
            _load().then((value) {
              _isLoaded = true;
              if (mounted) setState(() {});
            });
          });
        },
        icon: Icon(
          IconData(
            0xe6b2,
            fontFamily: 'absorber',
          ),
          size: 20,
          color: widget.color,
        ),
      );
    }
    //存在
    return IconButton(
      icon: Icon(
        IconData(
          0xe6b2,
          fontFamily: 'absorber',
        ),
        size: 20,
        color: _absorberResultOR.bucket.price >= _bulletin.bucket.waaPrice
            ? Colors.red
            : Colors.green,
      ),
      onPressed: () {
        widget.context.forward('/absorber/details/geo', arguments: {
          'absorber': _absorberResultOR.absorber.id,
          'stream': _streamController.stream.asBroadcastStream(),
          'initAbsorber': _absorberResultOR,
          'initBulletin': _bulletin,
        });
      },
    );
  }
}
