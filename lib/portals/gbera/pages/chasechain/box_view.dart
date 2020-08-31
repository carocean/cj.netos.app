import 'dart:io';

import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/content_box.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ContentBoxViewPage extends StatefulWidget {
  PageContext context;

  ContentBoxViewPage({this.context});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<ContentBoxViewPage> {
  TrafficPool _pool;
  ContentBoxOR _box;
  BoxPointerRealObject _boxRealObject;
  Future<String> _future_doLocation;
  Future<Person> _future_getPerson;

  @override
  void initState() {
    _pool = widget.context.parameters['pool'];
    _box = widget.context.parameters['box'];
    _boxRealObject = widget.context.parameters['boxRealObject'];
    _future_getPerson = _getPerson();
    _future_doLocation = _doLocation();
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

//
  Future<void> _load() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
  }

  Future<String> _doLocation() async {
    if (_box.location == null) {
      return null;
    }
    var geocode = await AmapSearch.searchReGeocode(_box.location);
    var list = await geocode.poiList;
    if (list.isEmpty) {
      return geocode.township;
    }
    var first = list[0];
    var address = await first.address;
    if (StringUtil.isEmpty(address)) {
      address = await first.title;
    }
    if (StringUtil.isEmpty(address)) {
      address = await first.businessArea;
    }
    return address;
  }

  Future<void> _goMap(LatLng location, String label) async {
//    var geocodeList = await AmapSearch.searchGeocode(
//      _pool.geoTitle,
//    );
//    if (geocodeList.isEmpty) {
//      return;
//    }
//    var first = geocodeList[0];
//    var location = await first.latLng;
    widget.context.forward('/gbera/location',
        arguments: {'location': location, 'label': label});
  }

  Future<Person> _getPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(_box.pointer.creator);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
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
                  _BoxInfoPanel(),
                  SizedBox(
                    height: 40,
                  ),
                  FutureBuilder<Person>(
                    future: _future_getPerson,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return CardItem(
                          title: '创建者',
                          tipsText: '...',
                        );
                      }
                      var person = snapshot.data;
                      return CardItem(
                        title: '创建者',
                        tipsText: '${person.nickName}',
                        onItemTap: () {
                          widget.context.forward('/person/view',
                              arguments: {'person': person});
                        },
                      );
                    },
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
//                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                ),
                child: Column(
                  children: <Widget>[],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BoxInfoPanel() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: StringUtil.isEmpty(_boxRealObject?.icon)
                ? Icon(
                    Icons.pool,
                    size: 60,
                    color: _boxRealObject.type == 'receptor'
                        ? Colors.green
                        : Colors.grey,
                  )
                : FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${_boxRealObject.icon}?accessToken=${widget.context.principal.accessToken}',
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
                  '${_boxRealObject.title}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '类型',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                        '${_boxRealObject.type == 'receptor' ? '地感知器' : '网流管道'}'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '在池',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text('${_pool.title}'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _boxRealObject.type != 'receptor'
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          FutureBuilder<String>(
                            future: _future_doLocation,
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return Text('...');
                              }
                              var locationText = snapshot.data;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _goMap(_boxRealObject.location,
                                      _boxRealObject.title);
                                },
                                child: Text(
                                  locationText ?? '',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              );
                            },
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

  List<Widget> _renderActionPanel() {
    var actions = <Widget>[];
    if (_boxRealObject.type == 'receptor') {
      actions.add(
        _FollowReceptorAction(
          context: widget.context,
          box: _box,
        ),
      );
    } else {
      actions.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.pushed,
              size: 20,
              color: Colors.grey,
            ),
            SizedBox(
              width: 10,
            ),
            //如果是地理感知器则关注，如果是管道则有：关注以推送动态给他或关注以接收他的动态
            Text(
              '关注以推送动态给它',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
      actions.add(
        SizedBox(
          height: 30,
          child: Divider(
            height: 1,
          ),
        ),
      );
      actions.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.receipt,
              size: 20,
              color: Colors.grey,
            ),
            SizedBox(
              width: 10,
            ),
            //如果是地理感知器则关注，如果是管道则有：关注以推送动态给他或关注以接收他的动态
            Text(
              '关注以接收它的动态',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return actions;
  }
}

class _FollowReceptorAction extends StatefulWidget {
  PageContext context;
  ContentBoxOR box;

  _FollowReceptorAction({
    this.context,
    this.box,
  });

  @override
  __FollowReceptorActionState createState() => __FollowReceptorActionState();
}

class __FollowReceptorActionState extends State<_FollowReceptorAction> {
  var _isFollowed = false;
  var _followLabel = '关注';
  var _isProcess = false;

  @override
  void initState() {
    _loadFollow().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(_FollowReceptorAction oldWidget) {
    if (oldWidget.box.id != widget.box.id) {
      oldWidget.box = widget.box;
      _loadFollow().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadFollow() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var receptorId = widget.box.pointer.id;
    var category = widget.box.pointer.type;
    int pos = category.lastIndexOf('.');
    category = category.substring(pos + 1);
    var exists = await receptorService.existsLocal(category, receptorId);
    _isFollowed = exists;
    _followLabel = exists ? '不再关注' : '关注';
  }

  Future<void> _follow() async {
    _isProcess = true;
    _followLabel = '处理中...';
    setState(() {});
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');

    var receptorId = widget.box.pointer.id;
    var category = widget.box.pointer.type;
    int pos = category.lastIndexOf('.');
    category = category.substring(pos + 1);
    if (_isFollowed) {
      //取消
      await receptorService.remove(category, receptorId);
      await receptorRemote.unfollow(category, receptorId);
      await _loadFollow();
      _isFollowed = false;
      _isProcess = false;
      _followLabel = '关注';
      if (mounted) {
        setState(() {});
      }
      return;
    }
    var receptor = await receptorRemote.getReceptor(category, receptorId);
    if (receptor != null) {
      await receptorService.add(receptor, isOnlySaveLocal: true);
    }
    await receptorRemote.follow(category, receptorId);
    await _loadFollow();
    _isFollowed = true;
    _isProcess = false;
    _followLabel = '不再关注';
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isProcess
          ? null
          : () {
              _follow().then((value) {});
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.attachment,
            size: 20,
            color: Colors.grey,
          ),
          SizedBox(
            width: 10,
          ),
          //如果是地理感知器则关注，如果是管道则有：关注以推送动态给他或关注以接收他的动态
          Text(
            '$_followLabel',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
