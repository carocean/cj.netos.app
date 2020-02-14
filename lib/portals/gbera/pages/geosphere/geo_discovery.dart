import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class GeoDiscovery extends StatefulWidget {
  PageContext context;

  GeoDiscovery({this.context});

  @override
  _GeoDiscoveryState createState() => _GeoDiscoveryState();
}

class _GeoDiscoveryState extends State<GeoDiscovery> {
  @override
  Widget build(BuildContext context) {
    var data = [
      _Category(
        title: '美食',
        count: 8565,
        icon: Icon(
          IconData(
            0xe630,
            fontFamily: 'geo_discovery',
          ),
        ),
      ),
      _Category(
        title: '出租车',
        count: 453,
        icon: Icon(
          IconData(0xe61d, fontFamily: 'geo_discovery'),
        ),
      ),
      _Category(
        title: '楼盘',
        count: 247,
        icon: Icon(
          IconData(0xe626, fontFamily: 'geo_discovery'),
        ),
      ),
      _Category(
        title: '便利店',
        count: 367,
        icon: Icon(
          IconData(0xe60f, fontFamily: 'geo_discovery'),
        ),
      ),
      _Category(
        title: '加油站',
        count: 744,
        icon: Icon(
          IconData(0xe617, fontFamily: 'geo_discovery'),
        ),
      ),
    ];

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
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: CustomScrollView(
          slivers: data.map((v) {
            return SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 10),
                          blurRadius: 10,
                          spreadRadius: -9,
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: CardItem(
                      title: v.title,
                      tipsText: '${v.count}个',
                      leading: v.icon,
                      onItemTap: () {
                        widget.context.backward(result: v.title);
                      },
                    ),
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Category {
  String title;
  int count;
  Icon icon;

  _Category({this.title, this.count, this.icon});
}
