import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class GberaEntrypoint extends StatefulWidget {
  PageContext context;

  GberaEntrypoint({this.context});

  @override
  _GberaEntrypointState createState() => _GberaEntrypointState();
}

class _GberaEntrypointState extends State<GberaEntrypoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('这是gbera框架'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
                child: Text('切换主题'),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.backward(result: {'aaa':'2222'});
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
