import 'package:amap_location_fluttify/amap_location_fluttify.dart';

class GeoPoi{
  String address;
  String title;
  LatLng latLng;
  int distance;
  String poiId;
  GeoPoi({this.poiId,this.address, this.title, this.latLng, this.distance});
}