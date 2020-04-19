import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoPOI {
  ReceptorInfo receptor;
  double distance;
  GeoCategoryOR categoryOR;
  Person creator;

  GeoPOI({this.categoryOR, this.receptor, this.distance, this.creator});
}

class GeoPOF {
  Person person;
  double distance;

  GeoPOF({
    this.person,
    this.distance,
  });
}

class ChannelOR {
  String channel;
  String title;
  String leading;
  String creator;
  String inPersonSelector;
  String outPersonSelector; //only_select, all_except,
  String outGeoSelector; //true,false;
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

class GeoPOD {
  GeosphereMessageOR message;
  double distance;

  GeoPOD({this.message, this.distance});

  GeoPOD.parse(pod) {
    this.distance = pod['distance'];
    var doc = pod['document'];
    message = GeosphereMessageOR(
      ctime: doc['ctime'],
      creator: doc['creator'],
      category: doc['category'],
      id: doc['id'],
      receptor: doc['receptor'],
      text: doc['text'],
      location: LatLng.fromJson(doc['location']),
      wy: doc['wy'],
      atime: doc['atime'],
      dtime: doc['dtime'],
      rtime: doc['rtime'],
      sourceApp: doc['sourceApp'],
      sourceSite: doc['sourceSite'],
      state: doc['state'],
      upstreamChannel: doc['upstreamChannel'],
      upstreamPerson: doc['upstreamPerson'],
    );
  }
}

