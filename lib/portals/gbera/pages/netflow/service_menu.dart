import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:webview_flutter/webview_flutter.dart';

///服务清单
class ServiceMenu extends StatelessWidget {
  PageContext context;

  ServiceMenu({this.context});

  @override
  Widget build(BuildContext context) {
    var services_page1 = <ThirdPartyService>[];
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1410704196,754504588&fm=26&gp=0.jpg',
      title: '费用｜积分',
      onTap: (){
        this.context.backward(result: {'selected':'费用'});
      },
    ));
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3461514539,795423572&fm=26&gp=0.jpg',
      title: '在用产品',
      onTap: (){
        this.context.backward(result: {'selected':'在用产品'});
      },
    ));
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3399756601,3876810634&fm=26&gp=0.jpg',
      title: '流量｜通话',
      onTap: (){
        this.context.backward(result: {'selected':'流量｜通话'});
      },
    ));
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1368553957,2392681342&fm=26&gp=0.jpg',
      title: '装机修障进度',
    ));
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=150135425,1929992673&fm=26&gp=0.jpg',
      title: '充值交费',
    ));
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=276772382,2920623207&fm=26&gp=0.jpg',
      title: '5G专区',
    ));
    services_page1.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2265008670,1770423049&fm=26&gp=0.jpg',
      title: '附近营业厅',
    ));
    var services_page2 = <ThirdPartyService>[];
    services_page2.add(ThirdPartyService(
      iconUrl:
          'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=144715234,836389000&fm=26&gp=0.jpg',
      title: '服务大厅',
    ));
    services_page2.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=108446868,1406702903&fm=26&gp=0.jpg',
      title: '优惠活动',
    ));
    services_page2.add(ThirdPartyService(
      iconUrl:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=4035533329,1566894074&fm=26&gp=0.jpg',
      title: '在线客服',
    ));
    var pageViews = <_PageView>[
      _PageView(
        services: services_page1,
      ),
      _PageView(
        services: services_page2,
      ),
    ];
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white70,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Image.network(
                        'https://sjbz-fd.zol-img.com.cn/t_s208x312c5/g5/M00/01/06/ChMkJ1w3FnmIE9dUAADdYQl3C5IAAuTxAKv7x8AAN15869.jpg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      '波涛旅行Hotle',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '服务市场',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Expanded(
            child: DefaultTabController(
              length: pageViews.length,
              child: _PageSelector(pageViews: pageViews),
            ),
          ),
        ],
      ),
    );
  }
}

class ThirdPartyService {
  String iconUrl;
  String title;
  Function() onTap;
  ThirdPartyService({this.iconUrl, this.title,this.onTap});
}

class _ServiceWidget extends StatelessWidget {
  ThirdPartyService service;

  _ServiceWidget({this.service});

  @override
  Widget build(BuildContext context) {
    var item = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: service.onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        width: 100,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                bottom: 5,
              ),
              child: Image.network(
                service.iconUrl,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              service.title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
    return item;
  }
}

class _PageView extends StatelessWidget {
  List<ThirdPartyService> services;

  _PageView({this.services});

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    for (ThirdPartyService _service in services) {
      list.add(
        _ServiceWidget(
          service: _service,
        ),
      );
    }
    return CustomScrollView(
      shrinkWrap: true,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.center,
            child: Wrap(
              children: list,
            ),
          ),
        ),
      ],
    );
  }
}

class _PageSelector extends StatelessWidget {
  List<_PageView> pageViews;

  _PageSelector({this.pageViews});

  @override
  Widget build(BuildContext context) {
    var _controller = DefaultTabController.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            child: TabBarView(
              children: pageViews,
            ),
          ),
        ),
        TabPageSelector(
          controller: _controller,
        ),
      ],
    );
  }
}

