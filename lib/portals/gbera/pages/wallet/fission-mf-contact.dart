import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class FissionMFContactUSPage extends StatefulWidget {
  PageContext context;

  FissionMFContactUSPage({this.context});

  @override
  _FissionMFContactUSPageState createState() => _FissionMFContactUSPageState();
}

class _FissionMFContactUSPageState extends State<FissionMFContactUSPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('平台联系方式'),
        elevation: 0,
      ),
      body: Container(),
    );
  }
}
