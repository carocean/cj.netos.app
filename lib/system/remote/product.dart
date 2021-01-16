import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

mixin IProductRemote {
  Future<String> getUseLayoutOfNewestVersion(String id, String os) {}
}

class ProductRemote implements IProductRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  String get productPortsUrl => site.getService('@.prop.ports.uc.product');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<String> getUseLayoutOfNewestVersion(String id, String os) async {
    return await remotePorts.portGET(
      productPortsUrl,
      'getUseLayoutOfNewestVersion',
      parameters: {
        'id': id,
        'os': os,
      },
    );
  }
}
