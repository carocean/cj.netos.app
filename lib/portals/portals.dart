import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/gbera_portal.dart' as gberaPortal;
import 'landagent/landagent_portal.dart' as landagent;
import 'isp/isp_portal.dart' as isp;

///引用函数形式无法使用hot reload即时生效，添加新页后需hot restart，因此改用使用类来定义portal
List<BuildPortal> buildPortals(IServiceProvider site) {
  return <BuildPortal>[
    gberaPortal.GberaPortal().buildPortal,
    landagent.buildPortal,
    isp.buildPortal,
  ];
}
