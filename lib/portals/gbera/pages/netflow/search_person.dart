import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class SearchPerson extends StatefulWidget {
  PageContext context;

  SearchPerson({this.context});

  @override
  _SearchPersonState createState() => _SearchPersonState();
}

class _SearchPersonState extends State<SearchPerson> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加公众'),
        elevation: 0,

      ),
      body: Container(),
    );
  }
}
