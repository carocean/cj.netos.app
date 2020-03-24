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
  Future<List<GeoCategory>> listCategory() async {
    var list = await remotePorts.portGET(
      _categoryPortsUrl,
      'listCategory',
    );
    List<GeoCategory> categories = [];
    for (var item in list) {
      categories.add(
        GeoCategory(
          creator: item['creator'],
          id: item['id'],
          title: item['title'],
          ctime: item['ctime'],
          sort: item['sort'],
          isDependon: item['isDependon'],
        ),
      );
    }
    return categories;
  }
}
