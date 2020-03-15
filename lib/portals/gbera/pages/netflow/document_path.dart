import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class DocumentPath extends StatefulWidget {
  PageContext context;

  DocumentPath({this.context});

  @override
  _DocumentPathState createState() => _DocumentPathState();
}

class _DocumentPathState extends State<DocumentPath> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
