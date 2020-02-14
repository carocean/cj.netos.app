import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/desktop.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';

import 'chats/chat_rooms.dart';

List<Desklet> buildDesklets(site) {
  return <Desklet>[
    Desklet(
      title: '金证银行指数',
      url: '/zjbank/chart',
      icon: Icons.pie_chart,
      desc: '显示您关注的金证银行',
      buildDesklet: (portlet, desklet, desktopContext) {
        return Card(
          margin: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Column(
              children: <Widget>[
                Flex(
                  mainAxisSize: MainAxisSize.max,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Image(
                            width: 20.0,
                            height: 20.0,
                            fit: BoxFit.cover,
                            image: NetworkImage(portlet?.imgSrc),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Align(
                              child: Text(
                                portlet?.title,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              alignment: Alignment.topRight,
                              heightFactor: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topRight,
                        heightFactor: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.directions_walk,
                              size: 12,
                            ),
                            Text(
                              '天河区·地商',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '指数：',
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 10,
                        ),
                        child: Text('2393.02'),
                      ),
                      Text(
                        '日成交：',
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Text('382.38'),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Adapt.screenW() - Adapt.px(100),
                        maxHeight: 150,
                      ),
                      child: CustomAxisTickFormatters.withSampleData(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
    Desklet(
      title: '卖场',
      url: '/store',
      icon: Icons.store_mall_directory,
      desc: '用于卖场',
      buildDesklet: (portlet, desklet, desktopContext) {
        return CardStore(
          content: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text('您的资产'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('当前价/原价'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('奖池/买单数'),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 10,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return new Divider(
                    height: 1.0,
                    color: Colors.grey[300],
                  );
                },
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Icon(
                          Icons.account_balance,
                          size: 25,
                          color: Colors.grey[400],
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Text('旺角女装'),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text('2838.23'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Text('2393.53'),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text('939.12'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Text('82.00'),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text('25.98'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    ),
    Desklet(
      title: '即时通讯',
      url: '/p2p',
      icon: Icons.chat_bubble,
      desc: '聊天、群、聊天室等',
      buildDesklet: (portlet, desklet, desktopContext) {
        return ChatRoomsPortlet(
          desklet: desklet,
          context: desktopContext,
          portlet: portlet,
        );
      },
    ),
  ];
}
