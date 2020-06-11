import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/landagent/pages/desktop.dart';
import 'package:netos_app/portals/landagent/pages/event_details.dart';
import 'package:netos_app/portals/landagent/styles/blue_styles.dart' as blue;
import 'package:netos_app/portals/nodepower/pages/desktop.dart';
import 'package:netos_app/portals/nodepower/pages/mine.dart';
import 'package:netos_app/portals/nodepower/pages/organization.dart';
import 'package:netos_app/portals/nodepower/pages/workbench.dart';
import 'package:netos_app/portals/nodepower/scaffolds.dart';

var buildPortal = (IServiceProvider site) => Portal(
      id: 'nodepower',
      title: '节点动力企业门户',
      icon: Icons.add,
      defaultTheme: '/orange',
      buildThemes: (site) => <ThemeStyle>[
        ThemeStyle(
          title: '橙色',
          desc: '淘宝色',
          url: '/orange',
          iconColor: Colors.deepOrangeAccent,
          buildStyle: (site) => blue.buildStyles(site),
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFFBE9E7),
            scaffoldBackgroundColor: Color(0xFFFBE9E7),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFFBE9E7),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.orange[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.orange[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFFBE9E7,
              {
                50: Color(0xFFFBE9E7),
                100: Color(0xFFFCCBC),
                200: Color(0xFFFAB91),
                300: Color(0xFF8A65),
                400: Color(0xFFF7043),
                500: Color(0xFFF5722),
                600: Color(0xFF4511E),
                700: Color(0xFFE64A19),
                800: Color(0xFFD84315),
                900: Color(0xFFBF360C),
              },
            ),
          ),
        ),
      ],
      buildDesklets: (site) => <Desklet>[],
      buildPages: (site) => <LogicPage>[
        LogicPage(
          title: '运营商',
          subtitle: '',
          icon: Icons.business,
          url: '/',
          buildPage: (PageContext pageContext) => NodePowerScaffold(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面',
          subtitle: '',
          icon: Icons.business,
          url: '/desktop',
          buildPage: (PageContext pageContext) => NodePowerDesktop(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工作台',
          subtitle: '',
          icon: Icons.business,
          url: '/workbench',
          buildPage: (PageContext pageContext) => Workbench(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '组织架构',
          subtitle: '',
          icon: Icons.business,
          url: '/organization',
          buildPage: (PageContext pageContext) => Organization(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '我',
          subtitle: '',
          icon: Icons.business,
          url: '/mine',
          buildPage: (PageContext pageContext) => Mine(
            context: pageContext,
          ),
        ),
      ],
    );
