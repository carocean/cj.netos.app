import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class PoolViewPage extends StatefulWidget {
  PageContext context;

  PoolViewPage({this.context});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
