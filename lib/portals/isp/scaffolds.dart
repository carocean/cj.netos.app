import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class IspScaffold extends StatelessWidget {
  PageContext context;

  IspScaffold({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this.context.part('/desktop', context),
    );
  }
}

