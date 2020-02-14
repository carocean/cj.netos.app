import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class GeoSettings extends StatelessWidget {
  PageContext context;

  GeoSettings({this.context});

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
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Container(

                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 10),
                          blurRadius: 10,
                          spreadRadius: -9,
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '位置',
                          tipsText: '在中国农业银行（燕塘支行）附近',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '半径',
                          tipsText: '5公里',
                          leading: Icon(
                            FontAwesomeIcons.streetView,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '我的动态',
//                          tipsText: '发表210篇',
                          leading: Icon(
                            FontAwesomeIcons.images,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: (){
                            this.context.forward('/geosphere/portal');
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 10),
                          blurRadius: 10,
                          spreadRadius: -9,
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '圈内实时发现',
                          tipsText: '2894个',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '事件',
                          tipsText: '进圈、离圈',
                          leading: Icon(
                            FontAwesomeIcons.streetView,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 10),
                          blurRadius: 10,
                          spreadRadius: -9,
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '网关',
                          tipsText: '开、关一些信息的接收和发送',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
