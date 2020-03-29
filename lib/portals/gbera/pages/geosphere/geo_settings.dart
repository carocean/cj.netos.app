import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoSettings extends StatefulWidget {
  PageContext context;

  GeoSettings({this.context});

  @override
  _GeoSettingsState createState() => _GeoSettingsState();
}

class _GeoSettingsState extends State<GeoSettings> {
  ReceptorInfo _receptor;
  String _poiTitle;
  GeoCategoryMoveableMode _moveMode;

  @override
  void initState() {
    _receptor = widget.context.page.parameters['receptor'];
    var mode = widget.context.page.parameters['moveMode'];
    switch (mode) {
      case 'unmoveable':
        _moveMode = GeoCategoryMoveableMode.unmoveable;
        break;
      case 'moveableSelf':
        _moveMode = GeoCategoryMoveableMode.moveableSelf;
        break;
      case 'moveableDependon':
        _moveMode = GeoCategoryMoveableMode.moveableDependon;
        break;
    }
    _loadLocation().then((v) {
      setState(() {});
    });
    geoLocation.listen('receptor.settings', 1, _updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('receptor.settings');
    _receptor = null;
    super.dispose();
  }

  Future<void> _loadLocation() async {
    var list = await AmapSearch.searchAround(_receptor.latLng,
        radius: 2000, type: amapPOIType);
    if (list == null || list.isEmpty) {
      return;
    }
    _poiTitle = await list[0].title;
  }

  Future<void> _updateLocation(Location location) async {
    if (_moveMode == 'unmoveable') {
      return;
    }
//    _poiAddress = await location.address;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        _getUDistanceItem(),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '位置',
                          tipsText: '${_poiTitle ?? ''}附近',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '半径',
                          tipsText:
                              '${_receptor.radius < 1000 ? '${_receptor.radius.toStringAsFixed(0)}米' : '${(_receptor.radius / 1000.0).toStringAsFixed(3)}公里'}',
                          leading: Icon(
                            FontAwesomeIcons.streetView,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
//                      borderRadius: BorderRadius.all(
//                        Radius.circular(8),
//                      ),
//                      boxShadow: [
//                        BoxShadow(
//                          color: Colors.grey,
//                          offset: Offset(0, 10),
//                          blurRadius: 10,
//                          spreadRadius: -9,
//                        ),
//                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '我的动态',
//                          tipsText: '发表210篇',
                          leading: Icon(
                            FontAwesomeIcons.font,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onItemTap: () {
                            widget.context.forward('/geosphere/portal');
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '圈内实时发现',
                          tipsText: '2894个',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '事件',
                          tipsText: '进圈、离圈',
                          leading: Icon(
                            FontAwesomeIcons.streetView,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
//                      borderRadius: BorderRadius.all(
//                        Radius.circular(8),
//                      ),
//                      boxShadow: [
//                        BoxShadow(
//                          color: Colors.grey,
//                          offset: Offset(0, 10),
//                          blurRadius: 10,
//                          spreadRadius: -9,
//                        ),
//                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '网关',
                          tipsText: '开、关一些信息的接收和发送',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward(
                          '/geosphere/receptor/settings/background',
                          arguments: {'receptor': _receptor});
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: <Widget>[
                          CardItem(
                            title: '背景设置',
                            tipsText: '',
                            leading: Icon(
                              Icons.settings_ethernet,
                              color: Colors.grey,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getUDistanceItem() {
    var title;
    var tips;
    var tail;
    bool enableButton=false;
    switch (_moveMode) {
      case GeoCategoryMoveableMode.unmoveable:
        title = '固定感知器';
        tail = Icon(
          Icons.remove,
          size: 16,
          color: Colors.white,
        );
        break;
      case GeoCategoryMoveableMode.moveableSelf:
        title = '移动感知器';
        tips = '更新距离：${getFriendlyDistance(_receptor.uDistance * 1.0)}';
        enableButton=true;
        break;
      case GeoCategoryMoveableMode.moveableDependon:
        title = '依赖感知器';
        tips = '该感知器依赖于我的地圈的位置更新通知';
        tail = Icon(
          Icons.remove,
          size: 16,
          color: Colors.white,
        );
        break;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:!enableButton?null: () {},
      child: CardItem(
        title: title,
        tipsText: tips,
        leading: Icon(
          Icons.category,
          color: Colors.grey,
          size: 24,
        ),
        tail: tail,
      ),
    );
  }
}
