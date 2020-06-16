import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/nodepower/menu.dart';

class Workbench extends StatefulWidget {
  PageContext context;

  Workbench({this.context});

  @override
  _WorkbenchState createState() => _WorkbenchState();
}

class _WorkbenchState extends State<Workbench> {
  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    for (var menu in nodePowerWorkbench.menus) {
      items.add(
        _rendMenu(
          menu,
        ),
      );
    }
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text('工作台'),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Container(
            child: _rendMenu(nodePowerWorkbench.toolbar),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            items,
          ),
        ),
      ],
    );
  }

  Widget _rendMenu(Menu menu) {
    if (menu.items.isEmpty) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 2,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '${menu.title ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Wrap(
            spacing: 15,
            runSpacing: 15,
            children: menu.items.map((item) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (){
                  item.onTap(widget.context);
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 10,
                    top: 10,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.network(
                            '${item.icon}?accessToken=${widget.context.principal.accessToken}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
