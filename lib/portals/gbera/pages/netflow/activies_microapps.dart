import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class ActivitiesMicroapps extends StatefulWidget {
  PageContext context;

  ActivitiesMicroapps({this.context});

  @override
  _ActivesSitesState createState() => _ActivesSitesState();
}

class _ActivesSitesState extends State<ActivitiesMicroapps>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: _allPages().length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.context.page.title),
        elevation: 0.0,
        titleSpacing: 0,
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          labelColor: Colors.black,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: _allPages().map<Tab>((_Page page) {
            return Tab(
              text: page.text,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: _allPages().map<Widget>((_Page page) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Container(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: _SiteRegion(
                context: widget.context,
                sites: page.sites ?? [],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<_Page> _allPages() => <_Page>[
        _Page(
          text: '全部',
          sites: [
            CardItem(
              title: '充值｜话费',
              tipsText: '中国电信',
              onItemTap: () {
                widget.context.forward('/micro/app');
              },
            ),
            CardItem(
              title: '会员注册',
              tipsText: '格力股份',
              onItemTap: () {
                widget.context.forward('/micro/app');
              },
            ),
            CardItem(
              title: '优惠｜打折',
              tipsText: '苏宁电器',
              onItemTap: () {
                widget.context.forward('/micro/app');
              },
            ),
          ],
        ),
        _Page(
          text: '餐饮',
          sites: [
            CardItem(
              title: '订餐',
              tipsText: '美团',
              onItemTap: () {
                widget.context.forward('/micro/app');
              },
            ),
          ],
        ),
        _Page(
          text: '教育',
          sites: [
            CardItem(
              title: '上门收件',
              tipsText: '中国邮政',
              onItemTap: () {
                widget.context.forward('/micro/app');
              },
            ),
          ],
        ),
        _Page(
          text: '旅游住宿',
          sites: [],
        ),
        _Page(
          text: '汽车',
          sites: [],
        ),
        _Page(
          text: '商店|超市',
          sites: [],
        ),
      ];
}

class _Page {
  const _Page({this.text, this.sites});

  final String text;
  final List<CardItem> sites;
}

class _SiteRegion extends StatefulWidget {
  var sites = <CardItem>[];
  PageContext context;

  _SiteRegion({this.sites, this.context});

  @override
  __SiteRegionState createState() => __SiteRegionState();
}

class __SiteRegionState extends State<_SiteRegion> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            widget.sites.map((item) {
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
    );
  }
}
