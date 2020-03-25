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

  GeoLocation._();

  Future<Location> get location async {
    if (await requestPermission()) {
      return await AmapLocation.fetchLocation(
        mode: LocationAccuracy.High,
      );
    }
    return null;
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
    AmapLocation.stopLocation();
  }

  Future<void> init() async {
    await enableFluttifyLog(false); // 关闭log
    /// !注意: 只要是返回Future的方法, 一律使用`await`修饰, 确保当前方法执行完成后再执行下一行, 在不能使用`await`修饰的环境下, 在`then`方法中执行下一步.
    /// 初始化 iOS在init方法中设置, android需要去AndroidManifest.xml里去设置, 详见 https://lbs.amap.com/api/android-sdk/gettingstarted
//    await AmapCore.init('2d819189dc47ebef8e38213e7ddc2ed8');
// 连续定位
    if (await requestPermission()) {
      AmapLocation.listenLocation(mode: LocationAccuracy.High)
          .listen((location) async {
        var listeners = _listens.values.toList(growable: false);
        for (var listener in listeners) {
          if (listener.offsetDistance == null || listener.offsetDistance == 0) {
            await listener.callback(location);
            continue;
          }
          if (listener.current == null) {
            var latlng = await location.latLng;
            String city = await location.city;
            if (StringUtil.isEmpty(city)) {
              continue;
            }
            listener.current = latlng;
            await listener.callback(location);
            continue;
          }
          var current = await location.latLng;
          var distance = getDistance(start: current, end: listener.current);
          if (distance < listener.offsetDistance) {
            //没到更新边界
            continue;
          }
          await listener.callback(location);
          listener.current = current;
        }
      });
    }
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
    return '${distance.toStringAsFixed(2)}米';
  }
  return '${(distance / 1000).toStringAsFixed(3)}公里';
}