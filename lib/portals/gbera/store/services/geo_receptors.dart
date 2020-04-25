import 'dart:convert';
import 'dart:io';

import 'package:amap_core_fluttify/src/dart/models.dart';
import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class GeoReceptorService implements IGeoReceptorService, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IGeoReceptorDAO receptorDAO;
  IGeoReceptorRemote receptorRemote;

  IRemotePorts get remotePorts => site.getService('@.remote.ports');
  IGeoReceptorCache receptorCache;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    receptorDAO = db.geoReceptorDAO;
    receptorRemote = site.getService('/remote/geo/receptors');
    receptorCache = site.getService('/cache/geosphere/receptor');
  }

  @override
  Future<bool> init(Location location) async {
    var mobileReceptor =
        await getMobileReceptor(principal.person, principal.device);
    if (mobileReceptor == null) {
      var receptor = await receptorRemote.getMyMobilReceptor();
      if (receptor != null) {
        await add(receptor, isOnlySaveLocal: true);
        return true;
      }
      var latlng = await location.latLng;
      await add(
        GeoReceptor(
          MD5Util.MD5(Uuid().v1()),
          '${principal.nickName}',
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
          'false',
          principal.person,
        ),
      );
      return true;
    }
    return false;
  }

  @override
  Future<void> add(GeoReceptor receptor, {bool isOnlySaveLocal = false}) async {
    var home = await getApplicationDocumentsDirectory();
    var dir = '${home.path}/images';
    var dirFile = Directory(dir);
    if (!dirFile.existsSync()) {
      dirFile.createSync();
    }
    if (!StringUtil.isEmpty(receptor.leading) &&
        receptor.leading.startsWith("http")) {
      var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(receptor.leading)}';
      var localFile = '$dir/$fn';
      await remotePorts.download(
          '${receptor.leading}?accessToken=${principal.accessToken}',
          localFile);
      receptor.leading = localFile;
    }
    if (!StringUtil.isEmpty(receptor.background) &&
        receptor.background.startsWith("http")) {
      var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(receptor.background)}';
      var localFile = '$dir/$fn';
      await remotePorts.download(
          '${receptor.background}?accessToken=${principal.accessToken}',
          localFile);
      receptor.background = localFile;
    }
    await this.receptorDAO.add(receptor);
    if (!isOnlySaveLocal) {
      await receptorRemote.addReceptor(receptor);
    }
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
  Future<Function> setAutoScrollMessage(
      String receptor, bool isAutoScrollMessage) async {
    await receptorDAO.setAutoScrollMessage(
        isAutoScrollMessage ? 'true' : 'false', receptor, principal.person);
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
  Future<GeoReceptor> get(String category, String receptorid) async {
    GeoReceptor receptor = await receptorDAO.get(receptorid, principal.person);
    if (receptor == null) {
      receptor = await receptorCache.get(category, receptorid);
    }
    return receptor;
  }

  @override
  Future<bool> existsLocal(String category, String receptor) async {
    CountValue count =
        await receptorDAO.countReceptor(receptor, category, principal.person);
    return count != null && count.value > 0;
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
  Future<void> updateLocation(String category,String receptor, LatLng location,{bool isOnlyLocal=false}) async {
    var json = jsonEncode(location.toJson());
    await receptorDAO.updateLocation(json, receptor, principal.person);
    if(!isOnlyLocal) {
      await receptorRemote.updateLocation(category,receptor,json);
    }
    return null;
  }

  @override
  Future<void> updateRadius(String id, double radius) async {
    await receptorDAO.updateRadius(radius, id, principal.person);
    return null;
  }
}

class GeoReceptorCache implements IGeoReceptorCache, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  ISharedPreferences sharedPreferences;
  IGeoReceptorRemote receptorRemote;

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    sharedPreferences = site.getService('@.sharedPreferences');
    receptorRemote = site.getService('/remote/geo/receptors');
  }

  @override
  Future<void> add(GeoReceptor receptor) async {
    var home = await getApplicationDocumentsDirectory();
    var dir = '${home.path}/images';
    var dirFile = Directory(dir);
    if (!dirFile.existsSync()) {
      dirFile.createSync();
    }
    if (!StringUtil.isEmpty(receptor.leading) &&
        receptor.leading.startsWith("http")) {
      var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(receptor.leading)}';
      var localFile = '$dir/$fn';
      await remotePorts.download(
          '${receptor.leading}?accessToken=${principal.accessToken}',
          localFile);
      receptor.leading = localFile;
    }
    if (!StringUtil.isEmpty(receptor.background) &&
        receptor.background.startsWith("http")) {
      var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(receptor.background)}';
      var localFile = '$dir/$fn';
      await remotePorts.download(
          '${receptor.background}?accessToken=${principal.accessToken}',
          localFile);
      receptor.background = localFile;
    }
    var json = jsonEncode(receptor.toMap());
    await sharedPreferences.setString(
        '/geosphere/receptors/${receptor.id}.${receptor.category}', json,
        person: principal.person);
  }

  @override
  Future<GeoReceptor> get(String category, String receptorid) async {
    var json = sharedPreferences.getString(
        '/geosphere/receptors/$receptorid.$category',
        person: principal.person);
    if (StringUtil.isEmpty(json)) {
      return null;
    }
    var map = jsonDecode(json);
    return GeoReceptor.load(map, principal.person);
  }
}
