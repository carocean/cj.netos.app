import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/avatar.dart';
import 'package:netos_app/portals/gbera/errors/errors.dart';
import 'package:netos_app/system/local/cache/channel_cache.dart';
import 'package:netos_app/system/local/cache/person_cache.dart';
import 'package:netos_app/system/remote/persons.dart';

import 'entrypoint.dart';
import 'local/local_principals.dart';
import 'local/persons.dart';
import 'local/principals.dart';
import 'login.dart';
import 'register.dart';

System buildSystem(IServiceProvider site) {
  return System(
    defaultTheme: '/grey',
    builderSceneServices: (site) async {
      return <String, dynamic>{};
    },
    builderShareServices: (site) async {
      return <String, dynamic>{
        "/principals": PrincipalService(),
        "/local/principals":DefaultLocalPrincipalManager(),
        "/gbera/persons": PersonService(),
        '/remote/persons':PersonRemote(),
        '/cache/persons':PersonCache(),
        '/cache/channels':ChannelCache(),
      };
    },
    buildThemes: buildThemes,
    buildPages: buildPages,
  );
}

List<ThemeStyle> buildThemes(site) {
  return <ThemeStyle>[
    ThemeStyle(
      title: '灰色',
      desc: '呈现淡灰色，接近白',
      url: '/grey',
      iconColor: Colors.grey[500],
      buildStyle: (site) {
        return <Style>[];
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
  ];
}

List<Page> buildPages(site) {
  return <Page>[
    Page(
      title: '控件，截取头像',
      subtitle: '',
      icon: null,
      url: '/widgets/avatar',
      buildPage: (PageContext pageContext) => GberaAvatar(
        context: pageContext,
      ),
    ),
    Page(
      title: '入口检测',
      subtitle: '',
      icon: null,
      url: '/public/entrypoint',
      buildPage: (PageContext pageContext) => EntryPoint(
        context: pageContext,
      ),
    ),
    Page(
      title: '登录',
      subtitle: '',
      icon: null,
      url: '/public/login',
      buildPage: (PageContext pageContext) => LoginPage(
        context: pageContext,
      ),
    ),
    Page(
      title: '注册',
      subtitle: '',
      icon: null,
      url: '/public/register',
      buildPage: (PageContext pageContext) => RegisterPage(
        context: pageContext,
      ),
    ),
    Page(
      title: '出错啦',
      subtitle: '',
      icon: null,
      url: '/error',
      buildPage: (PageContext pageContext) => GberaError(
        context: pageContext,
      ),
    ),
  ];
}
