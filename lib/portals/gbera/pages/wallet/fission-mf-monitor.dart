import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';

class FissionMFMonitorPage extends StatefulWidget {
  PageContext context;

  FissionMFMonitorPage({this.context});

  @override
  _FissionMFMonitorPageState createState() => _FissionMFMonitorPageState();
}

class _FissionMFMonitorPageState extends State<FissionMFMonitorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('运营监控'),
        titleSpacing: 0,
        elevation: 0,
        actions: [],
      ),
      body: Container(),
    );
  }
}
