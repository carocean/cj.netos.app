import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class BankCardDetails extends StatefulWidget {
  PageContext context;

  BankCardDetails({this.context});

  @override
  _CardDetailsState createState() => _CardDetailsState();
}

class _CardDetailsState extends State<BankCardDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 1.0,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showModalBottomSheet(context: context, builder: _showToolbar);
            },
            icon: Icon(
              Icons.linear_scale,
              size: 16,
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                bottom: 20,
                top: 20,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Image.network(
                      'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1571597501255&di=91a807b2a31ca7a35fe55248b1c618cc&imgtype=0&src=http%3A%2F%2Fpic.90sjimg.com%2Fdesign%2F00%2F07%2F85%2F23%2F59316cc6d4e84.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text(
                      '招商银行',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text(
                      '储蓄卡',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  Text('4338 23838 92992 3838'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '支付限额',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('单笔支付限额'),
                                Text('¥5000.00'),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('每日支付限额'),
                                Text('¥5000.00'),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showToolbar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            margin: EdgeInsets.only(
              bottom: 10,
            ),
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
            ),
            color: Colors.white,
            child: Text(
              '解除绑定',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            padding: EdgeInsets.only(
              top: 20,
              bottom: 50,
            ),
            color: Colors.white,
            child: Text('取消'),
          ),
        ],
      ),
    );
  }
}
