import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class BankCards extends StatelessWidget {
  PageContext context;

  BankCards({this.context});

  @override
  Widget build(BuildContext context) {
    var cardList = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: _itemBuilder,
        separatorBuilder: _separatorBuilder,
        itemCount: 4,
      ),
    );
    var opera = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 20,
        bottom: 20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Text(
                  '添加银行卡',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: cardList,
            ),
            Expanded(
              child: opera,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          this.context.forward('/wallet/card/details');
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                      Text(
                        '储蓄卡',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text('4338 23838 92992 3838'),
          ],
        ),
      ),
    );
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    return Divider(
      height: 1,
      indent: 40,
    );
  }
}
