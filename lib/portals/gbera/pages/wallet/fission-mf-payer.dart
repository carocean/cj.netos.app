import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class FissionMFPayersPage extends StatefulWidget {
  PageContext context;

  FissionMFPayersPage({this.context});

  @override
  _FissionMFPayersPageState createState() => _FissionMFPayersPageState();
}

class _FissionMFPayersPageState extends State<FissionMFPayersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('加群'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Container(),
    );
  }
}
