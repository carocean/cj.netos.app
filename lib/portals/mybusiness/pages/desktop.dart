import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';

class LandagentDesktop extends StatefulWidget {
  PageContext context;

  LandagentDesktop({this.context});

  @override
  _LandagentDesktopState createState() => _LandagentDesktopState();
}

class _LandagentDesktopState extends State<LandagentDesktop> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onLoad() async {}

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          
        ];
      },
      body: EasyRefresh(
        controller: _controller,
        onLoad: _onLoad,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          children: <Widget>[],
        ),
      ),
    );
  }
}
