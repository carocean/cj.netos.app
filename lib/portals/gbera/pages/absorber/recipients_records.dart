import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;

class AbsorberRecipientsRecordsPage extends StatefulWidget {
  PageContext context;

  AbsorberRecipientsRecordsPage({this.context});

  @override
  _RecipientsRecordsState createState() => _RecipientsRecordsState();
}

class _RecipientsRecordsState extends State<AbsorberRecipientsRecordsPage> {
  RecipientsOR _recipients;
  AbsorberResultOR _absorberOR;
  List<RecipientsRecordOR> _records = [];
  EasyRefreshController _controller;
  int _limit = 30, _offset = 0;
  DateTime _selected;
  double _totalBankOfMonth = 0, _totalPersonOfMonth = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _recipients = widget.context.parameters['recipients'];
    _absorberOR = widget.context.parameters['absorber'];
    _selected = DateTime.now();
    () async {
      await _total();
      await _onLoad();
    }();

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

  Future<void> _total() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    _totalBankOfMonth = await robotRemote.totalRecipientsRecordByOrderWhere2(
        _absorberOR.absorber.id,
        _recipients.id,
        0,
        _selected.year,
        _selected.month - 1);
    _totalPersonOfMonth = await robotRemote.totalRecipientsRecordByOrderWhere2(
        _absorberOR.absorber.id,
        _recipients.id,
        1,
        _selected.year,
        _selected.month - 1);
  }

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    List<RecipientsRecordOR> records =
        await robotRemote.pageRecipientsRecordWhere3(
            _absorberOR.absorber.id,
            _recipients.id,
            _selected.year,
            _selected.month - 1,
            _limit,
            _offset);
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
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Text(
              '没有记录',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
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
                          '${record.encourageCause}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${_parseOrder(record.order)}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(record.ctime))}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '¥${(record.amount / 100).toStringAsFixed(14)}',
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
        title: Text('${_recipients.personName}'),
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            _getFilterPannel(),
            Expanded(
              child: EasyRefresh(
                onRefresh: _onRefresh,
                onLoad: _onLoad,
                child: ListView(
                  shrinkWrap: true,
                  children: items,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getFilterPannel() {
    return Container(
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
                    await _total();
                    await _onRefresh();
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
                            '银行投资',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '¥${((_totalBankOfMonth ?? 0.00) / 100.00).toStringAsFixed(14)}',
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
                            '公众投资',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '¥${((_totalPersonOfMonth ?? 0) / 100.00).toStringAsFixed(2)}',
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
                        '洇金',
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
    );
  }

  _parseOrder(int order) {
    if(order==null) {
      return '-';
    }
    if(order==0) {
      return '纹银银行投资';
    }
    return '公众投资';
  }

}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
