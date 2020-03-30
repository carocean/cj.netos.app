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

  GeoPoi.from(String poiJson) {
    var map = jsonDecode(poiJson);
    poiId = map['poiId'];
    address = map['address'];
    latLng = LatLng.fromJson(jsonDecode(map['latLng']));
    title = map['title'];
    distance = map['distance'];
  }
}

enum BackgroundMode {
  vertical,
  horizontal,
  none,
}
enum ForegroundMode {
  original,
  white,
}

class OnRecetorBackgroundChangedEvent {
  String action;
  Map<String, dynamic> args;

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
    this.backgroundMode = BackgroundMode.none,
    this.foregroundMode = ForegroundMode.original,
    this.onBackgroudChanged,
    this.origin,
  });
}

class GeosphereMessageOR {
  String id;
  String upstreamPerson;

//如果是从网流来的消息
  String upstreamChannel;
  String sourceSite;
  String sourceApp;
  String receptor;
  String creator;
  int ctime;
  int atime;
  int rtime;
  int dtime;
  String state;
  String text;
  double wy;

  ///location是GEOPoi对象
  LatLng location;
  String category;

  GeosphereMessageOR({
    this.id,
    this.upstreamPerson,
    this.upstreamChannel,
    this.sourceSite,
    this.sourceApp,
    this.receptor,
    this.creator,
    this.ctime,
    this.atime,
    this.rtime,
    this.dtime,
    this.state,
    this.text,
    this.wy,
    this.location,
    this.category,
  });

  GeosphereMessageOR.form(GeosphereMessageOL ol) {
    this.id = ol.id;
    this.upstreamPerson = ol.upstreamPerson;
    this.upstreamChannel = ol.upstreamChannel;
    this.sourceSite = ol.sourceSite;
    this.sourceApp = ol.sourceApp;
    this.receptor = ol.receptor;
    this.creator = ol.creator;
    this.ctime = ol.ctime;
    this.atime = ol.atime;
    this.rtime = ol.rtime;
    this.dtime = ol.dtime;
    this.state = ol.state;
    this.text = ol.text;
    this.wy = ol.wy;
    this.location = LatLng.fromJson(jsonDecode(ol.location));
    this.category = ol.category;
  }

  Map toMap() {
    return {
      'id': id,
      'upstreamPerson': upstreamPerson,
      'upstreamChannel': upstreamChannel,
      'sourceSite': sourceSite,
      'sourceApp': sourceApp,
      'receptor': receptor,
      'creator': creator,
      'ctime': ctime,
      'atime': atime,
      'rtime': rtime,
      'dtime': dtime,
      'state': state,
      'text': text,
      'wy': wy,
      'location': location.toJson(),
      'category': category,
    };
  }
}
