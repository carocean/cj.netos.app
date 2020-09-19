import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';

class MyAbsorbersPage extends StatefulWidget {
  PageContext context;

  MyAbsorbersPage({this.context});

  @override
  _MyAbsorbersPageState createState() => _MyAbsorbersPageState();
}

class _MyAbsorbersPageState extends State<MyAbsorbersPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<_TabPageView> _tabPageViews;
  MyWallet _myWallet;
  StreamController _refreshController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _refreshController = StreamController.broadcast();
    _streamSubscription = Stream.periodic(
      Duration(
        seconds: 5,
      ),
      (count) {
        return count;
      },
    ).listen((event) async {
      var old = _myWallet;
      await _loadAccounts();
      if (old == null || old.absorb == _myWallet.absorb) {
        return;
      }
      if (mounted) {
        setState(() {});
      }
      _refreshController.add({'wallet': _myWallet});
    });
    _tabPageViews = <_TabPageView>[
      _TabPageView(
        title: '我的',
        view: _MyAbsorberListView(
          context: widget.context,
          timerStream: _refreshController.stream,
        ),
      ),
      _TabPageView(
        title: '参与的',
        view: _MyJioninAbsorberListView(
          context: widget.context,
          timerStream: _refreshController.stream,
        ),
      ),
      _TabPageView(
        title: '在圈的',
        view: _MyEnterAbsorberListView(
          context: widget.context,
          timerStream: _refreshController.stream,
        ),
      ),
    ];
    this._tabController =
        TabController(length: _tabPageViews.length, vsync: this);
    _loadAccounts().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _refreshController?.close();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    IWalletAccountRemote walletAccountService =
        widget.context.site.getService('/wallet/accounts');
    _myWallet = await walletAccountService.getAllAcounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, v) {
          var slivers = <Widget>[
            SliverAppBar(
              elevation: 0.0,
              title: Text('招财猫'),
              pinned: true,
              titleSpacing: 0,
            ),
          ];
          slivers.add(
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 15,
                    right: 15,
                  ),
                  margin: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 20,
                    bottom: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: 8,
                            ),
                            child: Icon(
                              Icons.blur_linear,
                              size: 16,
                              color: widget.context
                                  .style('/profile/list/item-icon.color'),
                            ),
                          ),
                          Text(
                            '可提洇金',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                        child: Divider(
                          height: 1,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.context
                            .forward('/wallet/absorb', arguments: {
                          'wallet': _myWallet,
                        }),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: Text(
                                      '¥${_myWallet?.absorbYan ?? '-'}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          slivers.add(
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                color: Theme.of(context).backgroundColor,
                // color: Colors.white,
                child: TabBar(
                  labelColor: Colors.black,
                  controller: this._tabController,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _tabPageViews.map((v) {
                    return Tab(
                      text: v.title,
                    );
                  }).toList(),
                ),
              ),
            ),
          );
          return slivers;
        },
        body: TabBarView(
          controller: this._tabController,
          children: _tabPageViews.map((v) {
            if (v.view == null) {
              return Container(
                width: 0,
                height: 0,
              );
            }
            return v.view;
          }).toList(),
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final Color color;

  _StickyTabBarDelegate({@required this.child, @required this.color});

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
  Widget view;

  _TabPageView({
    this.title,
    this.view,
  });
}

class _MyAbsorberListView extends StatefulWidget {
  PageContext context;
  Stream timerStream;

  _MyAbsorberListView({
    this.context,
    this.timerStream,
  });

  @override
  __MyAbsorberListViewState createState() => __MyAbsorberListViewState();
}

class __MyAbsorberListViewState extends State<_MyAbsorberListView> {
  EasyRefreshController _controller;
  List<AbsorberResultOR> _absorbers = [];
  int _limit = 10, _offset = 0;
  int _usage = -1;

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

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var absorbers =
        await robotRemote.pageMyAbsorberByUsage(_usage, _limit, _offset);
    if (absorbers.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += absorbers.length;
    _absorbers.addAll(absorbers);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _absorbers.clear();
    await _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list;
    if (_absorbers.isEmpty) {
      list = <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 20,
          ),
          color: Colors.white,
          child: Text(
            '没有猫',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      ];
    } else {
      list = _absorbers.map((e) {
        return Column(
          children: [
            _AbsorberItemPannel(
              context: widget.context,
              absorberResultOR: e,
              stream: widget.timerStream,
            ),
            SizedBox(
              height: 20,
              child: Divider(
                height: 1,
                indent: 60,
              ),
            ),
          ],
        );
      }).toList();
    }
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return SimpleDialog(
                      title: Text('选择'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'channel');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '网流猫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'receptor');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '地理猫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'ingot');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '抢元宝',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'fountain');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '金证喷泉',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                child: Text(
                                  '全部',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  widget.context.backward(result: 'all');
                                },
                              ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                          ),
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                        ),
                      ],
                    );
                  }).then((value) {
                if (value == null) {
                  return;
                }
                switch (value) {
                  case 'channel':
                    _usage = 0;
                    break;
                  case 'receptor':
                    _usage = 1;
                    break;
                  case 'fountain':
                    _usage = 3;
                    break;
                  case 'ingot':
                    _usage = 4;
                    break;
                  default:
                    _usage = -1;
                    break;
                }
                _onRefresh().then((value) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              });
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                right: 15,
                left: 15,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_getTypeLabel()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    FontAwesomeIcons.filter,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: 10,
          //   child: Divider(
          //     height: 1,
          //     indent: 20,
          //   ),
          // ),
          Expanded(
            child: EasyRefresh(
              controller: _controller,
              onLoad: _onLoad,
              onRefresh: _onRefresh,
              child: Column(
                children: list,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getTypeLabel() {
    switch (_usage) {
      case -1:
        return '全部';
      case 0:
        return '网流猫';
      case 1:
        return '地理猫';
      case 3:
        return '金证喷泉';
      case 4:
        return '抢元宝';
    }
  }
}

class _MyJioninAbsorberListView extends StatefulWidget {
  PageContext context;
  Stream timerStream;

  _MyJioninAbsorberListView({
    this.context,
    this.timerStream,
  });

  @override
  __MyJioninAbsorberListViewState createState() =>
      __MyJioninAbsorberListViewState();
}

class __MyJioninAbsorberListViewState extends State<_MyJioninAbsorberListView> {
  EasyRefreshController _controller;
  List<AbsorberResultOR> _absorbers = [];
  int _limit = 10, _offset = 0;
  int _usage = -1;

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

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var absorbers =
        await robotRemote.pageJioninAbsorberByUsage(_usage, _limit, _offset);
    if (absorbers.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += absorbers.length;
    _absorbers.addAll(absorbers);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _absorbers.clear();
    await _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list;
    if (_absorbers.isEmpty) {
      list = <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 20,
          ),
          color: Colors.white,
          child: Text(
            '没有猫',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      ];
    } else {
      list = _absorbers.map((e) {
        return Column(
          children: [
            _AbsorberItemPannel(
              context: widget.context,
              absorberResultOR: e,
              stream: widget.timerStream,
            ),
            SizedBox(
              height: 20,
              child: Divider(
                height: 1,
                indent: 60,
              ),
            ),
          ],
        );
      }).toList();
    }
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return SimpleDialog(
                      title: Text('选择'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'channel');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '网流猫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'receptor');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '地理猫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'ingot');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '抢元宝',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'fountain');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '金证喷泉',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                child: Text(
                                  '全部',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  widget.context.backward(result: 'all');
                                },
                              ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                          ),
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                        ),
                      ],
                    );
                  }).then((value) {
                if (value == null) {
                  return;
                }
                switch (value) {
                  case 'channel':
                    _usage = 0;
                    break;
                  case 'receptor':
                    _usage = 1;
                    break;
                  case 'fountain':
                    _usage = 3;
                    break;
                  case 'ingot':
                    _usage = 4;
                    break;
                  default:
                    _usage = -1;
                    break;
                }
                _onRefresh().then((value) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              });
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                right: 15,
                left: 15,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_getTypeLabel()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    FontAwesomeIcons.filter,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: 10,
          //   child: Divider(
          //     height: 1,
          //     indent: 20,
          //   ),
          // ),
          Expanded(
            child: EasyRefresh(
              controller: _controller,
              onLoad: _onLoad,
              onRefresh: _onRefresh,
              child: Column(
                children: list,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getTypeLabel() {
    switch (_usage) {
      case -1:
        return '全部';
      case 0:
        return '网流猫';
      case 1:
        return '地理猫';
      case 3:
        return '金证喷泉';
      case 4:
        return '抢元宝';
    }
  }
}

class _MyEnterAbsorberListView extends StatefulWidget {
  PageContext context;
  Stream timerStream;

  _MyEnterAbsorberListView({
    this.context,
    this.timerStream,
  });

  @override
  __MyEnterAbsorberListViewState createState() =>
      __MyEnterAbsorberListViewState();
}

class __MyEnterAbsorberListViewState extends State<_MyEnterAbsorberListView> {
  EasyRefreshController _controller;
  List<AbsorberResultOR> _absorbers = [];
  int _limit = 10, _offset = 0;
  int _usage = -1;
  GeoReceptor _myReceptor;

  @override
  void initState() {
    _controller = EasyRefreshController();
    () async {
      IGeoReceptorRemote receptorRemote =
          widget.context.site.getService('/remote/geo/receptors');
      _myReceptor = await receptorRemote.getMyMobilReceptor();
      await _onLoad();
    }();

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onLoad() async {
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');

    List<GeoPOI> pois = await receptorRemote.searchAroundReceptors(
        categroy: 'mobiles',
        receptor: _myReceptor.id,
        geoType: 'mobiles',
        limit: _limit,
        offset: _offset);
    if (pois.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    for (var poi in pois) {
      var receptor = poi.receptor;
      var absorbabler = '${receptor.category}/${receptor.id}';
      var absorber = await robotRemote.getAbsorberByAbsorbabler(absorbabler);
      if (absorber == null) {
        continue;
      }
      _absorbers.add(absorber);
    }
    _offset += pois.length;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _absorbers.clear();
    await _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list;
    if (_absorbers.isEmpty) {
      list = <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 20,
          ),
          color: Colors.white,
          child: Text(
            '没有猫',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      ];
    } else {
      list = _absorbers.map((e) {
        return Column(
          children: [
            _AbsorberItemPannel(
              context: widget.context,
              absorberResultOR: e,
              stream: widget.timerStream,
            ),
            SizedBox(
              height: 20,
              child: Divider(
                height: 1,
                indent: 60,
              ),
            ),
          ],
        );
      }).toList();
    }
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return SimpleDialog(
                      title: Text('选择'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'channel');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '网流猫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'receptor');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '地理猫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'ingot');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '抢元宝',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                            indent: 20,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context.backward(result: 'fountain');
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '金证喷泉',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                child: Text(
                                  '全部',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  widget.context.backward(result: 'all');
                                },
                              ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                          ),
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                        ),
                      ],
                    );
                  }).then((value) {
                if (value == null) {
                  return;
                }
                switch (value) {
                  case 'channel':
                    _usage = 0;
                    break;
                  case 'receptor':
                    _usage = 1;
                    break;
                  case 'fountain':
                    _usage = 3;
                    break;
                  case 'ingot':
                    _usage = 4;
                    break;
                  default:
                    _usage = -1;
                    break;
                }
                _onRefresh().then((value) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              });
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                right: 15,
                left: 15,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_getTypeLabel()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    FontAwesomeIcons.filter,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: 10,
          //   child: Divider(
          //     height: 1,
          //     indent: 20,
          //   ),
          // ),
          Expanded(
            child: EasyRefresh(
              controller: _controller,
              onLoad: _onLoad,
              onRefresh: _onRefresh,
              child: Column(
                children: list,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getTypeLabel() {
    switch (_usage) {
      case -1:
        return '全部';
      case 0:
        return '网流猫';
      case 1:
        return '地理猫';
      case 3:
        return '金证喷泉';
      case 4:
        return '抢元宝';
    }
  }
}

class _AbsorberItemPannel extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberResultOR;
  Stream stream;

  _AbsorberItemPannel({this.context, this.absorberResultOR, this.stream});

  @override
  __AbsorberItemPannelState createState() => __AbsorberItemPannelState();
}

class __AbsorberItemPannelState extends State<_AbsorberItemPannel> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  double _myAbsorbAmount = 0.00;
  StreamSubscription _streamSubscription;
  StreamController _streamController;

  bool get isRed {
    return _absorberResultOR.bucket.price >= _bulletin.bucket.waaPrice;
  }

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _absorberResultOR = widget.absorberResultOR;
    _load();
    _streamSubscription = widget.stream.listen((event) async {
      await _load();
      if (!_streamController.isClosed) {
        _streamController
            .add({'absorber': _absorberResultOR, 'bulletin': _bulletin});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AbsorberItemPannel oldWidget) {
    if (oldWidget.absorberResultOR.absorber.id !=
        widget.absorberResultOR.absorber.id) {
      oldWidget.absorberResultOR = widget.absorberResultOR;
      _absorberResultOR = widget.absorberResultOR;
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    _absorberResultOR =
        await robotRemote.getAbsorber(_absorberResultOR.absorber.id);
    _bulletin =
        await robotRemote.getDomainBucket(_absorberResultOR.absorber.bankid);
    _myAbsorbAmount = await robotRemote.totalRecipientsRecord(
        _absorberResultOR.absorber.id, widget.context.principal.person);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bulletin == null) {
      return SizedBox(
        height: 80,
        width: 0,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_absorberResultOR.absorber.type == 0) {
          widget.context.forward('/absorber/details/simple', arguments: {
            'absorber': _absorberResultOR.absorber.id,
            'stream': _streamController.stream.asBroadcastStream(),
            'initAbsorber': _absorberResultOR,
            'initBulletin': _bulletin,
          });
          return;
        }
        widget.context.forward('/absorber/details/geo', arguments: {
          'absorber': _absorberResultOR.absorber.id,
          'stream': _streamController.stream.asBroadcastStream(),
          'initAbsorber': _absorberResultOR,
          'initBulletin': _bulletin,
        });
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            Row(
              children: [
                Image.asset(
                  isRed
                      ? 'lib/portals/gbera/images/cat-red.gif'
                      : 'lib/portals/gbera/images/cat-green.gif',
                  width: 40,
                  height: 40,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_absorberResultOR.absorber.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${_getTypeLabel()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${_absorberResultOR.absorber.state == 1 ? '运行中' : '已关停'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¥${((_myAbsorbAmount ?? 0.00) / 100.00).toStringAsFixed(14)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    // color: isRed?Colors.red:Colors.green,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  _getTypeLabel() {
    switch (_absorberResultOR.absorber.type) {
      case 0:
        return '简易洇取器';
      case 1:
        return '地理洇取器';
      case 2:
        return '余额洇取器';
      default:
        return '';
    }
  }
}
