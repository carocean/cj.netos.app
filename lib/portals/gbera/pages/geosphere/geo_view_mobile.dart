import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class GeoViewMobile extends StatefulWidget {
  PageContext context;

  GeoViewMobile({this.context});

  @override
  _GeoViewMobileState createState() => _GeoViewMobileState();
}

class _GeoViewMobileState extends State<GeoViewMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地圈感知器'),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text(
                    '感知半径:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text('500米'),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text(
                    '离开距离:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text('10米'),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text(
                    '现在位置:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text('东山区四平路'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
