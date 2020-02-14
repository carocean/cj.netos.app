import 'dart:io';

///个人站点
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

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
  List<Channel> _myChannels = [];

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
    this._myChannels.clear();
    this.showOnAppbar = false;
    this._person = null;
    super.dispose();
  }

  _load() async {
    if (_person == null) {
      await _test();
    }

    String official =
        '${_person.accountName}@${_person.appid}.${_person.tenantid}';
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    _myChannels = await channelService.getChannelsOfPerson(official);

    setState(() {});
  }

  String get personName {
    return '${_person.nickName ?? _person.accountName}';
  }

  //用于测试，随时删除
  Future<void> _test() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _person = await personService.getPersonByUID('0020011912411634');
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
                              {'action': 'go_more'},
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
                              {'action': 'go_rights'},
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
                              {'action': 'go_message'},
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
                              {'action': 'delete'},
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
                            {'action': 'cancel'},
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
                    break;
                  case 'delete':
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
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                bottom: 2,
                top: 5,
              ),
              child: Text(
                '微站',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[600]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Body(
              channelItems: [
                _ChannelItemInfo(
                  title: '兰州拉面馆',
                  images: [
                    'http://b-ssl.duitang.com/uploads/item/201805/24/20180524220406_hllbq.jpg',
                    'http://cdn.duitang.com/uploads/item/201606/14/20160614002619_WfLXj.jpeg',
                  ],
                  onTap: () {
                    widget.context.forward('/site/marchant');
                  },
                ),
                _ChannelItemInfo(
                  title: '天主教堂',
                  images: [
                    'http://b-ssl.duitang.com/uploads/item/201805/24/20180524220406_hllbq.jpg',
                  ],
                  onTap: () {
                    widget.context.forward('/site/marchant');
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
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
                    child: _Body(
                      channelItems: [
                        _ChannelItemInfo(
                          title: '全部管道',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '已加管道',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: _myChannels.isEmpty
                                    ? '(无)'
                                    : '(${_myChannels.length}个)',
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
                    child: _Body(
                      channelItems: _myChannels.map((channel) {
                        return _ChannelItemInfo(
                          title: '${channel.name}',
                          leading: channel.leading,
                          onTap: () {
                            widget.context.forward('/netflow/portal/channel',
                                arguments: <String, Object>{
                                  'channel': channel
                                });
                          },
                        );
                      }).toList(),
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

  _Header(
      {this.imgSrc,
      this.uid,
      this.person,
      this.address,
      this.signText,
      this.title});

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
                  child: widget.imgSrc == null
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Image.file(
                          File(widget.imgSrc),
                          width: 80,
                          height: 80,
                          fit: BoxFit.fitWidth,
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
  List images;
  Function() onTap;

  _ChannelItemInfo({this.title, this.leading, this.images, this.onTap}) {
    if (this.images == null) {
      this.images = [];
    }
  }
}

class _Body extends StatefulWidget {
  List<_ChannelItemInfo> channelItems;

  _Body({this.channelItems});

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: widget.channelItems.map((value) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: value.onTap,
            child: Column(
              children: <Widget>[
                _ChannelItem(
                  title: value.title,
                  images: value.images,
                  avatar: value.leading,
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
  List images = [];
  String title;
  String avatar;

  _ChannelItem({
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
                  child: Image.file(
                    File(widget.avatar),
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
                    children: widget.images.map((value) {
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(3),
                          ),
                          child: Image.network(
                            value,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      );
                    }).toList(),
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
