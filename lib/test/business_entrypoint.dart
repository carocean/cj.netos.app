import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class BusinessEntrypoint extends StatefulWidget {
  PageContext context;

  BusinessEntrypoint({this.context});

  @override
  _BusinessEntrypointState createState() => _BusinessEntrypointState();
}

class _BusinessEntrypointState extends State<BusinessEntrypoint> {
  @override
  Widget build(BuildContext context) {
    print('-----${widget.context.site.getService('/service1')}');
    return Scaffold(
      appBar: AppBar(
        title: Text('这是mybussiness框架'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
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
                child: Text('这是mybussiness框架'),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.backward(result: {'xxxxx':'111111'});
              },
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('回到系统场景'),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/test');
              },
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('到页test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
