import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class PopularizeChannel extends StatefulWidget {
  PageContext context;

  PopularizeChannel({this.context});

  @override
  _PopularizeChannelState createState() => _PopularizeChannelState();
}

class _PopularizeChannelState extends State<PopularizeChannel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.context.page.title,),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: true,
      ),
      body: Container(),
    );
  }
}
