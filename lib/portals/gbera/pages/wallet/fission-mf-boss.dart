import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class FissionMFBecomeBossPage extends StatefulWidget {
  PageContext context;

  FissionMFBecomeBossPage({this.context});

  @override
  _FissionMFBecomeBossPageState createState() =>
      _FissionMFBecomeBossPageState();
}

class _FissionMFBecomeBossPageState extends State<FissionMFBecomeBossPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('老板'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {},
            child: Text('分享'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Text(
                    '说明',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '成为老板，把二维码分享到微信群或朋友圈，别人通过扫你的二维码抢红包就算是你的员工了，而且是永久员工。这样他抢的红包在每次提现时都有你的分账，爽歪歪吧，快来做老板吧！',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
