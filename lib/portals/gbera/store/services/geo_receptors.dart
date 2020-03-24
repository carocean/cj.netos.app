import 'dart:convert';

import 'package:amap_core_fluttify/src/dart/models.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class GeoReceptorService implements IGeoReceptorService, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IGeoReceptorDAO receptorDAO;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    receptorDAO = db.geoReceptorDAO;
  }

  @override
  Future<void> init() async {
    var mobileReceptor = await getReceptor(principal.person, principal.device);
    if (mobileReceptor == null) {
      var local = await geoLocation.location;
      var latlng = await local.latLng;
      add(
        GeoReceptor(
          MD5Util.MD5(Uuid().v1()),
          '我的地圈',
          'mobiles',
          null,
          principal.person,
          jsonEncode(latlng.toJson()),
          1000,
          DateTime.now().millisecondsSinceEpoch,
          principal.device,
          null,
          principal.person,
        ),
      );
    }
  }

  @override
  Future<void> add(GeoReceptor receptor) async {
    this.receptorDAO.add(receptor);
  }

  @override
  Future<Function> updateTitle(String id, String title) async {}

  @override
  Future<Function> updateLeading(String id, String leading) async {}

  @override
  Future<List<GeoReceptor>> page(int limit, int offset) async {
    return await receptorDAO.page(principal.person,limit,offset);
  }

  @override
  Future<GeoReceptor> get(String id) async {
    return await receptorDAO.get(id, principal.person);
  }

  @override
  Future<GeoReceptor> getReceptor(String person, String device) async {
    return await receptorDAO.getReceptor(person, device, principal.person);
  }

  @override
  Future<Function> remove(String id) async {}

  @override
  Future<void> updateLocation(String id, LatLng location) async {
    // TODO: implement updateLocation
    return null;
  }

  @override
  Future<void> updateRadius(String id, LatLng location) async {
    // TODO: implement updateRadius
    return null;
  }
}
