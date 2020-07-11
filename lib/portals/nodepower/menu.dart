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
  ],
);
