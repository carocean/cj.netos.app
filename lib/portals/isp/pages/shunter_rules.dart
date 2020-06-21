import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class ShunterRuleWidget extends StatelessWidget {
  PageContext context;

  ShunterRuleWidget({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '账比',
        ),
        elevation: 0,
      ),
      body: Container(),
    );
  }
}
