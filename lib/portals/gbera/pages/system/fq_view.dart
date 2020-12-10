import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/core_lib/_page_context.dart';

class FQView extends StatefulWidget {
  PageContext context;

  FQView({this.context});

  @override
  _FQViewState createState() => _FQViewState();
}

class _FQViewState extends State<FQView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('问答'),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () {
            widget.context.backward();
          },
        ),
      ),
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text(
                '为什么下载这个慢？',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text.rich(
                TextSpan(
                  text: '',
                  children: [
                    TextSpan(
                        text:
                            '迅雷是通过多通道下载，资源同时。迅雷是通过多通道下载，资源同时。迅雷是通过多通道下载，资源同时。迅雷是通过多通道下载，资源同时。迅雷是通过多通道下载，资源同时。')
                  ],
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('有帮助'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_down,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('没帮助'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
