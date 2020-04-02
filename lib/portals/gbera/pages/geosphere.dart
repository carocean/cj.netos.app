import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/wpopup_menu/w_popup_menu.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/cache/person_cache.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

import 'geosphere/geo_entities.dart';
import 'geosphere/geo_utils.dart';
import 'netflow/article_entities.dart';
import 'netflow/channel.dart';

class Geosphere extends StatefulWidget {
  PageContext context;

  Geosphere({this.context});

  @override
  _GeosphereState createState() => _GeosphereState();
}

class _GeosphereState extends State<Geosphere>
    with AutomaticKeepAliveClientMixin, AmapLocationDisposeMixin {
  bool use_wallpapper = false;
  EasyRefreshController _refreshController;
  GeoLocation _location;
  StreamController _messageStreamController;
  StreamController _notifyStreamController;
  int _limit = 15, _offset = 0;

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _messageStreamController = StreamController();
    _notifyStreamController = StreamController.broadcast();
    _location = geoLocation;
    _location.start();

    _refreshController = EasyRefreshController();
    _onload().then((v) {
      setState(() {});
    });
    _checkMobileReceptor();

    if (!widget.context.isListening(matchPath: '/geosphere/receptor')) {
      widget.context.listenNetwork(
        (frame) {
          switch (frame.command) {
            case 'pushDocument':
              _arrivedPushDocumentCommand(frame).then((message) {
                setState(() {});
              });
              break;
          }
        },
        matchPath: '/geosphere/receptor',
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.context.unlistenNetwork(matchPath: '/geosphere/receptor');
    _refreshController.dispose();
    _location.stop();
    _messageStreamController.close();
    _notifyStreamController.close();
    super.dispose();
  }

  Future<GeosphereMessageOL> _arrivedPushDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);
    var message =
        GeosphereMessageOL.from(docMap, widget.context.principal.person);
    message.state = 'arrived';
    message.atime = DateTime.now().millisecondsSinceEpoch;
    message.upstreamPerson = frame.head("sender");
    message.category = frame.parameter('category');

    if (message.creator == message.upstreamPerson) {
      await _cachePerson(message.creator);
    } else {
      await _cachePerson(message.creator);
      await _cachePerson(message.upstreamPerson);
    }

    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var exists = await messageService.getMessage(message.receptor, message.id);
    if (exists != null) {
      print('存在消息，被丢弃。');
      return null;
    }

    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var receptor = await receptorService.get(message.receptor);
    if (receptor != null) {
      //如果关注了感知器，则直接发往感知器
      await messageService.addMessage(message);
    } else {
      //感知器不存在则发往我的地圈
      var principal = widget.context.principal;
      receptor = await receptorService.getMobileReceptor(
          principal.person, principal.device);
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      message.upstreamReceptor = message.receptor;
      message.upstreamCategory = message.category;
      message.receptor = receptor.id;
      message.category = receptor.category;
      await messageService.addMessage(message);
    }

    //通知当前工作的管道有新消息到
    //网流的管道列表中的每个管道的显示消息提醒的状态栏
    _notifyStreamController.add({
      'command': 'pushDocumentCommand',
      'sender': frame.head('sender'),
      'message': message,
    });
    return message;
  }

  //如果不缓存用户的话，感知器打开时超慢，而且消息越多越慢，原因是每个消息均要加载消息的相关用户导致慢
  Future<void> _cachePerson(String _person) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    if (!(await personService.existsPerson(_person))) {
      var person =
          await personService.fetchPerson(_person, isDownloadAvatar: true);
      if (person != null) {
        IPersonCache _personCache =
            widget.context.site.getService('/cache/persons');
        await _personCache.cache(person);
      }
    }
  }

  Future<void> _onload() async {
    await _loadReceptors();
    return;
  }

  Future<void> _checkMobileReceptor() async {
    if (_offset > 0) {
      return;
    }
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    bool isInited = false;
    _location.listen('checkMobileReceptor', 0, (location) async {
      if (!isInited) {
        isInited = true;
        if (await receptorService.init(location)) {
          _loadReceptors();
          setState(() {});
        }
      }
      _location.unlisten('checkMobileReceptor');
    });
  }

  Future<void> _loadReceptors() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');

    var receptors = await receptorService.page(_limit, _offset);
    if (receptors.isEmpty) {
      _refreshController.finishLoad(success: true, noMore: true);
      return;
    }
    _offset += receptors.length;
    _messageStreamController.add(receptors);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    use_wallpapper = widget.context.parameters['use_wallpapper'];
    return EasyRefresh.custom(
      controller: _refreshController,
      onLoad: _onload,
      slivers: <Widget>[
        SliverPersistentHeader(
          floating: false,
          pinned: true,
          delegate: GberaPersistentHeaderDelegate(
            title: Text('地圈'),
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            actions: <Widget>[
              PopupMenuButton<String>(
                offset: Offset(
                  0,
                  50,
                ),
                onSelected: (value) async {
                  if (value == null) return;
                  var arguments = <String, Object>{};
                  switch (value) {
                    case '/netflow/manager/create_receptor':
                      widget.context
                          .forward(
                        '/geosphere/category/select',
                      )
                          .then((result) {
                        _offset = 0;
                        _messageStreamController.add('refresh');
                        _loadReceptors().then((v) {
                          setState(() {});
                        });
                      });
                      break;
                    case '/netflow/manager/scan_receptor':
                      break;
                    case '/netflow/manager/search_receptor':
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: '/netflow/manager/create_receptor',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            widget.context
                                .findPage('/netflow/manager/create_channel')
                                ?.icon,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '新建地理感知器',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: '/netflow/manager/scan_receptor',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            widget.context
                                .findPage('/netflow/manager/scan_receptor')
                                ?.icon,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '扫码以添加',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '/netflow/manager/search_receptor',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            widget.context
                                .findPage('/netflow/manager/search_receptor')
                                ?.icon,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '搜索以添加',
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
        ),
        SliverToBoxAdapter(
          child: _GeoDistrict(
            context: widget.context,
            location: _location,
            onTapFountain: () {
              widget.context.forward('/geosphere/fountain');
            },
            onTapYuanbao: () {
              widget.context.forward('/geosphere/yuanbao');
            },
          ),
        ),
        SliverToBoxAdapter(
          child: _GeoReceptors(
            context: widget.context,
            stream: _messageStreamController.stream,
            notify: _notifyStreamController.stream,
            onTapMarchant: (value) {
              widget.context.forward('/site/personal');
            },
            onTapFilter: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return widget.context.part('/geosphere/filter', context);
                  }).then((v) {
                print('----$v');
              });
            },
            onTapGeoCircle: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return widget.context.part('/geosphere/settings', context);
                  }).then((v) {
                print('----$v');
              });
            },
          ),
        ),
      ],
    );
  }
}

///当前行政区划
class _GeoDistrict extends StatefulWidget {
  PageContext context;
  GeoLocation location;
  Function() onTapFountain;
  Function() onTapYuanbao;

  _GeoDistrict(
      {this.context, this.location, this.onTapYuanbao, this.onTapFountain});

  @override
  _GeoDistrictState createState() => _GeoDistrictState();
}

class _GeoDistrictState extends State<_GeoDistrict> {
  String _locationLabel;

  @override
  void initState() {
    _initDistrictLocation();
    super.initState();
  }

  @override
  void dispose() {
    widget.location.unlisten('district');
    super.dispose();
  }

  Future<void> _initDistrictLocation() async {
    widget.location.listen('district', 1000, (location) async {
      //当坐标偏移一定距离时更新行政区信息
      await _updateDistrictInfo(location);
      setState(() {});
    });
  }

  _updateDistrictInfo(Location location) async {
    var city = await location.city;
    var district = await location.district;
    _locationLabel = '$city·$district';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 30,
              left: 10,
              right: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: _locationLabel ?? '定位中...',
                  ),
                  softWrap: true,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (widget.onTapFountain != null) {
                      widget.onTapFountain();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        child: Image.asset(
                          'lib/portals/gbera/images/penquan.png',
                          color: Colors.grey[600],
                          width: 20,
                          height: 20,
                        ),
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                child: Text(
                                  '金证喷泉',
                                ),
                                padding: EdgeInsets.only(
                                  right: 5,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              '2个',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onTapYuanbao == null) {
                      return;
                    }
                    widget.onTapYuanbao();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        child: Image.asset(
                          'lib/portals/gbera/images/yuanbao.png',
                          color: Colors.grey[600],
                          width: 20,
                          height: 20,
                        ),
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                child: Text(
                                  '元宝',
                                ),
                                padding: EdgeInsets.only(
                                  right: 5,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              '129个',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
//            color: Colors.white54,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return widget.context
                              .part('/geosphere/region', context);
                        });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: CardItem(
                      title: '市场',
                      paddingBottom: 12,
                      paddingTop: 12,
                      titleColor: Colors.grey[600],
                      leading: Icon(
                        FontAwesomeIcons.trademark,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      tipsText: '本地区有3个',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoReceptors extends StatefulWidget {
  PageContext context;
  Stream stream;
  Stream notify;
  Function() onTapFilter;
  Function() onTapGeoCircle;
  Function(Object args) onTapMarchant;

  _GeoReceptors({
    this.context,
    this.stream,
    this.notify,
    this.onTapFilter,
    this.onTapMarchant,
    this.onTapGeoCircle,
  });

  @override
  _GeoReceptorsState createState() => _GeoReceptorsState();
}

class _GeoReceptorsState extends State<_GeoReceptors> {
  LatLng _currentLatLng;
  double _offset = 0.0;
  List<GeoReceptor> _receptors = [];
  Map<String, _ReceptorItemStateBar> _stateBars = {};

  @override
  void initState() {
    geoLocation.listen('receptors', 5, (location) async {
      _currentLatLng = await location.latLng;
      setState(() {});
    });
    widget.stream.listen((receptors) {
      if (receptors is String && receptors == 'refresh') {
        _receptors.clear();
        return;
      }
      _receptors.addAll(receptors);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _receptors.clear();
    super.dispose();
  }

  Future<void> _deleteReceptor(GeoReceptor receptor) async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    await receptorService.remove(receptor.category, receptor.id);
    for (var i = 0; i < _receptors.length; i++) {
      if (_receptors[i].id == receptor.id) {
        _receptors.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 4,
                ),
                margin: EdgeInsets.all(0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  '地理感知器',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            children: _receptors.map((receptor) {
              var latlng = receptor.getLocationLatLng();
              double offset = 0.0;
              if (_currentLatLng != null) {
                offset = getDistance(start: _currentLatLng, end: latlng);
              }
              var backgroundMode;
              switch (receptor.backgroundMode) {
                case 'vertical':
                  backgroundMode = BackgroundMode.vertical;
                  break;
                case 'horizontal':
                  backgroundMode = BackgroundMode.horizontal;
                  break;
                case 'none':
                  backgroundMode = BackgroundMode.none;
                  break;
              }
              var foregroundMode;
              switch (receptor.foregroundMode) {
                case 'original':
                  foregroundMode = ForegroundMode.original;
                  break;
                case 'white':
                  foregroundMode = ForegroundMode.white;
                  break;
              }
              return _ReceptorItem(
                context: widget.context,
                onDelete: () {
                  _deleteReceptor(receptor).then((v) {
                    setState(() {});
                  });
                },
                receptor: ReceptorInfo(
                  title: receptor.title,
                  id: receptor.id,
                  leading: receptor.leading,
                  creator: receptor.creator,
                  isMobileReceptor: receptor.title == '我的地圈',
                  offset: offset,
                  category: receptor.category,
                  radius: receptor.radius,
                  isAutoScrollMessage: receptor.isAutoScrollMessage=='true'?true:false,
                  latLng: LatLng.fromJson(jsonDecode(receptor.location)),
                  uDistance: receptor.uDistance,
                  background: receptor.background,
                  backgroundMode: backgroundMode,
                  foregroundMode: foregroundMode,
                  origin: receptor,
                ),
                notify: widget.notify,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ReceptorItem extends StatefulWidget {
  PageContext context;
  ReceptorInfo receptor;
  Stream notify;
  Function() onDelete;

  _ReceptorItem({
    this.context,
    this.receptor,
    this.onDelete,
    this.notify,
  });

  @override
  _ReceptorItemState createState() => _ReceptorItemState();
}

class _ReceptorItemState extends State<_ReceptorItem> {
  double _percentage = 0.0;
  _ReceptorItemStateBar _stateBar;
  StreamSubscription<dynamic> _streamSubscription;

  @override
  void initState() {
    _stateBar = _ReceptorItemStateBar(isShow: false);
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _streamSubscription = widget.notify.listen((cmd) async {
      GeosphereMessageOL message = cmd['message'];
      var sender = cmd['sender'];
      switch (cmd['command']) {
        case 'pushDocumentCommand':
          _loadUnreadMessage().then((v) {
            setState(() {});
          });
          break;
      }
    });
    _loadUnreadMessage().then((v) {
      setState(() {});
    });
    super.initState();
  }

  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ReceptorItem oldWidget) {
    if (oldWidget.receptor.leading != widget.receptor.leading) {
      widget.receptor.leading = oldWidget.receptor.leading;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadUnreadMessage() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var message = await messageService.firstUnreadMessage(widget.receptor.id);
    if (message == null) {
      _stateBar.count = 0;
      _stateBar.atime = null;
      _stateBar.isShow = false;
      _stateBar.brackets = null;
      _stateBar.tips = null;
      return;
    }
    var count = await messageService.countUnreadMessage(widget.receptor.id);
    _stateBar.count = count;
    _stateBar.atime = message?.atime;
    var person;
    if (!StringUtil.isEmpty(message?.upstreamPerson)) {
      person = await personService.getPerson(message.upstreamPerson);
    } else {
      person = await personService.getPerson(message.creator);
    }
    _stateBar.brackets = '${count > 0 ? '$count条' : '${person.nickName}'}';
    _stateBar.tips = '${person.nickName}:${message?.text}';
    _stateBar.isShow = true;
  }

  Future<void> _updateLeading() async {
    if (_percentage > 0) {
      _percentage = 0.0;
      setState(() {});
    }
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var receptor = widget.receptor;
    var map = await widget.context.ports.upload(
        '/app',
        <String>[
          receptor.leading,
        ],
        accessToken: widget.context.principal.accessToken,
        onSendProgress: (i, j) {
      _percentage = ((i * 1.0 / j));
      setState(() {});
    });
    var remotePath = map[receptor.leading];
    await receptorService.updateLeading(
        receptor.category, receptor.id, receptor.leading, remotePath);
  }

  @override
  Widget build(BuildContext context) {
    Widget imgSrc = null;
    if (StringUtil.isEmpty(widget.receptor.leading)) {
      imgSrc = Icon(
        IconData(
          0xe604,
          fontFamily: 'netflow2',
        ),
        size: 32,
        color: Colors.grey[500],
      );
    } else if (widget.receptor.leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(widget.receptor.leading),
        width: 40,
        height: 40,
      );
    } else {
      imgSrc = Image.network(
        widget.receptor.leading,
        width: 40,
        height: 40,
      );
    }
    var item = Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: 15,
              left: 10,
              right: 10,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: _stateBar.isShow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      //如果不是自己的管道则不能改图标
                      if (widget.context.principal.person !=
                          widget.receptor.creator) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('不可修改图标！原因：不是您创建的感知器'),
                          ),
                        );
                        return;
                      }
                      widget.context
                          .forward(
                        '/widgets/avatar',
                      )
                          .then((path) {
                        if (StringUtil.isEmpty(path)) {
                          return;
                        }
                        widget.receptor.leading = path;
                        setState(() {});
                        _updateLeading();
                      });
                    },
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: imgSrc,
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -3,
                          child: !_stateBar.isShow
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Badge(
                                  position: BadgePosition.topRight(
                                    right: -3,
                                    top: 3,
                                  ),
                                  elevation: 0,
                                  showBadge: (_stateBar.count ?? 0) != 0,
                                  badgeContent: Text(
                                    '',
                                  ),
                                  child: null,
                                ),
                        ),
                        _percentage > 0 && _percentage < 1.0
                            ? Positioned(
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  value: _percentage,
                                ),
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: widget.receptor.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          widget.receptor.offset == 0
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: Text(
                                    '${getFriendlyDistance(widget.receptor.offset)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      !_stateBar.isShow
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.start,
                                spacing: 5,
                                runSpacing: 3,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      text: '[${_stateBar.brackets}]',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ',
                                        ),
                                        TextSpan(
                                          text: _stateBar.tips,
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _stateBar?.atime != null
                                        ? '${TimelineUtil.format(
                                            _stateBar?.atime,
                                            locale: 'zh',
                                            dayFormat: DayFormat.Simple,
                                          )}'
                                        : '',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
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
          Divider(
            height: 1,
            indent: 60,
          ),
        ],
      ),
    );
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        widget.receptor.isMobileReceptor
            ? Padding(
                padding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: Text(
                  '不能删除我的地圈',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              )
            : IconSlideAction(
                caption: '删除',
                foregroundColor: Colors.grey[500],
                icon: Icons.delete,
                onTap: () {
                  if (widget.onDelete != null) {
                    widget.onDelete();
                  }
                },
              ),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.context.forward('/geosphere/receptor', arguments: {
            'receptor': widget.receptor,
            'notify': widget.notify,
          }).then((v) {
            _loadUnreadMessage().then((v) {
              setState(() {});
            });
          });
        },
        child: item,
      ),
    );
  }
}

class _ReceptorItemStateBar {
  String brackets; //括号
  String tips; //提示栏
  int atime; //时间
  int count = 0; //消息数提示，0表示无提示
  bool isShow = false; //是否显示提供
  _ReceptorItemStateBar(
      {this.brackets, this.tips, this.atime, this.count, this.isShow = false});

  Future<void> update(String command, dynamic args) async {}
}
