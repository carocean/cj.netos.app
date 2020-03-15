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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/cache/person_cache.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:objectdb/objectdb.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:uuid/uuid.dart';

class WorkingChannel {
  Function() onRefreshChannelState;
}

class _ChannelStateBar {
  var channelid;
  IChannelMessageService channelMessageService;
  ChannelMessageDigest digest;
  Function() refresh;

  _ChannelStateBar({this.channelid, this.channelMessageService});

  Future<void> relead() async {
    digest = await channelMessageService.getChannelMessageDigest(channelid);
    if (refresh != null) {
      refresh();
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

  Future<List<_ChannelItem>> _future_loadChannels;

  //当前打开的正在工作的管道
  WorkingChannel _workingChannel;

  //管道列表项的消息状态条
  final _channelStateBars = <String, _ChannelStateBar>{};

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _workingChannel = WorkingChannel();
    _future_loadChannels = _loadChannels();
    super.initState();
  }

  @override
  void dispose() {
    _channelStateBars.clear();
    _workingChannel = null;
    _future_loadChannels = null;
    super.dispose();
  }

  //调用方：创建管道，修改管道图标
  Future<void> _refreshChannels() async {
    //该方法导致FutureBuilder的重绘
    _future_loadChannels = _loadChannels();
  }

  Future<List<_ChannelItem>> _loadChannels() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    List<Channel> list = await channelService.getAllChannel();
    if (list.isEmpty) {
      await channelService.initSystemChannel(widget.context.principal);
      list = await channelService.getAllChannel();
    }
    var items = List<_ChannelItem>();
    for (var ch in list) {
      var statebar = _ChannelStateBar(
        channelid: ch.id,
        channelMessageService: channelMessageService,
      );
      _channelStateBars[ch.id] = (statebar);
      await statebar.relead();
      items.add(
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
              if (_refreshChannels != null) {
                _refreshChannels();
              }
            });
          },
          isSystemChannel: channelService.isSystemChannel(ch.id),
          refreshChannels: (channelid) {
            for (var i = 0; i < items.length; i++) {
              if (items[i].channelid == channelid) {
                items.removeAt(i);
              }
            }
            setState(() {});
          },
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    use_wallpapper = widget.context.parameters['use_wallpapper'];

    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          floating: false,
          pinned: true,
          delegate: GberaPersistentHeaderDelegate(
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text('网流'),
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
                    case '/netflow/manager/create_channel':
                      widget.context
                          .forward(
                        value,
                      )
                          .then((v) {
                        if (_refreshChannels != null) {
                          _refreshChannels();
                        }
                      });
                      break;
                    case '/netflow/manager/scan_channel':
                      String cameraScanResult = await scanner.scan();
                      if (cameraScanResult == null) break;
                      arguments['qrcode'] = cameraScanResult;
                      widget.context
                          .forward(value, arguments: arguments)
                          .then((v) {
                        if (_refreshChannels != null) {
                          _refreshChannels();
                        }
                      });
                      break;
                    case '/netflow/manager/search_channel':
                      widget.context
                          .forward(value, arguments: arguments)
                          .then((v) {
                        if (_refreshChannels != null) {
                          _refreshChannels();
                        }
                      });
                      break;
                    case '/test/services':
                      widget.context
                          .forward(value, arguments: arguments)
                          .then((v) {
                        if (_refreshChannels != null) {
                          _refreshChannels();
                        }
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
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: '/test/services',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            widget.context.findPage('/test/services')?.icon,
                            color: Colors.grey[500],
                            size: 15,
                          ),
                        ),
                        Text(
                          '测试网流服务',
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
                              .findPage('/netflow/manager/channel_gateway')
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
                _future_loadChannels = _loadChannels();
                setState(() {});
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
          child: FutureBuilder<List<_ChannelItem>>(
            future: _future_loadChannels,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: Container(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('netflow---${snapshot.error}');
                return Container(
                  width: 0,
                  height: 0,
                );
              }
              if (snapshot.data == null) {
                return Container(
                  width: 0,
                  height: 0,
                );
              }
              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data.map((item) {
                  return item;
                }).toList(),
              );
            },
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
    if (!widget.context.isListening(matchPath: '/netflow/channel')) {
      widget.context.listenNetwork((frame) {
        _arrivedMessage(frame).then((message) {
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
    _streamSubscription.cancel();
    widget.context.unlistenNetwork(matchPath: '/netflow/channel');
    _messages.clear();
    super.dispose();
  }

  Future<InsiteMessage> _arrivedMessage(Frame frame) async {
    IInsiteMessageService messageService =
        widget.context.site.getService('/insite/messages');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');

    var text = frame.contentText;
    if (StringUtil.isEmpty(text)) {
      return null;
    }
    var docMap = jsonDecode(text);

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
    bool existsChannel =
        await channelService.existsChannel(message.upstreamChannel);
    if (frame.head('sender') != widget.context.principal.person &&
        existsChannel) {
      if (!(await personService.existsPerson(message.upstreamPerson))) {
        var person = await personService.fetchPerson(message.upstreamPerson,
            isDownloadAvatar: true);
        if (person != null) {
          IPersonCache _personCache =
              widget.context.site.getService('/cache/persons');
          await _personCache.cache(person);
        }
      }

      ChannelMessage channelMessage = message.copy();
      channelMessage.atime = DateTime.now().millisecondsSinceEpoch;
      channelMessage.state = 'arrived';
      IChannelMessageService channelMessageService =
          widget.context.site.getService('/channel/messages');
      await channelMessageService.addMessage(channelMessage);
      if (widget.workingChannel.onRefreshChannelState != null) {
        widget.workingChannel.onRefreshChannelState();
      }
      if (widget.channelStateBars.containsKey(message.upstreamChannel)) {
        widget.channelStateBars[message.upstreamChannel]?.relead();
      }
      //返回null是不在打印消息到界面
      return null;
    }
    IChannelCache channelCache =
        widget.context.site.getService('/cache/channels');
    if (!existsChannel) {
      //缓冲channel
      var channel = await channelService.fetchChannelOfPerson(
          message.upstreamChannel, message.upstreamPerson);
      if (channel != null) {
        await channelCache.cache(channel);
      }
    }
    var person = await personService.getPerson(message.upstreamPerson);
    var channel = await channelCache.get(message.upstreamChannel);
    if (channel != null) {
      if (channel.rights == 'denyInsite') {
        print(
            '已拒收<${person.nickName}>的管道<${channel.name}>的消息，消息被抛弃:${message.id}');
        return null;
      }
    }
    if (person != null) {
      if (person.rights == 'denyUpstream' || person.rights == 'denyBoth') {
        print('已拒收公号<${person.official}>的所有消息，消息被抛弃:${message.id}');
        return null;
      }
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
      setState(() {});
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
    widget.stateBar.refresh = () {
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

  @override
  Widget build(BuildContext context) {
    var digest = widget.stateBar.digest;
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
      imgSrc = Image.network(
        widget.leading,
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
              crossAxisAlignment: digest != null
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
                          child: digest == null
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
                                  showBadge: digest?.count != 0,
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
                      digest == null
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
                                      text:
                                          '[${digest?.count != 0 ? digest?.count : ''}条]',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ',
                                        ),
                                        TextSpan(
                                          text: '${digest?.text}',
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
                                    '${TimelineUtil.format(
                                      digest?.atime,
                                      locale: 'zh',
                                      dayFormat: DayFormat.Simple,
                                    )}',
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

  _deleteChannel(String channelid) async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    await channelService.remove(channelid);
  }
}
