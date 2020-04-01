import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class GeosphereReceptorDiscovery extends StatefulWidget {
  PageContext context;

  GeosphereReceptorDiscovery({this.context});

  @override
  _GeosphereReceptorDiscoveryState createState() =>
      _GeosphereReceptorDiscoveryState();
}

class _GeosphereReceptorDiscoveryState
    extends State<GeosphereReceptorDiscovery> {
  EasyRefreshController _controller;
  GeoCategoryOL _categoryOL;
  ReceptorInfo _receptor;
  int _limit = 15, _offset = 0;
  String _selectedCategory;
  String _selectedFilterLabel = '筛选';
  List<GeoPOI> _poiList = [];
  bool _isLoad = false;

  @override
  void initState() {
    _receptor = widget.context.parameters['receptor'];
    _loadCagetory().then((v) {});
    _onloadDiscoveryReceptors().then((v) {
      setState(() {});
    });
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _isLoad = false;
    _controller.dispose();
    _poiList.clear();
    super.dispose();
  }

  Future<void> _loadCagetory() async {
    IGeoCategoryLocal local =
        widget.context.site.getService('/geosphere/categories');
    _categoryOL = await local.get(_receptor.category);
  }

  Future<void> _onloadDiscoveryReceptors() async {
    _isLoad = false;
    IGeoCategoryRemote categoryRemote =
        widget.context.site.getService('/remote/geo/categories');
    var poiList = await categoryRemote.searchAroundReceptors(
      categroy: _receptor.category,
      receptor: _receptor.id,
      geoType: _selectedCategory,
      limit: _limit,
      offset: _offset,
    );
    if (poiList.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      _isLoad = true;
      return;
    }
    _offset += poiList.length;
    _poiList.addAll(poiList);
    _isLoad = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: '${_receptor.title}',
            children: [
              TextSpan(
                text: '实时成员',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
            ),
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return widget.context.part('/geosphere/filter', context,
                          arguments: {'category': _categoryOL});
                    }).then((v) {
                  if (v == null) {
                    return;
                  }
                  if (v == 'clear') {
                    _selectedFilterLabel = '筛选';
                    _selectedCategory = '';
                    _offset = 0;
                    _poiList.clear();

                    _onloadDiscoveryReceptors().then((v) {
                      setState(() {});
                    });
                    return;
                  }
                  _selectedFilterLabel = v['title'];
                  _selectedCategory = v['category'];
                  _offset = 0;
                  _poiList.clear();
                  _onloadDiscoveryReceptors().then((v) {
                    setState(() {});
                  });
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${_selectedFilterLabel ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 2,
                    ),
                    child: Icon(
                      FontAwesomeIcons.filter,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: EasyRefresh(
              onLoad: _onloadDiscoveryReceptors,
              controller: _controller,
              child: ListView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                children: _getReceptorWidgets(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getReceptorWidgets() {
    var list = <Widget>[];
    if (_poiList.isEmpty) {
      if (_isLoad) {
        list.add(
          Center(
            child: Text('没有发现'),
          ),
        );
        return list;
      }
      list.add(
        Center(
          child: Text('加载中...'),
        ),
      );
      return list;
    }
    for (var poi in _poiList) {
      String leading;
      var title;
      var subtitle;
      if (poi.categoryOR.id == 'mobiles') {
        leading = poi.creator.avatar;
        title = poi.creator.nickName;
        subtitle = '行人';
      } else {
        leading = poi.receptor.leading;
        title = poi.receptor.title;
        subtitle = poi.categoryOR.title;
      }
      var leadingImg;
      if (StringUtil.isEmpty(leading)) {
        leadingImg = Image.asset(
          'lib/portals/gbera/images/netflow.png',
          width: 40,
          height: 40,
        );
      } else if (leading.startsWith('/')) {
        leadingImg = Image.file(
          File(leading),
          width: 40,
          height: 40,
        );
      } else {
        leadingImg = Image.network(
          '$leading?accessToken=${widget.context.principal.accessToken}',
          width: 40,
          height: 40,
        );
      }
      list.add(
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              CardItem(
                leading: leadingImg,
                title: title,
                subtitle: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                tipsText: poi.receptor.id == _receptor.id
                    ? '感知器中心'
                    : '距中心：${getFriendlyDistance(poi.distance)}',
              ),
              Divider(
                height: 1,
                indent: 50,
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }
}
