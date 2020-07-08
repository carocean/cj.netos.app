import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;

class SimpleAbsorberRecipientsRecordsPage extends StatefulWidget {
  PageContext context;

  SimpleAbsorberRecipientsRecordsPage({this.context});

  @override
  _RecipientsRecordsState createState() => _RecipientsRecordsState();
}

class _RecipientsRecordsState
    extends State<SimpleAbsorberRecipientsRecordsPage> {
  RecipientsSummaryOR _recipients;
  AbsorberOR _absorberOR;
  List<RecipientsRecordOR> _records = [];
  EasyRefreshController _controller;
  int _limit = 50, _offset = 0;

  @override
  void initState() {
    _controller=EasyRefreshController();
    _recipients = widget.context.parameters['recipients'];
    _absorberOR = widget.context.parameters['absorber'];
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
    List<RecipientsRecordOR> records =
        await robotRemote.pageRecipientsRecordByPerson(
            _absorberOR.id, _recipients.person, _limit, _offset);
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
        child: EasyRefresh(
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView(
            shrinkWrap: true,
            children: items,
          ),
        ),
      ),
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
