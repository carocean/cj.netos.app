import 'dart:convert';

import 'package:amap_core_fluttify/src/dart/models.dart';
import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class GeoReceptorService implements IGeoReceptorService, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IGeoReceptorDAO receptorDAO;
  IGeoReceptorRemote receptorRemote;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    receptorDAO = db.geoReceptorDAO;
    receptorRemote = site.getService('/remote/geo/receptors');
  }

  @override
  Future<bool> init(Location location) async {
    var mobileReceptor =
        await getMobileReceptor(principal.person, principal.device);
    if (mobileReceptor == null) {
      var latlng = await location.latLng;
      await add(
        GeoReceptor(
          MD5Util.MD5(Uuid().v1()),
          '我的地圈',
          'mobiles',
          null,
          principal.person,
          jsonEncode(latlng.toJson()),
          1000,
          5,
          DateTime.now().millisecondsSinceEpoch,
          'false',
          'none',
          null,
          'false',
          principal.device,
          principal.person,
        ),
      );
      return true;
    }
    return false;
  }

  @override
  Future<void> add(GeoReceptor receptor) async {
    await this.receptorDAO.add(receptor);
    await receptorRemote.addReceptor(receptor);
  }

  @override
  Future<Function> updateTitle(String id, String title) async {
    await receptorDAO.updateTitle(title, id, principal.person);
  }

  @override
  Future<Function> updateLeading(
      String category, String id, String lleading, String rleading) async {
    await receptorDAO.updateLeading(lleading, category, id, principal.person);
    await receptorRemote.updateLeading(rleading, category, id);
  }

  @override
  Future<Function> setAutoScrollMessage(String receptor, bool isAutoScrollMessage) async{
    await receptorDAO.setAutoScrollMessage(isAutoScrollMessage?'true':'false',receptor, principal.person);
  }

  @override
  Future<Function> updateBackground(
      String receptor, BackgroundMode mode, String file) async {
    var _mode;
    switch (mode) {
      case BackgroundMode.vertical:
        _mode = "vertical";
        break;
      case BackgroundMode.horizontal:
        _mode = "horizontal";
        break;
      case BackgroundMode.none:
        _mode = "none";
        file = null;
        break;
    }
    await receptorDAO.updateBackground(_mode, file, receptor, principal.person);
    var o = await receptorDAO.get(receptor, principal.person);
    if (BackgroundMode.none == mode) {
      await receptorRemote.emptyBackground(o.category, receptor);
    } else {
      await receptorRemote.updateBackground(o.category, receptor, _mode, file);
    }
  }

  @override
  Future<Function> emptyBackground(String receptor) async {
    await receptorDAO.updateBackground('none', '', receptor, principal.person);
    var o = await receptorDAO.get(receptor, principal.person);
    await receptorRemote.emptyBackground(o.category, receptor);
  }

  @override
  Future<Function> updateForeground(
      String receptor, ForegroundMode mode) async {
    var _mode;
    switch (mode) {
      case ForegroundMode.original:
        _mode = 'original';
        break;
      case ForegroundMode.white:
        _mode = 'white';
        break;
    }
    await receptorDAO.updateForeground(_mode, receptor, principal.person);
    var o = await receptorDAO.get(receptor, principal.person);
    await receptorRemote.updateForeground(o.category, receptor, _mode);
  }

  @override
  Future<List<GeoReceptor>> page(int limit, int offset) async {
    return await receptorDAO.page(principal.person, limit, offset);
  }

  @override
  Future<GeoReceptor> get(String id) async {
    return await receptorDAO.get(id, principal.person);
  }

  @override
  Future<GeoReceptor> getMobileReceptor(String person, String device) async {
    return await receptorDAO.getReceptor(
        'mobiles', person, device, principal.person);
  }

  @override
  Future<Function> remove(String category, String id) async {
    await receptorDAO.remove(category, id, principal.person);
    await receptorRemote.removeReceptor(category, id);
  }

  @override
  Future<void> updateLocation(String id, LatLng location) async {
    var json = jsonEncode(location.toJson());
    await receptorDAO.updateLocation(json, id, principal.person);
    return null;
  }

  @override
  Future<void> updateRadius(String id, double radius) async {
    await receptorDAO.updateRadius(radius, id, principal.person);
    return null;
  }
}
