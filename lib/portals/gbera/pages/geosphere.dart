import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/gbera/store/sync_tasks.dart';
import 'package:netos_app/system/local/cache/person_cache.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import 'geosphere/geo_entities.dart';
import 'geosphere/geo_utils.dart';
import 'geosphere/receptor_handler.dart';
import 'netflow/article_entities.dart';
import 'netflow/channel.dart';

typedef GeosphereEvent = void Function(String action, dynamic args);

class _GeosphereEvents {
  final List<GeosphereEvent> listeners = [];

  void onAddReceptor(GeoReceptor receptor) {
    listeners.forEach((listener) {
      listener('addReceptor', receptor);
    });
  }

  void onRemoveReceptor(GeoReceptor receptor) {
    listeners.forEach((listener) {
      listener(
          ''
          '',
          receptor);
    });
  }
}

final geosphereEvents = _GeosphereEvents();

class Geosphere extends StatefulWidget {
  PageContext context;

  Geosphere({this.context});

  @override
  _GeosphereState createState() => _GeosphereState();
}

class _GeosphereState extends State<Geosphere>
    with AutomaticKeepAliveClientMixin {
  bool use_wallpapper = false;
  EasyRefreshController _refreshController;
  StreamController _receptorStreamController;
  int _limit = 15, _offset = 0;
  Lock _lock;
  bool _isSyning = false;
  StreamSubscription _onlineEventStreamSubscription;

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _lock = Lock();
    _receptorStreamController = StreamController.broadcast();
    geoLocation.start();

    _refreshController = EasyRefreshController();
    _load().then((v) {
      if(mounted) {
        setState(() {});
      }
    });

    _listenMeidaFileDownload();
    if (deviceStatus.state == DeviceNetState.online) {
      _listen();
    } else {
      _onlineEventStreamSubscription = onlineEvent.stream.listen((event) {
        _listen();
      });
    }

    geosphereEvents.listeners.add((action, args) {
      if (!mounted) {
        return;
      }
      switch (action) {
        case 'addReceptor':
          _receptorStreamController.add(<GeoReceptor>[args]);
          break;
        case 'removeReceptor':
          _receptorStreamController.add({'action': action, 'args': args});
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.context.ports.portTask.unlistener('/geosphere/doc/file.download');
    widget.context.unlistenMessage(matchPath: '/geosphere/receptor');
    _refreshController.dispose();
    // geoLocation.stop();
    _receptorStreamController.close();
    geosphereEvents.listeners.clear();
    _onlineEventStreamSubscription?.cancel();
    super.dispose();
  }

  void _listen() {
    if (!widget.context.isListeningMessage(matchPath: '/geosphere/receptor')) {
      widget.context.listenMessage(
        (frame) async {
          switch (frame.command) {
            case 'pushDocument':
              await _lock.synchronized(() async {
                await _arrivedPushDocumentCommand(frame);
                if (mounted) {
                  setState(() {});
                }
              });
              break;
            case 'likeDocument':
              await _lock.synchronized(() async {
                await _arrivedLikeDocumentCommand(frame);
                if (mounted) {
                  setState(() {});
                }
              });
              break;
            case 'unlikeDocument':
              await _lock.synchronized(() async {
                await _arrivedUnlikeDocumentCommand(frame);
                if (mounted) {
                  setState(() {});
                }
              });
              break;
            case 'commentDocument':
              await _lock.synchronized(() async {
                await _arrivedCommentDocumentCommand(frame);
                if (mounted) {
                  setState(() {});
                }
              });
              break;
            case 'uncommentDocument':
              await _lock.synchronized(() async {
                await _arrivedUncommentDocumentCommand(frame);
                if (mounted) {
                  setState(() {});
                }
              });
              break;
            case 'mediaDocument':
              await _lock.synchronized(() async {
                await _arrivedMediaDocumentCommand(frame);
                if (mounted) {
                  setState(() {});
                }
              });
              break;
          }
        },
        matchPath: '/geosphere/receptor',
      );
    }
  }

  Future<SyncArgs> _sync_check(PageContext context) async {
    var portsurl =
        context.site.getService('@.prop.ports.document.geo.receptor');
    return SyncArgs(
      portsUrl: portsurl,
      restCmd: 'getAllMyReceptor',
    );
  }

  Future<void> _sync_task(PageContext context, Frame frame) async {
    if (mounted) {
      setState(() {
        _isSyning = true;
      });
    }
    IGeoReceptorRemote receptorRemote =
        context.site.getService('/remote/geo/receptors');
    bool issync = await receptorRemote.syncTaskRemote(frame);
    _checkMobileReceptor();
    if (!issync) {
      if (mounted) {
        setState(() {
          _isSyning = false;
        });
      }
      return;
    }
    _offset = 0;
    _receptorStreamController.add('refresh');
    _isSyning = false;
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await _loadReceptors();
      });
    }
  }

  Future<void> _listenMeidaFileDownload() async {
    ProgressTaskBar progressTaskBar =
        widget.context.site.getService('@.prop.taskbar.progress');
    widget.context.ports.portTask.listener('/geosphere/doc/file.download',
        (Frame frame) async {
      switch (frame.head('sub-command')) {
        case 'begin':
          break;
        case 'receiveProgress':
          var count = frame.head('count');
          var total = frame.head('total');
          progressTaskBar.update(int.parse(count) * 1.0 / int.parse(total));
          break;
        case 'done':
          var mediaid = frame.parameter('id');
          var docid = frame.parameter('docid');
          var type = frame.parameter('type');
          var src = frame.parameter('src');
          var leading = frame.parameter('leading');
          var text = frame.parameter('text');
          var receptor = frame.parameter('receptor');
          var category = frame.parameter('category');
          var localFile = frame.parameter('localFile');

          IGeosphereMessageService messageService =
              widget.context.site.getService('/geosphere/receptor/messages');
          var exists = await messageService.getMessage(receptor, docid);
          if (exists == null) {
            print('消息不存在，被丢弃。');
            return null;
          }

          IGeosphereMediaService mediaService = widget.context.site
              .getService('/geosphere/receptor/messages/medias');

          var creator = frame.parameter('creator');
          // IPersonService personService =
          //     widget.context.site.getService('/gbera/persons');
          // var mediaPerson =
          //     await personService.getPerson(creator, isDownloadAvatar: true);

          var media = GeosphereMediaOL(
            mediaid,
            type,
            localFile,
            leading,
            docid,
            text,
            receptor,
            widget.context.principal.person,
          );
          await mediaService.addMedia(media, isOnlySaveLocal: true);

          //通知当前工作的管道有新消息到
          //网流的管道列表中的每个管道的显示消息提醒的状态栏
          receptorNotifyStreamController.add({
            'command': 'mediaDocumentCommand',
            'sender': creator,
            'receptor': receptor,
            'category': category,
            'media': media,
            'message': exists,
          });
          break;
        default:
          print(frame);
          break;
      }
    });
  }

  Future<void> _arrivedMediaDocumentCommand(frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);

    var receptor = docMap['receptor'];
    var category = docMap['category'];
    var docid = docMap['docid'];
    var sender = frame.head('sender-person');

    if (sender == widget.context.principal.person) {
      print('自已的点赞操作又发给自己，被丢弃。');
      return null;
    }

    await _cachePerson(sender);

    var toReceptors = jsonDecode(frame.head('to-receptors'));
    for (String receptor in toReceptors) {
      var home = await getApplicationDocumentsDirectory();
      var dir = '${home.path}/images';
      var dirFile = Directory(dir);
      if (!dirFile.existsSync()) {
        dirFile.createSync();
      }
      var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(docMap['src'])}';
      var localFile = '$dir/$fn';

      IRemotePorts remotePorts =
          widget.context.site.getService('@.remote.ports');
      remotePorts.portTask.addDownloadTask(
        '${docMap['src']}?accessToken=${widget.context.principal.accessToken}',
        localFile,
        callbackUrl:
            '/geosphere/doc/file.download?creator=$sender&localFile=$localFile&id=${docMap['id']}&type=${docMap['type']}&src=${docMap['src']}&leading=${docMap['leading']}&docid=${docMap['docid']}&text=${docMap['text']}&receptor=${receptor}&category=$category',
      );
    }
    return null;
  }

  Future<GeosphereMessageOL> _arrivedLikeDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);

    var receptor = frame.parameter('receptor');
    var category = frame.parameter('category');
    var docid = frame.parameter('docid');
    var sender = frame.head('sender-person');

    if (sender == widget.context.principal.person) {
      print('自已的点赞操作又发给自己，被丢弃。');
      return null;
    }

    await _cachePerson(sender);

    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var toReceptors = jsonDecode(frame.head('to-receptors'));
    for (String receptor in toReceptors) {
      var exists = await messageService.getMessage(receptor, docid);
      if (exists == null) {
        print('消息不存在，被丢弃。');
        return null;
      }

      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
      var sendPerson = await personService.getPerson(sender);
      var like = GeosphereLikePersonOL(
          MD5Util.MD5(Uuid().v1()),
          sender,
          sendPerson.avatar,
          docid,
          DateTime.now().millisecondsSinceEpoch,
          sendPerson.nickName,
          receptor,
          widget.context.principal.person);
      await messageService.like(like, isOnlySaveLocal: true);

      //通知当前工作的管道有新消息到
      //网流的管道列表中的每个管道的显示消息提醒的状态栏
      receptorNotifyStreamController.add({
        'command': 'likeDocumentCommand',
        'sender': frame.head('sender-person'),
        'receptor': receptor,
        'category': category,
        'like': like,
        'message': exists,
      });
    }

    return null;
  }

  Future<GeosphereMessageOL> _arrivedUnlikeDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);

    var receptor = frame.parameter('receptor');
    var category = frame.parameter('category');
    var docid = frame.parameter('docid');
    var sender = frame.head('sender-person');

    if (sender == widget.context.principal.person) {
      print('自已的取消赞操作又发给自己，被丢弃。');
      return null;
    }

    await _cachePerson(sender);

    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');

    var toReceptors = jsonDecode(frame.head('to-receptors'));
    for (String receptor in toReceptors) {
      var exists = await messageService.getMessage(receptor, docid);
      if (exists == null) {
        print('消息不存在，被丢弃。');
        return null;
      }

      await messageService.unlike(receptor, docid, sender,
          isOnlySaveLocal: true);

      //通知当前工作的管道有新消息到
      //网流的管道列表中的每个管道的显示消息提醒的状态栏
      receptorNotifyStreamController.add({
        'command': 'unlikeDocumentCommand',
        'sender': frame.head('sender-person'),
        'receptor': receptor,
        'category': category,
        'message': exists,
      });
    }
    return null;
  }

  Future<GeosphereMessageOL> _arrivedCommentDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);

    var receptor = frame.parameter('receptor');
    var category = frame.parameter('category');
    var docid = frame.parameter('docid');
    var commentid = frame.parameter('commentid');
    var comments = docMap['comments'];
    var sender = frame.head('sender-person');
    var toPerson = frame.head('to-person');

    if (sender == toPerson) {
      print('自已的评论操作又发给自己，被丢弃。');
      return null;
    }

    await _cachePerson(sender);

    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var toReceptors = jsonDecode(frame.head('to-receptors'));
    for (String receptor in toReceptors) {
      var exists = await messageService.getMessage(receptor, docid);
      if (exists == null) {
        print('消息不存在，被丢弃。');
        return null;
      }

      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
      var sendPerson = await personService.getPerson(sender);
      var comment = GeosphereCommentOL(
          commentid,
          sender,
          sendPerson.avatar,
          docid,
          comments,
          DateTime.now().millisecondsSinceEpoch,
          sendPerson.nickName,
          receptor,
          widget.context.principal.person);
      await messageService.addComment(comment, isOnlySaveLocal: true);

      //通知当前工作的管道有新消息到
      //网流的管道列表中的每个管道的显示消息提醒的状态栏
      receptorNotifyStreamController.add({
        'command': 'commentDocumentCommand',
        'sender': frame.head('sender-person'),
        'receptor': receptor,
        'category': category,
        'commentid': commentid,
        'comment': comment,
        'message': exists,
      });
    }

    return null;
  }

  Future<GeosphereMessageOL> _arrivedUncommentDocumentCommand(
      Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);

    var receptor = frame.parameter('receptor');
    var category = frame.parameter('category');
    var docid = frame.parameter('docid');
    var sender = frame.head('sender-person');
    var commentid = frame.parameter('commentid');

    if (sender == widget.context.principal.person) {
      print('自已的取消评论操作又发给自己，被丢弃。');
      return null;
    }

    await _cachePerson(sender);

    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    var toReceptors = jsonDecode(frame.head('to-receptors'));
    for (String receptor in toReceptors) {
      var exists = await messageService.getMessage(receptor, docid);
      if (exists == null) {
        print('消息不存在，被丢弃。');
        return null;
      }

      await messageService.removeComment(receptor, docid, commentid,
          isOnlySaveLocal: true);

      //通知当前工作的管道有新消息到
      //网流的管道列表中的每个管道的显示消息提醒的状态栏
      receptorNotifyStreamController.add({
        'command': 'uncommentDocumentCommand',
        'sender': sender,
        'receptor': receptor,
        'category': category,
        'commentid': commentid,
        'message': exists,
      });
    }
    return null;
  }

  Future<GeosphereMessageOL> _arrivedPushDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var toPerson = frame.head('to-person');
    if (frame.head('sender-person') == toPerson) {
      print('自已的消息又发给自己，被丢弃。');
      return null;
    }

    var docMap = jsonDecode(text);
    var message =
        GeosphereMessageOL.from(docMap, widget.context.principal.person);
    message.state = 'arrived';
    message.atime = DateTime.now().millisecondsSinceEpoch;
    message.upstreamPerson = frame.head('sender-person');

    if (message.creator == message.upstreamPerson) {
      await _cachePerson(message.creator);
    } else {
      await _cachePerson(message.creator);
      await _cachePerson(message.upstreamPerson);
    }

    IGeosphereMessageService messageService =
        widget.context.site.getService('/geosphere/receptor/messages');
//    var exists = await messageService.getMessage(message.receptor, message.id);
//    if (exists != null) {
//      print('存在消息，被丢弃。');
//      return null;
//    }
    //如果是cache则出现在感知器列表，这与关注冲突
    var upstreamReceptor = await _cacheReceptor(message.receptor);

    message.upstreamReceptor = upstreamReceptor?.id;
    message.upstreamCategory = upstreamReceptor?.category;

    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var toReceptors = jsonDecode(frame.head('to-receptors'));
    for (String receptorid in toReceptors) {
      var receptor = await receptorService.get(receptorid);
      if (receptor == null) {
        // var exists = await receptorService.get(receptorid);
        print('不存在感知器:$receptorid');
        continue;
      }
      message.receptor = receptor.id;
      message.category = upstreamReceptor.category;

      await receptorService.updateUtime(receptor.id);
      await messageService.addMessage(message, isOnlySaveLocal: true);
      await messageService.loadMessageExtraTask(
          message.creator, message.id, message.receptor);

      //通知当前工作的管道有新消息到
      //网流的管道列表中的每个管道的显示消息提醒的状态栏
      receptorNotifyStreamController.add({
        'command': 'pushDocumentCommand',
        'sender': frame.head('sender-person'),
        'receptor': message.receptor,
        'category': message.category,
        'message': message,
      });
    }

    return message;
  }

  Future<GeoReceptor> _cacheReceptor(receptor) async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var obj = await receptorService.get(receptor);
    if (obj == null) {
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      obj = await receptorRemote.getReceptor(receptor);
      if (obj != null) {
        IGeoReceptorCache receptorCache =
            widget.context.site.getService('/cache/geosphere/receptor');
        await receptorCache.add(obj);
      }
    }
    return obj;
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

  Future<void> _load() async {
    await _onload();
    if (_offset < 1) {
      syncTaskMananger.tasks['geoshpere'] = SyncTask(
        doTask: _sync_task,
      )..run(
          syncName: 'geoshpere',
          context: widget.context,
          checkRemote: _sync_check,
//      forceSync: true,
        );
    }
  }

  Future<void> _onload() async {
    await _loadReceptors();
  }

  Future<void> _checkMobileReceptor() async {
    if (_offset > 0 || !mounted) {
      return;
    }
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    bool isInited = false;
    geoLocation.listen('checkMobileReceptor', 0, (location) async {
      await _lock.synchronized(() async {
        if (!isInited) {
          isInited = true;
          if (await receptorService.init(location)) {
            _offset = 0;
            _receptorStreamController.add('refresh');
            _loadReceptors().then((v) {
              if (mounted) {
                setState(() {});
              }
            });
          }
        }
      });
      geoLocation.unlisten('checkMobileReceptor');
    });
  }

  Future<void> _loadReceptors() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');

    var receptors = await receptorService.page(_limit, _offset);
    if (receptors.isEmpty) {
      _refreshController.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += receptors.length;
    _receptorStreamController.add(receptors);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    use_wallpapper = widget.context.parameters['use_wallpapper'];
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          context: context,
          child: AppBar(
            title: Text('地圈'),
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            toolbarOpacity: 1,
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
                        _receptorStreamController.add('refresh');
                        _loadReceptors().then((v) {
                          setState(() {});
                        });
                      });
                      break;
                    case '/geosphere/recycleBin':
                      widget.context
                          .forward(
                        value,
                      )
                          .then((result) {
                        _offset = 0;
                        _receptorStreamController.add('refresh');
                        _loadReceptors().then((v) {
                          setState(() {});
                        });
                      });
                      break;
                    // case '/netflow/manager/scan_receptor':
                    //   break;
                    // case '/netflow/manager/search_receptor':
                    //   break;
                    case '/netflow/manager/my_persons':
                      widget.context.forward('/contacts/person/public',
                          arguments: {'personViewer': 'chasechain'});
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
                    value: '/netflow/manager/my_persons',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            Icons.group,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '我的公众',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '/geosphere/recycleBin',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            FontAwesomeIcons.recycle,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '回收站',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  /*
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

                   */
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: EasyRefresh.custom(
            header: MaterialHeader(),
            footer: MaterialFooter(),
            controller: _refreshController,
            onLoad: _onload,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _GeoDistrict(
                  context: widget.context,
                  onTapFountain: () {
                    widget.context.forward('/geosphere/fountain');
                  },
                  onTapYuanbao: () {
                    widget.context.forward('/geosphere/yuanbao');
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: _renderReceptors(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderReceptors() {
    if (_isSyning) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    '正在从云端你的感知器，请稍候...',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return _GeoReceptors(
      context: widget.context,
      stream: _receptorStreamController.stream,
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
              return widget.context.part('/geosphere/settings.lord', context);
            }).then((v) {
          print('----$v');
        });
      },
    );
  }
}

///当前行政区划
class _GeoDistrict extends StatefulWidget {
  PageContext context;
  Function() onTapFountain;
  Function() onTapYuanbao;

  _GeoDistrict({this.context, this.onTapYuanbao, this.onTapFountain});

  @override
  _GeoDistrictState createState() => _GeoDistrictState();
}

class _GeoDistrictState extends State<_GeoDistrict> {
  String _locationLabel;
  List<GeoPOI> _receptors = [];
  LatLng _location;
  bool _isSearching = false;
  ScrollController _controller;
  int _updateBeginTime = 0;

  @override
  void initState() {
    _controller = ScrollController(initialScrollOffset: 0);
    _initDistrictLocation();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    geoLocation.unlisten('district');
    super.dispose();
  }

  Future<void> _initDistrictLocation() async {
    geoLocation.listen('district', 0, (location) async {
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      if (_updateBeginTime != 0 && nowTime - _updateBeginTime <= 3000) {
        //如果小于等于3秒则不更新位置
        return;
      }
      _updateBeginTime = nowTime;
      //当坐标偏移一定距离时更新行政区信息
      var city =  location.city;
      var district =  location.district;
      if (StringUtil.isEmpty(district)) {
        return;
      }
      geoLocation.setOffsetDistance('district', 100); //将0米更新修改为多少米更新一次
      if (StringUtil.isEmpty(_locationLabel)) {
        _locationLabel = '$city·$district';
        if (mounted) {
          setState(() {});
        }
      }
      _location = location.latLng;

      _receptors.clear();
      await _searchAroundLocation();
      WidgetsBinding.instance.addPostFrameCallback((d) {
        if (mounted) {
          setState(() {
            _controller.jumpTo(_controller.position.maxScrollExtent);
          });
        }
      });
    });
  }

  Future<void> _searchAroundLocation() async {
    if (_isSearching) {
      return;
    }
    _isSearching = true;
    if (mounted) {
      setState(() {});
    }
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    var items = await receptorRemote.searchAroundLocation(
        _location, 2000, null, 20 /*各类取2个*/, 0);
    for (var poi in items) {
      if (poi.creator == null ||
          poi.receptor.creator == widget.context.principal.person) {
        continue;
      }
      _receptors.add(poi);
    }
    _isSearching = false;
    if (mounted) {
      setState(() {});
    }
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
          /*
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
           */
          Container(
//            color: Colors.white54,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: StringUtil.isEmpty(_locationLabel) || _isSearching
                      ? null
                      : () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return widget.context.part(
                                    '/geosphere/region', context,
                                    arguments: {'location': _location});
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
                      top: 5,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.all_out,
                              size: 25,
                              color: Colors.grey[800],
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              '发现',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: ListView(
                              controller: _controller,
                              padding: EdgeInsets.all(0),
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              children: _rendReceptors(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        StringUtil.isEmpty(_locationLabel) || _isSearching
                            ? SizedBox(
                                width: 0,
                                height: 0,
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                      ],
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

  List<Widget> _rendReceptors() {
    var items = <Widget>[];
    if (StringUtil.isEmpty(_locationLabel)) {
      items.add(
        Center(
          child: Text(
            '等待定位...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
      return items;
    }
    if (_isSearching) {
      items.add(
        Center(
          child: Text(
            '搜索中...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
      return items;
    }
    List<GeoPOI> receptors = _receptors.reversed.toList();
    for (var i = 0; i < receptors.length; i++) {
      var receptor = receptors[i];
      var img;
      if (StringUtil.isEmpty(receptor.receptor.leading)) {
        img = Image.asset('lib/portals/gbera/images/netflow.png');
      } else {
        img = FadeInImage.assetNetwork(
          placeholder: 'lib/portals/gbera/images/default_watting.gif',
          image:
              '${receptor.receptor.leading}?accessToken=${widget.context.principal.accessToken}',
        );
      }
      items.add(
        Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  child: img,
                ),
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    '${receptor.receptor.title}',
                    style: TextStyle(
                      fontSize: 8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '${getFriendlyDistance(receptor.distance)}',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      if (i < receptors.length - 1) {
        items.add(
          SizedBox(
            width: 10,
          ),
        );
      }
    }
    return items;
  }
}

class _GeoReceptors extends StatefulWidget {
  PageContext context;
  Stream stream;
  Function() onTapFilter;
  Function() onTapGeoCircle;
  Function(Object args) onTapMarchant;

  _GeoReceptors({
    this.context,
    this.stream,
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
  Map<String, GeoCategoryOL> _cacheCategories = {};
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    geoLocation.listen('receptors', 10, _updateLocation);

    _streamSubscription = widget.stream.listen((receptors) async {
      if (receptors is String && receptors == 'refresh') {
        _receptors.clear();
        if (mounted) {
          setState(() {});
        }
        return;
      }
      if (receptors is Map) {
        if (receptors['action'] == 'removeReceptor') {
          var the = receptors['args'] as GeoReceptor;
          bool isDel = false;
          for (var i = 0; i < _receptors.length; i++) {
            var receptor = _receptors[i];
            if (receptor == null) {
              continue;
            }
            if (receptor.id == the.id) {
              isDel = true;
              _receptors.removeAt(i);
              break;
            }
          }
          if (isDel && mounted) {
            setState(() {});
          }
        }
        return;
      }
      _receptors.addAll(receptors);
      await _sortReceptors();
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('receptors');
    _streamSubscription?.cancel();
    _receptors.clear();
    super.dispose();
  }

  Future<void> _sortReceptors() async {
    if (_currentLatLng == null) {
      return;
    }
    _receptors.sort((a, b) {
      var aLocation = LatLng.fromJson(jsonDecode(a.location));
      var bLocation = LatLng.fromJson(jsonDecode(b.location));
      var aDistance = getDistance(start: _currentLatLng, end: aLocation);
      var bDistance = getDistance(start: _currentLatLng, end: bLocation);
      return aDistance > bDistance
          ? 1
          : aDistance == bDistance
              ? 0
              : -1;
    });
  }

  Future<void> _updateLocation(location) async {
    bool isFirstSort = false;
    if (_currentLatLng == null) {
      isFirstSort = true;
    }
    _currentLatLng = await location.latLng;
    if (isFirstSort) {
      await _sortReceptors();
      isFirstSort = false;
    }
    if (mounted) {
      setState(() {});
    }
    _receptors.forEach((receptor) async {
      IGeoCategoryLocal categoryLocal =
          widget.context.site.getService('/geosphere/categories');
      var category = _cacheCategories[receptor.category];
      if (category == null) {
        category = await categoryLocal.get(receptor.category);
        if (category != null) {
          _cacheCategories[receptor.category] = category;
        }
      }

      if (category?.moveMode == 'unmoveable') {
        return;
      }

      var center = receptor.getLocationLatLng();
      var uDistance = receptor.uDistance ?? 5;
      var distance = getDistance(start: _currentLatLng, end: center);
      if (distance == double.nan) {
        return;
      }
//      print('----${category?.moveMode} ${getDistance(start: _currentLatLng, end: center)} $uDistance');
      if (distance >= uDistance &&
          receptor.creator == widget.context.principal.person) {
//        print('-更新位置---');
        try {
          await _updateReceptorCenter(category.id, receptor.id, _currentLatLng);
          receptor.location = jsonEncode(_currentLatLng.toJson());
//          print('-更新完毕---');
        } catch (e) {
          throw FlutterError('更新感知器位置失败');
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
    if (!isFirstSort) {
      await _sortReceptors();
    }
    if (mounted) setState(() {});
  }

  Future<void> _updateReceptorCenter(category, id, location) async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    await receptorService.updateLocation(id, location);
  }

  Future<void> _deleteReceptor(GeoReceptor receptor) async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    if (receptor.creator != widget.context.principal.person) {
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      try {
        await receptorRemote.unfollow(receptor.id);
      } catch (e) {
        print(e);
      }
    }
    bool isDel = false;
    await receptorService.remove(receptor.id);
    for (var i = 0; i < _receptors.length; i++) {
      if (_receptors[i].id == receptor.id) {
        _receptors.removeAt(i);
        isDel = true;
        break;
      }
    }
    if (isDel) {
      if (mounted) {
        setState(() {});
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
          _renderReceptor(),
        ],
      ),
    );
  }

  Widget _renderReceptor() {
    return ListView(
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
            _deleteReceptor(receptor);
          },
          receptor: ReceptorInfo(
            title: receptor.title,
            id: receptor.id,
            leading: receptor.leading,
            creator: receptor.creator,
            isMobileReceptor: receptor.category == 'mobiles',
            offset: offset,
            category: receptor.category,
            radius: receptor.radius,
            isAutoScrollMessage:
                receptor.isAutoScrollMessage == 'true' ? true : false,
            latLng: LatLng.fromJson(jsonDecode(receptor.location)),
            uDistance: receptor.uDistance,
            background: receptor.background,
            backgroundMode: backgroundMode,
            foregroundMode: foregroundMode,
            origin: receptor,
          ),
        );
      }).toList(),
    );
  }
//
// Widget _renderEmptyPanel() {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     mainAxisSize: MainAxisSize.max,
//     children: [
//       SizedBox(
//         height: 40,
//       ),
//       Text.rich(
//         TextSpan(
//           text: '没有感知器，请',
//           children: [
//             TextSpan(
//               text: '新建地理感知器',
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   widget.context
//                       .forward(
//                     '/geosphere/category/select',
//                   )
//                       .then((result) {
//                     _offset = 0;
//                     _receptors.clear();
//                     _loadReceptors();
//                   });
//                 },
//               style: TextStyle(
//                 color: Colors.blueGrey,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ],
//         ),
//         style: TextStyle(
//           color: Colors.blueGrey,
//           decoration: TextDecoration.underline,
//         ),
//       ),
//     ],
//   );
// }

}

class _ReceptorItem extends StatefulWidget {
  PageContext context;
  ReceptorInfo receptor;
  Function() onDelete;

  _ReceptorItem({
    this.context,
    this.receptor,
    this.onDelete,
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
    _streamSubscription =
        receptorNotifyStreamController.stream.listen((cmd) async {
      if (cmd['receptor'] != widget.receptor.id) {
        return;
      }
      switch (cmd['command']) {
        case 'pushDocumentCommand':
          _loadUnreadMessage().then((v) {
            setState(() {});
          });
          break;
        case 'likeDocumentCommand':
          var sender = cmd['sender'];
          var person = await personService.getPerson(sender);
          GeosphereMessageOL message = cmd['message'];
          _stateBar.count = 1;
          _stateBar.atime = message.atime;
          _stateBar.isShow = true;
          _stateBar.brackets = '赞';
          _stateBar.tips = '${person.nickName}赞对:${message.text}';
          setState(() {});
          break;
        case 'unlikeDocumentCommand':
          var sender = cmd['sender'];
          var person = await personService.getPerson(sender);
          GeosphereMessageOL message = cmd['message'];
          _stateBar.count = 1;
          _stateBar.atime = message.atime;
          _stateBar.isShow = true;
          _stateBar.brackets = '取消点赞';
          _stateBar.tips = '${person.nickName}取消点赞对:${message.text}';
          setState(() {});
          break;
        case 'commentDocumentCommand':
          var sender = cmd['sender'];
          var person = await personService.getPerson(sender);
          GeosphereMessageOL message = cmd['message'];
          GeosphereCommentOL comment = cmd['comment'];
          _stateBar.count = 1;
          _stateBar.atime = comment.ctime;
          _stateBar.isShow = true;
          _stateBar.brackets = '评论';
          _stateBar.tips = '${person.nickName}说:${comment.text}';
          setState(() {});
          break;
        case 'uncommentDocumentCommand':
          var sender = cmd['sender'];
          var person = await personService.getPerson(sender);
          GeosphereMessageOL message = cmd['message'];
          _stateBar.count = 1;
          _stateBar.atime = message.atime;
          _stateBar.isShow = true;
          _stateBar.brackets = '取消评论';
          _stateBar.tips = '${person.nickName}取消了对:${message.text}';
          setState(() {});
          break;
        case 'mediaDocumentCommand':
          var sender = cmd['sender'];
          var person = await personService.getPerson(sender);
          GeosphereMessageOL message = cmd['message'];
          _stateBar.count = 1;
          _stateBar.atime = message.atime;
          _stateBar.isShow = true;
          _stateBar.brackets = '图';
          _stateBar.tips = '${person.nickName}发图对:${message.text}';
          setState(() {});
          break;
      }
    });
    _loadUnreadMessage().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ReceptorItem oldWidget) {
//    if (oldWidget.receptor.leading != widget.receptor.leading) {
//      oldWidget.receptor.leading = widget.receptor.leading;
//    }
    if (oldWidget.receptor.id != widget.receptor.id) {
      oldWidget.receptor = widget.receptor;
      _stateBar = _ReceptorItemStateBar(isShow: false);
      _loadUnreadMessage().then((v) {
        if (mounted) {
          setState(() {});
        }
      });
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
        receptor.id, receptor.leading, remotePath);
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
      imgSrc = FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image:
            '${widget.receptor.leading}?accessToken=${widget.context.principal.accessToken}',
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
                      widget.context.forward(
                        '/widgets/avatar',
                        arguments: {'file': widget.receptor.leading},
                      ).then((path) {
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
                          top: -6,
                          left: -5,
                          child: (widget.receptor.creator !=
                                  widget.context.principal.person)
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  height: 16,
                                  width: 16,
                                  child: Icon(
                                    Icons.connect_without_contact_sharp,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                )
                              : SizedBox(
                                  width: 0,
                                  height: 0,
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
                                  position: BadgePosition.topEnd(
                                    end: -3,
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
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: widget.receptor.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                children: [
                                  widget.receptor.offset == 0
                                      ? TextSpan(text: '')
                                      : TextSpan(
                                          text:
                                              '  ${getFriendlyDistance(widget.receptor.offset)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                ],
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
    var tapItem = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        var url;
        if (widget.receptor.creator == widget.context.principal.person) {
          //每人只能有一个手机行人地圈
          if (widget.receptor.category == 'mobiles') {
            url = '/geosphere/receptor.lord';
          } else {
            url = '/geosphere/receptor.mines';
          }
        } else {
          url = '/geosphere/receptor.fans';
        }
        widget.context.forward(url, arguments: {
          'receptor': widget.receptor,
        }).then((v) {
          _loadUnreadMessage().then((v) {
            if (mounted) {
              setState(() {});
            }
          });
        });
      },
      child: item,
    );
    // if (widget.receptor.origin.canDel == 'false') {
    //   return tapItem;
    // }
    var hasFollowAction=widget.receptor.creator != widget.context.principal.person;
    var action;
    if(hasFollowAction) {
      action=IconSlideAction(
        caption: '不再关注',
        foregroundColor: Colors.grey[500],
        icon: Icons.remove_red_eye,
        onTap: () {
          if (widget.onDelete != null) {
            widget.onDelete();
          }
        },
      );
    }else{
      // if(widget.receptor.category=='mobiles'){
      //   action=SizedBox.shrink();
      // }else{
      //   action=IconSlideAction(
      //     caption: '删除',
      //     foregroundColor: Colors.grey[500],
      //     icon: Icons.delete,
      //     onTap: () {
      //       if (widget.onDelete != null) {
      //         widget.onDelete();
      //       }
      //     },
      //   );
      // }
      action=IconSlideAction(
        caption: '删除',
        foregroundColor: Colors.grey[500],
        icon: Icons.delete,
        onTap: () {
          if (widget.onDelete != null) {
            widget.onDelete();
          }
        },
      );
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
       action,
      ],
      child: tapItem,
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
