import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class Geofountain extends StatelessWidget {
  PageContext context;

  Geofountain({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            this.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            color: Colors.white,
            child: CardItem(
              title: '元田金证喷泉',
              leading: Image.network(
                'http://hbimg.b0.upaiyun.com/2952cc54574f0385a32e4d40c0940be73a50af4a3993-sDU6no_fw658',
                width: 30,
                height: 30,
              ),
              subtitle: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(text: '1800元/小时'),
                    TextSpan(text: '\r\n'),
                    TextSpan(text: '半径30米'),
                    TextSpan(text: '   '),
                    TextSpan(text: '现场235人'),
                  ],
                ),
              ),
              tipsText: '距您1.2公里，导航',
              onItemTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('选择导航方式'),
                        children: <Widget>[
                          DialogItem(
                            text: '步行',
                            color: Colors.grey,
                            icon:
                                IconData(0xe636, fontFamily: 'geo_navigation'),
                          ),
                          DialogItem(
                            text: '骑行',
                            color: Colors.grey,
                            icon:
                                IconData(0xe616, fontFamily: 'geo_navigation'),
                          ),
                          DialogItem(
                            text: '驾车',
                            color: Colors.grey,
                            icon:
                                IconData(0xe688, fontFamily: 'geo_navigation'),
                          ),
                        ],
                      );
                    });
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            height: 10,
          );
        },
        itemCount: 10,
      ),
    );
  }
}
