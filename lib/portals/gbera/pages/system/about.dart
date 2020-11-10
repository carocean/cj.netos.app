import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class About extends StatelessWidget {
  PageContext context;

  About({this.context});

  @override
  Widget build(BuildContext context) {
    var card_1 = Container(
      height: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 0,
            ),
            child: Image.asset(
              'lib/portals/gbera/images/gbera.png',
              fit: BoxFit.contain,
              width: 70,
              height: 70,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 2,
            ),
            child: Text('地微'),
          ),
          Text(
            '郑州节点动力信息科技有限公司',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    var card_2 = Container(
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              '公司说明',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: '\t'),
                  TextSpan(
                    text:
                        '总部位于深圳市高新区的深圳软件园，是一家专业从事工业4.0核心产品研发、生产、销售和服务的国家级高新技术企业、双软企业。',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(text: '\r\n\r\n'),
                  TextSpan(text: '      '),
                  TextSpan(
                    text:
                        '十多年来的不断创新和发展，显控产品不断成熟并逐步确立了行业领先地位，受到国内外用户的青睐。目前，产品已远销美国、欧盟、印度、俄罗斯等三十多个国家和地区。公司在广州、佛山、东莞、北京、南京、无锡、成都、杭州、宁波、天津、青岛、武汉、西安、沈阳、郑州、南宁、泉州等国内主要城市设立了办事处，与全国各区域代理商一起为广大客户提供高品质全方位服务。',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(text: '\r\n\r\n'),
                  TextSpan(text: '      '),
                  TextSpan(
                    text: '期待与您：',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  TextSpan(
                    text: '携手迈向工业4.0时代，共创中国智造的美好未来！',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
                text: '      节点动力',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              softWrap: true,
            ),
          ),
          Divider(
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 70,
                        child: Text(
                          '地址',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('广州市天河区科韵路天河软件园建中路22号 区科韵路天河软件园建中路22号'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 70,
                        child: Text(
                          '客服电话',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('020-28384833'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 70,
                        child: Text(
                          '节点动力号',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('0002838472166117239929'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 60,
            ),
            alignment: Alignment.bottomCenter,
            child: Text.rich(
              TextSpan(text: '© 1997-2019 节点动力版权所有'),
              style: TextStyle(color: Colors.grey[400],),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
    var card_3 = Container();
    var bb = this.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 1.0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            card_1,
            card_2,
            card_3,
          ],
        ),
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        this.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
