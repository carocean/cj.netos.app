import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/avatar.dart';
import 'package:netos_app/common/icons.dart';
import 'package:netos_app/common/location_map.dart';
import 'package:netos_app/common/media_watcher.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/box_view.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/content_box.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/content_provider.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/person_view.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/pool_view.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/traffic_pools.dart';
import 'package:netos_app/portals/gbera/pages/screen/screen_popup.dart';
import 'package:netos_app/portals/gbera/pages/system/fq_view.dart';
import 'package:netos_app/portals/gbera/pages/system/tiptool_view.dart';
import 'package:netos_app/portals/gbera/pages/system/wo_flow.dart';
import 'package:netos_app/portals/gbera/pages/system/wo_view.dart';
import 'package:netos_app/portals/gbera/pages/wallet/fission-mf-record-recharge.dart';
import 'package:netos_app/portals/gbera/pages/wallet/recharge_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/withdraw_details.dart';
import 'package:netos_app/portals/gbera/store/remotes/channels.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_helper.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tipoff.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/operation_screen.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_prices.dart';
import 'package:netos_app/portals/gbera/store/services/channel_pin.dart';
import 'package:netos_app/portals/gbera/store/services/channels.dart';
import 'package:netos_app/portals/landagent/remote/bills.dart';
import 'package:netos_app/portals/landagent/remote/records.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:netos_app/portals/landagent/styles/blue_styles.dart' as blue;
import 'package:netos_app/portals/nodepower/pages/account_details.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/adopt_isp.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/adopt_la.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/adopt_wybank.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/ttm_config_dialog.dart';
import 'package:netos_app/portals/nodepower/pages/channel_bill.dart';
import 'package:netos_app/portals/nodepower/pages/colleagues.dart';
import 'package:netos_app/portals/nodepower/pages/create_workflow.dart';
import 'package:netos_app/portals/nodepower/pages/create_workgroup.dart';
import 'package:netos_app/portals/nodepower/pages/desktop.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/help_create.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/help_feedback.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/tipoff_direct.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/tipoff_direct_flow.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/tipoff_object.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/tipoff_object_flow.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/tiptool_create.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/tiptool_main.dart';
import 'package:netos_app/portals/nodepower/pages/feedback/wo_flows.dart';
import 'package:netos_app/portals/nodepower/pages/fission/FissionMFAbsorbAccountPage.dart';
import 'package:netos_app/portals/nodepower/pages/fission/FissionMFBusinessAccountPage.dart';
import 'package:netos_app/portals/nodepower/pages/fission/FissionMFIncomeAccountPage.dart';
import 'package:netos_app/portals/nodepower/pages/mine.dart';
import 'package:netos_app/portals/nodepower/pages/platform_fund.dart';
import 'package:netos_app/portals/nodepower/pages/screen/create_subject.dart';
import 'package:netos_app/portals/nodepower/pages/screen/popup_rule.dart';
import 'package:netos_app/portals/nodepower/pages/screen/screen_main.dart';
import 'package:netos_app/portals/nodepower/pages/screen/view_subject.dart';
import 'package:netos_app/portals/nodepower/pages/view_colleague.dart';
import 'package:netos_app/portals/nodepower/pages/weny/exchange_details.dart';
import 'package:netos_app/portals/nodepower/pages/weny/purchase_details.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_absorber_details.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_absorber_details_more.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_absorber_location.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_absorb.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_free.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_freezen.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_fund.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_isp.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_la.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_shunters.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_account_stock.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bank.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bank_info.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bill_free.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bill_freezen.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bill_fund.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bill_hubtails.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bill_shunt.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_bill_stock.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_geo_recipients_records.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_invest_records.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_market.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_parameters.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_records.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_robot.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_robot_absorbers.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_simple_recipients_records.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_trades.dart';
import 'package:netos_app/portals/nodepower/pages/weny/weny_withdraw_records.dart';
import 'package:netos_app/portals/nodepower/pages/workbench.dart';
import 'package:netos_app/portals/nodepower/pages/workflow_details.dart';
import 'package:netos_app/portals/nodepower/pages/workflow_manager.dart';
import 'package:netos_app/portals/nodepower/pages/workgroup_details.dart';
import 'package:netos_app/portals/nodepower/pages/workgroup_manager.dart';
import 'package:netos_app/portals/nodepower/remote/fission-mf-accounts.dart';
import 'package:netos_app/portals/nodepower/remote/fission-mf-records.dart';
import 'package:netos_app/portals/nodepower/remote/uc_remote.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:netos_app/portals/nodepower/remote/workgroup_remote.dart';
import 'package:netos_app/portals/nodepower/scaffolds.dart';
import 'package:netos_app/system/pages/person_card.dart';

import 'desklets/desklet_workflow.dart';

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
      buildDesklets: (site) => <Desklet>[
        Desklet(
          title: '工作',
          url: '/workflow',
          icon: Icons.group_work,
          subtitle: '',
          desc: '',
          buildDesklet: (portlet, desklet, context) {
            return WorkflowDesklet(
              context: context,
              desklet: desklet,
              portlet: portlet,
            );
          },
        )
      ],
      builderSceneServices: (site) async {
        return <String, dynamic>{
          '/remote/org/workflow': WorkflowRemote(),
          '/remote/org/workgroup': WorkgroupRemote(),
          '/remote/org/isp': IspRemote(),
          '/remote/org/la': LaRemote(),
          '/remote/org/licence': LicenceRemote(),
          '/uc/app': AppRemote(),
          '/wybank/remote': WybankRemote(),
          '/wybank/bill/prices': PriceRemote(),
          '/wybank/records': WybankRecordRemote(),
          '/wybank/bills': WenyBillRemote(),
          '/wybank/robot': RobotRemote(),
          '/wallet/records': WalletRecordRemote(),
          '/wallet/trades': WalletTradeRemote(),
          '/wallet/payChannels': PayChannelRemote(),
          '/wallet/accounts': WalletAccountRemote(),
          '/feedback/woflow': WOFlowRemote(),
          '/feedback/helper': HelperRemote(),
          '/feedback/tipoff': TipOffRemote(),
          '/feedback/tiptool': TipToolRemote(),
          '/operation/screen': DefaultScreenRemote(),
          '/wallet/fission/mf/cashier': FissionMFCashierRemote(),
          '/wallet/fission/mf/account': FissionMFAccountRemote(),
          '/wallet/fission/mf/account/records': FissionMFRecordRemote(),
          '/wallet/fission/mf/cashier/record': FissionMFCashierRecordRemote(),
          '/remote/chasechain/recommender': ChasechainRecommenderRemote(),
          '/remote/geo/receptors': GeoReceptorRemote(),
          '/remote/channels': ChannelRemote(),
          '/netflow/channels': ChannelService(),
          '/channel/pin': ChannelPinService(),
        };
      },
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
          title: '同事',
          subtitle: '',
          icon: Icons.business,
          url: '/colleagues',
          buildPage: (PageContext pageContext) => ColleaguePage(
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
          title: '图片',
          subtitle: '',
          icon: Icons.business,
          url: '/widgets/avatar',
          buildPage: (PageContext pageContext) => GberaAvatar(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工作流管理',
          subtitle: '',
          icon: Icons.business,
          url: '/work/workflow',
          buildPage: (PageContext pageContext) => WorkflowManager(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '创建工作流程',
          subtitle: '',
          icon: Icons.business,
          url: '/work/createWorkflow',
          buildPage: (PageContext pageContext) => CreateWorkflow(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工作流详情',
          subtitle: '',
          icon: Icons.business,
          url: '/work/workflow/details',
          buildPage: (PageContext pageContext) => WorkflowDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工作组管理',
          subtitle: '',
          icon: Icons.business,
          url: '/work/workgroup',
          buildPage: (PageContext pageContext) => WorkgroupManager(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '创建工作组',
          subtitle: '',
          icon: Icons.business,
          url: '/work/createWorkgroup',
          buildPage: (PageContext pageContext) => CreateWorkgroup(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工作组详情',
          subtitle: '',
          icon: Icons.business,
          url: '/work/workgroup/details',
          buildPage: (PageContext pageContext) => WorkgroupDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众名片',
          subtitle: '',
          icon: null,
          url: '/public/card/basicPerson',
          buildPage: (PageContext pageContext) => PersonCard(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: 'ISP平台审批',
          subtitle: '',
          icon: null,
          url: '/work/workitem/adoptISP',
          buildPage: (PageContext pageContext) => AdoptISP(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: 'LA平台审批',
          subtitle: '',
          icon: null,
          url: '/work/workitem/adoptLA',
          buildPage: (PageContext pageContext) => AdoptLA(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '福利中心审批',
          subtitle: '',
          icon: null,
          url: '/work/workitem/adoptWybank',
          buildPage: (PageContext pageContext) => AdoptWybank(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '图片查看器',
          subtitle: '',
          desc: '',
          icon: Icons.image,
          url: '/images/viewer',
          buildRoute:
              (RouteSettings settings, LogicPage page, IServiceProvider site) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                PageContext pageContext = PageContext(
                  page: page,
                  site: site,
                  context: context,
                );
                return MediaWatcher(
                  pageContext: pageContext,
                );
              },
              fullscreenDialog: true,
            );
          },
        ),
        LogicPage(
          title: '市盈率配置列表',
          subtitle: '',
          icon: null,
          url: '/adopt/wybank/ttm',
          buildPage: (PageContext pageContext) => TtmConfigDialog(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看同事',
          subtitle: '',
          icon: null,
          url: '/viewer/colleague',
          buildPage: (PageContext pageContext) => ColleagueViewer(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银市场',
          subtitle: '',
          icon: null,
          url: '/weny/market',
          buildPage: (PageContext pageContext) => PlatformWenyMarket(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '福利中心',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank',
          buildPage: (PageContext pageContext) => PlatformWenyBankWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行交易明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/trades',
          buildPage: (PageContext pageContext) => PlatformWenyTradesPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行参数',
          subtitle: '市盈率、账比等',
          icon: Icons.business,
          url: '/weny/parameters',
          buildPage: (PageContext pageContext) => PlatformWenyParametersPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申购明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/details/purchase',
          buildPage: (PageContext pageContext) => PlatformPurchaseDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '承兑明细',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/details/exchange',
          buildPage: (PageContext pageContext) => PlatformExchangeDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银存量',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/stock',
          buildPage: (PageContext pageContext) => PlatformStockWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '资金现量',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/fund',
          buildPage: (PageContext pageContext) => PlatformFundWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结资金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/freezen',
          buildPage: (PageContext pageContext) => PlatformFreezenWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '自由金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/free',
          buildPage: (PageContext pageContext) => PlatformFreeWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '账金账户',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/shunters',
          buildPage: (PageContext pageContext) => PlatformShuntersWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '资金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/fund',
          buildPage: (PageContext pageContext) => PlatformFundWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/freezen',
          buildPage: (PageContext pageContext) => PlatformFreezenWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '自由金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/free',
          buildPage: (PageContext pageContext) => PlatformFreeWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '运营商分账账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/shunt',
          buildPage: (PageContext pageContext) => PlatformShuntWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '尾金账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/hubTails',
          buildPage: (PageContext pageContext) => PlatformHubTailsWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银账单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/bill/stock',
          buildPage: (PageContext pageContext) => PlatformStockWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申购记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/purchase',
          buildPage: (PageContext pageContext) => PlatformPurchaseRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '承兑记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/exchange',
          buildPage: (PageContext pageContext) => PlatformExchangeRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '分账记录单',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/record/shunt',
          buildPage: (PageContext pageContext) => PlatformShuntRecordPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网络洇金',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/absorb',
          buildPage: (PageContext pageContext) => PlatformAbsorbWenyAccount(
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
          title: '运营商',
          subtitle: '',
          icon: Icons.business,
          url: '/wenybank/account/isp',
          buildPage: (PageContext pageContext) => IspWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取中心',
          subtitle: '',
          icon: Icons.business,
          url: '/weny/robot',
          buildPage: (PageContext pageContext) => PlatformRobotPage(
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
          buildPage: (PageContext pageContext) => PlatformWithdrawRecordsPage(
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
          buildPage: (PageContext pageContext) => WenyAbsorberDetailsMorePage(
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
          buildPage: (PageContext pageContext) => PlatformWenyBankInfoPage(
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
          title: '进场资金',
          subtitle: '',
          icon: Icons.business,
          url: '/claf/fund/platform',
          buildPage: (PageContext pageContext) => PlatformFundPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '渠道账户',
          subtitle: '',
          icon: Icons.business,
          url: '/claf/channel/account',
          buildPage: (PageContext pageContext) => ChannelAccountDetailsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '渠道账户账单',
          subtitle: '',
          icon: Icons.business,
          url: '/claf/channel/account/bill',
          buildPage: (PageContext pageContext) => PageChannelBillPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '充值单查看',
          icon: null,
          url: '/wallet/recharge/details',
          buildPage: (PageContext pageContext) => RechargeDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '提现单查看',
          icon: null,
          url: '/wallet/withdraw/details',
          buildPage: (PageContext pageContext) => WithdrawDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工单审核流程',
          subtitle: '',
          icon: null,
          url: '/feedback/woflow',
          buildPage: (PageContext pageContext) => WOFlows(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '工单流程',
          subtitle: '',
          icon: null,
          url: '/feedback/wo/flow',
          buildPage: (PageContext pageContext) => WOFlow(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '问题详情',
          subtitle: '',
          icon: null,
          url: '/system/wo/view',
          buildPage: (PageContext pageContext) => WOView(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '帮助管理',
          subtitle: '',
          icon: null,
          url: '/feedback/helpers',
          buildPage: (PageContext pageContext) => HelpFeedbackPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '帮助',
          subtitle: '',
          icon: null,
          url: '/system/fq/view',
          buildPage: (PageContext pageContext) => FQView(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '创建帮助',
          subtitle: '',
          icon: null,
          url: '/feedback/helper/create',
          buildPage: (PageContext pageContext) => HelperCreator(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看帮助',
          subtitle: '',
          icon: null,
          url: '/feedback/helper/view',
          buildPage: (PageContext pageContext) => FQView(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '直接举报',
          subtitle: '',
          icon: null,
          url: '/feedback/tipoff/direct',
          buildPage: (PageContext pageContext) => TipOffDirectPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '对象举报',
          subtitle: '',
          icon: null,
          url: '/feedback/tipoff/object',
          buildPage: (PageContext pageContext) => TipOffObjectPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '直接举报流程',
          subtitle: '',
          icon: null,
          url: '/feedback/tipoff/direct/flow',
          buildPage: (PageContext pageContext) => TipOffDirectFlowPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '对象举报流程',
          subtitle: '',
          icon: null,
          url: '/feedback/tipoff/object/flow',
          buildPage: (PageContext pageContext) => TipOffObjectFlowPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面提示主页',
          subtitle: '',
          icon: null,
          url: '/feedback/tiptool/main',
          buildPage: (PageContext pageContext) => TipToolMain(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '创建提示',
          subtitle: '',
          icon: null,
          url: '/feedback/tiptool/creator',
          buildPage: (PageContext pageContext) => TipsDocCreator(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '填充并创建提示',
          subtitle: '',
          icon: null,
          url: '/feedback/tiptool/previewAndcreate',
          buildPage: (PageContext pageContext) => TipsDocPreviewAndCreate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面弹屏',
          subtitle: '',
          icon: null,
          url: '/operation/screen',
          buildPage: (PageContext pageContext) => ScreenMain(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '创建弹屏主体',
          subtitle: '',
          icon: null,
          url: '/operation/screen/create',
          buildPage: (PageContext pageContext) => CreateScreenSubjectPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看弹屏主体',
          subtitle: '',
          icon: null,
          url: '/operation/screen/view',
          buildPage: (PageContext pageContext) => ViewScreenSubjectPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '弹屏',
          subtitle: '',
          icon: null,
          url: '/desktop/screen',
          buildPage: (PageContext pageContext) => ScreenPopupPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '弹屏规则参数设置',
          subtitle: '',
          icon: null,
          url: '/desktop/screen/rule',
          buildPage: (PageContext pageContext) => PopupRulePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '二维码扫描对话框',
          subtitle: '',
          icon: null,
          url: '/qrcode/scanner',
          buildPage: (PageContext pageContext) => QrScannerDialog(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '营业账户',
          subtitle: '',
          icon: null,
          url: '/wallet/fission/mf/account/business',
          buildPage: (PageContext pageContext) => FissionMFBusinessAccountPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '营业账户',
          subtitle: '',
          icon: null,
          url: '/wallet/fission/mf/account/income',
          buildPage: (PageContext pageContext) => FissionMFIncomeAccountPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '营业账户',
          subtitle: '',
          icon: null,
          url: '/wallet/fission/mf/account/absorb',
          buildPage: (PageContext pageContext) => FissionMFAbsorbAccountPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '用户视图',
          subtitle: '',
          icon: Icons.business,
          url: '/person/view',
          buildPage: (PageContext pageContext) => PersonViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '流量中国',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/traffic/pools',
          buildPage: (PageContext pageContext) => TrafficPoolsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '内容盒',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/box',
          buildPage: (PageContext pageContext) => ContentBoxPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '内容提供商',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/provider',
          buildPage: (PageContext pageContext) => ContentProviderPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '流量池信息',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/pool/view',
          buildPage: (PageContext pageContext) => PoolViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '内容盒信息',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/box/view',
          buildPage: (PageContext pageContext) => ContentBoxViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '位置地图',
          subtitle: '',
          icon: Icons.business,
          url: '/gbera/location',
          buildPage: (PageContext pageContext) => LocationMapPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '裂变游戏充值单',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/fission/mf/record/recharge',
          buildPage: (PageContext pageContext) => FissionMFRecordRechargePage(
            context: pageContext,
          ),
        ),
      ],
    );
