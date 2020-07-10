import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_account_freezen.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_account_stock.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/isp/pages/adopt/adopt_wybank.dart';
import 'package:netos_app/portals/isp/pages/desktop.dart';
import 'package:netos_app/portals/isp/pages/event_details.dart';
import 'package:netos_app/portals/isp/pages/land_agents.dart';
import 'package:netos_app/portals/isp/pages/mine.dart';
import 'package:netos_app/portals/isp/pages/org_isp.dart';
import 'package:netos_app/portals/isp/pages/org_la.dart';
import 'package:netos_app/portals/isp/pages/shunter_rules.dart';
import 'package:netos_app/portals/isp/pages/weny_account_absorb.dart';
import 'package:netos_app/portals/isp/pages/weny_account_free.dart';
import 'package:netos_app/portals/isp/pages/weny_account_fund.dart';
import 'package:netos_app/portals/isp/pages/weny_account_isp.dart';
import 'package:netos_app/portals/isp/pages/weny_account_platform.dart';
import 'package:netos_app/portals/isp/pages/weny_bank.dart';
import 'package:netos_app/portals/isp/pages/weny_market.dart';
import 'package:netos_app/portals/isp/styles/orange_styles.dart' as orange;
import 'package:netos_app/portals/landagent/remote/org.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'scaffolds.dart';

var buildPortal = (IServiceProvider site) => Portal(
      id: 'isp',
      title: '运营商门户',
      icon: Icons.add,
      defaultTheme: '/orange',
      buildThemes: (site) => <ThemeStyle>[
        ThemeStyle(
          title: '橙色',
          desc: '淘宝色',
          url: '/orange',
          iconColor: Colors.deepOrangeAccent,
          buildStyle: orange.buildStyles,
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
                100: Color(0xFFFFCCBC),
                200: Color(0xFFFFAB91),
                300: Color(0xFFFF8A65),
                400: Color(0xFFFF7043),
                500: Color(0xFFFF5722),
                600: Color(0xFFF4511E),
                700: Color(0xFFE64A19),
                800: Color(0xFFD84315),
                900: Color(0xFFBF360C),
              },
            ),
          ),
        ),
      ],
      builderSceneServices: (site) async {
        return <String, dynamic>{
          '/org/isp': IspRemote(),
          '/org/la':LaRemote(),
          '/org/la2':OrgLaRemote(),
          '/org/licence':LicenceRemote(),
          '/org/workflow':WorkflowRemote(),
          '/wybank/remote': WybankRemote(),
        };
      },
      buildDesklets: (site) => <Desklet>[],
      buildPages: (site) => <LogicPage>[
        LogicPage(
          title: '运营商',
          subtitle: '',
          icon: Icons.business,
          url: '/',
          buildPage: (PageContext pageContext) => IspScaffold(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面',
          subtitle: '',
          icon: Icons.business,
          url: '/desktop',
          buildPage: (PageContext pageContext) => IspDesktop(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地商',
          subtitle: '地商列表界面',
          icon: Icons.business,
          url: '/landagents',
          buildPage: (PageContext pageContext) => LandAgentsPage(
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
        LogicPage(
          title: '事件查看器',
          subtitle: '',
          icon: Icons.business,
          url: '/event/details',
          buildPage: (PageContext pageContext) => IspEventDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看运营商信息',
          subtitle: '',
          icon: Icons.business,
          url: '/org/isp',
          buildPage: (PageContext pageContext) => OrgISPPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看运营商信息',
          subtitle: '',
          icon: Icons.business,
          url: '/org/la',
          buildPage: (PageContext pageContext) => OrgLAPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银市场',
          subtitle: '',
          icon: Icons.business,
          url: '/market',
          buildPage: (PageContext pageContext) => WenyMarket(
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
          buildPage: (PageContext pageContext) => FundWenyAccount(
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
          buildPage: (PageContext pageContext) => FreeWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '平台',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/platform',
          buildPage: (PageContext pageContext) => PlatformWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '运营商',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/isp',
          buildPage: (PageContext pageContext) => IspWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网络洇金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/absorb',
          buildPage: (PageContext pageContext) => AbsorbWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '分账规则',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/shunters',
          buildPage: (PageContext pageContext) => ShunterRuleWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银银行已阅',
          subtitle: '',
          icon: Icons.business,
          url: '/adopt/wenybank',
          buildPage: (PageContext pageContext) => AdoptWybank(
            context: pageContext,
          ),
        ),
      ],
    );
