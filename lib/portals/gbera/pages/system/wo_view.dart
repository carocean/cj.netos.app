import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class WOView extends StatefulWidget {
  PageContext context;

  WOView({this.context});

  @override
  _WOViewState createState() => _WOViewState();
}

class _WOViewState extends State<WOView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('问题详情'),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () {
            widget.context.backward();
          },
        ),
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(),
    );
  }
}
