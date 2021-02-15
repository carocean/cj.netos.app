import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/market/tab_page.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_bill.dart';

class FissionMFBillPage extends StatefulWidget {
  PageContext context;

  FissionMFBillPage({this.context});

  @override
  _FissionMFBillPageState createState() => _FissionMFBillPageState();
}

class _FissionMFBillPageState extends State<FissionMFBillPage>
    with SingleTickerProviderStateMixin {
  EasyRefreshController _controller;
  TabController tabController;
  List<TabPageView> tabPageViews;
  DateTime _selected;
  int _total_order0 = 0,
      _total_order1 = 0,
      _total_order2 = 0,
      _total_order3 = 0;
  StreamController _datePickerNotify;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _datePickerNotify = StreamController.broadcast();
    _selected = DateTime.now();
    _loadIndexer().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    this.tabPageViews = [
      TabPageView(
        title: '全部',
        view: _CashierBillTabView(
          context: widget.context,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: -1,
        ),
      ),
      TabPageView(
        title: '收入单',
        view: _CashierBillTabView(
          context: widget.context,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 3,
        ),
      ),
      TabPageView(
        title: '支出单',
        view: _CashierBillTabView(
          context: widget.context,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 2,
        ),
      ),
      TabPageView(
        title: '充值单',
        view: _CashierBillTabView(
          context: widget.context,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 0,
        ),
      ),
      TabPageView(
        title: '提取单',
        view: _CashierBillTabView(
          context: widget.context,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
          order: 1,
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

  Future<void> _loadIndexer() async {
    IFissionMFCashierBillRemote cashierBillRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/bill');
    _total_order0 = await cashierBillRemote.totalBillOfMonthByOrder(
        0, _selected.year, _selected.month);
    _total_order1 = await cashierBillRemote.totalBillOfMonthByOrder(
        1, _selected.year, _selected.month);
    _total_order2 = await cashierBillRemote.totalBillOfMonthByOrder(
        2, _selected.year, _selected.month);
    _total_order3 = await cashierBillRemote.totalBillOfMonthByOrder(
        3, _selected.year, _selected.month);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, v) {
          return <Widget>[
            SliverAppBar(
              title: Text('账单'),
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
                              await _loadIndexer();
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
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 5,
                                        ),
                                        child: Text(
                                          '支出',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '¥${((_total_order2 ?? 0) / 100.00).toStringAsFixed(2)}',
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
                                          '收入',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '¥${((_total_order3 ?? 0) / 100.00).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 5,
                                        ),
                                        child: Text(
                                          '充值',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '¥${((_total_order0 ?? 0) / 100.00).toStringAsFixed(2)}',
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
                                          '提现',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '¥${((_total_order1 ?? 0) / 100.00).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
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
                                  '资金',
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

class _CashierBillTabView extends StatefulWidget {
  PageContext context;
  Stream datePicker;
  DateTime defaultDate;
  int order;

  _CashierBillTabView({
    this.context,
    this.datePicker,
    this.defaultDate,
    this.order,
  });

  @override
  _CashierBillTabViewState createState() => _CashierBillTabViewState();
}

class _CashierBillTabViewState extends State<_CashierBillTabView> {
  List<CashierBillOR> _bills = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  DateTime _selectedDateTime;
  int _order;
  StreamSubscription _date_picker_streamSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    _selectedDateTime = widget.defaultDate;
    _order = widget.order;
    _controller = EasyRefreshController();
    _date_picker_streamSubscription = widget.datePicker.listen((event) async {
      _selectedDateTime = event['date'];
      await _onRefresh();
      if (mounted) {
        setState(() {});
      }
    });

    _onload().then((value) {
      if (mounted) {
        _isLoading = false;
      }
    });
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
    IFissionMFCashierBillRemote cashierBillRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/bill');
    List<CashierBillOR> bills;
    if (_order == -1) {
      bills = await cashierBillRemote.getBillOfMonth(
          _selectedDateTime.year, _selectedDateTime.month, _limit, _offset);
    } else {
      bills = await cashierBillRemote.pageBillOfMonth(_order,
          _selectedDateTime.year, _selectedDateTime.month, _limit, _offset);
    }
    if (bills.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += bills.length;
    _bills.addAll(bills);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(_CashierBillTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order ||
        oldWidget.defaultDate != widget.defaultDate) {
      oldWidget.order = widget.order;
      oldWidget.defaultDate = widget.defaultDate;
    }
  }

  Future<void> _forward(CashierBillOR bill) async {
    switch (bill.order) {
      case 0: //充值
        widget.context.forward('/wallet/fission/mf/record/recharge',
            arguments: {'sn': bill.refsn});
        break;
      case 1: //提现
        widget.context.forward('/wallet/fission/mf/record/withdraw',
            arguments: {'sn': bill.refsn});
        break;
      case 2: //支出
      case 3: //收入
        widget.context.forward('/wallet/fission/mf/record/pay',
            arguments: {'sn': bill.refsn});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isLoading) {
      content = Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          top: 30,
        ),
        child: Text(
          '正在加载...',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    } else {
      if (_bills.isEmpty) {
        content = Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            top: 30,
          ),
          child: Text(
            '没有数据',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        );
      } else {
        content = Expanded(
          child: EasyRefresh.custom(
            controller: _controller,
            onLoad: _onload,
            onRefresh: _onRefresh,
            slivers: _bills.map((bill) {
              return SliverToBoxAdapter(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _forward(bill);
                  },
                  child: Row(
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
                                          Expanded(
                                            child: Text(
                                              '${bill.sn}',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
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
                                              '¥${((bill.amount ?? 0.0) / 100.00).toStringAsFixed(2)}',
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
                                              '¥${((bill.balance ?? 0.0) / 100.00).toStringAsFixed(2)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
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
                ),
              );
            }).toList(),
          ),
        );
      }
    }
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
          content,
        ],
      ),
    );
  }

  _getOrderType(CashierBillOR bill) {
    switch (bill.order) {
      case 0:
        return '充值单';
      case 1:
        return '提取单';
      case 2:
        return '支出单';
      case 3:
        return '收入单';
    }
    return '';
  }
}
