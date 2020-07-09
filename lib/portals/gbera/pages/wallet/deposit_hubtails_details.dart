import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_bills.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';

class DepositHubTailsDetails extends StatefulWidget {
  PageContext context;

  DepositHubTailsDetails({this.context});

  @override
  _DepositHubTailsDetailsState createState() => _DepositHubTailsDetailsState();
}

class _DepositHubTailsDetailsState extends State<DepositHubTailsDetails> {
  List<DepositHubTailsActivityOR> _activities = [];
  Timer _timer;
  DepositHubTailsOR _record;
  WenyBank _bank;

  @override
  void initState() {
    _record = widget.context.parameters['transHubtails'];
    _bank = widget.context.parameters['bank'];
    if (mounted) {
      setState(() {});
    }
    _loadActivities().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _activities?.clear();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService("/wallet/records");
    _activities = await recordRemote.getDepositHubTailsActivies(_record.sn);
  }

  @override
  Widget build(BuildContext context) {
    DepositHubTailsOR record = _record;
    WenyBank bank = _bank;
    var slivers = <Widget>[
      SliverAppBar(
        pinned: true,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text('经营尾金入账账单'),
        centerTitle: true,
      ),
    ];
    if (_bank == null || record == null) {
      slivers.add(
        SliverToBoxAdapter(
          child: Center(
            child: Text('没有数据'),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverToBoxAdapter(
          child: _AmountCard(record, bank),
        ),
      );
      slivers.add(
        SliverFillRemaining(
          child: _DetailsCard(record, bank),
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: slivers,
      ),
    );
  }

  Widget _AmountCard(DepositHubTailsOR record, WenyBank bank) {
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 60,
              bottom: 4,
            ),
            child: Text(
              '金额:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(
            child: Text(
              '¥${(record.amount / 100.00).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DetailsCard(DepositHubTailsOR record, WenyBank bank) {
    var minWidth = 70.00;
    return Container(
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '单号:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${record.sn}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '请求金额:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥${(record.amount / 100).toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '来源:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: '${_bank.info.title}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '订单状态:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${record.state == 0 ? '申购中' : record.state == 1 ? '已完成' : ''}  ${record.status} ${record.message}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '收单时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(record.ctime))}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '完成时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(record.lutime))}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 40,
              right: 40,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                  ),
                  child: Text(
                    '协议内容:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '查看',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
              top: 30,
              left: 15,
            ),
            child: Text(
              '处理过程:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Column(
              children: _activities.map((activity) {
                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.grey[500],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text(
                              '${activity.activityNo}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 5,
                              children: <Widget>[
                                Text(
                                  '${activity.activityName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${intl.DateFormat('yyyy/MM/dd HH:mm:ss SSS').format(parseStrTime(activity.ctime))}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  children: <Widget>[
                                    Text(
                                      '${activity.status}',
                                    ),
                                    Text(
                                      '${activity.message}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
