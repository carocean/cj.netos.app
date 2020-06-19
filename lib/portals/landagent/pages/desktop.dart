import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class LandagentDesktop extends StatefulWidget {
  PageContext context;

  LandagentDesktop({this.context});

  @override
  _LandagentDesktopState createState() => _LandagentDesktopState();
}

class _LandagentDesktopState extends State<LandagentDesktop>
    with SingleTickerProviderStateMixin {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];
  TabController tabController;
  List<_TabPageView> tabPageViews;

  @override
  void initState() {
    _controller = EasyRefreshController();
    this.tabPageViews = [
      _TabPageView(
        title: '待办',
        buildView: _todoListPanel,
      ),
      _TabPageView(
        title: '已办',
        buildView: _doneListPanel,
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
    _onRefresh();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    this.tabController?.dispose();
    this.tabPageViews?.clear();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/org/workflow');
    var items = await workflowRemote.pageMyWorkItem(_limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _offset += items.length;
    _workitems.addAll(items);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, v) {
        return <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            title: Text(
              '地商(LA)',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add,
                ),
                onPressed: () {
                  widget.context.forward('/apply/wybank');
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 30,
                right: 40,
                top: 20,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Image.file(
                            File(
                              '${widget.context.principal.avatarOnLocal}',
                            ),
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 2,
                          children: <Widget>[
                            Text(
                              '${widget.context.principal.nickName}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text:
                                    '${widget.context.principal.signature ?? ''}',
                                children: [],
                              ),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                controller: this.tabController,
                tabs: tabPageViews.map((v) {
                  return Tab(
                    text: v.title,
                  );
                }).toList(),
              ),
            ),
          )
        ];
      },
      body: TabBarView(
        controller: this.tabController,
        children: tabPageViews.map((v) {
          if (v.buildView == null) {
            return Container(
              width: 0,
              height: 0,
            );
          }
          return v.buildView();
        }).toList(),
      ),
    );
  }

  Widget _todoListPanel() {
    var items = <Widget>[];
    if (_workitems.isEmpty) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 10,
          ),
          alignment: Alignment.center,
          child: Text(
            '没有事件',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < _workitems.length; i++) {
      var item = _workitems[i];
      var inst = item.workInst;
      var event = item.workEvent;
      items.add(
        _OperatorEvent(
          eventLeading: FadeInImage.assetNetwork(
            placeholder: 'lib/portals/gbera/images/default_watting.gif',
            image:
                '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          ),
          eventName: '${inst.name}',
          eventDetails: '待处理: ${event.title} ${event.sender ?? ''}',
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return widget.context.part('/event/details', context);
                });
          },
        ),
      );
    }
    return EasyRefresh(
      onRefresh: _onRefresh,
      controller: _controller,
      child: ListView(
        padding: EdgeInsets.only(top: 15,),
        children: items,
      ),
    );
  }

  Widget _doneListPanel() {
    var items = <Widget>[];
    if (_workitems.isEmpty) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 10,
          ),
          alignment: Alignment.center,
          child: Text(
            '没有事件',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < _workitems.length; i++) {
      var item = _workitems[i];
      var inst = item.workInst;
      var event = item.workEvent;
      items.add(
        _OperatorEvent(
          eventLeading: FadeInImage.assetNetwork(
            placeholder: 'lib/portals/gbera/images/default_watting.gif',
            image:
                '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          ),
          eventName: '${inst.name}',
          eventDetails: '待处理: ${event.title} ${event.sender ?? ''}',
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return widget.context.part('/event/details', context);
                });
          },
        ),
      );
    }
    return EasyRefresh(
      onRefresh: _onRefresh,
      controller: _controller,
      child: ListView(
        padding: EdgeInsets.only(top: 15,),
        children: items,
      ),
    );
  }
}

class _OperatorEvent extends StatelessWidget {
  String eventName;
  String eventDetails;
  Widget eventLeading;
  bool isBottom;
  Function() onTap;

  _OperatorEvent({
    this.eventName,
    this.eventDetails,
    this.eventLeading,
    this.isBottom = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                  child: eventLeading,
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 4,
                          children: <Widget>[
                            Text(
                              eventName ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              eventDetails ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 15,
              ),
              child: isBottom
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : Divider(
                      height: 1,
                      indent: 25,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final Color color;

  StickyTabBarDelegate({@required this.child, @required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: this.child,
      color: color,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _TabPageView {
  String title;
  Widget Function() buildView;

  _TabPageView({this.title, this.buildView});
}
