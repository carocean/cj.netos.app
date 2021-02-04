import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';

class FissionMFCashierPage extends StatefulWidget {
  PageContext context;

  FissionMFCashierPage({this.context});

  @override
  _FissionMFCashierPageState createState() => _FissionMFCashierPageState();
}

class _FissionMFCashierPageState extends State<FissionMFCashierPage> {
  bool _isOpening=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出纳柜台'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {},
            child: Text(
              '收益及明细',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '今日收益',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '¥23.83',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            '今日获客',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '128人',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Text(
                  '红包余额',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text.rich(
                  TextSpan(
                    text: '¥',
                    children: [
                      TextSpan(
                        text: '382.34',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '营业状态：${_isOpening?'营业中':'已停业'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Column(
              children: [
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '营业状态',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '营业中状态表示系统会将你推荐给其他用户，用户通过点你头像，从而会消耗你的红包余额；停止营业则不会扣费，系统也不会向其他用户推荐你',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '${_isOpening?'营业中':'已停业'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Switch.adaptive(
                            value: _isOpening,
                            onChanged: (v) {
                              setState(() {
                                _isOpening=v;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 0,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                     Padding(
                       padding: EdgeInsets.only(right: 15,),
                       child:  Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             '充钱到红包',
                             style: TextStyle(
                               fontSize: 16,
                             ),
                           ),
                           SizedBox(
                             height: 5,
                           ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             mainAxisSize: MainAxisSize.max,
                             children: [
                               Text(
                                 '从钱包零钱划扣',
                                 style: TextStyle(
                                   fontSize: 12,
                                   color: Colors.grey[700],
                                 ),
                               ),
                               SizedBox(width: 10,),
                               Icon(
                                 Icons.arrow_forward_ios,
                                 size: 18,
                                 color: Colors.grey,
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                      SizedBox(height: 30,child: Divider(height: 1,),),
                      Padding(padding: EdgeInsets.only(right: 15,),child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '退款到零钱',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                '将从当前红包余额转入零钱',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '自动充值策略',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '想拉新就要正确定义你的推广策略。系统会按你的定义从你的地微钱包零钱中划扣，并充钱到红包余额',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '扣费策略',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 10,),
                          Row(
                            children: [
                              Text(
                                '每日',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                '¥500.00',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
