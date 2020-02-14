import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class TestServices extends StatefulWidget {
  PageContext context;

  TestServices({this.context});

  @override
  _TestServicesState createState() => _TestServicesState();
}

class _TestServicesState extends State<TestServices> {
  bool _isTest = false;

  @override
  void initState() {
    bool isTest = widget.context.site.getService("@.prop.isTest");
    if (isTest == null || !isTest) {
      this._isTest = isTest;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //下面是测试
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _Card(
              items: <Widget>[
                CardItem(
                  title: '初始化公众数据',
                  onItemTap: (){
                    widget.context.forward('/test/services/gbera/persons');
                  },
                ),
                CardItem(
                  title: '摸拟消息入站',
                  onItemTap: (){
                    widget.context.forward('/test/services/insite/messages');
                  },
                ),
              ],
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
