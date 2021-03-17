import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class FissionMFAbsorbAccountPage extends StatefulWidget {
  PageContext context;

  FissionMFAbsorbAccountPage({this.context});

  @override
  _FissionMFAbsorbAccountPageState createState() =>
      _FissionMFAbsorbAccountPageState();
}

class _FissionMFAbsorbAccountPageState
    extends State<FissionMFAbsorbAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('洇金账户'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
