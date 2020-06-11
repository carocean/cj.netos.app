import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class NodePowerScaffold extends StatelessWidget {
  PageContext context;

  NodePowerScaffold({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this.context.part('/desktop', context),
    );
  }
}

