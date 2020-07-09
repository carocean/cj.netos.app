import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/bills.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class HubTailsWenyBill extends StatefulWidget {
  PageContext context;

  HubTailsWenyBill({this.context});

  @override
  _HubTailsWenyBillState createState() => _HubTailsWenyBillState();
}

class _HubTailsWenyBillState extends State<HubTailsWenyBill>
    with SingleTickerProviderStateMixin {
  EasyRefreshController _controller;
  TabController tabController;
  List<TabPageView> tabPageViews;
  BankInfo _bank;
  DateTime _selected;
  double _totalInOfMonth = 0, _totalOutOfMonth = 0;
  StreamController _datePickerNotify;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _datePickerNotify = StreamController.broadcast();
    _selected = DateTime.now();
    _bank = widget.context.parameters['bank'];
    _loadHubTailsIndexer().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    this.tabPageViews = [
      TabPageView(
        title: '全部',
        view: _HubTailsBillTabView(
          context: widget.context,
          bank: _bank,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: -1,
        ),
      ),
      TabPageView(
        title: '洇金提取尾金入账',
        view: _HubTailsBillTabView(
          context: widget.context,
          bank: _bank,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 0,
        ),
      ),
      TabPageView(
        title: '投单尾金入账',
        view: _HubTailsBillTabView(
          context: widget.context,
          bank: _bank,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 1,
        ),
      ),
      TabPageView(
        title: '尾金转出',
        view: _HubTailsBillTabView(
          context: widget.context,
          bank: _bank,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 2,
        ),
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _datePickerNotify?.close();
    _controller?.dispose();
    tabController?.dispose();
    tabPageViews?.clear();
    super.dispose();
  }

  Future<void> _loadHubTailsIndexer() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    _totalInOfMonth = await robotRemote.totalInBillOfMonth(_bank.id, _selected);
    _totalOutOfMonth =
        await robotRemote.totalOutBillOfMonth(_bank.id, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, v) {
          return <Widget>[
            SliverAppBar(
              title: Text('经营尾金账单'),
              pinned: true,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints.tightForFinite(
                        width: double.maxFinite,
                      ),
                      padding: EdgeInsets.only(
                        bottom: 30,
                        right: 10,
                      ),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          DatePicker.showDatePicker(
                            context,
                            dateFormat: 'yyyy年-MM月',
                            locale: DateTimePickerLocale.zh_cn,
                            pickerMode: DateTimePickerMode.date,
                            initialDateTime: _selected,
                            onConfirm: (date, list) async {
                              _selected = date;
                              _datePickerNotify.add({'date': date});
                              await _loadHubTailsIndexer();
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              margin: EdgeInsets.only(
                                right: 4,
                              ),
                              child: Text(
                                '${intl.DateFormat(
                                  'yyyy年MM月',
                                ).format(_selected)}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              FontAwesomeIcons.filter,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey[400],
                            ),
                          ),
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: Text(
                                      '入账',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '¥${((_totalInOfMonth ?? 0) / 100.00).toStringAsFixed(14)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: Text(
                                      '出账',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '¥${((_totalOutOfMonth ?? 0) / 100.00).toStringAsFixed(14)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 2,
                          left: 18,
                          right: 18,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(
                                  left: 2,
                                  right: 2,
                                ),
                                child: Text(
                                  '尾金',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
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
            SliverPersistentHeader(
              pinned: true,
              floating: false,
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
            ),
          ];
        },
        body: TabBarView(
          controller: this.tabController,
          children: tabPageViews.map((v) {
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

class _HubTailsBillTabView extends StatefulWidget {
  PageContext context;
  BankInfo bank;
  Stream datePicker;
  DateTime defaultDate;
  int order;

  _HubTailsBillTabView({
    this.context,
    this.bank,
    this.datePicker,
    this.defaultDate,
    this.order,
  });

  @override
  _HubTailsBillTabViewState createState() => _HubTailsBillTabViewState();
}

class _HubTailsBillTabViewState extends State<_HubTailsBillTabView> {
  List<HubTailsBillOR> _bills = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  DateTime _selectedDateTime;
  StreamSubscription _date_picker_streamSubscription;

  @override
  void initState() {
    _selectedDateTime = widget.defaultDate;
    _controller = EasyRefreshController();
    _date_picker_streamSubscription = widget.datePicker.listen((event) async {
      _selectedDateTime = event['date'];
      await _onRefresh();
      if (mounted) {
        setState(() {});
      }
    });

    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _date_picker_streamSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _bills.clear();
    await _onload();
  }

  Future<void> _onload() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    var bill;
    if (widget.order > -1) {
      bill = await robotRemote.pageBillOfMonth(
          widget.bank.id, _selectedDateTime, widget.order, _limit, _offset);
    } else {
      bill = await robotRemote.getBillOfMonth(
          widget.bank.id, _selectedDateTime, _limit, _offset);
    }
    if (bill.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _bills.addAll(bill);
    _offset += bill.length;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(_HubTailsBillTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order ||
        oldWidget.defaultDate != widget.defaultDate) {
      oldWidget.order = widget.order;
      oldWidget.defaultDate = widget.defaultDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          Expanded(
            child: EasyRefresh.custom(
              controller: _controller,
              onLoad: _onload,
              onRefresh: _onRefresh,
              slivers: _bills.map((bill) {
                return SliverToBoxAdapter(
                  child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Icon(
                          FontAwesomeIcons.buysellads,
                          color: Colors.grey[800],
                          size: 35,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '${bill.sn}',
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        child: Wrap(
                                          spacing: 5,
                                          crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                          children: <Widget>[
                                            widget.order > -1
                                                ? SizedBox(
                                              height: 0,
                                              width: 0,
                                            )
                                                : Text(
                                              '类型:${_getOrderType(bill)}',
                                              style: TextStyle(
                                                fontWeight:
                                                FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            Text(
                                              '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(bill.ctime, len: 14))}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        child: Wrap(
                                          spacing: 5,
                                          crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              '金额:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '¥${((bill.amount ?? 0.0) / 100.00).toStringAsFixed(14)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        child: Wrap(
                                          spacing: 5,
                                          crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              '余额:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '¥${((bill.balance ?? 0.0) / 100.00).toStringAsFixed(14)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
//                                Icon(
//                                  Icons.arrow_forward_ios,
//                                  size: 16,
//                                  color: Colors.grey[500],
//                                ),
                              ],
                            ),
                            Container(
                              height: 20,
                              child: Divider(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  _getOrderType(HubTailsBillOR bill) {
    switch (bill.order) {
      case 0:
        return '洇金提取尾金';
      case 1:
        return '投单尾金';
      case 2:
        return '尾金提取单';
    }
    return '';
  }
}
