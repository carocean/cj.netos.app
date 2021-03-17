import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class FissionMFIncomeAccountPage extends StatefulWidget {
  PageContext context;

  FissionMFIncomeAccountPage({this.context});

  @override
  _FissionMFIncomeAccountPageState createState() =>
      _FissionMFIncomeAccountPageState();
}

class _FissionMFIncomeAccountPageState
    extends State<FissionMFIncomeAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收益账户'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
