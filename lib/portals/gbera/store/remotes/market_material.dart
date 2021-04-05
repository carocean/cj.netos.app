import 'package:framework/framework.dart';

mixin IMarketMaterialRemote {
  Future<List<Map<String, Object>>> pageMaterial(
      int materialId, int limit, int offset);

  Future<List<Map<String, Object>>> searchMaterial(
      String query, int materialId, int limit, int offset) {}

  Future<Map<String, dynamic>> createTaoPWD(
      String userId, String text, String url, String logo) {}
}

class TaobaoMarketMaterialRemote
    implements IMarketMaterialRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get materialPortsUrl => site.getService('@.prop.ports.market.material');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    return null;
  }

  @override
  Future<List<Map<String, Object>>> pageMaterial(
      int materialId, int limit, int offset) async {
    List list = await remotePorts.portGET(
      materialPortsUrl,
      'pageMaterial',
      parameters: {
        'materialId': materialId,
        'limit': limit,
        'offset': offset,
      },
    );
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, Object>>> searchMaterial(
      String query, int materialId, int limit, int offset) async {
    List list = await remotePorts.portGET(
      materialPortsUrl,
      'searchMaterial',
      parameters: {
        'query': query,
        'materialId': materialId,
        'limit': limit,
        'offset': offset,
      },
    );
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createTaoPWD(
      String userId, String text, String url, String logo) async {
    return await remotePorts.portGET(
      materialPortsUrl,
      'createTaoPWD',
      parameters: {
        'userId': userId,
        'text': text,
        'url': url,
        'logo': logo,
      },
    );
  }
}
