import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class IspDesktop extends StatefulWidget {
  PageContext context;

  IspDesktop({this.context});

  @override
  _IspDesktopState createState() => _IspDesktopState();
}

class _IspDesktopState extends State<IspDesktop>
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
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, s) {
        return [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            title: Text(
              '运营商(ISP)',
            ),
            actions: <Widget>[
              PopupMenuButton(
                onSelected: (String value) {
                  switch (value) {
                    case 'publishNews':
//                      widget.context.forward('/public/login', scene: '/');
                      break;
                  }
                },
                offset: Offset(0, 40),
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  PopupMenuItem(
                    value: "publishNews",
                    child: new Text("发资讯"),
                  ),
                  PopupMenuItem(
                    value: "applyWybank",
                    child: new Text("申请纹银银行"),
                  ),
                ],
              ),
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
                            StringUtil.isEmpty(
                                    widget.context.principal.signature)
                                ? SizedBox(
                                    height: 0,
                                    width: 0,
                                  )
                                : Text.rich(
                                    TextSpan(
                                      text:
                                          '${widget.context.principal.signature}',
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
            delegate: _TabBar(
              child: TabBar(
                labelColor: Colors.black,
                controller: this.tabController,
                tabs: tabPageViews.map((v) {
                  return Tab(
                    text: v.title,
                  );
                }).toList(),
              ),
              color: Colors.white,
            ),
          ),
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

class _TabBar extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final Color color;

  _TabBar({@required this.child, @required this.color});

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
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}

class _TabPageView {
  String title;
  Widget Function() buildView;

  _TabPageView({this.title, this.buildView});
}

class _TodoWorkitem extends StatefulWidget {
  PageContext context;

  _TodoWorkitem({this.context});

  @override
  __TodoWorkitemState createState() => __TodoWorkitemState();
}

class __TodoWorkitemState extends State<_TodoWorkitem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _DoneWorkitem extends StatefulWidget {
  PageContext context;

  _DoneWorkitem({this.context});

  @override
  __DoneWorkitemState createState() => __DoneWorkitemState();
}

class __DoneWorkitemState extends State<_DoneWorkitem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _MyCreatedInstWorkItem extends StatefulWidget {
  PageContext context;

  _MyCreatedInstWorkItem({this.context});

  @override
  __MyCreatedInstWorkItemState createState() => __MyCreatedInstWorkItemState();
}

class __MyCreatedInstWorkItemState extends State<_MyCreatedInstWorkItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
