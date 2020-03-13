import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class SeeChannelPinPersons extends StatefulWidget {
  PageContext context;

  SeeChannelPinPersons({this.context});

  @override
  _SeeChannelPinPersonsState createState() => _SeeChannelPinPersonsState();
}

class _SeeChannelPinPersonsState extends State<SeeChannelPinPersons> {
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
  String _pinType;
  Channel _channel;
  String _directionTips;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: 0.0);
    _controller.addListener(_listener);
    _channel = widget.context.parameters['channel'];
    _person = widget.context.parameters['person'];
    _pinType = widget.context.parameters['pinType'];
    _directionTips = widget.context.parameters['direction_tips'];
    _load();
  }

  @override
  void dispose() {
    this.showOnAppbar = false;
    this._person = null;
    this._pinType = null;
    super.dispose();
  }

  void _load() async {}

  @override
  Widget build(BuildContext context) {
    var personName = '${_person.nickName ?? _person.accountCode}';
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
                            '更多他的资料',
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
                            '查看他在该管道的动态',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              ctx,
                              {'action': 'see_activities'},
                            );
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            '发消息给他',
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
              imgSrc: _person.avatar,
              title: personName,
              uid: '${_person.uid}',
              person:
                 _person.official,
              signText: '${_person.signature ?? ''}',
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
                right: 10,
                bottom: 5,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: '${this._channel.name}: ',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        children: [
                          TextSpan(
                            text: _directionTips,
                          ),
                          TextSpan(
                            text: '${_person.nickName ?? _person.accountCode}>',
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Card(
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    CardItem(
                      leading: Image.network(
                        'http://47.105.165.186:7100/public/avatar/06aa9aeb1ece0f4bc63a664ddef0404a.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.fitWidth,
                      ),
                      title: '万年一梦于',
                      onItemTap: () {
                        IPersonService personService =
                            widget.context.site.getService('/gbera/persons');
//                        personService.getPerson(id)//求当前项的person对象，传给see_persons
                        widget.context.forward(
                            '/netflow/channel/pin/see_persons',
                            arguments: {
                              'person': _person,
                              'pinType': 'downstream',
                              'channel': _channel,
                              'direction_tips':
                                  '${_directionTips}>${_person.nickName ?? _person.accountCode}>'
                            }).then((obj) {});
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 40,
                    ),
                    CardItem(
                      leading: Image.network(
                        'http://47.105.165.186:7100/public/avatar/341d5e0f2d4fbd21ff5a2acafcf44cdb.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.fitWidth,
                      ),
                      title: '李小姐',
                      onItemTap: () {
                        IPersonService personService =
                        widget.context.site.getService('/gbera/persons');
//                        personService.getPerson(id)//求当前项的person对象，传给see_persons
                        widget.context.forward(
                            '/netflow/channel/pin/see_persons',
                            arguments: {
                              'person': _person,
                              'pinType': 'downstream',
                              'channel': _channel,
                              'direction_tips':
                              '${_directionTips}>${_person.nickName ?? _person.accountCode}>'
                            }).then((obj) {});
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 40,
                    ),
                    CardItem(
                      leading: Image.network(
                        'http://47.105.165.186:7100/public/avatar/4b456c8abe0df947d351503b1219611c.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.fitWidth,
                      ),
                      title: '虎妞',
                      onItemTap: () {
                        IPersonService personService =
                        widget.context.site.getService('/gbera/persons');
//                        personService.getPerson(id)//求当前项的person对象，传给see_persons
                        widget.context.forward(
                            '/netflow/channel/pin/see_persons',
                            arguments: {
                              'person': _person,
                              'pinType': 'downstream',
                              'channel': _channel,
                              'direction_tips':
                              '${_directionTips}>${_person.nickName ?? _person.accountCode}>'
                            }).then((obj) {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                  child: Image.file(
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
