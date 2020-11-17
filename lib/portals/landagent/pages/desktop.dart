import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:intl/intl.dart' as intl;

class LandagentDesktop extends StatefulWidget {
  PageContext context;

  LandagentDesktop({this.context});

  @override
  _LandagentDesktopState createState() => _LandagentDesktopState();
}

class _LandagentDesktopState extends State<LandagentDesktop>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List<_TabPageView> tabPageViews;

  @override
  void initState() {
    this.tabPageViews = [
      _TabPageView(
        title: '待办',
        buildView: () {
          return _TodoWorkitem(context: widget.context);
        },
      ),
      _TabPageView(
        title: '已办',
        buildView: () {
          return _DoneWorkitem(context: widget.context);
        },
      ),
      _TabPageView(
        title: '发件',
        buildView: () {
          return _MyCreatedInstWorkItem(context: widget.context);
        },
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    this.tabController?.dispose();
    this.tabPageViews?.clear();
    super.dispose();
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
                  Icons.more_vert,
                ),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (ctx) {
                      return CupertinoAlertDialog(
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.comment,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                Text("发资讯"),
                              ],
                            ),
                            onPressed: () {
                              widget.context.backward(result: 'sendNews');
                            },
                          ),
                          CupertinoDialogAction(
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.userCheck,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                Text("发工单"),
                              ],
                            ),
                            onPressed: () {
                              widget.context.backward(result: 'sendWorkOrder');
                            },
                          ),
                          CupertinoDialogAction(
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.wonSign,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                Text("申请福利中心"),
                              ],
                            ),
                            onPressed: () {
                              widget.context.backward(result: 'applyWybank');
                            },
                          ),
                        ],
                      );
                    },
                  ).then((value) {
                    if (value == null) {
                      return;
                    }
                    switch (value) {
                      case 'applyWybank':
                        widget.context.forward('/apply/wybank');
                        break;
                      case 'sendWorkOrder':
                        break;
                      case 'sendNews':
                        break;
                      default:
                        print('不支持的命令:$value');
                        break;
                    }
                  });
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
}

class _TodoWorkitem extends StatefulWidget {
  PageContext context;

  _TodoWorkitem({this.context});

  @override
  __TodoWorkitemState createState() => __TodoWorkitemState();
}

class __TodoWorkitemState extends State<_TodoWorkitem> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _workitems.clear();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onload() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/org/workflow');
    var items = await workflowRemote.pageMyWorkItemByFilter(0, _limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
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
          eventDetails: '当前处理: ${event.title}' +
              '\n送达时间: ' +
              intl.DateFormat('HH:mm yyyy/MM/dd').format(
                parseStrTime(
                  event.ctime,
                  len: 17,
                ),
              ) +
              (StringUtil.isEmpty(event.sender)
                  ? ''
                  : '\n发件人: ${event.sender}'),
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return widget.context
                      .part('/event/details', context, arguments: {
                    'workitem': item,
                  });
                }).then((value) {
              if (value == null) {
                return;
              }
              _onRefresh();
            });
          },
        ),
      );
    }
    return EasyRefresh(
      onRefresh: _onRefresh,
      onLoad: _onload,
      controller: _controller,
      child: ListView(
        padding: EdgeInsets.only(
          top: 15,
        ),
        children: items,
      ),
    );
  }
}

class _DoneWorkitem extends StatefulWidget {
  PageContext context;

  _DoneWorkitem({this.context});

  @override
  __DoneWorkitemState createState() => __DoneWorkitemState();
}

class __DoneWorkitemState extends State<_DoneWorkitem> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _workitems.clear();
    await _onLoad();
  }

  Future<void> _onLoad() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/org/workflow');
    var items = await workflowRemote.pageMyWorkItemByFilter(1, _limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
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
          eventDetails: '当前处理: ${event.title}' +
              '\n送达时间: ' +
              intl.DateFormat('HH:mm yyyy/MM/dd').format(
                parseStrTime(
                  event.ctime,
                  len: 17,
                ),
              ) +
              (StringUtil.isEmpty(event.sender)
                  ? ''
                  : '\n发件人: ${event.sender}') +
              (StringUtil.isEmpty(event.recipient)
                  ? ''
                  : '\n收件人: ${event.recipient}'),
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return widget.context
                      .part('/event/details', context, arguments: {
                    'workitem': item,
                  });
                }).then((value) {
              if (value == null) {
                return;
              }
              _onRefresh();
            });
          },
        ),
      );
    }
    return EasyRefresh(
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      controller: _controller,
      child: ListView(
        padding: EdgeInsets.only(
          top: 15,
        ),
        children: items,
      ),
    );
  }
}

class _MyCreatedInstWorkItem extends StatefulWidget {
  PageContext context;

  _MyCreatedInstWorkItem({this.context});

  @override
  __MyCreatedInstWorkItemState createState() => __MyCreatedInstWorkItemState();
}

class __MyCreatedInstWorkItemState extends State<_MyCreatedInstWorkItem> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onRefresh();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

//
//  @override
//  void didUpdateWidget(_MyCreatedInstWorkItem oldWidget) {
//    super.didUpdateWidget(oldWidget);
//  }

  Future<void> _onRefresh() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/org/workflow');
    var items = await workflowRemote.pageMyWorkItemByFilter(2, _limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
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
          eventDetails: '当前处理: ${event.title}' +
              '\n送达时间: ' +
              intl.DateFormat('HH:mm yyyy/MM/dd').format(
                parseStrTime(
                  event.ctime,
                  len: 17,
                ),
              ) +
              (StringUtil.isEmpty(event.recipient)
                  ? ''
                  : '\n处理人: ${event.recipient}'),
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return widget.context
                      .part('/event/details', context, arguments: {
                    'workitem': item,
                  });
                }).then((value) {
              if (value == null) {
                return;
              }
              _onRefresh();
            });
          },
        ),
      );
    }
    return EasyRefresh(
      onRefresh: _onRefresh,
      controller: _controller,
      child: ListView(
        padding: EdgeInsets.only(
          top: 15,
        ),
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
