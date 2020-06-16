import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';

import '../portlets.dart';

class NodePowerDesktop extends StatefulWidget {
  PageContext context;

  NodePowerDesktop({this.context});

  @override
  _NodePowerDesktopState createState() => _NodePowerDesktopState();
}

class _NodePowerDesktopState extends State<NodePowerDesktop> {
  List<Widget> _desklets = [];
  bool _isloaded = false;

  @override
  void initState() {
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    var portlets = nodePowerPortlets;
    for (Portlet portlet in portlets) {
      var desklet = portlet.build(context: widget.context);
      _desklets.add(desklet);
    }
    _isloaded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isloaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text('节点动力'),
          elevation: 0,
        ),
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            _desklets.map((let) {
              return Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  let,
                  SizedBox(
                    height: 15,
                  ),
                ],
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
