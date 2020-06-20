import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/avatar.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/landagent/pages/desktop.dart';
import 'package:netos_app/portals/landagent/pages/event_details.dart';
import 'package:netos_app/portals/landagent/styles/blue_styles.dart' as blue;
import 'package:netos_app/portals/nodepower/pages/adopt/adopt_isp.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/adopt_la.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/adopt_wybank.dart';
import 'package:netos_app/portals/nodepower/pages/create_workflow.dart';
import 'package:netos_app/portals/nodepower/pages/create_workgroup.dart';
import 'package:netos_app/portals/nodepower/pages/desktop.dart';
import 'package:netos_app/portals/nodepower/pages/mine.dart';
import 'package:netos_app/portals/nodepower/pages/organization.dart';
import 'package:netos_app/portals/nodepower/pages/workbench.dart';
import 'package:netos_app/portals/nodepower/pages/workflow_details.dart';
import 'package:netos_app/portals/nodepower/pages/workflow_manager.dart';
import 'package:netos_app/portals/nodepower/pages/workgroup_details.dart';
import 'package:netos_app/portals/nodepower/pages/workgroup_manager.dart';
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
          '/remote/org/licence':LicenceRemote(),
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
          title: '纹银银行审批',
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
                return new ImageViewer(
                  context: pageContext,
                );
              },
              fullscreenDialog: true,
            );
          },
        ),
      ],
    );
