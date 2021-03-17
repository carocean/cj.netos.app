import 'package:flutter/cupertino.dart';
import 'package:framework/core_lib/_page_context.dart';

class MenuItem {
  String id;
  String title;
  String icon;
  Function(PageContext context) onTap;

  MenuItem({
    this.id,
    this.title,
    this.onTap,
    this.icon,
  });
}

class Menu {
  String id;
  String title;
  List<MenuItem> items;

  Menu({this.id, this.title, this.items});
}

class Workbench {
  Menu toolbar;
  List<Menu> menus;

  Workbench({this.toolbar, this.menus});
}

Workbench nodePowerWorkbench = Workbench(
  toolbar: Menu(
    id: 'shortcuts',
    title: '常用工具栏',
    items: [
      MenuItem(
        title: '工作组管理',
        id: 'workflow.manage',
        icon: 'http://47.105.165.186:7100/app/org/workflow/workgroup.png',
        onTap: (context) {
          context.forward(
            '/work/workgroup',
          );
        },
      ),
    ],
  ),
  menus: [
    Menu(
      id: 'workService',
      title: '工作类服务',
      items: [
        MenuItem(
          title: '工作流管理',
          id: 'workflow.manage',
          icon: 'http://47.105.165.186:7100/app/org/workflow/workflow-2.png',
          onTap: (context) {
            context.forward(
              '/work/workflow',
            );
          },
        ),
        MenuItem(
          title: '桌面提示管理',
          id: 'feedback.tiptool.manage',
          icon: 'http://47.105.165.186:7100/app/feedback/icons/tishi.png',
          onTap: (context) {
            context.forward(
              '/feedback/tiptool/main',
            );
          },
        ),
        MenuItem(
          title: '工单审核流程',
          id: 'feedback.woflow.manage',
          icon: 'http://47.105.165.186:7100/app/feedback/icons/gongdan.png',
          onTap: (context) {
            context.forward(
              '/feedback/woflow',
            );
          },
        ),
        MenuItem(
          title: '帮助管理',
          id: 'feedback.helper.manage',
          icon: 'http://47.105.165.186:7100/app/feedback/icons/helper.png',
          onTap: (context) {
            context.forward(
              '/feedback/helpers',
            );
          },
        ),
        MenuItem(
          title: '直接举报',
          id: 'feedback.helper.manage',
          icon: 'http://47.105.165.186:7100/app/feedback/icons/tipoff_direct.png',
          onTap: (context) {
            context.forward(
              '/feedback/tipoff/direct',
            );
          },
        ),
        MenuItem(
          title: '对象举报',
          id: 'feedback.helper.manage',
          icon: 'http://47.105.165.186:7100/app/feedback/icons/tipoff_object.png',
          onTap: (context) {
            context.forward(
              '/feedback/tipoff/object',
            );
          },
        ),
        MenuItem(
          title: '桌面弹屏',
          id: 'operation.screen',
          icon: 'http://47.105.165.186:7100/app/operation/popup.png',
          onTap: (context) {
            context.forward(
              '/operation/screen',
            );
          },
        ),
      ],
    ),
    Menu(
      id: 'operatorService',
      title: '经营类服务',
      items: [
        MenuItem(
          title: '纹银市场',
          id: 'weny.market.manage',
          icon: 'http://47.105.165.186:7100/app/system/bi.png',
          onTap: (context) {
            context.forward(
              '/weny/market',
            );
          },
        ),
      ],
    ),
    Menu(
      id: 'fundService',
      title: '会计类服务',
      items: [
        MenuItem(
          title: '平台资金池',
          id: 'claf.fund.manager',
          icon: 'http://47.105.165.186:7100/app/system/zijin.png',
          onTap: (context) {
            context.forward(
              '/claf/fund/platform',
            );
          },
        ),
      ],
    ),
    Menu(
      id: 'fissionMFService',
      title: '裂变游戏·交个朋友',
      items: [
        MenuItem(
          title: '营业账户',
          id: 'fission.mf.account.business',
          icon: 'http://47.105.165.186:7100/app/system/yingyeshouru.png',
          onTap: (context) {
            context.forward(
              '/wallet/fission/mf/account/business',
            );
          },
        ),
        MenuItem(
          title: '收益账户',
          id: 'fission.mf.account.income',
          icon: 'http://47.105.165.186:7100/app/system/shouyi.png',
          onTap: (context) {
            context.forward(
              '/wallet/fission/mf/account/income',
            );
          },
        ),
        MenuItem(
          title: '洇金账户',
          id: 'fission.mf.account.absorb',
          icon: 'http://47.105.165.186:7100/app/system/zhaocaimao.png',
          onTap: (context) {
            context.forward(
              '/wallet/fission/mf/account/absorb',
            );
          },
        ),
      ],
    ),
  ],
);
