import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';

class PageChannelBillPage extends StatefulWidget {
  PageContext context;

  PageChannelBillPage({this.context});

  @override
  _PageChannelBillPageState createState() => _PageChannelBillPageState();
}

class _PageChannelBillPageState extends State<PageChannelBillPage>
    with SingleTickerProviderStateMixin {
  EasyRefreshController _controller;
  DateTime _selected;
  double _totalInOfMonth = 0, _totalOutOfMonth = 0;
  StreamController _datePickerNotify;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _datePickerNotify = StreamController.broadcast();
    _selected = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _datePickerNotify?.close();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadAcountIndexer() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, v) {
          return <Widget>[
            SliverAppBar(
              title: Text('进场账单'),
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
                              await _loadAcountIndexer();
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                '¥${((_totalInOfMonth ?? 0) / 100.00).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
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
          ];
        },
        body: _ChannelBillList(
          context: widget.context,
          datePicker: _datePickerNotify.stream.asBroadcastStream(),
          defaultDate: _selected,
        ),
      ),
    );
  }
}

class _ChannelBillList extends StatefulWidget {
  PageContext context;
  Stream datePicker;
  DateTime defaultDate;

  _ChannelBillList({
    this.context,
    this.datePicker,
    this.defaultDate,
  });

  @override
  __ChannelBillListState createState() => __ChannelBillListState();
}

class __ChannelBillListState extends State<_ChannelBillList> {
  List<ChannelBillOR> _fundBills = [];
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
    _fundBills.clear();
    await _onload();
  }

  Future<void> _onload() async {}

  @override
  void didUpdateWidget(_ChannelBillList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultDate != widget.defaultDate) {
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
              slivers: _fundBills.map((bill) {
                return SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
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
                                              Text(
                                                      '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(bill.ctime, len: 14))}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
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
          ),
        ],
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
