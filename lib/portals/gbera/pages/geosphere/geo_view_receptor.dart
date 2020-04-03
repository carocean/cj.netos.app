import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class GeoViewReceptor extends StatefulWidget {
  PageContext context;

  GeoViewReceptor({this.context});

  @override
  _GeoViewReceptorState createState() => _GeoViewReceptorState();
}

class _GeoViewReceptorState extends State<GeoViewReceptor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Container(),
    );
  }
}
