import 'dart:io';

///个人站点
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class PersonalSite extends StatefulWidget {
  PageContext context;

  PersonalSite({this.context});

  @override
  _PersonalSiteState createState() => _PersonalSiteState();
}

class _PersonalSiteState extends State<PersonalSite> {
  _listener() {
    if (_controller.offset >= 1) {
      if (!showOnAppbar) {
        setState(() {
          showOnAppbar = true;
        });
      }
      return;
    }
    if (_controller.offset < 1) {
      if (showOnAppbar) {
        setState(() {
          showOnAppbar = false;
        });
      }
      return;
    }
  }

  bool showOnAppbar = false;
  var _controller;
  Person _person;
  List<_ChannelItemInfo> _linkedChannels = [];
  List<_ChannelItemInfo> _cachedChannels = [];
  List<_ChannelItemInfo> _otherChannels = [];

  @override
  void initState() {
    _controller = ScrollController(initialScrollOffset: 0.0);
    _controller.addListener(_listener);
    _person = widget.context.parameters['person'];

    _load();
    super.initState();
  }

  @override
  void dispose() {
    this._linkedChannels.clear();
    this._cachedChannels.clear();
    this._otherChannels.clear();
    this.showOnAppbar = false;
    this._person = null;
    super.dispose();
  }

  _load() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');

    var linkedChannels =
        await channelService.getChannelsOfPerson(_person.official);
    for (Channel channel in linkedChannels) {
      _linkedChannels.add(
        _ChannelItemInfo(
          title: '${channel.name}',
          leading: channel.leading,
          onTap: () {
            widget.context
                .forward('/netflow/portal/channel', arguments: <String, Object>{
              'channel': channel,
              'owner': _person.official,
            });
          },
        ),
      );
    }
    IChannelCache channelCache =
        widget.context.site.getService('/cache/channels');
    var cachedChannels = await channelCache.listAll(_person.official);
    for (Channel channel in cachedChannels) {
      var inperson =
          await pinService.getInputPerson(_person.official, channel.id);
      bool hasRights = inperson?.rights != 'deny';
      _cachedChannels.add(
        _ChannelItemInfo(
          channel: channel.id,
          title: '${channel.name}',
          leading: channel.leading,
          canSwipe: true,
          rights: hasRights,
          tips: !hasRights ? '已拒收取该管道消息，左滑以开通' : '',
          onTap: () {
            widget.context
                .forward('/netflow/portal/channel', arguments: <String, Object>{
              'channel': channel,
              'owner': _person.official,
            });
          },
        ),
      );
    }
    var otherChannels =
        await channelService.fetchChannelsOfPerson(_person.official);
    for (Channel channel in otherChannels) {
      _otherChannels.add(
        _ChannelItemInfo(
          title: '${channel.name}',
          leading: channel.leading,
          onTap: () {
            widget.context
                .forward('/netflow/portal/channel', arguments: <String, Object>{
              'channel': channel,
              'owner': _person.official,
            });
          },
        ),
      );
    }
    setState(() {});
  }

  String get personName {
    return '${_person.nickName ?? _person.accountCode}';
  }

  _removePerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(_person.official);
    widget.context.backward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
          ),
        ),
        title: showOnAppbar ? Text(personName) : Text(''),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (ctx) {
                    return CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          child: Text(
                            '更多资料',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              ctx,
                              'go_more',
                            );
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            '权限',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              ctx,
                              'go_rights',
                            );
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            '发消息',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              ctx,
                              'go_message',
                            );
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            '删除',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              ctx,
                              'delete',
                            );
                          },
                        ),
                      ],
                      cancelButton: FlatButton(
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            ctx,
                            'cancel',
                          );
                        },
                      ),
                    );
                  }).then((action) {
                switch (action) {
                  case 'go_message':
                    break;
                  case 'go_more':
                    widget.context.forward('/site/personal/profile');
                    break;
                  case 'go_rights':
                    widget.context.forward('/site/personal/rights',
                        arguments: {'person': _person});
                    break;
                  case 'delete':
                    _removePerson();
                    break;
                  case 'cancel':
                    break;
                }
              });
//
            },
            icon: Icon(
              FontAwesomeIcons.ellipsisH,
              size: 14,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _Header(
              context: widget.context,
              imgSrc: _person?.avatar,
              title: personName,
              uid: '${_person?.uid}',
              person: personName,
              signText: '${_person?.signature ?? ''}',
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
//          SliverToBoxAdapter(
//            child: Container(
//              padding: EdgeInsets.only(
//                left: 10,
//                bottom: 2,
//                top: 5,
//              ),
//              child: Text(
//                '微站',
//                style: TextStyle(
//                    fontWeight: FontWeight.w500,
//                    fontSize: 14,
//                    color: Colors.grey[600]),
//              ),
//            ),
//          ),
//          SliverToBoxAdapter(
//            child: _Card(
//              channelItems: [
//                _ChannelItemInfo(
//                  title: '兰州拉面馆',
//                  images: [
//                    'http://b-ssl.duitang.com/uploads/item/201805/24/20180524220406_hllbq.jpg',
//                    'http://cdn.duitang.com/uploads/item/201606/14/20160614002619_WfLXj.jpeg',
//                  ],
//                  onTap: () {
//                    widget.context.forward('/site/marchant');
//                  },
//                ),
//                _ChannelItemInfo(
//                  title: '天主教堂',
//                  images: [
//                    'http://b-ssl.duitang.com/uploads/item/201805/24/20180524220406_hllbq.jpg',
//                  ],
//                  onTap: () {
//                    widget.context.forward('/site/marchant');
//                  },
//                ),
//              ],
//            ),
//          ),
//          SliverToBoxAdapter(
//            child: Container(
//              height: 10,
//            ),
//          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                bottom: 2,
                top: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '管道',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '已连接管道',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: _linkedChannels.isEmpty
                                    ? '(无)'
                                    : '(${_linkedChannels.length}个)',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      left: 20,
                      top: 20,
                      bottom: 20,
                      right: 20,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 30,
                    ),
                    child: _Card(
                      context: widget.context,
                      channelItems: _linkedChannels,
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '已缓存管道',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: _cachedChannels.isEmpty
                                    ? '(无)'
                                    : '(${_cachedChannels.length}个)',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      left: 20,
                      top: 20,
                      bottom: 20,
                      right: 20,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 30,
                    ),
                    child: _Card(
                      context: widget.context,
                      channelItems: _cachedChannels,
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '其它管道',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: _otherChannels.isEmpty
                                    ? '(无)'
                                    : '(${_otherChannels.length}个)',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      left: 20,
                      top: 20,
                      bottom: 20,
                      right: 20,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 30,
                    ),
                    child: _Card(
                      context: widget.context,
                      channelItems: _otherChannels,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Operator {
  IconData iconData;
  String text;

  _Operator({this.iconData, this.text});
}

class _OperatorCard extends StatefulWidget {
  List<_Operator> operators;

  _OperatorCard({this.operators});

  @override
  __OperatorCardState createState() => __OperatorCardState();
}

class __OperatorCardState extends State<_OperatorCard> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.operators.map((value) {
          var orignal = Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: Icon(
                    value.iconData,
                    size: 14,
                    color: Colors.blueGrey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: Text(
                    value.text,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (index < widget.operators.length - 1) {
            index++;
            return Column(
              children: <Widget>[
                orignal,
                Divider(
                  height: 1,
                ),
              ],
            );
          }
          index = 0;
          return orignal;
        }).toList(),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  String imgSrc;
  String title;
  String uid;
  String person;
  String address;
  String signText;
  PageContext context;
  _Header(
      {this.imgSrc,
      this.uid,
      this.person,
      this.address,
      this.signText,
      this.title,this.context,});

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  right: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: getAvatarWidget(
                      widget.imgSrc,
                      widget.context,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '用户号: ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: widget.uid,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '公号: ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: widget.person,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: widget.signText == null
                                  ? ''
                                  : "${widget.signText}",
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelItemInfo {
  String leading;
  String title;
  String tips;
  List images;
  bool canSwipe;
  String channel;
  bool rights;
  Function() onTap;

  _ChannelItemInfo(
      {this.title,
      this.tips,
      this.channel,
      this.rights,
      this.canSwipe = false,
      this.leading,
      this.images,
      this.onTap}) {
    if (this.images == null) {
      this.images = [];
    }
  }
}

class _Card extends StatefulWidget {
  PageContext context;
  List<_ChannelItemInfo> channelItems;

  _Card({this.channelItems, this.context});

  @override
  _CardState createState() => _CardState();
}

class _CardState extends State<_Card> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _allowInsite(channel) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    Person person = widget.context.parameters['person'];
    var inperson = await pinService.getInputPerson(person.official, channel);
    if (inperson.rights == 'deny') {
      await pinService.updateInputPersonRights(
          person.official, channel, 'allow');
    }
  }

  Future<void> _removeCacheChannel(channel) async {
    IChannelCache channelCache =
        widget.context.site.getService('/cache/channels');
    await channelCache.remove(channel);
  }

  Future<void> _emptyCacheChannel(channel) async {
    IInsiteMessageService insiteMessageService =
        widget.context.site.getService('/insite/messages');
    await insiteMessageService.emptyChannel(channel);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: widget.channelItems.map((value) {
          var actions = <Widget>[
            IconSlideAction(
              caption: '删除',
              foregroundColor: Colors.grey[600],
              icon: Icons.delete,
              closeOnTap: true,
              onTap: () {
                _removeCacheChannel(value.channel).then((v) {
                  for (int i = 0; i < widget.channelItems.length; i++) {
                    var item = widget.channelItems[i];
                    if (item.channel == value.channel) {
                      widget.channelItems.removeAt(i);
                    }
                  }
                  setState(() {});
                });
              },
            ),
            IconSlideAction(
              caption: '清空消息',
              foregroundColor: Colors.grey[600],
              icon: Icons.delete_sweep,
              closeOnTap: true,
              onTap: () {
                _emptyCacheChannel(value.channel).then((v) {
                  setState(() {});
                });
              },
            ),
          ];
          if (!(value.rights ?? false)) {
            actions.add(
              IconSlideAction(
                caption: '不再拒收',
                foregroundColor: Colors.red,
                icon: Icons.check,
                closeOnTap: true,
                onTap: () {
                  _allowInsite(value.channel).then((v) {
                    value.rights = true;
                    value.tips = '';
                    setState(() {});
                  });
                },
              ),
            );
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: value.onTap,
            child: Column(
              children: <Widget>[
                value.canSwipe
                    ? Slidable(
                        child: _ChannelItem(
                          title: value.title,
                          tips: value.tips,
                          images: value.images,
                          avatar: value.leading,
                          context: widget.context,
                        ),
                        actionPane: SlidableDrawerActionPane(),
                        secondaryActions: actions,
                      )
                    : _ChannelItem(
                        title: value.title,
                        tips: value.tips,
                        images: value.images,
                        avatar: value.leading,
                        context: widget.context,
                      ),
                Divider(
                  height: 1,
                  indent: 20,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChannelItem extends StatefulWidget {
  PageContext context;
  List images = [];
  String title;
  String tips;
  String avatar;

  _ChannelItem({
    this.context,
    this.tips,
    this.title = '',
    this.images,
    this.avatar,
  });

  @override
  __ChannelItemState createState() => __ChannelItemState();
}

class __ChannelItemState extends State<_ChannelItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StringUtil.isEmpty(widget.avatar)
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Container(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: StringUtil.isEmpty(widget.avatar)
                      ? Image.asset(
                          'lib/portals/gbera/images/netflow.png',
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        )
                      : widget.avatar.startsWith('/')
                          ? Image.file(
                              File(widget.avatar),
                              fit: BoxFit.fitWidth,
                              height: 30,
                              width: 30,
                            )
                          : Image.network(
                              '${widget.avatar}?accessToken=${widget.context.principal.accessToken}',
                              fit: BoxFit.fitWidth,
                              height: 30,
                              width: 30,
                            ),
                ),
          Container(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        '${widget.tips ?? ''}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 15,
                    bottom: 15,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
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
