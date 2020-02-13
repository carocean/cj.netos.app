import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class SystemTest extends StatefulWidget {
  PageContext context;

  SystemTest({this.context});

  @override
  _SystemTestState createState() => _SystemTestState();
}

class _SystemTestState extends State<SystemTest> {
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
            child: Text('这是系统测试Z'),
          ),
        ),
      ),
    );
  }
}
