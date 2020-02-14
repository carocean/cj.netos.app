import 'dart:io';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

import '../parts/headers.dart';
import 'package:qrscan/qrscan.dart' as scanner;

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
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: Text('选择管道类型'),
                              children: <Widget>[
                                DialogItem(
                                  text: '开环管道',
                                  icon: IconData(
                                    0xe604,
                                    fontFamily: 'netflow',
                                  ),
                                  color: Colors.grey[500],
                                  subtext: '适用于无穷级网络。自行添加管道出入口的公众',
                                  onPressed: () {
                                    widget.context.backward(
                                        result: <String, Object>{
                                          'type': 'openLoop'
                                        });
                                  },
                                ),
                                DialogItem(
                                  text: '闭环管道',
                                  icon: IconData(
                                    0xe62f,
                                    fontFamily: 'netflow',
                                  ),
                                  color: Colors.grey[500],
                                  subtext:
                                      '适用于：点对点聊天、群聊。管道的入口公众全是出口公众，自行添加出口公众同时也会被添加到入口',
                                  onPressed: () {
                                    widget.context.backward(
                                        result: <String, Object>{
                                          'type': 'closeLoop'
                                        });
                                  },
                                ),
                              ],
                            );
                          }).then((v) {
                        if (v == null) return;
                        widget.context.forward(value, arguments: v).then((v) {
                          if (_refreshChannels != null) {
                            _refreshChannels();
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
          code: ch.code,
          title: ch.name,
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
          loopType: ch.loopType,
          openAvatar: () {
            //如果不是自己的管道则不能改图标
            if (widget.context.principal.person != ch.owner) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('不可修改图标！原因：不是您创建的管道'),
                ),
              );
              return;
            }
            widget.context.forward(
              '/netflow/channel/avatar',
              arguments: <String, Object>{
                'channel': ch,
              },
            ).then((v) {
              if (_refreshChannels != null) {
                _refreshChannels();
              }
            });
          },
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
          isSystemChannel: channelService.isSystemChannel(ch.code),
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
        loopType: channel.loopType,
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
                                            text:
                                                '  ${v.loopType == 'openLoop' ? '开环管道:' : '闭环管道:'}'),
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

class _ChannelItem extends StatelessWidget {
  PageContext context;
  String code;
  String leading;
  String title;
  String who;
  String subtitle;
  String time;
  bool showNewest;
  String loopType;
  int unreadMsgCount;
  var openAvatar;
  var openChannel;
  bool isSystemChannel;

  _ChannelItem({
    this.context,
    this.code,
    this.leading,
    this.title,
    this.who,
    this.subtitle,
    this.loopType,
    this.unreadMsgCount,
    this.time,
    this.showNewest,
    this.openAvatar,
    this.openChannel,
    this.isSystemChannel,
  });

  @override
  Widget build(BuildContext context) {
    Widget imgSrc = null;
    if (StringUtil.isEmpty(leading)) {
      imgSrc = Icon(
        IconData(
          0xe606,
          fontFamily: 'netflow',
        ),
        size: 32,
        color: Colors.grey[500],
      );
    } else if (leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(leading),
        width: 40,
        height: 40,
      );
    } else {
      imgSrc = Image.network(
        this.leading,
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
              crossAxisAlignment: this.showNewest
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
                    onTap: this.openAvatar,
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
                            showBadge: this.unreadMsgCount != 0,
                            badgeContent: Text(
                              '',
                            ),
                            child: null,
                          ),
                        ),
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: Icon(
                            IconData(
                              this.loopType == 'closeLoop' ? 0xe62f : 0xe604,
                              fontFamily: 'netflow',
                            ),
                            size: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: openChannel,
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
                            text: this.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                        if (showNewest)
                          Padding(padding: EdgeInsets.only(top: 5,),child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.start,
                            spacing: 5,
                            runSpacing: 3,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text:
                                  '[${this.unreadMsgCount != 0 ? this.unreadMsgCount : ''}条]',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' ',
                                    ),
                                    TextSpan(
                                      text: '${this.subtitle}',
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
                                '${this.time}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),),
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
    if (this.isSystemChannel) {
      return Dismissible(
        key: Key('key_${Uuid().v1()}'),
        child: item,
        direction: DismissDirection.endToStart,
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: Text('不能删除系统管道！'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, 'cancel');
                        },
                      )
                    ],
                  ),
                ) !=
                'cancel';
          }
          return false;
        },
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(
            right: 10,
          ),
          child: Icon(
            Icons.delete_sweep,
            size: 16,
          ),
        ),
        background: Container(),
        onDismissed: (direction) {
          if (direction != DismissDirection.endToStart) {
            return;
          }
        },
      );
    }
    return Dismissible(
      key: Key('key_${Uuid().v1()}'),
      child: item,
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showConfirmationDialog(context) == 'yes';
        }
        return false;
      },
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(
          right: 10,
        ),
        child: Icon(
          Icons.delete_sweep,
          size: 16,
        ),
      ),
      background: Container(),
      onDismissed: (direction) {
        switch (direction) {
          case DismissDirection.endToStart:
            print('---------do deleted');
            _deleteChannel(this.code);
            break;
          case DismissDirection.vertical:
            // TODO: Handle this case.
            break;
          case DismissDirection.horizontal:
            // TODO: Handle this case.
            break;
          case DismissDirection.startToEnd:
            // TODO: Handle this case.
            break;
          case DismissDirection.up:
            // TODO: Handle this case.
            break;
          case DismissDirection.down:
            // TODO: Handle this case.
            break;
        }
      },
    );
  }

  Future<String> _showConfirmationDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text.rich(
          TextSpan(
            text: '是否删除该管道？',
            children: [
              TextSpan(text: '\r\n'),
              TextSpan(
                text: '删除管道同时会删除管道内数据！',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 'no');
            },
          ),
          FlatButton(
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 'yes');
            },
          ),
        ],
      ),
    );
  }

  _deleteChannel(String channelid) async {
    IChannelService channelService =
        this.context.site.getService('/netflow/channels');
    await channelService.remove(channelid);
  }
}
