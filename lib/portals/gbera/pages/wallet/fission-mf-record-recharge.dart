import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
class FissionMFRecordRechargePage extends StatefulWidget {
  PageContext context;

  FissionMFRecordRechargePage({this.context});

  @override
  _FissionMFRecordRechargePageState createState() =>
      _FissionMFRecordRechargePageState();
}

class _FissionMFRecordRechargePageState
    extends State<FissionMFRecordRechargePage> {
  FissionMFRechargeRecordOR _record;
  bool _isLoading = true;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRecordRemote recordRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/record');
    var sn = widget.context.parameters['sn'];
    _record = await recordRemote.getRechargeRecord(sn);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Person> _loadPerson(String salesman) async {
    int pos=salesman.lastIndexOf('@');
    if(pos<0) {
      salesman='$salesman@gbera.netos';
    }
    IPersonService personService =
    widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(salesman);
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (_isLoading) {
      items.addAll(
        [
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              height: 100,
              child: Text(
                '正在加载...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      if (_record == null) {
        items.addAll(
          [
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.center,
                height: 100,
                child: Text(
                  '账单已不存在',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        items.addAll(
          [
            SliverToBoxAdapter(
              child: _AmountCard(),
            ),
            SliverFillRemaining(
              child: _DetailsCard(),
            ),
          ],
        );
      }
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('充值单'),
            pinned: true,
            elevation: 0,
            titleSpacing: 0,
            centerTitle: true,
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _AmountCard() {
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
              '¥${(_record.amount / 100.00).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _DetailsCard() {
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
                    '${_record.sn}',
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
                    '充值者:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_record.nickName}',
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
                    '充入余额:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥${(_record.remnantAmount/100.00).toStringAsFixed(2)}',
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
                    '服务费:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '¥${(_record.shuntAmount/100.00).toStringAsFixed(2)}',
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
                    '账比:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${(_record.shuntRatio*100.00).toStringAsFixed(2)}%',
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
                    '经手人:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<Person>(
                    future: _loadPerson(_record.salesman),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState !=
                          ConnectionState.done) {
                        return Text(
                          '...',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            decoration:
                            TextDecoration.underline,
                          ),
                        );
                      }
                      var person = snapshot.data;
                      if (person == null) {
                        return Text(
                          '不存在：${_record.salesman}',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            decoration:
                            TextDecoration.underline,
                          ),
                        );
                      }
                      return InkWell(
                        onTap: (){
                          widget.context.forward('/person/view',
                              arguments: {'person': person});
                        },
                        child: Text(
                          '${person.nickName}',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            decoration:
                            TextDecoration.underline,
                          ),
                        ),
                      );
                    },
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
                      '${_record.state == 0 ? '申购中' : _record.state == 1 ? '已完成' : ''}  ${_record.status} ${_record.message}'),
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
                    '交易时间:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(_record.ctime))}'),
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
        ],
      ),
    );
  }
}
