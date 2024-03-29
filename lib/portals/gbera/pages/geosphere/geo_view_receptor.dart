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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/netflow/article_entities.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/service_menu.dart';
import 'package:netos_app/portals/gbera/pages/system/tip_off_item.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

import '../geosphere.dart';

class GeoViewReceptor extends StatefulWidget {
  PageContext context;

  GeoViewReceptor({this.context});

  @override
  _GeoViewReceptorState createState() => _GeoViewReceptorState();
}

class _GeoViewReceptorState extends State<GeoViewReceptor> {
  List<ChannelMessage> messages = [];
  ReceptorInfo _receptorInfo;
  EasyRefreshController _refreshController;
  GeoCategoryOL _category;
  bool _isLoaded = false;
  int _limit = 15, _offset = 0;
  List<_GeosphereMessageWrapper> _messageList = [];
  bool _isLoadedMessages = false;
  AmapPoi _currentPoi;
  Person _owner;

  @override
  void initState() {
    _receptorInfo = widget.context.parameters['receptor'];
    _refreshController = EasyRefreshController();
    _onloadOwner().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
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

    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('geosphere.receptors');
    _messageList.clear();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onloadOwner() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _owner = await personService.getPerson(_receptorInfo.creator);
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

    List<GeosphereMessageOL> messages = await receptorRemote.pageMessage(
        _receptorInfo.id, _receptorInfo.creator, _limit, _offset);
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

  Future<void> _fillMessageWrapper(message, wrappers) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    List<GeosphereMediaOR> medias =
        await receptorRemote.listExtraMedia(message.id);
    Person creator =
        await personService.getPerson(message.creator, isDownloadAvatar: true);
    Person upstreamPerson;
    if (!StringUtil.isEmpty(message.upstreamPerson)) {
      upstreamPerson = await personService.getPerson(message.upstreamPerson,
          isDownloadAvatar: true);
    }
    List<MediaSrc> _medias = [];
    for (GeosphereMediaOR mediaOR in medias) {
      _medias.add(mediaOR.toMedia());
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
    if (_owner == null) {
      return Container(
        height: 0,
        width: 0,
      );
    }
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
                  if (_receptorInfo.backgroundMode != null &&
                      _receptorInfo.backgroundMode != BackgroundMode.none) {
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
            owner: _owner,
            receptorInfo: _receptorInfo,
            isShowWhite: _receptorInfo.foregroundMode == ForegroundMode.white,
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
    appBar.title = Text(
      _receptorInfo.category == 'mobiles'
          ? '${_owner.nickName}'
          : _receptorInfo.title,
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
            paddingContentLeft: 40,
            content: _MessageCard(
              context: widget.context,
              messageWrapper: msg,
              receptor: _receptorInfo,
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
                        text: '${TimelineUtil.format(
                          msg.message.ctime,
                          locale: 'zh',
                          dayFormat: DayFormat.Simple,
                        )}',
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
                            text:
                                '¥${((msg.purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
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
      /*
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
       */
    ];
  }
}

class _HeaderWidget extends StatefulWidget {
  PageContext context;
  Function() refresh;
  ReceptorInfo receptorInfo;
  Person owner;
  bool isShowWhite;
  GeoCategoryOL categoryOL;

  _HeaderWidget({
    this.context,
    this.refresh,
    this.owner,
    this.receptorInfo,
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
  List<List<ThirdPartyService>> _serviceMenu = [];
  Map<String, String> _selectCategory;
  var _controller;
  var _isFollowed = false;
  var _followCount = 0;
  var _followLabel = '关注';
  bool _isHiddenServiceMenu = false;

  @override
  void initState() {
    _isHiddenServiceMenu =
        widget.context.parameters['isHiddenServiceMenu'] ?? false;
    _controller = DefaultTabController.of(context);
    _loadLocation().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    geoLocation.listen('receptor.header',
        (widget.receptorInfo.uDistance ?? 10) * 1.0, _updateLocation);
//    _workingChannel = widget.context.parameters['workingChannel'];
//    _workingChannel.onRefreshChannelState = (command, args) {
//      _arrivedMessageCount++;
//      setState(() {});
//    };
//     _loadServiceMenu().then((v) {
//       if (mounted) {
//         setState(() {});
//       }
//     });
    _loadFollow().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('receptor.header');
    if (_workingChannel != null) {
      _workingChannel.onRefreshChannelState = null;
    }
    _serviceMenu.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(_HeaderWidget oldWidget) {
    if (oldWidget.categoryOL != widget.categoryOL) {
      oldWidget.categoryOL = widget.categoryOL;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadLocation() async {
    _currentLatLng = widget.receptorInfo.latLng;
    var list = await AmapSearch.instance.searchAround(_currentLatLng,
        radius: 2000, type: amapPOIType);
    if (list == null || list.isEmpty) {
      return;
    }
    _poiTitle = list[0].title;
  }

  _updateLocation(Location location) async {
    if (widget.categoryOL == null) {
      return;
    }
    if (widget.categoryOL.moveMode == 'unmoveable') {
      _currentLatLng = location.latLng;
      setState(() {});
      return;
    }
    _currentLatLng = location.latLng;
    _poiTitle = location.poiName;
    setState(() {});
  }

  _loadFollow() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    var exists = await receptorService.existsLocal(widget.receptorInfo.id);
    _followCount =
        await receptorRemote.countReceptorFans(widget.receptorInfo.id);
    _isFollowed = exists;
    _followLabel = exists ? '不再关注' : '关注';
  }

  Future<void> _follow() async {
    _followLabel = '处理中...';
    setState(() {});
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    if (_isFollowed) {
      //取消
      await receptorService.remove(widget.receptorInfo.id);
      await receptorRemote.unfollow(widget.receptorInfo.id);
      await _loadFollow();
      geosphereEvents.onRemoveReceptor(widget.receptorInfo.origin);
      _isFollowed = false;
      _followLabel = '关注';
      return;
    }
    var recobj = await receptorRemote.getReceptor(widget.receptorInfo.id);
    if (recobj == null) {
      recobj = widget.receptorInfo.origin;
    }
    await receptorService.add(recobj, isOnlySaveLocal: true);
    await receptorRemote.follow(recobj.id);
    await _loadFollow();
    geosphereEvents.onAddReceptor(recobj);
    _isFollowed = true;
    _followLabel = '不再关注';
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
              bottom: 0,
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
                                '/geosphere/settings.viewer', context,
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
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                              ),
                              child: Flex(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      widget.context.forward(
                                        '/geosphere/receptor/settings/links/fans',
                                        arguments: {
                                          'receptor': widget.receptorInfo,
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: 10,
                                      ),
                                      child: Text(
                                        '粉丝($_followCount)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _follow().then((v) {
                                        setState(() {});
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                      ),
                                      child: Text(
                                        '${_followLabel}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
//          _renderServiceMenu(),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context
                          .forward('/person/view', arguments: {'person': widget.owner});
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(1),
                          child: ClipOval(
                            child: Image(
                              image: _getImageWidget(),
                              height: 30,
                              width: 30,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                              ),
                              child: Text(
                                widget.owner.nickName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: widget.receptorInfo.backgroundMode ==
                                          BackgroundMode.vertical
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 1,
                                left: 5,
                              ),
                              child: Text(
                                '圈主',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.receptorInfo.backgroundMode ==
                                          BackgroundMode.vertical
                                      ? Colors.white70
                                      : Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderServiceMenu() {
    if (_serviceMenu.isEmpty || _isHiddenServiceMenu) {
      return Container(
        height: 0,
        width: 0,
      );
    }
    var pageViews = <Widget>[];
    for (var menu in _serviceMenu) {
      List<ThirdPartyService> list = menu;
      pageViews.add(
        CustomScrollView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.center,
//                decoration: BoxDecoration(
//                  color: Colors.white,
////                  borderRadius: BorderRadius.all(Radius.circular(20)),
//                ),
                height: 180,
                child: Wrap(
                  children: list.map((service) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: service.onTap,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        width: 100,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Image.network(
                                service.iconUrl,
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              service.title,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: DefaultTabController(
        length: pageViews.length,
        child: Column(
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.all(10),
                child: TabBarView(
                  children: pageViews,
                ),
              ),
            ),
            SizedBox(
              height: 12,
              child: TabPageSelector(
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getImageWidget() {
    var avatar = widget.owner?.avatar;
    if (StringUtil.isEmpty(avatar)) {
      return FileImage(
        File(
          avatar,
        ),
      );
    }
    if (avatar.startsWith('/')) {
      return FileImage(
        File(
          avatar,
        ),
      );
    }
    return NetworkImage(
      '${avatar}?accessToken=${widget.context.principal.accessToken}',
    );
  }
}

class _MessageCard extends StatefulWidget {
  PageContext context;
  _GeosphereMessageWrapper messageWrapper;
  ReceptorInfo receptor;
  void Function(_GeosphereMessageWrapper message) onDeleted;

  _MessageCard({
    this.context,
    this.messageWrapper,
    this.receptor,
    this.onDeleted,
  });

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  int maxLines = 4;
  _InteractiveRegionRefreshAdapter _interactiveRegionRefreshAdapter;

  @override
  void initState() {
    _interactiveRegionRefreshAdapter = _InteractiveRegionRefreshAdapter();
    super.initState();
  }

  @override
  void dispose() {
    _interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: 15,
        left: 0,
        right: 10,
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  // DefaultTabController(
                  //   length: widget.messageWrapper.medias.length,
                  //   child: PageSelector(
                  //     medias: widget.messageWrapper.medias,
                  //     onMediaLongTap: (media, index) {
                  //       widget.context.forward(
                  //         '/images/viewer',
                  //         arguments: {
                  //           'medias': widget.messageWrapper.medias,
                  //           'index': index,
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
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
                    receptor: widget.receptor,
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
  ReceptorInfo receptor;
  _InteractiveRegionRefreshAdapter interactiveRegionRefreshAdapter;

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
        switch (cause) {
          case 'comment':
            _isShowCommentEditor = true;
            if(mounted) {
              setState(() {});
            }
            break;
          case 'liked':
          case 'unliked':
            Future.delayed(Duration(seconds: 1), (){
              if(mounted) {
                setState(() {});
              }
            });
            break;
          default:
            if(mounted) {
              setState(() {});
            }
            break;
        }

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
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var persons = <String, Person>{};

    List<GeosphereLikeOR> likes =
        await receptorRemote.pageLike(widget.messageWrapper.message.id, 10, 0);
    List<GeosphereLikePersonOL> likesLocal = [];
    for (var like in likes) {
      var person = persons[like.person];
      if (person == null) {
        person = await personService.fetchPerson(like.person);
        if (person == null) {
          continue;
        }
        persons[like.person] = person;
      }
      likesLocal.add(
        GeosphereLikePersonOL(
          MD5Util.MD5(Uuid().v1()),
          person.official,
          person.avatar,
          like.docid,
          like.ctime,
          person.nickName,
          like.receptor,
          widget.context.principal.person,
        ),
      );
    }
    List<GeosphereCommentOR> comments = await receptorRemote.pageComment(
        widget.messageWrapper.message.id, 20, 0);
    List<GeosphereCommentOL> commentsLocal = [];
    for (var comment in comments) {
      var person = persons[comment.person];
      if (person == null) {
        person = await personService.fetchPerson(comment.person);
        if (person == null) {
          continue;
        }
        persons[comment.person] = person;
      }
      commentsLocal.add(
        GeosphereCommentOL(
          comment.id,
          person.official,
          person.avatar,
          comment.docid,
          comment.content,
          comment.ctime,
          person.nickName,
          comment.receptor,
          widget.context.principal.person,
        ),
      );
    }
    return <String, List<dynamic>>{
      "likePersons": likesLocal,
      "comments": commentsLocal
    };
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
                    widget.context
                        .forward('/person/view', arguments: {'official': comment.person});
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
                                      widget.context
                                          .forward('/person/view', arguments: {'official': like.person});
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
