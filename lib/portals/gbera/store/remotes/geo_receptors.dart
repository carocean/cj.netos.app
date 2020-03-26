import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_remote_ports.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/system/local/entities.dart';

mixin IGeoReceptorRemote {
  Future<void> addReceptor(GeoReceptor receptor);

  Future<void> removeReceptor(String category, String id);

  Future<void> updateLeading(String rleading, String category, String id) {}
}

class GeoReceptorRemote implements IGeoReceptorRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _receptorPortsUrl =>
      site.getService('@.prop.ports.document.geo.receptor');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    return null;
  }

  @override
  Future<Function> addReceptor(GeoReceptor receptor) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'addGeoReceptor',
      parameters: {
        'id': receptor.id,
        'title': receptor.title,
        'category': receptor.category,
        'leading': receptor.leading,
        'location': receptor.location,
        'radius': receptor.radius,
        'uDistance': receptor.uDistance,
      },
    );
  }

  @override
  Future<Function> removeReceptor(String category, String id) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'removeGeoReceptor',
      parameters: {
        'id': id,
        'category': category,
      },
    );
  }

  @override
  Future<Function> updateLeading(
      String leading, String category, String id) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'updateLeading',
      parameters: {
        'id': id,
        'category': category,
        'leading': leading,
      },
    );
  }
}
