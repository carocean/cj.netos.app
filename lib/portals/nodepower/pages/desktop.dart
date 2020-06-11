import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class NodePowerDesktop extends StatefulWidget {
  PageContext context;

  NodePowerDesktop({this.context});

  @override
  _NodePowerDesktopState createState() => _NodePowerDesktopState();
}

class _NodePowerDesktopState extends State<NodePowerDesktop> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('节点动力'),
        ),
        SliverToBoxAdapter(
          child: Container(
            child: GestureDetector(behavior: HitTestBehavior.opaque,onTap: (){

            },child: Text('这是节点动力公司的系统应用'),),
          ),
        ),
      ],
    );
  }
}
