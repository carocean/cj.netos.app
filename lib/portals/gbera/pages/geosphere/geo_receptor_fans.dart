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
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/util.dart';
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
import 'package:netos_app/system/system.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import '../geosphere.dart';
import 'receptor_handler.dart';

class GeoReceptorFansWidget extends StatefulWidget {
  PageContext context;

  GeoReceptorFansWidget({this.context});

  @override
  _GeoReceptorFansWidgetState createState() => _GeoReceptorFansWidgetState();
}

class _GeoReceptorFansWidgetState extends State<GeoReceptorFansWidget> {
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
  Person _owner;
  bool _isDenyFollowSpeak = true;

  @override
  void initState() {
    _receptorInfo = widget.context.parameters['receptor'];
    _loadIsDenyFollowSpeak().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    _onloadOwner().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    _receptorInfo.onSettingsChanged = _onSettingChanged;
    geoLocation.listen('geosphere.receptors.fans',
        (_receptorInfo.uDistance ?? 10) * 1.0, _updateLocation);
    _refreshController = EasyRefreshController();
    _loadCategory().then((v) {
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    });
    _onloadMessages().then((v) async {
      if (_messageList.isEmpty) {
        await _loadRemoteMessages();
      }
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
    geoLocation.unlisten('geosphere.receptors.fans');
    _messageList.clear();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onloadOwner() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _owner = await personService.getPerson(_receptorInfo.creator);
  }

  Future<void> _loadIsDenyFollowSpeak() async {
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    _isDenyFollowSpeak =
        await receptorRemote.isDenyFollowSpeak(_receptorInfo.id);
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
    var city = location.city;
    if (StringUtil.isEmpty(city)) {
      return;
    }
    //计算文档离我的距离
    var latLng = location.latLng;
    var poiList = await AmapSearch.instance
        .searchAround(latLng, radius: 500, type: amapPOIType);
    if (poiList.isEmpty) {
      return;
    }
    var amapPoi = poiList[0];
    var title = amapPoi.title;
    var address = amapPoi.address;
    var poiId = amapPoi.poiId;

    var distance = 0;
    _currentPoi = AmapPoi(
      distance: distance,
      title: title,
      latLng: latLng,
      address: address,
      poiId: poiId,
    );
    for (var msgwrapper in _messageList) {
      String loc = msgwrapper.message.location;
      if (StringUtil.isEmpty(loc)) {
        continue;
      }
      var msglatLng = LatLng.fromJson(jsonDecode(loc));
      var distanceLabel =
          getFriendlyDistance(getDistance(start: latLng, end: msglatLng));
      msgwrapper.distanceLabel = distanceLabel;
      msgwrapper.poi = _currentPoi;
    }
    setState(() {});
  }

  Future<void> _loadCategory() async {
    IGeoCategoryLocal categoryLocal =
        widget.context.site.getService('/geosphere/categories');
    _category = await categoryLocal.get(_receptorInfo.category);
  }

  //如果页面为空则从远程尝试拉取消息
  Future<void> _loadRemoteMessages() async {
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');

    var messages = await receptorRemote.pageDocument(_receptorInfo.id, 20, 0);
    List<_GeosphereMessageWrapper> wrappers = [];
    for (var message in messages) {
      await messageService.addMessage(message, isOnlySaveLocal: true);
      await _fillRemoteMessageWrapper(message, wrappers);
    }
    _messageList.addAll(wrappers);
  }

  Future<void> _fillRemoteMessageWrapper(message, wrappers) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IGeosphereMediaService mediaService =
        widget.context.site.getService('/geosphere/receptor/messages/medias');
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
      await mediaService.addMedia(
          mediaOR.toLocal(widget.context.principal.person),
          isOnlySaveLocal: true);
    }

    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var purchaseOR = await purchaserRemote.getPurchaseRecordPerson(
        message.creator, message.purchaseSn);
    await _loadAndSaveRemoteInterviews(message);
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

  Future<void> _loadAndSaveRemoteInterviews(message) async {
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var persons = <String, Person>{};

    List<GeosphereLikeOR> likes =
        await receptorRemote.pageLike(message.id, 10, 0);
    for (var like in likes) {
      var person = persons[like.person];
      if (person == null) {
        person = await personService.fetchPerson(like.person);
        if (person == null) {
          continue;
        }
        persons[like.person] = person;
      }
      var likeOL = GeosphereLikePersonOL(
        MD5Util.MD5(Uuid().v1()),
        person.official,
        person.avatar,
        like.docid,
        like.ctime,
        person.nickName,
        like.receptor,
        widget.context.principal.person,
      );
      messageService.like(likeOL, isOnlySaveLocal: true);
    }
    List<GeosphereCommentOR> comments =
        await receptorRemote.pageComment(message.id, 20, 0);
    for (var comment in comments) {
      var person = persons[comment.person];
      if (person == null) {
        person = await personService.fetchPerson(comment.person);
        if (person == null) {
          continue;
        }
        persons[comment.person] = person;
      }
      var commentOL = GeosphereCommentOL(
        comment.id,
        person.official,
        person.avatar,
        comment.docid,
        comment.content,
        comment.ctime,
        person.nickName,
        comment.receptor,
        widget.context.principal.person,
      );
      messageService.addComment(commentOL, isOnlySaveLocal: true);
    }
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
      await _fillLocalMessageWrapper(message, wrappers);
    }
    _messageList.addAll(wrappers);
  }

  Future<void> _fillLocalMessageWrapper(message, wrappers) async {
    IGeosphereMediaService mediaService =
        widget.context.site.getService('/geosphere/receptor/messages/medias');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
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
    await _fillLocalMessageWrapper(messageOL, wrappers);
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
            owner: _owner,
            context: widget.context,
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
                              : Colors.grey[400],
                        ),
                        children: [
                          TextSpan(text: '  '),
                          (useSimpleLayout()||msg.purchaseOR?.principalAmount==null)?TextSpan(text: ''):
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
                                '${msg.poi == null ? '' : '${msg.poi.title}附近'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _receptorInfo.backgroundMode ==
                                      BackgroundMode.vertical
                                  ? Colors.white
                                  : Colors.grey[400],
                            ),
                            children: msg.distanceLabel == null
                                ? []
                                : [
                                    TextSpan(text: ' '),
                                    TextSpan(
                                      text: '距${msg.distanceLabel}',
                                      style: TextStyle(
                                        fontSize: 12,
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
            paddingLeft: 12,
            paddingContentLeft: 40,
          ),
        ),
      );
    }
    return list;
  }

  List<Widget> _getActions(Color color) {
    var actions = <Widget>[
    ];
    if (!_isDenyFollowSpeak) {
      actions.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () {
            if(useSimpleLayout()){
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
      );
    }
    return actions;
  }
}

class _HeaderWidget extends StatefulWidget {
  PageContext context;
  Function() refresh;
  ReceptorInfo receptorInfo;
  bool isShowWhite;
  Function(List filter) filterMessages;
  GeoCategoryOL categoryOL;
  Person owner;

  _HeaderWidget({
    this.context,
    this.refresh,
    this.filterMessages,
    this.receptorInfo,
    this.isShowWhite,
    this.categoryOL,
    this.owner,
  });

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<_HeaderWidget> {
  int _arrivedMessageCount = 0;
  var _workingChannel;
  String _poiTitle;
  LatLng _currentLatLng;
  StreamSubscription _streamSubscription;
  List<List<ThirdPartyService>> _serviceMenu = [];
  TabController _controller;
  List _filter; //0为channel;1为category;2为brand
  var _isFollowed = false;
  var _followCount = 0;
  var _followLabel = '关注';

  @override
  void initState() {
    _controller = DefaultTabController.of(context);
    _loadLocation().then((v) {
      setState(() {});
    });
    _loadFollow().then((v) {
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
    _controller?.dispose();
    _serviceMenu.clear();
    _streamSubscription.cancel();
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

  Future<void> _loadUnreadMessage() async {
    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    _arrivedMessageCount =
        await messageService.countUnreadMessage(widget.receptorInfo.id);
  }

  Future<void> _loadLocation() async {
    _currentLatLng = widget.receptorInfo.latLng;
    var list = await AmapSearch.instance
        .searchAround(_currentLatLng, radius: 2000, type: amapPOIType);
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
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _currentLatLng = location.latLng;
    _poiTitle = location.poiName;
    if (mounted) {
      setState(() {});
    }
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
      widget.context.backward();
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
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return widget.context.part(
                                '/geosphere/settings.fans', context,
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
                      widget.context.forward('/person/view', arguments: {
                        'official': widget.context.principal.person
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(1),
                          child: ClipOval(
                            child: Image(
                              image: FileImage(
                                File(
                                  widget.context.principal?.avatarOnLocal,
                                ),
                              ),
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
                                widget.context.principal.nickName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                              ),
                              child: Text(
                                '我为粉丝',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey[500],
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
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      _arrivedMessageCount == 0
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                if (widget.refresh != null) {
                                  await widget.refresh();
                                  _arrivedMessageCount = 0;
                                  setState(() {});
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
                      /*
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
                            Icon(
                              FontAwesomeIcons.filter,
                              size: 13,
                              color: widget.isShowWhite
                                  ? Colors.white70
                                  : Colors.grey[500],
                            ),
                          ],
                        ),
                      ),

                       */
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
      return '筛选';
    }
    if (_filter[2] != null) {
      return _filter[2].title;
    }
    return _filter[1].title;
  }

  Widget _renderServiceMenu() {
    if (_serviceMenu.isEmpty) {
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
  Person _creator;
  bool _isMine = false;

  @override
  void initState() {
    _interactiveRegionRefreshAdapter = _InteractiveRegionRefreshAdapter();
    _setTitleLabel() ;
    super.initState();
  }

  @override
  void dispose() {
    _interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(_MessageCard oldWidget) {
    if (oldWidget.messageWrapper.message.id !=
        widget.messageWrapper.message.id) {
      oldWidget.messageWrapper = widget.messageWrapper;
      _setTitleLabel() ;
    }
    super.didUpdateWidget(oldWidget);
  }

  _setTitleLabel() {
    _creator = widget.messageWrapper.creator;
    _isMine = widget.context.principal?.person ==
        widget.messageWrapper.creator.official;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward(
                  '/geosphere/portal.owner',
                  arguments: {
                    'receptor': widget.receptor,
                    'personFilter': _creator.official,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: 5, right: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _getleadingImg(),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.context.forward(
                  '/geosphere/portal.owner',
                  arguments: {
                    'receptor': widget.receptor,
                    'personFilter': _creator.official,
                  },
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Text(
                '${_creator?.nickName ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: 10,
          ),
          margin: EdgeInsets.only(
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200],
                blurRadius: 5,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  widget.receptor.creator ==
                              widget.messageWrapper.message.creator ||
                          _upstreamReceptor == null
                      ? Container(
                          height: 0,
                          width: 0,
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


               */
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
              Container(
                height: 7,
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
                receptor: widget.receptor,
                interactiveRegionRefreshAdapter:
                    _interactiveRegionRefreshAdapter,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getleadingImg() {
    var _leading=_creator.avatar;
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
                      imgSrc=widget.messageWrapper.creator.avatar;
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
                          'title': widget.messageWrapper.creator.nickName,
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
  List<GeosphereCommentOL> _comments = [];
  List<GeosphereLikePersonOL> _likes = [];

  @override
  void initState() {
    if (widget.interactiveRegionRefreshAdapter != null) {
      widget.interactiveRegionRefreshAdapter.handler = (cause) {
        print(cause);
        switch (cause) {
          case 'comment':
            _isShowCommentEditor = true;
            if (mounted) {
              setState(() {});
            }
            break;
          case 'liked':
          case 'unliked':
            _likes.clear();
            _loadLikes().then((value) {
              if (mounted) {
                setState(() {});
              }
            });
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

  @override
  void didUpdateWidget(_InteractiveRegion oldWidget) {
    if (oldWidget.messageWrapper.message.id ==
        widget.messageWrapper.message.id) {
      oldWidget.messageWrapper = widget.messageWrapper;
      _refresh();
      _load().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  _refresh() {
    _likes.clear();
    _comments.clear();
  }

  Future<void> _load() async {
    await _loadLikes();
    await _loadComments();
  }

  Future<void> _loadComments() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    List<GeosphereCommentOL> comments = await geoMessageService.pageComments(
        widget.messageWrapper.message.receptor,
        widget.messageWrapper.message.id,
        20,
        0);
    _comments.addAll(comments);
  }

  Future<void> _loadLikes() async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    List<GeosphereLikePersonOL> likes = await geoMessageService.pageLikePersons(
        widget.messageWrapper.message.receptor,
        widget.messageWrapper.message.id,
        10,
        0);
    _likes.addAll(likes);
  }

  _appendComment(String content) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var c = GeosphereCommentOL(
      '${Uuid().v1()}',
      widget.context.principal.person,
      widget.context.principal.avatarOnRemote,
      widget.messageWrapper.message.id,
      content,
      DateTime.now().millisecondsSinceEpoch,
      widget.context.principal.nickName ?? widget.context.principal.accountCode,
      widget.messageWrapper.message.receptor,
      widget.context.principal.person,
    );
    await geoMessageService.addComment(c);
    _comments.insert(0, c);
  }

  _deleteComment(GeosphereCommentOL comment) async {
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    await geoMessageService.removeComment(
        widget.messageWrapper.message.receptor, comment.msgid, comment.id);
    _comments.removeWhere((element) => element.id == comment.id);
  }

  @override
  Widget build(BuildContext context) {
    bool isHide = _comments.isEmpty && _likes.isEmpty && !_isShowCommentEditor;
    if (isHide) {
      return Container(
        width: 0,
        height: 0,
      );
    }
    var comments = _comments;
    var likePersons = _likes;

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
