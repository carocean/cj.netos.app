import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class FundEnterPage extends StatefulWidget {
  PageContext context;

  FundEnterPage({this.context});

  @override
  _FundEnterPageState createState() => _FundEnterPageState();
}

class _FundEnterPageState extends State<FundEnterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('进场资金'),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: Container(),
    );
  }
}
