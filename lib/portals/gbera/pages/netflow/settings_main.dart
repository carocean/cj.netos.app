import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class SettingsMain extends StatefulWidget {
  PageContext context;

  SettingsMain({this.context});

  @override
  _SettingsMainState createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          widget.context.page.title,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              widget.context.backward();
            },
            icon: Icon(
              Icons.close,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _Card(
              items: <Widget>[
                CardItem(
                  title: '公众',
                  onItemTap: () {
                    widget.context
                        .forward('/netflow/channel/settings/persons');
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: _Card(
              items: <Widget>[
                CardItem(
                  title: '微站',
                  onItemTap: () {
                    widget.context.forward('/netflow/activies/sites');
                  },
                ),
                CardItem(
                  title: '微应用',
                  onItemTap: () {
                    widget.context.forward('/netflow/activies/microapps');
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatefulWidget {
  List<Widget> items = [];

  _Card({this.items});

  @override
  __CardState createState() => __CardState();
}

class __CardState extends State<_Card> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: widget.items.map((v) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: v,
              ),
              Container(
                child: Divider(
                  height: 1,
                  indent: 20,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
