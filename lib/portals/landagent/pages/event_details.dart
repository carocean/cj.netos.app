import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class LandagentEventDetails extends StatefulWidget {
  PageContext context;

  LandagentEventDetails({this.context});

  @override
  _LandagentEventDetailsState createState() => _LandagentEventDetailsState();
}

class _LandagentEventDetailsState extends State<LandagentEventDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '事务',
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
