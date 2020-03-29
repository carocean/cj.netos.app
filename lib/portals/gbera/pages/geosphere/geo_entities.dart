import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoPoi {
  String address;
  String title;
  LatLng latLng;
  int distance;
  String poiId;

  GeoPoi({this.poiId, this.address, this.title, this.latLng, this.distance});

  String toJson() {
    return jsonEncode({
      'address': address,
      'title': title,
      'latLng': jsonEncode(latLng.toJson()),
      'distance': distance,
      'poiId': poiId,
    });
  }

  GeoPoi.from(String location) {
    var map = jsonDecode(location);
    poiId = map['poiId'];
    address = map['address'];
    latLng = LatLng.fromJson(jsonDecode(map['latLng']));
    title = map['title'];
    distance = map['distance'];
  }
}
enum BackgroundMode{
  vertical,horizontal,none,
}
enum ForegroundMode{
  original,white,
}
class OnRecetorBackgroundChangedEvent{
  String action;
  Map<String,dynamic> args;

  OnRecetorBackgroundChangedEvent({this.action, this.args});
}
class ReceptorInfo {
  String id;
  String title;
  String leading;
  bool isMobileReceptor;
  String creator;
  double offset;
  String category;
  LatLng latLng;
  double radius;
  int uDistance;
  ForegroundMode foregroundMode;
  ///vertical|horizontal|none
  BackgroundMode backgroundMode;
  String background;
  Future<void> Function(OnRecetorBackgroundChangedEvent e) onBackgroudChanged;
  GeoReceptor origin;
  ReceptorInfo({
    this.id,
    this.title,
    this.leading,
    this.isMobileReceptor = false,
    this.creator,
    this.offset,
    this.category,
    this.latLng,
    this.radius,
    this.uDistance,
    this.background,
    this.backgroundMode=BackgroundMode.none,
    this.foregroundMode=ForegroundMode.original,
    this.onBackgroudChanged,
    this.origin,
  });
}
