import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';

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
  });
}
