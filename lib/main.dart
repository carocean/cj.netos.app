import 'package:framework/framework.dart';
import 'package:netos_app/portals/portals.dart';

import 'system/local/dao/database.dart';
import 'system/local/local_principals.dart';
import 'system/local/persons.dart';
import 'system/local/principals.dart';
import 'system/system.dart';

void main() => platformRun(
      AppCreator(
        title: '金证时代',
        entrypoint: '/entrypoint',
        appKeyPair: AppKeyPair(
          appid: 'system.netos',
          appKey: '995C2A861BE8064A1F8A022B5C0D2E36',
          appSecret: '6EA4774EE78DCDF0768CA18ECF3AD1DB',
        ),
        props: {
          ///默认应用，即终端未指定应用号时登录或注册的目标应用
          '@.prop.entrypoint.app': 'gbera.netos',
          '@.prop.ports.uc.auth': 'http://47.105.165.186/uc/auth.service',
          '@.prop.ports.uc.register':
              'http://47.105.165.186/uc/register.service',
          '@.prop.ports.uc.person':
              'http://47.105.165.186/uc/person/self.service',
          '@.prop.ports.uc.platform':
              'http://47.105.165.186/uc/platform/self.service',
          '@.prop.fs.delfile': 'http://47.105.165.186:7110/del/file/',
          '@.prop.fs.uploader':
              'http://47.105.165.186:7110/upload/uploader.service',
          '@.prop.fs.reader': 'http://47.105.165.186:7100',
        },
        buildServices: (site) async{
          final database = await $FloorAppDatabase
              .databaseBuilder('app_database.db')
              .build();
          return <String, dynamic>{
              '@.db':database,
          };
        },
        buildSystem: buildSystem,
        buildPortals: buildPortals,
        localPrincipal: DefaultLocalPrincipal(),
      ),
    );

class DefaultLocalPrincipal implements ILocalPrincipal {
  ILocalPrincipalVisitor _visitor;

  @override
  String current() {
    return _visitor?.current();
  }

  @override
  IPrincipal get(String person) {
    return _visitor?.get(person);
  }

  @override
  void setVisitor(ILocalPrincipalVisitor visitor) {
    this._visitor = visitor;
  }
}
