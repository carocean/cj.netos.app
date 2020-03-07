import 'dart:io';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:uuid/uuid.dart';

import '../parts/headers.dart';
import 'netflow/channel.dart';
import 'netflow/message_views.dart';

class Netflow extends StatefulWidget {
  PageContext context;

  Netflow({this.context});

  @override
  _NetflowState createState() => _NetflowState();
}

class _NetflowState extends State<Netflow> with AutomaticKeepAliveClientMixin {
  var _backgroud_transparent = true;
  bool use_wallpapper = false;
  Future<List<MessageView>> _future_getMessages;
  Future<List<_ChannelItem>> _future_loadChannels;

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _future_getMessages = _getMessages();
    _future_loadChannels = _loadChannels();
    super.initState();
  }

  @override
  void dispose() {
    _future_getMessages = null;
    _future_loadChannels = null;
    super.dispose();
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
          child: Container(
            child: FutureBuilder<List<MessageView>>(
              future: _future_getMessages,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
//                    value: 0.3,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.grey[600]),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error?.toString(),
                    ),
                  );
                }
                var msgviews = snapshot.data;

                return msgviews.length > 0
                    ? _MessagesRegion(context: widget.context, views: msgviews)
                    : Container(
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
              },
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

  //调用方：创建管道，修改管道图标
  Future<void> _refreshChannels() async {
    //该方法导致FutureBuilder的重绘
    _future_loadChannels = _loadChannels();
  }

  Future<List<_ChannelItem>> _loadChannels() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    List<Channel> list = await channelService.getAllChannel();
    if (list.isEmpty) {
      await channelService.initSystemChannel(widget.context.principal);
      list = await channelService.getAllChannel();
    }
    var items = List<_ChannelItem>();
    for (var ch in list) {
      items.add(
        _ChannelItem(
          context: widget.context,
          channelid: ch.id,
          title: ch.name,
          owner: ch.owner,
          subtitle: '',
          showNewest: false,
          leading: ch.leading,
          time: '',
//          time: TimelineUtil.format(
//            ch.atime,
//            dayFormat: DayFormat.Simple,
//          ),
          unreadMsgCount: 0,
          who: ': ',
          openChannel: () {
            widget.context.forward(
              '/netflow/channel',
              arguments: {'channel': ch},
            ).then((v) {
              if (_refreshChannels != null) {
                _refreshChannels();
              }
            });
          },
          isSystemChannel: channelService.isSystemChannel(ch.origin),
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

  Future<List<MessageView>> _getMessages() async {
    IInsiteMessageService messageService =
        widget.context.site.getService('/insite/messages');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var messages = await messageService.pageMessage(4, 0);
    var msgviews = <MessageView>[];
    for (var msg in messages) {
      var person = await personService.getPerson(msg.creator);
      var timeText = TimelineUtil.formatByDateTime(
              DateTime.fromMillisecondsSinceEpoch(msg.ctime),
              locale: 'zh',
              dayFormat: DayFormat.Simple)
          .toString();
      var channel = await channelService.getChannel(msg.onChannel);
      var act = MessageView(
        who: person.accountName,
        channel: channel?.name,
        content: msg.digests,
        money: ((msg.wy ?? 0) * 0.00012837277272).toStringAsFixed(2),
        time: timeText,
        picCount: 0,
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return widget.context
                    .part('/site/insite/approvals', context, arguments: {
                  'message': msg,
                  'channel': channel,
                  'person': person,
                });
              }).then((result) {
            print('-----$result');
          });
        },
      );
      msgviews.add(act);
    }
    return msgviews;
  }
}

class _MessagesRegion extends StatefulWidget {
  List<MessageView> views = [];
  PageContext context;

  _MessagesRegion({this.views, this.context});

  @override
  _MessagesRegionState createState() => _MessagesRegionState();
}

class _MessagesRegionState extends State<_MessagesRegion> {
  var index = 0;

  @override
  Widget build(BuildContext context) {
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
              children: widget.views.map((v) {
                index++;
                bool notBottom = index < widget.views.length;
                if (index >= widget.views.length) {
                  index = 0;
                }
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: v.onTap,
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
                                text: '${v.content}',
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
                              !StringUtil.isEmpty(v.time)
                                  ? TextSpan(text: '${v.time}')
                                  : TextSpan(text: ''),
                              !StringUtil.isEmpty(v.money)
                                  ? TextSpan(
                                      text: '  洇金:¥',
                                      children: [
                                        TextSpan(
                                          text: '${v.money}',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : TextSpan(text: ''),
                              TextSpan(
                                text: '  来自:',
                              ),
                              TextSpan(
                                text: '  ${v.who}',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              !StringUtil.isEmpty(v.channel)
                                  ? TextSpan(
                                      text: '',
                                      children: [
                                        TextSpan(
                                          text: '${v.channel}',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : TextSpan(text: ''),
                              v.picCount > 0
                                  ? TextSpan(text: '  图片${v.picCount}个')
                                  : TextSpan(text: ''),
                            ],
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      notBottom
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
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChannelItem extends StatefulWidget {
  PageContext context;
  String channelid;
  String leading;
  String title;
  String owner;
  String who;
  String subtitle;
  String time;
  bool showNewest;
  int unreadMsgCount;
  var openChannel;
  bool isSystemChannel;
  Function(String channelid) refreshChannels;

  _ChannelItem({
    this.context,
    this.channelid,
    this.leading,
    this.title,
    this.owner,
    this.who,
    this.subtitle,
    this.unreadMsgCount,
    this.time,
    this.showNewest,
    this.openChannel,
    this.isSystemChannel,
    this.refreshChannels,
  });

  @override
  __ChannelItemState createState() => __ChannelItemState();
}

class __ChannelItemState extends State<_ChannelItem> {
  double _percentage = 0.0;

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
    Widget imgSrc = null;
    if (StringUtil.isEmpty(widget.leading)) {
      imgSrc = Icon(
        IconData(
          0xe606,
          fontFamily: 'netflow',
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
              crossAxisAlignment: widget.showNewest
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
                          child: Badge(
                            position: BadgePosition.topRight(
                              right: -3,
                              top: 3,
                            ),
                            elevation: 0,
                            showBadge: widget.unreadMsgCount != 0,
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.openChannel,
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
                        !widget.showNewest
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
                                            '[${widget.unreadMsgCount != 0 ? widget.unreadMsgCount : ''}条]',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' ',
                                          ),
                                          TextSpan(
                                            text: '${widget.subtitle}',
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
                                      '${widget.time}',
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
        child: item,
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
      child: item,
    );
  }

  _deleteChannel(String channelid) async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    await channelService.remove(channelid);
  }
}
