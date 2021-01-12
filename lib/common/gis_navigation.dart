import 'dart:io';
import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showNavigationDialog({LatLng latLng, BuildContext context}) async {
  showBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return _GisMapList(latLng: latLng);
    },
  );
}

Future<void> showNavigationDialog2(
    {LatLng latLng, GlobalKey<ScaffoldState> key}) async {
  key.currentState.showBottomSheet(
    (context) {
      return _GisMapList(latLng: latLng);
    },
    backgroundColor: Colors.transparent,
  );
}

class _GisMapList extends StatefulWidget {
  LatLng latLng;

  _GisMapList({this.latLng});

  @override
  __GisMapListState createState() => __GisMapListState();
}

class __GisMapListState extends State<_GisMapList> {
  LatLng latLng;
  List<Widget> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    latLng = widget.latLng;
    _load();
    super.initState();
  }

  Future<void> _load() async {
    var style = TextStyle(
      fontSize: 16,
    );
    if (await GisMapUtil.checkBaiduMap(latLng.longitude, latLng.latitude)) {
      _list.add(
        InkWell(
          onTap: () {
            GisMapUtil.gotoBaiduMap(latLng.longitude, latLng.latitude);
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                Icon(
                  IconData(0xe62a, fontFamily: 'gis_map'),
                  size: 30,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '百度地图',
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      _list.add(
        Divider(
          height: 1,
        ),
      );
    }
    if (await GisMapUtil.checkAMap(latLng.longitude, latLng.latitude)) {
      _list.add(
        InkWell(
          onTap: () {
            GisMapUtil.gotoAMap(latLng.longitude, latLng.latitude);
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                Icon(
                  IconData(0xe6fe, fontFamily: 'gis_map'),
                  size: 30,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '高德地图',
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      _list.add(
        Divider(
          height: 1,
        ),
      );
    }
    if (await GisMapUtil.checkTencentMap(latLng.longitude, latLng.latitude)) {
      _list.add(
        InkWell(
          onTap: () {
            GisMapUtil.gotoTencentMap(latLng.longitude, latLng.latitude);
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                Icon(
                  IconData(0xe61e, fontFamily: 'gis_map'),
                  size: 30,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '腾讯地图',
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      _list.add(
        Divider(
          height: 1,
        ),
      );
    }
    if (await GisMapUtil.checkAppleMap(latLng.longitude, latLng.latitude)) {
      _list.add(
        InkWell(
          onTap: () {
            GisMapUtil.gotoAppleMap(latLng.longitude, latLng.latitude);
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                Icon(
                  IconData(0xe60b, fontFamily: 'gis_map'),
                  size: 30,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '苹果地图',
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_list.isEmpty) {
      _list.add(
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '地微支持百度、高德、腾讯、苹果地图，在你的手机上没有检测到',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: _isLoading
                ? Container(
                    padding: EdgeInsets.all(20),
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '正在检测本地地图...',
                    ),
                  )
                : Column(
                    children: _list,
                  ),
          ),
          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              color: Colors.white,
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              alignment: Alignment.center,
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GisMapUtil {
  /// 高德地图
  static Future<bool> checkAMap(longitude, latitude) async {
    var url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=$latitude&lon=$longitude&dev=0&style=2';
    bool canLaunchUrl = await canLaunch(url);
    return canLaunchUrl;
  }

  /// 高德地图
  static Future<bool> gotoAMap(longitude, latitude) async {
    var url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=$latitude&lon=$longitude&dev=0&style=2';

    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
      print('未检测到高德地图~');
      return false;
    }

    await launch(url);

    return true;
  }

  /// 腾讯地图
  static Future<bool> checkTencentMap(longitude, latitude) async {
    var url =
        'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=$latitude,$longitude&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';
    bool canLaunchUrl = await canLaunch(url);
    return canLaunchUrl;
  }

  /// 腾讯地图
  static Future<bool> gotoTencentMap(longitude, latitude) async {
    var url =
        'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=$latitude,$longitude&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';
    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
      print('未检测到腾讯地图~');
      return false;
    }

    await launch(url);

    return canLaunchUrl;
  }

  /// 百度地图
  static Future<bool> checkBaiduMap(longitude, latitude) async {
    var url =
        'baidumap://map/direction?destination=$latitude,$longitude&coord_type=bd09ll&mode=driving';
    bool canLaunchUrl = await canLaunch(url);
    return canLaunchUrl;
  }

  /// 百度地图
  static Future<bool> gotoBaiduMap(longitude, latitude) async {
    var url =
        'baidumap://map/direction?destination=$latitude,$longitude&coord_type=bd09ll&mode=driving';

    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
      print('未检测到百度地图~');
      return false;
    }

    await launch(url);

    return canLaunchUrl;
  }

  /// 苹果地图
  static Future<bool> checkAppleMap(longitude, latitude) async {
    var url = 'http://maps.apple.com/?&daddr=$latitude,$longitude';
    bool canLaunchUrl = await canLaunch(url);
    return canLaunchUrl;
  }

  /// 苹果地图
  static Future<bool> gotoAppleMap(longitude, latitude) async {
    var url = 'http://maps.apple.com/?&daddr=$latitude,$longitude';

    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
      print('打开失败~');
      return false;
    }

    await launch(url);
  }
}
