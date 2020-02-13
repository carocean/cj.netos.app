import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/test/business_entrypoint.dart';
import 'package:netos_app/test/business_test.dart';
import 'package:netos_app/test/gbera_entrypoint.dart';
import 'package:netos_app/test/gbera_test.dart';
import 'package:netos_app/test/system_test.dart';

import 'test/system_entrypoint.dart';

class TestDbService1 implements IDBService{
  @override
  Future<void> init(IServiceProvider site)async {
    print(site.getService('/service2'));
    return ;
  }

}
class TestDbService2 implements IDBService{
  @override
  Future<void> init(IServiceProvider site) async{
    print(site.getService('/service1'));
    return ;
  }

}
void main() => platformRun(AppCreator(
      entrypoint: '/entrypoint',
      title: '金证时代',
      props: {},
  localPrincipalManager: _LocalPrincipalManager(),
      buildSystem: (site) {
        return System(
          defaultTheme: '/grey',
          buildStore: (site) {
            return SystemStore(
              services: {
                '/service1':TestDbService1(),
                '/service2':TestDbService2(),
              },
              loadDatabase: ()async{
                return {'db':'sss'};
              },
            );
          },
          buildThemes: (site){
            return [
              ThemeStyle(
                title: '灰色',
                desc: '呈现淡灰色，接近白',
                url: '/grey',
                iconColor: Colors.grey[500],
                buildStyle: (site) {
                  return <Style>[
                    Style(
                        url: '/desktop/settings/portlet.activeColor',
                        desc: '栏目列表siwtch组件激活色',
                        get: () {
                          return Colors.grey[800];
                        }),
                  ];
                },
                buildTheme: (BuildContext context) {
                  return ThemeData(
                    backgroundColor: Color(0xFFF5F5f5),
                    scaffoldBackgroundColor: Color(0xFFF5F5f5),
                    brightness: Brightness.light,
                    appBarTheme: AppBarTheme.of(context).copyWith(
                      color: Color(0xFFF5F5f5),
                      textTheme: TextTheme(
                        title: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      actionsIconTheme: IconThemeData(
                        color: Colors.grey[700],
                        opacity: 1,
                        size: 20,
                      ),
                      brightness: Brightness.light,
                      iconTheme: IconThemeData(
                        color: Colors.grey[700],
                        opacity: 1,
                        size: 20,
                      ),
                      elevation: 1.0,
                    ),
                    primarySwatch: MaterialColor(
                      0xFFF5F5f5,
                      {
                        50: Color(0xFFE8F5E9),
                        100: Color(0xFFC8E6C9),
                        200: Color(0xFFA5D6A7),
                        300: Color(0xFF81C784),
                        400: Color(0xFF66BB6A),
                        500: Color(0xFF4CAF50),
                        600: Color(0xFF43A047),
                        700: Color(0xFF388E3C),
                        800: Color(0xFF2E7D32),
                        900: Color(0xFF1B5E20),
                      },
                    ),
                  );
                },
              ),
              ThemeStyle(
                title: '绿色',
                desc: '呈现淡绿',
                url: '/green',
                iconColor: Colors.green[500],
                buildStyle: (site) {
                  return <Style>[
                    Style(
                        url: '/desktop/settings/portlet.activeColor',
                        desc: '栏目列表siwtch组件激活色',
                        get: () {
                          return Colors.grey[800];
                        }),
                  ];
                },
                buildTheme: (BuildContext context) {
                  return ThemeData(
                    backgroundColor: Color(0xFFE8F5E9),
                    scaffoldBackgroundColor: Color(0xFFE8F5E9),
                    appBarTheme: AppBarTheme.of(context).copyWith(
                      color: Color(0xFFE8F5E9),
                      textTheme: TextTheme(
                        title: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      actionsIconTheme: IconThemeData(
                        color: Colors.green,
                        opacity: 1,
                        size: 20,
                      ),
                      brightness: Brightness.light,
                      iconTheme: IconThemeData(
                        color: Colors.green,
                        opacity: 1,
                        size: 20,
                      ),
                      elevation: 1.0,
                    ),
                    primarySwatch: MaterialColor(
                      0xFF4CAF50,
                      {
                        50: Color(0xFFE8F5E9),
                        100: Color(0xFFC8E6C9),
                        200: Color(0xFFA5D6A7),
                        300: Color(0xFF81C784),
                        400: Color(0xFF66BB6A),
                        500: Color(0xFF4CAF50),
                        600: Color(0xFF43A047),
                        700: Color(0xFF388E3C),
                        800: Color(0xFF2E7D32),
                        900: Color(0xFF1B5E20),
                      },
                    ),
                  );
                },
              ),
            ];
          },
          buildPages: (site){
            return <Page>[
              Page(
                title: '入口',
                subtitle: '',
                icon: null,
                url: '/entrypoint',
                buildPage: (PageContext pageContext) => SystemEntrypoint(
                  context: pageContext,
                ),
              ),
              Page(
                title: '测试',
                subtitle: '',
                icon: null,
                url: '/test',
                buildPage: (PageContext pageContext) => SystemTest(
                  context: pageContext,
                ),
              ),
            ];
          },
        );
      },
      buildPortals: (site) {
        return <BuildPortal>[
          buildGberaPortal,
          buildBusinessPortal,
        ];
      },

    ));

class _LocalPrincipalManager implements ILocalPrincipalManager{
  String _current='cj@gbera.netos';
  @override
  String current() {
    // TODO: implement current
    return _current;
  }

  @override
  IPrincipal get(String person) {
    return DefaultPrincipal();
  }

}
class DefaultPrincipal implements IPrincipal{
  @override
  // TODO: implement accessToken
  String get accessToken => "23232323";

  @override
  // TODO: implement accountCode
  String get accountCode => "cj";

  @override
  // TODO: implement appid
  String get appid => "gbera.netos";

  @override
  // TODO: implement device
  String get device => 'ge23ss2';

  @override
  // TODO: implement expiretime
  int get expiretime => 239933;

  @override
  // TODO: implement lavatar
  String get lavatar => 'http://sss.com/ss.jpg';

  @override
  // TODO: implement ltime
  int get ltime => 9328823;

  @override
  // TODO: implement nickName
  String get nickName => '赵向彬';

  @override
  // TODO: implement person
  String get person => 'cj@gbera.netos';

  @override
  // TODO: implement portal
  String get portal => 'gbera';

  @override
  // TODO: implement pubtime
  int get pubtime => 23232244;

  @override
  // TODO: implement ravatar
  String get ravatar => '/ss/ee/232.mp3';

  @override
  // TODO: implement refreshToken
  String get refreshToken => 'xxxx';

  @override
  // TODO: implement roles
  String get roles => 'app:users@gbera.netos';

  @override
  // TODO: implement signature
  String get signature => '我是最好的';

  @override
  // TODO: implement uid
  String get uid => '0002393993939393';

}
Portal buildBusinessPortal(IServiceProvider site) {
  return Portal(
      id: 'business',
      title: '',
      icon: null,
      defaultTheme: '/grey',
      buildStore: (site){
        return PortalStore(
          services: {
            '/service1':TestDbService1(),
            '/service2':TestDbService2(),
          },
          loadDatabase:()async{

          },
        );
      },
      buildPages: (site) {
        return <Page>[
          Page(
            title: '入口',
            subtitle: '',
            icon: null,
            url: '/entrypoint',
            buildPage: (PageContext pageContext) => BusinessEntrypoint(
              context: pageContext,
            ),
          ),
          Page(
            title: '测试',
            subtitle: '',
            icon: null,
            url: '/test',
            buildPage: (PageContext pageContext) => BusinessTest(
              context: pageContext,
            ),
          ),
        ];
      },
      buildThemes: (site) {
        return <ThemeStyle>[
          ThemeStyle(
            title: '灰色',
            desc: '呈现淡灰色，接近白',
            url: '/grey',
            iconColor: Colors.grey[500],
            buildStyle: (site) {
              return <Style>[
                Style(
                    url: '/desktop/settings/portlet.activeColor',
                    desc: '栏目列表siwtch组件激活色',
                    get: () {
                      return Colors.grey[800];
                    }),
              ];
            },
            buildTheme: (BuildContext context) {
              return ThemeData(
                backgroundColor: Color(0xFFF5F5f5),
                scaffoldBackgroundColor: Color(0xFFF5F5f5),
                brightness: Brightness.light,
                appBarTheme: AppBarTheme.of(context).copyWith(
                  color: Color(0xFFF5F5f5),
                  textTheme: TextTheme(
                    title: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  actionsIconTheme: IconThemeData(
                    color: Colors.grey[700],
                    opacity: 1,
                    size: 20,
                  ),
                  brightness: Brightness.light,
                  iconTheme: IconThemeData(
                    color: Colors.grey[700],
                    opacity: 1,
                    size: 20,
                  ),
                  elevation: 1.0,
                ),
                primarySwatch: MaterialColor(
                  0xFFF5F5f5,
                  {
                    50: Color(0xFFE8F5E9),
                    100: Color(0xFFC8E6C9),
                    200: Color(0xFFA5D6A7),
                    300: Color(0xFF81C784),
                    400: Color(0xFF66BB6A),
                    500: Color(0xFF4CAF50),
                    600: Color(0xFF43A047),
                    700: Color(0xFF388E3C),
                    800: Color(0xFF2E7D32),
                    900: Color(0xFF1B5E20),
                  },
                ),
              );
            },
          ),
          ThemeStyle(
            title: '绿色',
            desc: '呈现淡绿',
            url: '/green',
            iconColor: Colors.green[500],
            buildStyle: (site) {
              return <Style>[
                Style(
                    url: '/desktop/settings/portlet.activeColor',
                    desc: '栏目列表siwtch组件激活色',
                    get: () {
                      return Colors.grey[800];
                    }),
              ];
            },
            buildTheme: (BuildContext context) {
              return ThemeData(
                backgroundColor: Color(0xFFE8F5E9),
                scaffoldBackgroundColor: Color(0xFFE8F5E9),
                appBarTheme: AppBarTheme.of(context).copyWith(
                  color: Color(0xFFE8F5E9),
                  textTheme: TextTheme(
                    title: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  actionsIconTheme: IconThemeData(
                    color: Colors.green,
                    opacity: 1,
                    size: 20,
                  ),
                  brightness: Brightness.light,
                  iconTheme: IconThemeData(
                    color: Colors.green,
                    opacity: 1,
                    size: 20,
                  ),
                  elevation: 1.0,
                ),
                primarySwatch: MaterialColor(
                  0xFF4CAF50,
                  {
                    50: Color(0xFFE8F5E9),
                    100: Color(0xFFC8E6C9),
                    200: Color(0xFFA5D6A7),
                    300: Color(0xFF81C784),
                    400: Color(0xFF66BB6A),
                    500: Color(0xFF4CAF50),
                    600: Color(0xFF43A047),
                    700: Color(0xFF388E3C),
                    800: Color(0xFF2E7D32),
                    900: Color(0xFF1B5E20),
                  },
                ),
              );
            },
          ),
        ];
      },);
}
Portal buildGberaPortal(IServiceProvider site) {
  return Portal(
    id: 'gbera',
    title: '',
    defaultTheme: '/green',
    icon: null,
    buildPages: (site) {
      return <Page>[
        Page(
          title: '入口',
          subtitle: '',
          icon: null,
          url: '/entrypoint',
          buildPage: (PageContext pageContext) => GberaEntrypoint(
            context: pageContext,
          ),
        ),
        Page(
          title: '测试',
          subtitle: '',
          icon: null,
          url: '/test',
          buildPage: (PageContext pageContext) => GberaTest(
            context: pageContext,
          ),
        ),
      ];
    },
    buildThemes: (site) {
      return <ThemeStyle>[
        ThemeStyle(
          title: '灰色',
          desc: '呈现淡灰色，接近白',
          url: '/grey',
          iconColor: Colors.grey[500],
          buildStyle: (site) {
            return <Style>[
              Style(
                  url: '/desktop/settings/portlet.activeColor',
                  desc: '栏目列表siwtch组件激活色',
                  get: () {
                    return Colors.grey[800];
                  }),
            ];
          },
          buildTheme: (BuildContext context) {
            return ThemeData(
              backgroundColor: Color(0xFFF5F5f5),
              scaffoldBackgroundColor: Color(0xFFF5F5f5),
              brightness: Brightness.light,
              appBarTheme: AppBarTheme.of(context).copyWith(
                color: Color(0xFFF5F5f5),
                textTheme: TextTheme(
                  title: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actionsIconTheme: IconThemeData(
                  color: Colors.grey[700],
                  opacity: 1,
                  size: 20,
                ),
                brightness: Brightness.light,
                iconTheme: IconThemeData(
                  color: Colors.grey[700],
                  opacity: 1,
                  size: 20,
                ),
                elevation: 1.0,
              ),
              primarySwatch: MaterialColor(
                0xFFF5F5f5,
                {
                  50: Color(0xFFE8F5E9),
                  100: Color(0xFFC8E6C9),
                  200: Color(0xFFA5D6A7),
                  300: Color(0xFF81C784),
                  400: Color(0xFF66BB6A),
                  500: Color(0xFF4CAF50),
                  600: Color(0xFF43A047),
                  700: Color(0xFF388E3C),
                  800: Color(0xFF2E7D32),
                  900: Color(0xFF1B5E20),
                },
              ),
            );
          },
        ),
        ThemeStyle(
          title: '绿色',
          desc: '呈现淡绿',
          url: '/green',
          iconColor: Colors.green[500],
          buildStyle: (site) {
            return <Style>[
              Style(
                  url: '/desktop/settings/portlet.activeColor',
                  desc: '栏目列表siwtch组件激活色',
                  get: () {
                    return Colors.grey[800];
                  }),
            ];
          },
          buildTheme: (BuildContext context) {
            return ThemeData(
              backgroundColor: Color(0xFFE8F5E9),
              scaffoldBackgroundColor: Color(0xFFE8F5E9),
              appBarTheme: AppBarTheme.of(context).copyWith(
                color: Color(0xFFE8F5E9),
                textTheme: TextTheme(
                  title: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actionsIconTheme: IconThemeData(
                  color: Colors.green,
                  opacity: 1,
                  size: 20,
                ),
                brightness: Brightness.light,
                iconTheme: IconThemeData(
                  color: Colors.green,
                  opacity: 1,
                  size: 20,
                ),
                elevation: 1.0,
              ),
              primarySwatch: MaterialColor(
                0xFF4CAF50,
                {
                  50: Color(0xFFE8F5E9),
                  100: Color(0xFFC8E6C9),
                  200: Color(0xFFA5D6A7),
                  300: Color(0xFF81C784),
                  400: Color(0xFF66BB6A),
                  500: Color(0xFF4CAF50),
                  600: Color(0xFF43A047),
                  700: Color(0xFF388E3C),
                  800: Color(0xFF2E7D32),
                  900: Color(0xFF1B5E20),
                },
              ),
            );
          },
        ),
      ];
    },
    buildDesklets: (site) {
      return <Desklet>[];
    },
    buildStore: (site) {
      return PortalStore(
        loadDatabase: () {
          return null;
        },
        services: {},
      );
    },
  );
}
