import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/pages/desktop.dart';
import 'package:netos_app/portals/landagent/pages/event_details.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_freezen.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_stock.dart';
import 'package:netos_app/portals/landagent/pages/weny_bank.dart';
import 'package:netos_app/portals/landagent/styles/blue_styles.dart' as blue;

import 'scaffolds.dart';

var buildPortal = (IServiceProvider site) => Portal(
      id: 'landagent',
      title: '地商门户',
      icon: Icons.add,
      defaultTheme: '/blue',
      buildThemes: (site) => <ThemeStyle>[
        ThemeStyle(
          title: '蓝色',
          desc: '呈现淡蓝，接近白',
          url: '/blue',
          iconColor: Colors.blue[500],
          buildStyle: (site) => blue.buildStyles(site),
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFE1f5fe),
            scaffoldBackgroundColor: Color(0xFFE1f5fe),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFE1f5fe),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.blue[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.blue[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFE1f5fe,
              {
                50: Color(0xFFE1f5fe),
                100: Color(0xffb3e5fc),
                200: Color(0xff81d4fa),
                300: Color(0xff4fc3f7),
                400: Color(0xff29b6f6),
                500: Color(0xff03a9f4),
                600: Color(0xff039be5),
                700: Color(0xFF0288d1),
                800: Color(0xFF0277bd),
                900: Color(0xff01579b),
              },
            ),
          ),
        ),
      ],
      buildDesklets: (site) => <Desklet>[],
      buildPages: (site) => <LogicPage>[
        LogicPage(
          title: '地商',
          subtitle: '',
          icon: Icons.business,
          url: '/',
          buildPage: (PageContext pageContext) => LandagentScaffold(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面',
          subtitle: '',
          icon: Icons.business,
          url: '/desktop',
          buildPage: (PageContext pageContext) => LandagentDesktop(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '事件查看器',
          subtitle: '',
          icon: Icons.business,
          url: '/event/details',
          buildPage: (PageContext pageContext) => LandagentEventDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银银行',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank',
          buildPage: (PageContext pageContext) => WenyBankWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银存量',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/stock',
          buildPage: (PageContext pageContext) => StockWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '资金现量',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/fund',
          buildPage: (PageContext pageContext) => StockWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结资金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/freezen',
          buildPage: (PageContext pageContext) => FreezenWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '自由金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/free',
          buildPage: (PageContext pageContext) => FreezenWenyAccount(
            context: pageContext,
          ),
        ),
      ],
    );
