import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chattalk_opener.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class NetflowPersonPortal extends StatefulWidget {
  PageContext context;

  NetflowPersonPortal({this.context});

  @override
  _NetflowPersonPortalState createState() => _NetflowPersonPortalState();
}

class _NetflowPersonPortalState extends State<NetflowPersonPortal> {
  Person _person;
  List<Channel> _linkedChannels = [];
  List<Channel> _myCreatorChannels = [];

  @override
  void initState() {
    _person = widget.context.parameters['person'];
    () async {
      await _loadLinkedChannels();
      if (mounted) {
        setState(() {});
      }
      await _loadMyCreateChannels();
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadLinkedChannels() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');

    var linkedChannels =
        await channelService.getChannelsOfPerson(_person.official);
    _linkedChannels.addAll(linkedChannels);
  }

  Future<void> _loadMyCreateChannels() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var channels = await channelService.fetchChannelsOfPerson(_person.official);
    _myCreatorChannels.addAll(channels);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, s) {
          var items = <Widget>[];
          items.add(
            SliverAppBar(
              pinned: true,
              elevation: 0,
              titleSpacing: 0,
              backgroundColor: Colors.white,
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
                              _person.official==widget.context.principal.person?SizedBox(width: 0,height: 0,):
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
                          messageSender
                              .open(widget.context, members: <String>[_person.official]);
                          break;
                        case 'go_more':
                          widget.context.forward('/profile/view',
                              arguments: {'person': _person.official});
                          break;
                        case 'go_rights':
                          widget.context.forward('/site/personal/rights',
                              arguments: {'person': _person});
                          break;
                        case 'cancel':
                          break;
                      }
                    });
//
                  },
                  icon: Icon(
                    FontAwesomeIcons.ellipsisV,
                    size: 14,
                  ),
                ),
              ],
            ),
          );
          items.add(
            SliverToBoxAdapter(
              child: _Header(
                context: widget.context,
                person: _person,
              ),
            ),
          );
          items.add(
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 15,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_person.official != widget.context.principal.person ? '他' : '我'}连接的',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 10,
                      bottom: 10,
                    ),
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _renderLinkedChannel(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          return items;
        },
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 15,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Text(
                    '${_person.official != widget.context.principal.person ? '他' : '我'}的管道',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints.expand(),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: _renderMyCreatorChannels(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderLinkedChannel() {
    var items = <Widget>[];
    if (_linkedChannels.isEmpty) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Center(
            child: Text(
              '没有连接的管道',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
      return items;
    }
    for (Channel ch in _linkedChannels) {
      items.add(
        GestureDetector(
          onTap: (){
            widget.context.forward("/netflow/channel/portal/channel", arguments: {
              'channel': ch.id,
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: SizedBox(
              width: 60,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: getAvatarWidget(
                      ch.leading,
                      widget.context,
                      'lib/portals/gbera/images/netflow.png',
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      '${ch.name}',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }

  List<Widget> _renderMyCreatorChannels() {
    var items = <Widget>[];
    if (_myCreatorChannels.isEmpty) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Center(
            child: Text(
              '${_person.official != widget.context.principal.person ? '他' : '我'}没有管道',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
      return items;
    }
    for (var ch in _myCreatorChannels) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            widget.context.forward("/netflow/channel/portal/channel", arguments: {
              'channel': ch.id,
              'origin':_person.official,
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: getAvatarWidget(
                    ch.leading,
                    widget.context,
                    'lib/portals/gbera/images/netflow.png',
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text('${ch.name}'),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 50,
        ),
      );
    }
    return items;
  }
}

class _Header extends StatefulWidget {
  Person person;
  PageContext context;

  _Header({
    this.person,
    this.context,
  });

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  @override
  void didUpdateWidget(covariant _Header oldWidget) {
    if (oldWidget.person != widget.person) {
      oldWidget.person = widget.person;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var person = widget.person;
    return Container(
      alignment: Alignment.topLeft,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 40,
        top: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
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
                    width: 50,
                    height: 50,
                    child: getAvatarWidget(
                      person.avatar,
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
                        person.nickName,
                        style: TextStyle(
                          fontSize: 20,
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
                          text: '',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${person.signature ?? ''}',
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
