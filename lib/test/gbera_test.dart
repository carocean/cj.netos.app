import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class GberaTest extends StatefulWidget {
  PageContext context;

  GberaTest({this.context});

  @override
  _GberaTestState createState() => _GberaTestState();
}

class _GberaTestState extends State<GberaTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('xxx'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.context.currentTheme() == '/green') {
              widget.context.switchTheme('/grey');
            } else {
              widget.context.switchTheme('/green');
            }
          },
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text('gbera'),
          ),
        ),
      ),
    );
  }
}
