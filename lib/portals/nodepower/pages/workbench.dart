import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class Workbench extends StatefulWidget {
  PageContext context;

  Workbench({this.context});

  @override
  _WorkbenchState createState() => _WorkbenchState();
}

class _WorkbenchState extends State<Workbench> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text('工作台'),
          centerTitle: true,
        ),
      ],
    );
  }
}
