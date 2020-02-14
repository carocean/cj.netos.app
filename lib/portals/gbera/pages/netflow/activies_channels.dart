import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class ActivitiesChannels extends StatefulWidget {
  PageContext context;

  ActivitiesChannels({this.context});

  @override
  _ActivesSitesState createState() => _ActivesSitesState();
}

class _ActivesSitesState extends State<ActivitiesChannels> {
  @override
  Widget build(BuildContext context) {
    var items = <CardItem>[];
    for (int i = 0; i < 10; i++) {
      items.add(
        CardItem(
          title: '雅园小区',
          onItemTap: () {
            widget.context.forward('/channel/viewer');
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.context.page.title),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 5,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '423个',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              items.map((item) {
                return Container(
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  color: Colors.white,
                  child: item,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
