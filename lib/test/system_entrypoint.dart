import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class SystemEntrypoint extends StatefulWidget {
  PageContext context;

  SystemEntrypoint({this.context});

  @override
  _SystemEntrypointState createState() => _SystemEntrypointState();
}

class _SystemEntrypointState extends State<SystemEntrypoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/test');
              },
              child: Text('系统场景测试:主题切换'),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/public/entrypoint', scene: 'gbera',onFinishedSwitchScene: (v){
                  print(v);
                });
              },
              child: Text('进入场景：gbera'),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                widget.context.forward('/public/entrypoint', scene: 'business',onFinishedSwitchScene: (v){
                  print(v);
                });
              },
              child: Text('进入场景：business'),
            ),
          ],
        ),
      ),
    );
  }
}
