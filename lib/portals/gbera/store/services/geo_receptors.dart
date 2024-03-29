import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
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
  IRobotRemote robotRemote;

  IRemotePorts get remotePorts => site.getService('@.remote.ports');
  IGeoReceptorCache receptorCache;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    receptorDAO = db.geoReceptorDAO;
    receptorRemote = site.getService('/remote/geo/receptors');
    receptorCache = site.getService('/cache/geosphere/receptor');
    robotRemote = site.getService('/remote/robot');
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
      var latlng = location.latLng;
      var reGeocode=await AmapSearch.instance.searchReGeocode(latlng,radius: 200);
      var townCode =reGeocode.townCode;
      var myDevice = GeoReceptor(
        MD5Util.MD5(Uuid().v1()),
        '${principal.nickName}',
        townCode,
        'transits',
        'mobiles',
        null,
        'moveableSelf',
        principal.avatarOnRemote,
        principal.person,
        jsonEncode(latlng.toJson()),
        1000,
        100,
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
        'false',
        'none',
        null,
        'false',
        principal.device,
        'false',
        principal.person,
      );
      await add(myDevice);
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
    var leading = receptor.leading;
    if (!StringUtil.isEmpty(leading) && leading.startsWith("http")) {
      var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(leading)}';
      var localFile = '$dir/$fn';
      await remotePorts.download(
          '$leading?accessToken=${principal.accessToken}', localFile);
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

    if (!isOnlySaveLocal) {
      receptor.leading = leading;
      await receptorRemote.addReceptor(receptor);
    }

    await this.receptorDAO.add(receptor);

  }

  @override
  Future<Function> updateTitle(String id, String title) async {
    await receptorDAO.updateTitle(title, id, principal.person);
  }

  @override
  Future<Function> updateLeading(
      String id, String lleading, String rleading) async {
    await receptorDAO.updateLeading(lleading, id, principal.person);
    await receptorRemote.updateLeading(rleading, id);
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
    if (BackgroundMode.none == mode) {
      await receptorRemote.emptyBackground(receptor);
    } else {
      await receptorRemote.updateBackground(receptor, _mode, file);
    }
  }

  @override
  Future<Function> emptyBackground(String receptor) async {
    await receptorDAO.updateBackground('none', '', receptor, principal.person);
    await receptorRemote.emptyBackground(receptor);
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
    await receptorRemote.updateForeground(receptor, _mode);
  }

  @override
  Future<List<GeoReceptor>> page(int limit, int offset) async {
    return await receptorDAO.page(principal.person, limit, offset);
  }

  @override
  Future<GeoReceptor> get(String receptorid) async {
    GeoReceptor receptor = await receptorDAO.get(receptorid, principal.person);
    if (receptor == null) {
      receptor = await receptorCache.get(receptorid);
    }
    return receptor;
  }

  @override
  Future<bool> existsLocal(String receptor) async {
    CountValue count =
        await receptorDAO.countReceptor(receptor, principal.person);
    return count != null && count.value > 0;
  }

  @override
  Future<GeoReceptor> getMobileReceptor(String person, String device) async {
    return await receptorDAO.getReceptor(
        'mobiles', person, device, principal.person);
  }

  @override
  Future<GeoReceptor> getMobileReceptor2(String person) async{
    return await receptorDAO.getReceptor2(
        'mobiles', person, principal.person);
  }

  @override
  Future<Function> remove(String id) async {
    await receptorDAO.remove(id, principal.person);
    await receptorRemote.removeReceptor(id);
  }

  @override
  Future<void> updateLocation(String receptor, LatLng location,
      {bool isOnlyLocal = false}) async {
    var json = jsonEncode(location.toJson());
    await receptorDAO.updateLocation(json, receptor, principal.person);
    if (!isOnlyLocal) {
      await receptorRemote.updateLocation(receptor, json);
      // var receptorObj = await receptorDAO.get(receptor, principal.person);
      // if (receptorObj.moveMode != 'unmoveable') {
      //   var absorbabler = 'geo.receptor/$receptor';
      //   var absorber = await robotRemote.getAbsorberByAbsorbabler(absorbabler);
      //   if (absorber != null) {
      //     await robotRemote.updateAbsorberLocation(
      //         absorber.absorber.id, location);
      //   }
      // }
    }
    return null;
  }

  @override
  Future<void> updateRadius(String id, double radius) async {
    await receptorDAO.updateRadius(radius, id, principal.person);
    return null;
  }

  @override
  Future<Function> updateUtime(String receptor)async {
    await receptorDAO.updateUtime(DateTime.now().millisecondsSinceEpoch,receptor,principal.person);
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
        '/geosphere/receptors/${receptor.id}', json,
        person: principal.person);
  }

  @override
  Future<GeoReceptor> get(String receptorid) async {
    var json = sharedPreferences.getString('/geosphere/receptors/$receptorid',
        person: principal.person);
    if (StringUtil.isEmpty(json)) {
      return null;
    }
    var map = jsonDecode(json);
    return GeoReceptor.load(map,'true', principal.person);
  }
}
