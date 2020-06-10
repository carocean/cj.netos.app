import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class LandagentScaffold extends StatelessWidget {
  PageContext context;

  LandagentScaffold({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this.context.part('/desktop', context),
    );
  }
}
