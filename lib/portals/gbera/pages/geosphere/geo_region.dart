import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

///区域市场
class GeoRegion extends StatefulWidget {
  PageContext context;

  GeoRegion({this.context});

  @override
  _GeoRegionState createState() => _GeoRegionState();
}

class _GeoRegionState extends State<GeoRegion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: CardItem(
                      title: '旺生堂纹银银行',
                      subtitle: Text(
                        '涨:0.00001200002',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.red[700],
                        ),
                      ),
                      titleColor: Colors.grey[800],
                      leading: Image.network(
                        'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=201729472,2326921524&fm=26&gp=0.jpg',
                        width: 30,
                        height: 30,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      tipsText: '0.2838277773元/纹',
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: CardItem(
                      title: '宏生帑指交易所',
                      subtitle: Text(
                        '涨:4.82',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.red[700],
                        ),
                      ),
                      titleColor: Colors.grey[800],
                      leading: Image.network(
                        'https://f11.baidu.com/it/u=2567626472,4132160589&fm=72',
                        width: 30,
                        height: 30,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      tipsText: '12.51元/点',
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: CardItem(
                      title: '千牛商家拆借交易所',
                      subtitle: Text(
                        '涨:0.08',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.red[700],
                        ),
                      ),
                      titleColor: Colors.grey[800],
                      leading: Image.network(
                        'https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=331142760,931679119&fm=26&gp=0.jpg',
                        height: 30,
                        width: 30,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      tipsText: '2.17元/帑',
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: CardItem(
                      title: '元丰帑银交易所',
                      subtitle: Text(
                        '跌:0.12',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.green[700],
                        ),
                      ),
                      titleColor: Colors.grey[800],
                      leading: Image.network(
                        'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2873093951,318547924&fm=26&gp=0.jpg',
                        height: 30,
                        width: 30,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      tipsText: '1.61元/帑',
                    ),
                  ),
                  Divider(
                    height: 5,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: CardItem(
                      title: '实体+',
                      subtitle: Text(
                        '实体店面',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.green[700],
                        ),
                      ),
                      titleColor: Colors.grey[800],
                      leading: Icon(
                        Icons.store,
                        size: 30,
                        color: Colors.grey,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      tipsText: '5390家',
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: CardItem(
                      title: '卖场+',
                      subtitle: Text(
                        '网店，线上店铺',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.green[700],
                        ),
                      ),
                      titleColor: Colors.grey[800],
                      leading:  Icon(
                        Icons.shop,
                        size: 30,
                        color: Colors.grey,
                      ),
                      tail: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      tipsText: '2948家',
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
