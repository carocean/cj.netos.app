import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

final IReceptorOpener receptorOpener = _DefaultReceptorOpener();
mixin IReceptorOpener {
  Future<void> open(PageContext context, String id,
      Future<bool> Function(GeoReceptor receptor) beforeOpen);
}

class _DefaultReceptorOpener implements IReceptorOpener {
  @override
  Future<void> open(PageContext context, String id,
      Future<bool> Function(GeoReceptor receptor) beforeOpen) async{
    IGeoReceptorService receptorService =
    context.site.getService('/geosphere/receptors');
    var receptor=await receptorService.get(id);
    if (receptor == null) {
      return;
    }
    bool entrySurface=true;
    if (beforeOpen != null) {
      entrySurface= await beforeOpen(receptor);
    }
    if(!entrySurface){
      return;
    }
    var url;
    if (receptor.creator == context.principal.person) {
      //每人只能有一个手机行人地圈
      if (receptor.category == 'mobiles') {
        url = '/geosphere/receptor.lord';
      } else {
        url = '/geosphere/receptor.mines';
      }
    } else {
      url = '/geosphere/receptor.fans';
    }
    await context.forward(url, arguments: {
      'receptor': ReceptorInfo.create(receptor),
    });
  }
}
