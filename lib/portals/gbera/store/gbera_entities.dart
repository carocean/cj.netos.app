import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoPOI{
  ReceptorInfo receptor;
  double distance;
  GeoCategoryOR categoryOR;
  Person creator;
  GeoPOI({this.categoryOR,this.receptor, this.distance,this.creator});
}

class GeoPOF{
  Person person;
  double distance;
  GeoPOF({this.person,this.distance,});
}
class ChannelOR{
  String channel;
  String title;
  String leading;
  String creator;
  String inPersonSelector;
  String outPersonSelector;//only_select, all_except,
  String outGeoSelector;//true,false;
  int ctime;

  ChannelOR(
      {this.channel,
      this.title,
      this.leading,
      this.creator,
      this.inPersonSelector,
      this.outPersonSelector,
      this.outGeoSelector,
      this.ctime});
}