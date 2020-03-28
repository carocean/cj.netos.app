import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';

import '../services.dart';

class GeoCategoryRemote implements IGeoCategoryRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _categoryPortsUrl =>
      site.getService('@.prop.ports.document.geo.category');

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
}
