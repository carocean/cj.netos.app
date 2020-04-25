import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoSettingsLord extends StatefulWidget {
  PageContext context;

  GeoSettingsLord({this.context});

  @override
  _GeoSettingsLordState createState() => _GeoSettingsLordState();
}

class _GeoSettingsLordState extends State<GeoSettingsLord> {
  ReceptorInfo _receptor;
  String _poiTitle;
  GeoCategoryMoveableMode _moveMode;
  bool _switchMessageATipMode = false;

  @override
  void initState() {
    _receptor = widget.context.page.parameters['receptor'];
    _switchMessageATipMode = _receptor.isAutoScrollMessage;

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
      if (mounted) {
        setState(() {});
      }
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateMessageArrivedMode() async {
    _receptor.isAutoScrollMessage = _switchMessageATipMode;
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    await receptorService.setAutoScrollMessage(
        _receptor.id, _receptor.isAutoScrollMessage);
    if (_receptor.onSettingsChanged != null) {
      await _receptor.onSettingsChanged(
        OnReceptorSettingsChangedEvent(
          action: 'scrollMessageMode',
          args: {
            'isAutoScrollMessage': _receptor.isAutoScrollMessage,
          },
        ),
      );
    }
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
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '实时成员',
                          tipsText: '能相互收到对方消息',
                          leading: Icon(
                            Icons.cached,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/receptor/settings/links/discovery_receptors',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '粉丝',
                          tipsText: '能收到本感知器消息',
                          leading: Icon(
                            Icons.supervisor_account,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/receptor/settings/links/fans',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                        _moveMode != GeoCategoryMoveableMode.moveableSelf
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Divider(
                                height: 1,
                                indent: 35,
                              ),
                        _moveMode != GeoCategoryMoveableMode.moveableSelf
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : CardItem(
                                title: '网流消息接收网关',
                                tipsText: '能接收网流消息到感知器',
                                leading: Icon(
                                  Icons.security,
                                  color: Colors.grey,
                                  size: 23,
                                ),
                                onItemTap: () {
                                  widget.context.forward(
                                      '/geosphere/receptor/settings/links/netflow_gateway');
                                },
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
                            widget.context.forward(
                              '/geosphere/portal.owner',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '本地动态',
//                          tipsText: '发表210篇',
                          leading: Icon(
                            FontAwesomeIcons.history,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/hostories',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
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
                          onItemTap: () {
                            widget.context.forward(
                                '/geosphere/receptor/settings/background',
                                arguments: {'receptor': _receptor});
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '消息到达模式',
                          tipsText: '自动滚屏还是接收为提示消息',
                          leading: Icon(
                            Icons.refresh,
                            color: Colors.grey,
                            size: 25,
                          ),
                          tail: SizedBox(
                            height: 25,
                            child: Switch.adaptive(
                              value: _switchMessageATipMode,
                              onChanged: (v) {
                                _switchMessageATipMode = v;
                                _updateMessageArrivedMode();
                                setState(() {});
                              },
                            ),
                          ),
                          onItemTap: () {
                            _switchMessageATipMode = !_switchMessageATipMode;
                            _updateMessageArrivedMode();
                            setState(() {});
                          },
                        ),
                      ],
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
    bool enableButton = false;
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
        enableButton = true;
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
      onTap: !enableButton ? null : () {},
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
