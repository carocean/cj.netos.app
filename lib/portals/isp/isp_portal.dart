import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_prices.dart';
import 'package:netos_app/portals/isp/pages/adopt/adopt_wybank.dart';
import 'package:netos_app/portals/isp/pages/desktop.dart';
import 'package:netos_app/portals/isp/pages/event_details.dart';
import 'package:netos_app/portals/isp/pages/exchange_details.dart';
import 'package:netos_app/portals/isp/pages/land_agents.dart';
import 'package:netos_app/portals/isp/pages/mine.dart';
import 'package:netos_app/portals/isp/pages/org_isp.dart';
import 'package:netos_app/portals/isp/pages/org_la.dart';
import 'package:netos_app/portals/isp/pages/purchase_details.dart';
import 'package:netos_app/portals/isp/pages/shunter_rules.dart';
import 'package:netos_app/portals/isp/pages/weny_absorber_details.dart';
import 'package:netos_app/portals/isp/pages/weny_absorber_details_more.dart';
import 'package:netos_app/portals/isp/pages/weny_absorber_location.dart';
import 'package:netos_app/portals/isp/pages/weny_account_absorb.dart';
import 'package:netos_app/portals/isp/pages/weny_account_free.dart';
import 'package:netos_app/portals/isp/pages/weny_account_freezen.dart';
import 'package:netos_app/portals/isp/pages/weny_account_fund.dart';
import 'package:netos_app/portals/isp/pages/weny_account_la.dart';
import 'package:netos_app/portals/isp/pages/weny_account_platform.dart';
import 'package:netos_app/portals/isp/pages/weny_account_shunters.dart';
import 'package:netos_app/portals/isp/pages/weny_account_stock.dart';
import 'package:netos_app/portals/isp/pages/weny_bank.dart';
import 'package:netos_app/portals/isp/pages/weny_bank_info.dart';
import 'package:netos_app/portals/isp/pages/weny_bill_free.dart';
import 'package:netos_app/portals/isp/pages/weny_bill_freezen.dart';
import 'package:netos_app/portals/isp/pages/weny_bill_fund.dart';
import 'package:netos_app/portals/isp/pages/weny_bill_hubtails.dart';
import 'package:netos_app/portals/isp/pages/weny_bill_shunt.dart';
import 'package:netos_app/portals/isp/pages/weny_bill_stock.dart';
import 'package:netos_app/portals/isp/pages/weny_geo_recipients_records.dart';
import 'package:netos_app/portals/isp/pages/weny_invest_records.dart';
import 'package:netos_app/portals/isp/pages/weny_market.dart';
import 'package:netos_app/portals/isp/pages/weny_parameters.dart';
import 'package:netos_app/portals/isp/pages/weny_records.dart';
import 'package:netos_app/portals/isp/pages/weny_robot.dart';
import 'package:netos_app/portals/isp/pages/weny_robot_absorbers.dart';
import 'package:netos_app/portals/isp/pages/weny_simple_recipients_records.dart';
import 'package:netos_app/portals/isp/pages/weny_trades.dart';
import 'package:netos_app/portals/isp/pages/weny_withdraw_records.dart';
import 'package:netos_app/portals/isp/styles/orange_styles.dart' as orange;
import 'package:netos_app/portals/landagent/remote/bills.dart';
import 'package:netos_app/portals/landagent/remote/org.dart';
import 'package:netos_app/portals/landagent/remote/records.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
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
          '/org/la': LaRemote(),
          '/org/la2': OrgLaRemote(),
          '/org/licence': LicenceRemote(),
          '/org/workflow': WorkflowRemote(),
          '/wybank/remote': WybankRemote(),
          '/wybank/bill/prices': PriceRemote(),
          '/wybank/records': WybankRecordRemote(),
          '/wybank/bills': WenyBillRemote(),
          '/wybank/robot': RobotRemote(),
          '/wallet/records': WalletRecordRemote(),
          '/wallet/trades': WalletTradeRemote(),
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
          title: '福利中心',
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
          buildPage: (PageContext pageContext) => IspStockWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '资金现量',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/fund',
          buildPage: (PageContext pageContext) => IspFundWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结资金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/freezen',
          buildPage: (PageContext pageContext) => IspFreezenWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '自由金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/free',
          buildPage: (PageContext pageContext) => IspFreeWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '平台',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/platform',
          buildPage: (PageContext pageContext) => IspPlatformWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地商',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/la',
          buildPage: (PageContext pageContext) => LaWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网络洇金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/absorb',
          buildPage: (PageContext pageContext) => IspAbsorbWenyAccount(
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
          title: '福利中心已阅',
          subtitle: '',
          icon: Icons.business,
          url: '/adopt/wenybank',
          buildPage: (PageContext pageContext) => AdoptWybank(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行交易明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/trades',
          buildPage: (PageContext pageContext) => WenyTradesPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行参数',
          subtitle: '市盈率、账比等',
          icon: Icons.business,
          url: '/weny/parameters',
          buildPage: (PageContext pageContext) => WenyParametersPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申购明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/details/purchase',
          buildPage: (PageContext pageContext) => IspPurchaseDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '承兑明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/details/exchange',
          buildPage: (PageContext pageContext) => IspExchangeDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/stock',
          buildPage: (PageContext pageContext) => IspStockWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申购记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/purchase',
          buildPage: (PageContext pageContext) => IspPurchaseRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '承兑记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/exchange',
          buildPage: (PageContext pageContext) => IspExchangeRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '分账记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/shunt',
          buildPage: (PageContext pageContext) => IspShuntRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '账金账户',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/shunters',
          buildPage: (PageContext pageContext) => IspShuntersWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '资金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/fund',
          buildPage: (PageContext pageContext) => IspFundWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/freezen',
          buildPage: (PageContext pageContext) => IspFreezenWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '自由金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/free',
          buildPage: (PageContext pageContext) => IspFreeWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '运营商分账账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/shunt',
          buildPage: (PageContext pageContext) => IspShuntWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取中心',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/robot',
          buildPage: (PageContext pageContext) => IspRobotPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取器列表',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/robot/absorbers',
          buildPage: (PageContext pageContext) => RobotAbsorbersPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '尾金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/hubTails',
          buildPage: (PageContext pageContext) => IspHubTailsWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取人资金记录',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/recipients/records/simple',
          buildPage: (PageContext pageContext) =>
              SimpleAbsorberRecipientsRecordsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取人资金记录',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/recipients/records/geo',
          buildPage: (PageContext pageContext) =>
              GeoAbsorberRecipientsRecordsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '投资记录',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/records/invest',
          buildPage: (PageContext pageContext) => InvestRecordsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '投资记录',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/records/withdraw',
          buildPage: (PageContext pageContext) => IspWithdrawRecordsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取器详情',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/robot/absorbers/details',
          buildPage: (PageContext pageContext) => AbsorberDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取器详情',
          subtitle: '更多配置',
          icon: Icons.business,
          url: '/weny/robot/absorbers/details/more',
          buildPage: (PageContext pageContext) =>
              WenyAbsorberDetailsMorePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看洇取器位置',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/absorber/location',
          buildPage: (PageContext pageContext) => AbsorberLocationPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看福利中心信息',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bank/info',
          buildPage: (PageContext pageContext) => IspWenyBankInfoPage(
            context: pageContext,
          ),
        ),
      ],
    );
