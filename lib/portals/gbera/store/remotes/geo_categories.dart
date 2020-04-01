import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/system/local/entities.dart';

import '../gbera_entities.dart';
import '../services.dart';

class GeoCategoryRemote implements IGeoCategoryRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _categoryPortsUrl =>
      site.getService('@.prop.ports.document.geo.category');

  get _geospherePortsUrl => site.getService('@.prop.ports.link.geosphere');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<GeoCategoryAppOR>> getApps(String category, String on) async {
    var list = await remotePorts.portGET(
      _categoryPortsUrl,
      'listGeoCategoryApp',
      parameters: {'category': category, 'on': on},
    );
    var apps = <GeoCategoryAppOR>[];
    for (var obj in list) {
      apps.add(
        GeoCategoryAppOR(
          title: obj['title'],
          ctime: obj['ctime'],
          id: obj['id'],
          creator: obj['creator'],
          leading: obj['leading'],
          path: obj['path'],
          category: obj['category'],
        ),
      );
    }
    return apps;
  }

  @override
  Future<GeoCategoryOR> getCategory(String category) async {
    var map = await remotePorts.portGET(
      _categoryPortsUrl,
      'getCategory',
      parameters: {'id': category},
    );
    var moveMode = map['moveMode'];
    var lmode = GeoCategoryMoveableMode.unmoveable;
    switch (moveMode) {
      case 'unmoveable':
        lmode = GeoCategoryMoveableMode.unmoveable;
        break;
      case 'moveableSelf':
        lmode = GeoCategoryMoveableMode.moveableSelf;
        break;
      case 'moveableDependon':
        lmode = GeoCategoryMoveableMode.moveableDependon;
        break;
    }
    return GeoCategoryOR(
      id: map['id'],
      creator: map['creator'],
      title: map['title'],
      leading: map['leading'],
      ctime: map['ctime'],
      sort: map['sort'],
      defaultRadius: map['defaultRadius'] ?? 500.00,
      moveMode: lmode,
    );
  }

  @override
  Future<List<GeoCategoryOR>> listCategory() async {
    var list = await remotePorts.portGET(
      _categoryPortsUrl,
      'listCategory',
    );
    List<GeoCategoryOR> categories = [];
    for (var item in list) {
      var moveMode = item['moveMode'];
      var lmode = GeoCategoryMoveableMode.unmoveable;
      switch (moveMode) {
        case 'unmoveable':
          lmode = GeoCategoryMoveableMode.unmoveable;
          break;
        case 'moveableSelf':
          lmode = GeoCategoryMoveableMode.moveableSelf;
          break;
        case 'moveableDependon':
          lmode = GeoCategoryMoveableMode.moveableDependon;
          break;
      }
      categories.add(
        GeoCategoryOR(
          id: item['id'],
          creator: item['creator'],
          title: item['title'],
          leading: item['leading'],
          ctime: item['ctime'],
          sort: item['sort'],
          defaultRadius: item['defaultRadius'] ?? 500.00,
          moveMode: lmode,
        ),
      );
    }
    return categories;
  }

  @override
  Future<List<GeoPOI>> searchAroundReceptors(
      {String categroy,
      String receptor,
      String geoType,
      int limit,
      int offset}) async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'searchAroundReceptors',
      parameters: {
        'category': categroy,
        'receptor': receptor,
        'geoType': geoType,
        'limit': limit,
        'offset': offset,
      },
    );
    IPersonService personService = await site.getService('/gbera/persons');
    List<GeoPOI> pois = [];
    for (var item in list) {
      var receptor = item['receptor'];
      var foregroundMode;
      switch (receptor['foregroundMode']) {
        case 'white':
          foregroundMode = ForegroundMode.white;
          break;
        case 'original':
          foregroundMode = ForegroundMode.original;
          break;
      }
      var backgroundMode;
      switch (receptor['backgroundMode']) {
        case 'none':
          backgroundMode = BackgroundMode.none;
          break;
        case 'vertical':
          backgroundMode = BackgroundMode.vertical;
          break;
        case 'horizontal':
          backgroundMode = BackgroundMode.horizontal;
          break;
      }
      var category = await getCategory(receptor['category']);
      var creator = await personService.getPerson(receptor['creator']);
      pois.add(
        GeoPOI(
            categoryOR: category,
            creator: creator,
            distance: item['distance'],
            receptor: ReceptorInfo(
              foregroundMode: foregroundMode,
              backgroundMode: backgroundMode,
              background: receptor['background'],
              uDistance: receptor['uDistance'],
              radius: receptor['radius'],
              latLng: LatLng.fromJson(receptor['location']),
              title: receptor['title'],
              leading: receptor['leading'],
              id: receptor['id'],
              creator: receptor['creator'],
              category: receptor['category'],
              isMobileReceptor: receptor['category'] == 'mobiles',
              offset: item['distance'],
            )),
      );
    }
    return pois;
  }

  @override
  Future<List<GeoPOF>> pageReceptorFans(
      {String categroy, String receptor, int limit, int offset}) async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'pageReceptorFans',
      parameters: {
        'category': categroy,
        'receptor': receptor,
        'limit': limit,
        'skip': offset,
      },
    );
    IPersonService personService = await site.getService('/gbera/persons');
    var pofList = <GeoPOF>[];
    for (var pof in list) {
      var follow = pof['follow'];
      var person = await personService.getPerson(follow['person']);
      pofList.add(
        GeoPOF(
          person: person,
          distance: pof['distance'],
        ),
      );
    }
    return pofList;
  }

  @override
  Future<List<ChannelOR>> listReceptorChannels() async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'listReceptorChannels',
    );
    List<ChannelOR> channels = [];
    for (var item in list) {
      channels.add(
        ChannelOR(
          creator: item['creator'],
          leading: item['leading'],
          title: item['title'],
          ctime: item['ctime'],
          channel: item['channel'],
          inPersonSelector: item['inPersonSelector'],
          outGeoSelector: item['outGeoSelector'],
          outPersonSelector: item['outPersonSelector'],
        ),
      );
    }
    return channels;
  }
}
