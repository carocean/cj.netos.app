import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_prices.dart';
import 'package:netos_app/portals/landagent/pages/desktop.dart';
import 'package:netos_app/portals/landagent/pages/event_details.dart';
import 'package:netos_app/portals/landagent/pages/exchange_details.dart';
import 'package:netos_app/portals/landagent/pages/mine.dart';
import 'package:netos_app/portals/landagent/pages/org_la.dart';
import 'package:netos_app/portals/landagent/pages/purchase_details.dart';
import 'package:netos_app/portals/landagent/pages/shunter_rules.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_absorb.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_free.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_freezen.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_fund.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_isp.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_platform.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_shunters.dart';
import 'package:netos_app/portals/landagent/pages/weny_account_stock.dart';
import 'package:netos_app/portals/landagent/pages/weny_apply.dart';
import 'package:netos_app/portals/landagent/pages/weny_bank.dart';
import 'package:netos_app/portals/landagent/pages/weny_bill_free.dart';
import 'package:netos_app/portals/landagent/pages/weny_bill_freezen.dart';
import 'package:netos_app/portals/landagent/pages/weny_bill_fund.dart';
import 'package:netos_app/portals/landagent/pages/weny_bill_shunt.dart';
import 'package:netos_app/portals/landagent/pages/weny_bill_stock.dart';
import 'package:netos_app/portals/landagent/pages/weny_market.dart';
import 'package:netos_app/portals/landagent/pages/weny_parameters.dart';
import 'package:netos_app/portals/landagent/pages/weny_records.dart';
import 'package:netos_app/portals/landagent/pages/weny_trades.dart';
import 'package:netos_app/portals/landagent/remote/bills.dart';
import 'package:netos_app/portals/landagent/remote/org.dart';
import 'package:netos_app/portals/landagent/remote/records.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:netos_app/portals/landagent/styles/blue_styles.dart' as blue;
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

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
      builderSceneServices: (site) async {
        return <String, dynamic>{
          '/org/la': OrgLaRemote(),
          '/org/workflow': WorkflowRemote(),
          '/wybank/remote': WybankRemote(),
          '/wybank/bill/prices': PriceRemote(),
          '/wybank/records': WybankRecordRemote(),
          '/wybank/bills': WenyBillRemote(),
        };
      },
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
          title: '我',
          subtitle: '',
          icon: Icons.business,
          url: '/mine',
          buildPage: (PageContext pageContext) => Mine(
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
          title: '地商信息',
          subtitle: '',
          icon: Icons.business,
          url: '/org/la',
          buildPage: (PageContext pageContext) => OrgLAPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申请纹银银行',
          subtitle: '',
          icon: Icons.business,
          url: '/apply/wybank',
          buildPage: (PageContext pageContext) => ApplyWyBank(
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
          buildPage: (PageContext pageContext) => LAPurchaseDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '承兑明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/details/exchange',
          buildPage: (PageContext pageContext) => LAExchangeDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '账金账户',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/shunters',
          buildPage: (PageContext pageContext) => ShuntersWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/stock',
          buildPage: (PageContext pageContext) => LAStockWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申购记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/purchase',
          buildPage: (PageContext pageContext) => PurchaseRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '承兑记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/exchange',
          buildPage: (PageContext pageContext) => ExchangeRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '资金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/fund',
          buildPage: (PageContext pageContext) => LAFundWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '分账记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/shunt',
          buildPage: (PageContext pageContext) => ShuntRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/freezen',
          buildPage: (PageContext pageContext) => LAFreezenWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '自由金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/free',
          buildPage: (PageContext pageContext) => LAFreeWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地商分账账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/shunt',
          buildPage: (PageContext pageContext) => ShuntWenyBill(
            context: pageContext,
          ),
        ),
      ],
    );
