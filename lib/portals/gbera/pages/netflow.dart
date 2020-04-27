import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/phoenix_footer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/gbera/store/sync_tasks.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/cache/person_cache.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:uuid/uuid.dart';

import '../../../main.dart';

class WorkingChannel {
  Function(String command, dynamic args) onRefreshChannelState;
}

class _ChannelStateBar {
  var channelid;
  IChannelMessageService channelMessageService;
  Function(String command, dynamic args) refresh;
  String brackets; //括号
  String tips; //提示栏
  int atime; //时间
  int count = 0; //消息数提示，0表示无提示
  bool isShow = false; //是否显示提供

  _ChannelStateBar({this.channelid, this.channelMessageService});

  Future<void> update(String command, dynamic args) async {
    switch (command) {
      case 'pushDocumentCommand':
      case 'loadChannelsCommand':
        var digest =
            await channelMessageService.getChannelMessageDigest(channelid);
        if (digest != null) {
          brackets = '[${digest.count}条]';
          tips = digest.text;
          atime = digest.atime;
          count = digest.count;
          isShow = true;
        }
        break;
      case 'likeDocumentCommand':
        ChannelMessage message = args['message'];
        LikePerson likePerson = args['like'];
        Person liker = args['liker'];
        brackets = '[赞]';
        atime = likePerson.ctime;
        tips = '${liker.nickName}:${message.text}';
        isShow = true;
        break;
      case 'unlikeDocumentCommand':
        ChannelMessage message = args['message'];
        Person unliker = args['unliker'];
        brackets = '[撤消赞]';
        atime = DateTime.now().millisecondsSinceEpoch;
        tips = '${unliker.nickName}:${message.text}';
        isShow = true;
        break;
      case 'commentDocumentCommand':
        ChannelComment comment = args['comment'];
        Person commenter = args['commenter'];
        brackets = '[评论]';
        atime = comment.ctime;
        tips = '${commenter.nickName}:${comment.text}';
        isShow = true;
        break;
      case 'uncommentDocumentCommand':
        ChannelMessage message = args['message'];
        Person uncommenter = args['uncommenter'];
        brackets = '[撤消评论]';
        atime = DateTime.now().millisecondsSinceEpoch;
        tips = '${uncommenter.nickName}:${message.text}';
        isShow = true;
        break;
      case 'mediaDocumentCommand':
        ChannelMessage message = args['message'];
        Person mediaer = args['mediaer'];
        Media media = args['media'];
        switch (media.type) {
          case 'image':
            brackets = '[图]';
            break;
          case 'video':
            brackets = '[视频]';
            break;
          case 'audio':
            brackets = '[语音]';
            break;
          default:
            brackets = '[文件]';
            break;
        }
        atime = DateTime.now().millisecondsSinceEpoch;
        tips = '${mediaer.nickName}:${message.text}';
        isShow = true;
        break;
      default:
        print('不支持的更新指令:$command');
        break;
    }

    if (refresh != null) {
      refresh(command, args);
    }
  }
}

class Netflow extends StatefulWidget {
  PageContext context;

  Netflow({this.context});

  @override
  _NetflowState createState() => _NetflowState();
}

class _NetflowState extends State<Netflow> with AutomaticKeepAliveClientMixin {
  bool use_wallpapper = false;

  //当前打开的正在工作的管道
  WorkingChannel _workingChannel;

  //管道列表项的消息状态条
  final _channelStateBars = <String, _ChannelStateBar>{};
  EasyRefreshController _controller;
  List<_ChannelItem> _items = [];

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    _workingChannel = WorkingChannel();
    _loadChannels().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    syncTaskMananger.tasks['netflow'] = SyncTask(
      doTask: _sync_task,
    )..run(
        syncName: 'netflow',
        context: widget.context,
        checkRemote: _sync_check,
      );
    super.initState();
  }

  @override
  void dispose() {
    _items.clear();
    _controller.dispose();
    _channelStateBars.clear();
    _workingChannel = null;
    super.dispose();
  }

  Future<SyncArgs> _sync_check(PageContext context) async {
    var portsurl = context.site.getService('@.prop.ports.link.netflow');
    return SyncArgs(
      portsUrl: portsurl,
      restCmd: 'pageChannel',
      parameters: {
        'limit': 10000,
        /*全取出来*/
        'offset': 0,
      },
    );
  }

  Future<void> _sync_task(PageContext context, Frame frame) async {
    var source = frame.contentText;
    List list = jsonDecode(source);
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    IChannelCache channelCache =
        widget.context.site.getService('/cache/channels');

    for (var map in list) {
      var ch = Channel.fromMap(map, context.principal.person);

      bool existsChannel = await channelService.existsChannel(ch.id);
      if (existsChannel) {
        continue;
      }
      //缓冲channel
      await channelCache.cache(ch);
      await channelService.addChannel(ch, isOnlyLocal: true);
      _items.clear();
      await _loadChannels();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadChannels() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    List<Channel> list = await channelService.getAllChannel();
    if (list.isEmpty) {
      await channelService.initSystemChannel(widget.context.principal);
      list = await channelService.getAllChannel();
    }
    for (var ch in list) {
      var statebar = _ChannelStateBar(
        channelid: ch.id,
        channelMessageService: channelMessageService,
      );
      _channelStateBars[ch.id] = (statebar);
      await statebar.update('loadChannelsCommand', null);
      _items.add(
        _ChannelItem(
          context: widget.context,
          channelid: ch.id,
          title: ch.name,
          owner: ch.owner,
          leading: ch.leading,
          stateBar: statebar,
          openChannel: () {
            widget.context.forward(
              '/netflow/channel',
              arguments: {'channel': ch, 'workingChannel': _workingChannel},
            ).then((v) {
              _items.clear();
              _loadChannels().then((v) {
                if (mounted) {
                  setState(() {});
                }
              });
            });
          },
          isSystemChannel: channelService.isSystemChannel(ch.id),
          refreshChannels: (channelid) {
            for (var i = 0; i < _items.length; i++) {
              if (_items[i].channelid == channelid) {
                _items.removeAt(i);
              }
            }
            setState(() {});
          },
        ),
      );
    }
    _controller.finishLoad(success: true, noMore: true);
  }

  @override
  Widget build(BuildContext context) {
    use_wallpapper = widget.context.parameters['use_wallpapper'];

    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          context: context,
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text('网流'),
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
                    case '/netflow/manager/create_channel':
                      widget.context
                          .forward(
                        value,
                      )
                          .then((v) {
                        _items.clear();
                        _loadChannels().then((v) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      });
                      break;
                    case '/netflow/manager/scan_channel':
                      String cameraScanResult = await scanner.scan();
                      if (cameraScanResult == null) break;
                      arguments['qrcode'] = cameraScanResult;
                      widget.context
                          .forward(value, arguments: arguments)
                          .then((v) {
                        _items.clear();
                        _loadChannels().then((v) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      });
                      break;
                    case '/netflow/manager/search_channel':
                      widget.context
                          .forward(value, arguments: arguments)
                          .then((v) {
                        _items.clear();
                        _loadChannels().then((v) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      });
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: '/netflow/manager/create_channel',
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
                          '新建管道',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: '/netflow/manager/scan_channel',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            widget.context
                                .findPage('/netflow/manager/scan_channel')
                                ?.icon,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '扫码以连接',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '/netflow/manager/search_channel',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            widget.context
                                .findPage('/netflow/manager/search_channel')
                                ?.icon,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '搜索以连接',
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
        Expanded(
          child: EasyRefresh.custom(
            controller: _controller,
            onLoad: _loadChannels,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    bottom: 5,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.context.forward('/netflow/manager/settings',
                              arguments: {'title': '公众活动'});
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                widget.context
                                    .findPage(
                                        '/netflow/manager/channel_gateway')
                                    ?.icon,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '公众活动',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return CupertinoActionSheet(
                                  actions: <Widget>[
                                    CupertinoActionSheetAction(
                                      child: const Text.rich(
                                        TextSpan(
                                          text: '全屏',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(text: '\r\n'),
                                            TextSpan(
                                              text: '长按全屏按钮可直接进入全屏',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: () {
                                        widget.context.backward();
                                        widget.context.forward(
                                            '/netflow/publics/activities',
                                            arguments: {'title': '公众活动'});
                                      },
                                    ),
                                    CupertinoActionSheetAction(
                                      child: const Text.rich(
                                        TextSpan(
                                          text: '取消',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(text: '\r\n'),
                                            TextSpan(
                                              text: '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, 'Profiteroles');
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        onLongPress: () {
                          widget.context.forward('/netflow/publics/activities',
                              arguments: {'title': '公众活动'});
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: 15,
                          ),
                          child: Icon(
                            Icons.open_with,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: NotificationListener(
                  onNotification: (e) {
                    if (e is ChannelsRefresher) {
                      _items.clear();
                      _loadChannels().then((v) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    }
                    return true;
                  },
                  child: _InsiteMessagesRegion(
                    context: widget.context,
                    workingChannel: _workingChannel,
                    channelStateBars: _channelStateBars,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    bottom: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '我的管道',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  physics: NeverScrollableScrollPhysics(),
                  children: _items.map((item) {
                    return item;
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsiteMessagesRegion extends StatefulWidget {
  PageContext context;
  WorkingChannel workingChannel;
  Map<String, _ChannelStateBar> channelStateBars;

  _InsiteMessagesRegion(
      {this.context, this.workingChannel, this.channelStateBars});

  @override
  _InsiteMessagesRegionState createState() => _InsiteMessagesRegionState();
}

class _InsiteMessagesRegionState extends State<_InsiteMessagesRegion> {
  var index = 0;
  int _msgListMaxLength = 4;
  Queue<InsiteMessage> _messages = Queue();
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _listenMeidaFileDownload();
    if (!widget.context.isListening(matchPath: '/netflow/channel')) {
      widget.context.listenNetwork((frame) {
        switch (frame.command) {
          case 'pushDocument':
            _arrivedPushDocumentCommand(frame).then((message) {
              if (message == null) {
                return;
              }
              if (message.upstreamPerson == widget.context.principal.person) {
                return;
              }
              if (_messages.length >= _msgListMaxLength) {
                _messages.removeLast();
              }
              _messages.addFirst(message);
              setState(() {});
            });
            break;
          case 'likeDocument':
            _arrivedLikeDocumentCommand(frame);
            break;
          case 'unlikeDocument':
            _arrivedUnlikeDocumentCommand(frame);
            break;
          case 'commentDocument':
            _arrivedCommentDocumentCommand(frame);
            break;
          case 'uncommentDocument':
            _arrivedUncommentDocumentCommand(frame);
            break;
          case 'mediaDocument':
            _arrivedMediaDocumentCommand(frame);
            break;
          default:
            print('收到不支持的命令:${frame.command}');
            break;
        }
      }, matchPath: '/netflow/channel');
    }
    _loadMessages().then((messages) {
      for (var msg in messages) {
        _messages.addFirst(msg);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _unlistenMeidaFileDownload();
    _streamSubscription?.cancel();
    widget.context.unlistenNetwork(matchPath: '/netflow/channel');
    _messages.clear();
    super.dispose();
  }

  Future<void> _arrivedUnlikeDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，已丢弃。');
      return null;
    }
    if (frame.head('sender') == widget.context.principal.person) {
      print('自已发送的动态又发还自己，因此丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);
//    {id: 6dec8d5530d5364ed2815c27cc7c9bfc, creator: cj@gbera.netos, channel: d99bf0e3b662b062d8328b9477e6df16, wy: 10.0, ctime: 1584507865101, content: 好了！好了, medias: []}
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    ChannelMessage message =
        await channelMessageService.getChannelMessage(docMap['id']);
    if (message == null) {
      print('本地不存在消息，已丢弃。');
      return null;
    }
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    await likeService.unlike(
      docMap['id'],
      frame.parameter('unliker'),
      onlySaveLocal: true,
    );
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var unliker = frame.parameter('unliker');
    var unlikerPerson =
        await personService.getPerson(unliker, isDownloadAvatar: true);
    //通知当前工作的管道有新消息到
    if (widget.workingChannel.onRefreshChannelState != null) {
      widget.workingChannel.onRefreshChannelState('unlikeDocumentCommand', {
        'message': message,
        'unliker': unlikerPerson,
      });
    }
    //网流的管道列表中的每个管道的显示消息提醒的状态栏
    if (widget.channelStateBars.containsKey(docMap['channel'])) {
      widget.channelStateBars[docMap['channel']]
          ?.update('unlikeDocumentCommand', {
        'message': message,
        'unliker': unlikerPerson,
      });
    }
  }

  Future<void> _arrivedLikeDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，已丢弃。');
      return null;
    }
    if (frame.head('sender') == widget.context.principal.person) {
      print('自已发送的动态又发还自己，因此丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);
//    {id: 6dec8d5530d5364ed2815c27cc7c9bfc, creator: cj@gbera.netos, channel: d99bf0e3b662b062d8328b9477e6df16, wy: 10.0, ctime: 1584507865101, content: 好了！好了, medias: []}
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    ChannelMessage message =
        await channelMessageService.getChannelMessage(docMap['id']);
    if (message == null) {
      print('本地不存在消息，已丢弃。');
      return null;
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    var liker = frame.parameter('liker');
    var likerPerson =
        await personService.getPerson(liker, isDownloadAvatar: true);
    var like = LikePerson(
      Uuid().v1(),
      liker,
      likerPerson.avatar,
      docMap['id'],
      docMap['ctime'],
      likerPerson.nickName,
      docMap['channel'],
      widget.context.principal.person,
    );
    await likeService.like(
      like,
      onlySaveLocal: true,
    );

    //通知当前工作的管道有新消息到
    if (widget.workingChannel.onRefreshChannelState != null) {
      widget.workingChannel.onRefreshChannelState('likeDocumentCommand', {
        'message': message,
        'like': like,
        'liker': likerPerson,
      });
    }
    //网流的管道列表中的每个管道的显示消息提醒的状态栏
    if (widget.channelStateBars.containsKey(docMap['channel'])) {
      widget.channelStateBars[docMap['channel']]
          ?.update('likeDocumentCommand', {
        'message': message,
        'like': like,
        'liker': likerPerson,
      });
    }
  }

  _listenMeidaFileDownload() {
    ProgressTaskBar progressTaskBar =
        widget.context.site.getService('@.prop.taskbar.progress');
    IRemotePorts remotePorts = widget.context.site.getService('@.remote.ports');
    remotePorts.portTask.listener('/channel/doc/file.download',
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
          var channel = frame.parameter('channel');
          var localFile = frame.parameter('localFile');

          IChannelMessageService channelMessageService =
              widget.context.site.getService('/channel/messages');
          ChannelMessage message =
              await channelMessageService.getChannelMessage(docid);
          if (message == null) {
            print('本地不存在消息，已丢弃。');
            return null;
          }

          var creator = frame.parameter('creator');
          IPersonService personService =
              widget.context.site.getService('/gbera/persons');
          IChannelMediaService mediaService =
              widget.context.site.getService('/channel/messages/medias');
          var mediaPerson =
              await personService.getPerson(creator, isDownloadAvatar: true);

          var media = Media(
            mediaid,
            type,
            localFile,
            leading,
            docid,
            text,
            channel,
            widget.context.principal.person,
          );

          await mediaService.addMedia(
            media,
          );

          //通知当前工作的管道有新消息到
          if (widget.workingChannel.onRefreshChannelState != null) {
            widget.workingChannel
                .onRefreshChannelState('mediaDocumentCommand', {
              'message': message,
              'media': media,
              'mediaer': mediaPerson,
            });
          }
          //网流的管道列表中的每个管道的显示消息提醒的状态栏
          if (widget.channelStateBars.containsKey(channel)) {
            widget.channelStateBars[channel]?.update('mediaDocumentCommand', {
              'message': message,
              'media': media,
              'mediaer': mediaPerson,
            });
          }
          break;
        default:
          print(frame);
          break;
      }
    });
  }

  _unlistenMeidaFileDownload() {
    IRemotePorts remotePorts = widget.context.site.getService('@.remote.ports');
    remotePorts.portTask.unlistener('/channel/doc/file.download');
  }

  Future<void> _arrivedMediaDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，已丢弃。');
      return null;
    }
    var map = jsonDecode(text);

    IRemotePorts remotePorts = widget.context.site.getService('@.remote.ports');
    var creator = frame.parameter('creator');

    var home = await getApplicationDocumentsDirectory();
    var dir = '${home.path}/images';
    var dirFile = Directory(dir);
    if (!dirFile.existsSync()) {
      dirFile.createSync();
    }
    var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(map['src'])}';
    var localFile = '$dir/$fn';
    remotePorts.portTask.addDownloadTask(
      '${map['src']}?accessToken=${widget.context.principal.accessToken}',
      localFile,
      callbackUrl:
          '/channel/doc/file.download?creator=$creator&localFile=$localFile&id=${map['id']}&type=${map['type']}&src=${map['src']}&leading=${map['leading']}&docid=${map['docid']}&text=${map['text']}&channel=${map['channel']}',
    );
  }

  Future<void> _arrivedCommentDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，已丢弃。');
      return null;
    }
    if (frame.head('sender') == widget.context.principal.person) {
      print('自已发送的动态又发还自己，因此丢弃。');
      return null;
    }
    var map = jsonDecode(text);
    var docMap = map['doc'];
    var comments = map['comments'];
//    {id: 6dec8d5530d5364ed2815c27cc7c9bfc, creator: cj@gbera.netos, channel: d99bf0e3b662b062d8328b9477e6df16, wy: 10.0, ctime: 1584507865101, content: 好了！好了, medias: []}
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    ChannelMessage message =
        await channelMessageService.getChannelMessage(docMap['id']);
    if (message == null) {
      print('本地不存在消息，已丢弃。');
      return null;
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    var commenter = frame.parameter('commenter');
    var commentid = frame.parameter('commentid');
    var commentPerson =
        await personService.getPerson(commenter, isDownloadAvatar: true);
    var comment = ChannelComment(
      commentid,
      commentPerson.official,
      commentPerson.avatar,
      docMap['id'],
      comments,
      DateTime.now().millisecondsSinceEpoch,
      commentPerson.nickName,
      frame.parameter('channel'),
      widget.context.principal.person,
    );
    await commentService.addComment(
      comment,
      onlySaveLocal: true,
    );

    //通知当前工作的管道有新消息到
    if (widget.workingChannel.onRefreshChannelState != null) {
      widget.workingChannel.onRefreshChannelState('commentDocumentCommand', {
        'message': message,
        'comment': comment,
        'commenter': commentPerson,
      });
    }
    //网流的管道列表中的每个管道的显示消息提醒的状态栏
    if (widget.channelStateBars.containsKey(docMap['channel'])) {
      widget.channelStateBars[docMap['channel']]
          ?.update('commentDocumentCommand', {
        'message': message,
        'comment': comment,
        'commenter': commentPerson,
      });
    }
  }

  Future<void> _arrivedUncommentDocumentCommand(Frame frame) async {
    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，已丢弃。');
      return null;
    }
    if (frame.head('sender') == widget.context.principal.person) {
      print('自已发送的动态又发还自己，因此丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);
//    {id: 6dec8d5530d5364ed2815c27cc7c9bfc, creator: cj@gbera.netos, channel: d99bf0e3b662b062d8328b9477e6df16, wy: 10.0, ctime: 1584507865101, content: 好了！好了, medias: []}
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    ChannelMessage message =
        await channelMessageService.getChannelMessage(docMap['id']);
    if (message == null) {
      print('本地不存在消息，已丢弃。');
      return null;
    }
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    await commentService.removeComment(
      docMap['id'],
      frame.parameter('commentid'),
      onlySaveLocal: true,
    );
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var uncommenter = frame.parameter('uncommenter');
    var uncommentPerson =
        await personService.getPerson(uncommenter, isDownloadAvatar: true);
    //通知当前工作的管道有新消息到
    if (widget.workingChannel.onRefreshChannelState != null) {
      widget.workingChannel.onRefreshChannelState('uncommentDocumentCommand', {
        'message': message,
        'uncommenter': uncommentPerson,
      });
    }
    //网流的管道列表中的每个管道的显示消息提醒的状态栏
    if (widget.channelStateBars.containsKey(docMap['channel'])) {
      widget.channelStateBars[docMap['channel']]
          ?.update('uncommentDocumentCommand', {
        'message': message,
        'uncommenter': uncommentPerson,
      });
    }
  }

  Future<InsiteMessage> _arrivedPushDocumentCommand(Frame frame) async {
    IInsiteMessageService messageService =
        widget.context.site.getService('/insite/messages');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');

    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      print('消息为空，已丢弃。');
      return null;
    }
    var docMap = jsonDecode(text);

    await channelMessageService.setCurrentActivityTask(
      creator: docMap['creator'],
      docid: docMap['id'],
      channel: docMap['channel'],
      attach: '',
      action: 'arrive',
    );

    var existsmsg =
        await messageService.getMessage(docMap['id'], docMap['channel']);
    if (existsmsg != null) {
      print('入站消息已存在，被丢弃。');
      return null;
    }
//    print(docMap);
    var message = InsiteMessage(
      Uuid().v1(),
      docMap['id'],
      frame.head('sender'),
      docMap['channel'],
      null,
      null,
      docMap['creator'],
      docMap['ctime'],
      DateTime.now().millisecondsSinceEpoch,
      docMap['content'],
      docMap['wy'],
      null,
      widget.context.principal.person,
    );

    IPersonService personService =
        widget.context.site.getService('/gbera/persons');

    var person = await personService.getPerson(message.upstreamPerson);
    if (person != null) {
      if (person.rights == 'denyUpstream' || person.rights == 'denyBoth') {
        print('已拒收公号<${person.official}>的所有消息，消息被抛弃:${message.id}');
        return null;
      }
    }

    bool existsChannel =
        await channelService.existsChannel(message.upstreamChannel);

    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');

    if (!existsChannel) {
      //缓冲channel
      var channel = await channelService.fetchChannelOfPerson(
          message.upstreamChannel, message.upstreamPerson);
      if (channel != null) {
        IChannelCache channelCache =
            widget.context.site.getService('/cache/channels');
        await channelCache.cache(channel);
      }
    }

    var iperson = await pinService.getInputPerson(
        message.upstreamPerson, message.upstreamChannel);
    if ('deny' == iperson?.rights) {
      Channel channel = await channelService.getChannel(
        message.upstreamChannel,
      );
      if (channel == null) {
        IChannelCache channelCache =
            widget.context.site.getService('/cache/channels');
        channel = await channelCache.get(message.upstreamChannel);
      }
      print(
          '已拒收公号<${person.official}>的管道<${channel?.name}>消息，消息被抛弃:${message.id}');
      return null;
    }

    bool exitsInputPerson = existsChannel
        ? await pinService.existsInputPerson(
            message.upstreamPerson, message.upstreamChannel)
        : false;

    if (frame.head('sender') != widget.context.principal.person &&
        exitsInputPerson) {
      if (!(await personService.existsPerson(message.upstreamPerson))) {
        var person = await personService.fetchPerson(message.upstreamPerson,
            isDownloadAvatar: true);
        if (person != null) {
          IPersonCache _personCache =
              widget.context.site.getService('/cache/persons');
          await _personCache.cache(person);
        }
      }

      ChannelMessage existsCMSG =
          await channelMessageService.getChannelMessage(message.docid);
      if (existsCMSG != null) {
        print('管道消息已存在，被丢弃。');
        return null;
      }
      ChannelMessage channelMessage = message.copy();
      channelMessage.atime = DateTime.now().millisecondsSinceEpoch;
      channelMessage.state = 'arrived';

      await channelMessageService.addMessage(channelMessage);

      await channelMessageService.loadMessageExtraTask(
          channelMessage.creator, channelMessage.id, channelMessage.onChannel);

      //通知当前工作的管道有新消息到
      if (widget.workingChannel.onRefreshChannelState != null) {
        widget.workingChannel.onRefreshChannelState('pushDocumentCommand',
            {'sender': person, 'message': channelMessage});
      }
      //网流的管道列表中的每个管道的显示消息提醒的状态栏
      if (widget.channelStateBars.containsKey(message.upstreamChannel)) {
        widget.channelStateBars[message.upstreamChannel]?.update(
            'pushDocumentCommand',
            {'sender': person, 'message': channelMessage});
      }
      //返回null是不在打印消息到界面
      return null;
    }

    await messageService.addMessage(message);
    return message;
  }

  Future<List<InsiteMessage>> _loadMessages() async {
    IInsiteMessageService messageService =
        widget.context.site.getService('/insite/messages');
    return await messageService.pageMessage(_msgListMaxLength, 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_messages.isEmpty) {
      return Container(
        height: 40,
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          '无消息',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          margin: EdgeInsets.only(
            bottom: 15,
            left: 10,
            right: 10,
          ),
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              children: _messages.map((message) {
                index++;
                bool notBottom = index < _messages.length;
                if (index >= _messages.length) {
                  index = 0;
                }
                return NotificationListener(
                  onNotification: (e) {
                    if (e is ChannelsRefresher) {
                      _messages.clear();
                      _loadMessages().then((messages) {
                        for (var msg in messages) {
                          _messages.addFirst(msg);
                        }
                        setState(() {});
                      });
                    }
                    return false;
                  },
                  child: _InsiteMessageItem(
                    context: widget.context,
                    message: message,
                    notBottom: notBottom,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsiteMessageItem extends StatefulWidget {
  InsiteMessage message;
  bool notBottom;
  PageContext context;

  _InsiteMessageItem({this.context, this.message, this.notBottom});

  @override
  __InsiteMessageItemState createState() => __InsiteMessageItemState();
}

class __InsiteMessageItemState extends State<_InsiteMessageItem> {
  Channel _channel;
  Person _person;

  @override
  void initState() {
    () async {
      _person = await _loadPerson();
      _channel = await _loadChannel();
      setState(() {});
    }();
    super.initState();
  }

  @override
  void dispose() {
    _channel = null;
    _person = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(_InsiteMessageItem oldWidget) {
    oldWidget.message = widget.message;
    oldWidget.notBottom = widget.notBottom;
    () async {
      _person = await _loadPerson();
      _channel = await _loadChannel();
      if (mounted) {
        setState(() {});
      }
    }();
    super.didUpdateWidget(oldWidget);
  }

  Future<Person> _loadPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(widget.message.upstreamPerson);
  }

  Future<Channel> _loadChannel() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var message = widget.message;
    return await channelService.findChannelOfPerson(
        message.upstreamChannel, widget.message.upstreamPerson);
  }

  @override
  Widget build(BuildContext context) {
    var atime = TimelineUtil.formatByDateTime(
            DateTime.fromMillisecondsSinceEpoch(widget.message.atime),
            locale: 'zh',
            dayFormat: DayFormat.Simple)
        .toString();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return widget.context
                  .part('/site/insite/approvals', context, arguments: {
                'message': widget.message,
                'channel': _channel,
                'person': _person,
              });
            }).then((result) {
          if (result != null && (result['refresh'] ?? false)) {
            ChannelsRefresher().dispatch(context);
          }
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                    text: '${widget.message.digests ?? ''}',
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
              right: 10,
              left: 10,
              top: 6,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${atime ?? ''}'),
                  TextSpan(
                    text: '  洇金:¥',
                    children: [
                      TextSpan(
                        text: (widget.message.wy ?? 0).toStringAsFixed(2),
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextSpan(
                    text: '  来自:',
                  ),
                  TextSpan(
                    text: '${_person != null ? _person.nickName : ''}',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: '  ${_channel == null ? '' : _channel.name}',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
//                v.picCount > 0
//                    ? TextSpan(text: '  图片${v.picCount}个')
//                    : TextSpan(text: ''),
                ],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              ),
            ),
          ),
          widget.notBottom
              ? Container(
                  child: Divider(
                    height: 1,
                  ),
                  padding: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }
}

class ChannelsRefresher extends Notification {}

class _ChannelItem extends StatefulWidget {
  PageContext context;
  String channelid;
  String leading;
  String title;
  String owner;
  var openChannel;
  bool isSystemChannel;
  _ChannelStateBar stateBar;
  Function(String channelid) refreshChannels;

  _ChannelItem({
    this.context,
    this.channelid,
    this.leading,
    this.title,
    this.owner,
    this.openChannel,
    this.isSystemChannel,
    this.refreshChannels,
    this.stateBar,
  });

  @override
  __ChannelItemState createState() => __ChannelItemState();
}

class __ChannelItemState extends State<_ChannelItem> {
  double _percentage = 0.0;

  @override
  void initState() {
    widget.stateBar.refresh = (command, args) {
      setState(() {});
    };
    super.initState();
  }

  void dispose() {
    widget.stateBar.refresh = null;
    super.dispose();
  }

  Future<void> _updateLeading() async {
    if (_percentage > 0) {
      _percentage = 0.0;
      setState(() {});
    }
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var map = await widget.context.ports.upload(
        '/app',
        <String>[
          widget.leading,
        ],
        accessToken: widget.context.principal.accessToken,
        onSendProgress: (i, j) {
      _percentage = ((i * 1.0 / j));
      setState(() {});
    });
    var remotePath = map[widget.leading];
    await channelService.updateLeading(
        widget.leading, remotePath, widget.channelid);
  }

  _deleteChannel(String channelid) async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    await channelService.remove(channelid);
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    await pinService.emptyInputPersons(channelid);
  }

  @override
  Widget build(BuildContext context) {
    Widget imgSrc = null;
    if (StringUtil.isEmpty(widget.leading)) {
      imgSrc = Icon(
        IconData(
          0xe604,
          fontFamily: 'netflow2',
        ),
        size: 32,
        color: Colors.grey[500],
      );
    } else if (widget.leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(widget.leading),
        width: 40,
        height: 40,
      );
    } else {
      imgSrc = FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/netflow.png',
        image:
            '${widget.leading}?accessToken=${widget.context.principal.accessToken}',
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
              crossAxisAlignment: widget.stateBar.isShow
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
                      if (widget.context.principal.person != widget.owner) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('不可修改图标！原因：不是您创建的管道'),
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
                        widget.leading = path;
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
                          child: !widget.stateBar.isShow
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
                                  showBadge: (widget.stateBar.count ?? 0) != 0,
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
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: widget.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      !widget.stateBar.isShow
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
                                      text: widget.stateBar.brackets,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ',
                                        ),
                                        TextSpan(
                                          text: widget.stateBar.tips,
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
                                    widget.stateBar?.atime != null
                                        ? '${TimelineUtil.format(
                                            widget.stateBar?.atime,
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
    if (widget.isSystemChannel) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          Text(
            '不能删除系统管道',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.openChannel,
          child: item,
        ),
      );
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '删除',
          foregroundColor: Colors.grey[500],
          icon: Icons.delete,
          onTap: () async {
            await _deleteChannel(widget.channelid);
            widget.refreshChannels(widget.channelid);
          },
        ),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.openChannel,
        child: item,
      ),
    );
  }
}
