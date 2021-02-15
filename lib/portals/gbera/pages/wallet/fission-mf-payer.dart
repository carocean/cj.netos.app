import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;
import 'fission-mf-payee.dart';

class FissionMFPayersPage extends StatefulWidget {
  PageContext context;

  FissionMFPayersPage({this.context});

  @override
  _FissionMFPayersPageState createState() => _FissionMFPayersPageState();
}

class _FissionMFPayersPageState extends State<FissionMFPayersPage> {
  EasyRefreshController _easyRefreshController;
  int _limit = 20, _offset = 0;
  List<PayPersonOR> _records = [];
  final List<ChartSampleData> chartData = <ChartSampleData>[];
  int _maxNum = 0, _minNum = 0;
  DateTime _maxTime, _minTime;
  CashierOR _cashierOR;

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController();
    _cashierOR = widget.context.parameters['cashier'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    await _onload();
  }
  Future<void> _onRefresh()async{
    _offset=0;
    _records.clear();
    await _onload();
  }
  Future<void> _onload() async {
    IFissionMFCashierRecordRemote cashierRecordRemote =
    widget.context.site.getService('/wallet/fission/mf/cashier/record');
    var records = await cashierRecordRemote.pagePayerDetails(_limit, _offset);
    if (records.isEmpty) {
      _easyRefreshController.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += records.length;
    for (var record in records) {
      if (record.amount > _maxNum) {
        _maxNum = record.amount;
      }
      if (record.amount < _minNum) {
        _minNum = record.amount;
      }
      var time = parseStrTime(record.ctime, len: 17);
      if (_maxTime == null) {
        _maxTime = time;
      }
      if (_minTime == null) {
        _minTime = time;
      }
      if (time.millisecondsSinceEpoch > _maxTime.millisecondsSinceEpoch) {
        _maxTime = time;
      }
      if (time.millisecondsSinceEpoch < _minTime.millisecondsSinceEpoch) {
        _minTime = time;
      }
      chartData.add(
        ChartSampleData(
            x: time, yValue: (record.amount / 100.00), person: record),
      );
      _records.add(record);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, s) {
          return [
            SliverAppBar(
              title: Text('加群'),
              pinned: true,
              elevation: 0,
              titleSpacing: 0,
            ),
            _renderChart(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '已加群',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.context.forward('/wallet/fission/mf/tag/condition',arguments: {'direct':'payee'});
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '设置拉新条件',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _renderTags(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 3,
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: EasyRefresh(
            controller: _easyRefreshController,
            onLoad: _onload,
            onRefresh: _onRefresh,
            child: ListView(
              children: _records.map((e) {
                var person = e.person;
                return InkWell(
                  onTap: (){
                    widget.context.forward('/wallet/fission/mf/person',arguments: {'record':e,'direct':'payee'});

                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: '',
                              image: '${person.avatarUrl}',
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${person.nickName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${person.gender == 1 ? '男' : person.gender == 2 ? '女' : ''}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '+ ¥${(e.amount / 100.00).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${TimelineUtil.format(parseStrTime(e.ctime, len: 17).millisecondsSinceEpoch, locale: 'zh')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                        child: Divider(
                          height: 1,
                          indent: 50,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderChart() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        height: 250,
        color: Colors.white,
        child: _getLabelDateTimeAxisChart(),
      ),
    );
  }

  Widget _renderTags() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Wrap(
          children: [],
        ),
      ),
    );
  }

  /// Returns the scatter chart with datatime axis label format.
  SfCartesianChart _getLabelDateTimeAxisChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: '群主分布'),

      /// X axis as date time axis placed here.
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.hours,
        majorGridLines: MajorGridLines(width: 0),
        interval: 1,
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        dateFormat: intl.DateFormat('M/d HH:mm'),
        maximum:_maxTime==null?null: _maxTime.add(Duration(hours: 1)),
        minimum: _minTime==null?null:_minTime.subtract(Duration(hours: 1)),
        // title: AxisTitle(text: '时间'),
      ),
      primaryYAxis: NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
        minimum: (_minNum / 100.00),
        maximum: ((_maxNum+ _cashierOR.cacAverage) / 100.00),
        interval: (_cashierOR?.cacAverage ?? 0.00) / 2.0 / 100.00,
        numberFormat: intl.NumberFormat.currency(decimalDigits: 2, name: '¥'),
        // title: AxisTitle(text: '花费'),
      ),
      series: _getLabelDateTimeAxisSeries(),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        // builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
        //     int seriesIndex) {
        //   var csd = data as ChartSampleData;
        //   var payPerson = csd.person;
        //   var person = payPerson.person;
        //   return Container(
        //     height: 80,
        //     width: 160,
        //     padding: EdgeInsets.all(10),
        //     decoration: const BoxDecoration(color: Colors.black),
        //     child: Column(
        //       children: [
        //         Row(
        //           children: <Widget>[
        //             FadeInImage.assetNetwork(
        //               placeholder: '',
        //               image: '${person.avatarUrl}',
        //               width: 30,
        //               height: 30,
        //             ),
        //             SizedBox(
        //               width: 10,
        //             ),
        //             Expanded(
        //               child: Text(
        //                 '${person.nickName}',
        //                 style: TextStyle(color: Colors.white, fontSize: 12),
        //               ),
        //             ),
        //           ],
        //         ),
        //         SizedBox(
        //           height: 10,
        //           child: Divider(
        //             height: 1,
        //             color: Colors.white,
        //           ),
        //         ),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: <Widget>[
        //             Text(
        //               '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(payPerson.ctime, len: 17))}',
        //               style: TextStyle(color: Colors.white, fontSize: 10),
        //             ),
        //             SizedBox(
        //               width: 10,
        //             ),
        //             Text(
        //               '¥${(payPerson.amount / 100.00).toStringAsFixed(2)}',
        //               style: TextStyle(color: Colors.white, fontSize: 10),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   );
        // },
        format: 'point.x : point.y',
        header: '',
        canShowMarker: false,
      ),
    );
  }

  /// Returns the list of chart series
  /// which need to render on the scatter chart.
  List<ScatterSeries<ChartSampleData, DateTime>> _getLabelDateTimeAxisSeries() {
    return <ScatterSeries<ChartSampleData, DateTime>>[
      ScatterSeries<ChartSampleData, DateTime>(
          opacity: 0.8,
          markerSettings: MarkerSettings(height: 15, width: 15),
          dataSource: chartData,
          xValueMapper: (ChartSampleData data, _) => data.x,
          yValueMapper: (ChartSampleData data, _) => data.yValue,
          color: const Color.fromRGBO(232, 84, 84, 1))
    ];
  }
}
