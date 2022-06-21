import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';

class ChatCirclePortlet extends StatefulWidget {
  Portlet portlet;
  Desklet desklet;
  PageContext context;

  ChatCirclePortlet({this.portlet, this.desklet, this.context});

  @override
  _ChatCirclePortletState createState() => _ChatCirclePortletState();
}

class _ChatCirclePortletState extends State<ChatCirclePortlet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(
        bottom: 5,
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 0,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: 5,
                ),
                child: Icon(
                  Icons.my_location,
                  size: 18,
                  color: Colors.grey[500],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        '我的移动广场',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '500米',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2,),
                  Row(
                    children: [
                      Text(
                        '新郑市郑港街道世界港·丽宫润丰锦尚',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 25,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[128条]',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: '烧烤场:',
                          children: [
                            TextSpan(
                              text: '亲们！大场地，草坪上的烧烤，生啤，快来享受人生呢！通过地微导航过来的，送啤酒！',
                            ),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          // color: Colors.grey[600],
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 43,
                    top: 2,
                  ),
                  child: Text(
                    '3分钟前',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
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
