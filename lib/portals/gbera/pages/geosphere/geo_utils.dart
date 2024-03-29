import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as Math;

Future<bool> requestPermission() async {
  final permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.location]);

  if (permissions[PermissionGroup.location] == PermissionStatus.granted) {
    return true;
  } else {
    print('需要定位权限!');
    return false;
  }
}

class _GeoLocationListener {
  double offsetDistance = 0;
  LatLng current;
  Function(Location location) callback;

  _GeoLocationListener({this.offsetDistance, this.callback});
}

final geoLocation = GeoLocation._();

class GeoLocation {
  Map<String, _GeoLocationListener> _listens = {};
  bool _isStarted = false;
  Location _current;

  GeoLocation._();

  Future<Location> get location async {
    if (_current != null) {
      return _current;
    }
    //以下代码注释掉，原因：在使用一次性和侦听并用时，侦听会失效
    if (!_isStarted && await requestPermission()) {
      _current = await AmapLocation.instance.fetchLocation(
        mode: LocationAccuracy.High,
      );
      start();
      return _current;
    }
    return _current;
  }

  void listen(String listener, double offsetDistance,
      Function(Location location) callback) {
    _listens[listener] = _GeoLocationListener(
        callback: callback, offsetDistance: offsetDistance);
  }

  void unlisten(String listener) {
    _listens.remove(listener);
  }

  void stop() {
    if (!_isStarted) {
      return;
    }
    AmapLocation.instance.stopLocation();
    _isStarted = false;
  }

  void forceStop() {
    AmapLocation.instance.stopLocation();
    _isStarted = false;
  }

  Future<void> start() async {
    if (_isStarted) {
      return;
    }

// 连续定位
    if (await requestPermission()) {
      _isStarted = true;
      await for (var location in AmapLocation.instance.listenLocation(
          mode: LocationAccuracy.High, timeout: Duration(minutes: 60))) {
        _current = location;
        var listeners = _listens.values.toList(growable: false);
        for (var listener in listeners) {
          try {
            if (listener.offsetDistance == null ||
                listener.offsetDistance == 0) {
              await listener.callback(location);
              continue;
            }
            if (listener.current == null) {
              var latlng = location.latLng;
              String city = location.city;
              if (StringUtil.isEmpty(city)) {
                continue;
              }
              listener.current = latlng;
              await listener.callback(location);
              continue;
            }
            var current = location.latLng;
            var distance = getDistance(start: current, end: listener.current);
            if (distance < listener.offsetDistance) {
              //没到更新边界
              continue;
            }
            await listener.callback(location);
            listener.current = current;
          } catch (e) {
            print('地理位置执行失败:$e');
            continue;
          }
        }
      }
    }
  }

  void setOffsetDistance(String listener, double offsetDistance) {
    var the = _listens[listener];
    if (the == null) {
      return;
    }
    the.offsetDistance = offsetDistance;
  }
}

/*
 * 计算两点之间距离
 * @param start
 * @param end
 * @return 米
 */
double getDistance({LatLng start, LatLng end}) {
  double lat1 = (Math.pi / 180) * start.latitude;
  double lat2 = (Math.pi / 180) * end.latitude;

  double lon1 = (Math.pi / 180) * start.longitude;
  double lon2 = (Math.pi / 180) * end.longitude;

//      double Lat1r = (Math.PI/180)*(gp1.getLatitudeE6()/1E6);
//      double Lat2r = (Math.PI/180)*(gp2.getLatitudeE6()/1E6);
//      double Lon1r = (Math.PI/180)*(gp1.getLongitudeE6()/1E6);
//      double Lon2r = (Math.PI/180)*(gp2.getLongitudeE6()/1E6);

  //地球半径
  double R = 6371;

  //两点间距离 km，如果想要米的话，结果*1000就可以了
  double d = Math.acos(Math.sin(lat1) * Math.sin(lat2) +
          Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1)) *
      R;

  return d * 1000;
}

String getFriendlyDistance(double distance) {
  if (distance < 1000) {
    return '${distance.toStringAsFixed(0)}米';
  }
  return '${(distance / 1000).toStringAsFixed(3)}公里';
}

final amapPOIType =
    '汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施';
