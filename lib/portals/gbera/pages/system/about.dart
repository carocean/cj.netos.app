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
                        '郑州节点动力息科技有限公司于2020年4月28日于郑州成立，立足中原，致力于打造移动互联网创新型企业，通过技术和模式创新，丰富互联网用户生活，助力企业数字化升级。',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(text: '\r\n\r\n'),
                  TextSpan(text: '      '),
                  TextSpan(
                    text:
                        '节点动力𣄃下拥有多项发明专利以及丰富多样的互联网产品，其中地微app独特的平聊、网流，地圈，追链传播渠道，让人与人之间的沟通更加方便快捷高效，让信息的推广更加多维，更加精准，更有深度。',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(text: '\r\n\r\n'),
                  TextSpan(text: '      '),
                  TextSpan(
                    text:
                    '\"技术改变生活\”是节点动力全球化发展的核心战略。',
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
                    text: '携手并进，共创未来。',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
                text: '      ',
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
                        child: Text('河南省郑州市航空港区裕鸿世界港·商业广场4号楼A座'),
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
                          '电话',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('0371-63396318'),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.only(
                //     bottom: 10,
                //   ),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.end,
                //     children: <Widget>[
                //       Container(
                //         width: 70,
                //         child: Text(
                //           '节点动力号',
                //           style: TextStyle(
                //             fontWeight: FontWeight.w500,
                //             color: Colors.grey[600],
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Text('0002838472166117239929'),
                //       ),
                //     ],
                //   ),
                // ),
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
