import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class IspEventDetails extends StatefulWidget {
  PageContext context;

  IspEventDetails({this.context});

  @override
  _IspEventDetailsState createState() => _IspEventDetailsState();
}

class _IspEventDetailsState extends State<IspEventDetails> {
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
