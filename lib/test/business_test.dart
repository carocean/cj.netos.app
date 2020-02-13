import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class BusinessTest extends StatefulWidget {
  PageContext context;

  BusinessTest({this.context});

  @override
  _BusinessTestState createState() => _BusinessTestState();
}

class _BusinessTestState extends State<BusinessTest> {
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
            child: Text('mybussiness'),
          ),
        ),
      ),
    );
  }
}
