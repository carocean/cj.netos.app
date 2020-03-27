import 'package:amap_location_fluttify/amap_location_fluttify.dart';

class GeoPoi{
  String address;
  String title;
  LatLng latLng;
  int distance;
  String poiId;
  GeoPoi({this.poiId,this.address, this.title, this.latLng, this.distance});
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
  });
}
