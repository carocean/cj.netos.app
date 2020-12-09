import 'dart:io';

import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chattalk_opener.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class PersonViewPage extends StatefulWidget {
  PageContext context;

  PersonViewPage({this.context});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<PersonViewPage> {
  Person _person;
  bool _isSaving = false;
  bool _isAdded = false;

  @override
  void initState() {
    _person = widget.context.parameters['person'];
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    IPersonService personService =
    widget.context.site.getService('/gbera/persons');
    var official = widget.context.parameters['official'];
    if(_person==null&&!StringUtil.isEmpty(official)) {
      _person=await personService.fetchPerson(official);
    }
    _isAdded = await _isAddedPerson();
  }

  Future<bool> _isAddedPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.existsPerson(_person.official);
  }

  Future<void> _addPerson() async {
    if (_isSaving || _isAdded) {
      return;
    }
    _isSaving = true;
    if (mounted) {
      setState(() {});
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var dio = widget.context.site.getService('@.http');
    var avatar = _person.avatar.startsWith('/')
        ? _person.avatar
        : await downloadPersonAvatar(
            dio: dio,
            avatarUrl:
                '${_person.avatar}?accessToken=${widget.context.principal.accessToken}');
    Person person = Person(
        _person.official,
        _person.uid,
        _person.accountCode,
        _person.appid,
        avatar,
        null,
        _person.nickName,
        _person.signature,
        PinyinHelper.getPinyin(_person.nickName),
        widget.context.principal.person);
    await personService.addPerson(person);
    _isSaving = false;
    _isAdded = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removePerson() async {
    if (_isSaving || !_isAdded) {
      return;
    }
    _isSaving = true;
    if (mounted) {
      setState(() {});
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(_person.official);
    _isSaving = false;
    _isAdded = false;
    if (mounted) {
      setState(() {});
    }
  }

  String _getActionLabel() {
    if (_person.official == widget.context.principal.person) {
      return '';
    }
    if (_isAdded) {
      if (_isSaving) {
        return '取消中...';
      } else {
        return '不再关注为公众';
      }
    } else {
      if (_isSaving) {
        return '关注中...';
      } else {
        return '关注为公众';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.more_horiz,
            ),
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (ctx) {
                    return CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          child: Text(
                            '基本资料',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              ctx,
                              'go_profile',
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
                  case 'go_profile':
                    widget.context.forward('/profile/view',
                        arguments: {'person': _person.official});
                    break;
                  case 'cancel':
                    break;
                }
              });
            },
          ),
        ],
      ),
      body: _renderBody(),
    );
  }
  Widget _renderBody(){
    if(_person==null) {
      return SizedBox(width: 0,height: 0,);
    }
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
          ),
          child: Column(
            children: <Widget>[
              _renderProviderInfoPanel(),
              SizedBox(
                height: 40,
              ),
//              CardItem(
//                title: '权限',
//                tipsText: '',
//              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
//                        Icon(
//                          Icons.add,
//                          size: 12,
//                          color: Colors.grey,
//                        ),
//                        SizedBox(
//                          width: 2,
//                        ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _isSaving ||
                          _person.official ==
                              widget.context.principal.person
                          ? null
                          : () {
                        if (_isAdded) {
                          _removePerson();
                        } else {
                          _addPerson();
                        }
                      },
                      child: Text(
                        '${_getActionLabel()}',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          alignment: Alignment.center,
          child: Column(
            children: _renderActionPanel(),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
            ),
            color: Colors.white,
            constraints: BoxConstraints.expand(),
            child: _ContentBoxListPanel(
              context: widget.context,
            ),
          ),
        ),
      ],
    );
  }
  Widget _renderProviderInfoPanel() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: _person.avatar.startsWith('/')
                ? Image.file(
                    File('${_person.avatar}'),
                    width: 60,
                    height: 60,
                  )
                : FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${_person.avatar}?accessToken=${widget.context.principal.accessToken}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${_person.nickName}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '用户号',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      '${_person.uid}',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '公号',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      '${_person.official}',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${_person.signature ?? ''}',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _renderActionPanel() {
    var actions = <Widget>[];
    actions.add(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          messageSender
              .open(widget.context, members: <String>[_person.official]);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.message,
              size: 20,
              color: Colors.grey,
            ),
            SizedBox(
              width: 10,
            ),
            //如果是地理感知器则关注，如果是管道则有：关注以推送动态给他或关注以接收他的动态
            Text(
              '发消息',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
    return actions;
  }
}

class _ContentBoxListPanel extends StatefulWidget {
  PageContext context;

  _ContentBoxListPanel({
    this.context,
  });

  @override
  __ContentBoxListPanelState createState() => __ContentBoxListPanelState();
}

class __ContentBoxListPanelState extends State<_ContentBoxListPanel> {
  int _limit = 10, _offset = 0;
  bool _isLoading = false;
  List<ContentBoxOR> _boxList = [];
  EasyRefreshController _controller;
  Person _person;

  @override
  void initState() {
    _person = widget.context.parameters['person'];
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ContentBoxListPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    var official = widget.context.parameters['official'];
    if(_person==null&&!StringUtil.isEmpty(official)){
      IPersonService personService =
      widget.context.site.getService('/gbera/persons');
      _person=await personService.fetchPerson(official);
    }
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    List<ContentBoxOR> boxList = await recommender.pageContentBoxByAssigner(
        _person.official, _limit, _offset);
    if (boxList.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += boxList.length;
    _boxList.addAll(boxList);
    if (mounted) {
      setState(() {});
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      shrinkWrap: true,
      controller: _controller,
      onLoad: _load,
      slivers: _boxList.map((box) {
        return SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward(
                '/chasechain/box',
                arguments: {'box': box, 'pool': box.pool},
              );
            },
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      StringUtil.isEmpty(box.pointer.leading)
                          ? Image.asset(
                              'lib/portals/gbera/images/netflow.png',
                              width: 40,
                              height: 40,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder:
                                  'lib/portals/gbera/images/default_watting.gif',
                              image:
                                  '${box.pointer.leading}?accessToken=${widget.context.principal.accessToken}',
                              width: 40,
                              height: 40,
                            ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${box.pointer.title}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${box.pointer.type.startsWith('geo.receptor') ? '地理感知器' : '网流管道'}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                  child: Divider(
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
