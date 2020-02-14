import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class ActivitiesGatewaySettings extends StatefulWidget {
  PageContext context;

  ActivitiesGatewaySettings({this.context});

  @override
  _ActivesSitesState createState() => _ActivesSitesState();
}

class _ActivesSitesState extends State<ActivitiesGatewaySettings> {
  @override
  Widget build(BuildContext context) {
    var users = <CardItem>[
      CardItem(
        title: '会飞的鱼',
        onItemTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return widget.context.part('/channel/list_of_user', context);
              });
        },
      ),
      CardItem(
        title: '菁灵仔',
        onItemTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return widget.context.part('/channel/list_of_user', context);
              });
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.context.page.title),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Text(
                '被拒的公众',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 5,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              users.map((item) {
                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      color: Colors.white,
                      child: Dismissible(
                        key: ObjectKey(item),
                        child: item,
                        background: Container(),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.delete_sweep,
                            size: 16,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (DismissDirection.endToStart != direction) {
                            return false;
                          }
                          return await _showConfirmationDialog(context) == true;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            print('----todo delete');
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text.rich(
          TextSpan(
            text: '是否移除？',
            children: [
              TextSpan(text: '\r\n'),
              TextSpan(
                text: '移除后便可再次接收他的信息',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          FlatButton(
            child: const Text('确定'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }
}
