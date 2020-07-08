import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;

class WithdrawRecordsPage extends StatefulWidget {
  PageContext context;

  WithdrawRecordsPage({this.context});

  @override
  _WithdrawRecordsPageState createState() => _WithdrawRecordsPageState();
}

class _WithdrawRecordsPageState extends State<WithdrawRecordsPage> {
  BankInfo _bank;
  List<WithdrawRecordOR> _records = [];
  EasyRefreshController _controller;
  int _limit = 50, _offset = 0;
  int _totalWithdrawsAmount = 0;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
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
    _records.clear();
    await _onLoad();
  }

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    _totalWithdrawsAmount = await robotRemote.totalAmountWithdraws(_bank.id);
    List<WithdrawRecordOR> records =
        await robotRemote.pageWithdrawRecord(_bank.id, _limit, _offset);
    if (records.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += records.length;
    _records.addAll(records);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_records.isEmpty) {
      items.add(
        Center(
          child: Text('没有数据'),
        ),
      );
    }
    for (var record in _records) {
      items.add(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          '${record.personName ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 5,
                          children: <Widget>[
                            Text(
                              '${record.alias ?? ''}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(record.ctime))}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${record.realAmount==null?'计算中...':'¥${((record.realAmount) / 100).toStringAsFixed(2)}'}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('提取明细'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                bottom: 20,
              ),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: <Widget>[
                  Text(
                    '总提取',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '¥${((_totalWithdrawsAmount??0.00) / 100).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: EasyRefresh(
                  onRefresh: _onRefresh,
                  onLoad: _onLoad,
                  child: ListView(
                    shrinkWrap: true,
                    children: items,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
