import 'dart:convert';

import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoViewMobile extends StatefulWidget {
  PageContext context;

  GeoViewMobile({this.context});

  @override
  _GeoViewMobileState createState() => _GeoViewMobileState();
}

class _GeoViewMobileState extends State<GeoViewMobile> {
  GeoReceptor _receptor;
  String _address;

  @override
  void initState() {
    _loadMobileReceptor().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _receptor = null;
    super.dispose();
  }

  Future<void> _loadMobileReceptor() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    _receptor = await receptorService.getMobileReceptor(
        widget.context.principal.person, widget.context.principal.device);
    var map = jsonDecode(_receptor.location);
    LatLng latLng = LatLng.fromJson(map);
    ReGeocode code =
        await AmapSearch.instance.searchReGeocode(latLng, radius: _receptor.radius);
    _address = code.formatAddress;
  }

  @override
  Widget build(BuildContext context) {
    if (_receptor == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            '地圈感知器',
          ),
        ),
        body: Center(
          child: Text('加载中...'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_receptor.title),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text(
                    '感知半径:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text('${_receptor.radius.toStringAsFixed(0)}米'),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text(
                    '更新距离:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text('${_receptor.uDistance??5}米'),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text(
                    '现在位置:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(_address ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
