import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_bill.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FissionMFStaffPage extends StatefulWidget {
  PageContext context;

  FissionMFStaffPage({this.context});

  @override
  _FissionMFStaffPageState createState() => _FissionMFStaffPageState();
}

class _FissionMFStaffPageState extends State<FissionMFStaffPage> {
  EasyRefreshController _easyRefreshController;
  int _limit = 20, _offset = 0;
  List<StaffOR> _records = [];
  final List<ChartSampleData> _chartData = <ChartSampleData>[];
  int _maxNum = 0, _minNum = 0;
  int _payeesCount = 0, _payeesAmount = 0;
  DateTime _maxTime, _minTime;
  CashierOR _cashierOR;
  String _filter = 'current'; //current当下的伙伴；histories历史伙伴
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
    IFissionMFCashierRecordRemote cashierRecordRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/record');
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    if(_filter=='histories') {
      _payeesCount = await cashierRecordRemote.totalAllStaff();
      _payeesAmount = await cashierRecordRemote.totalAllStaffAmount();
    }else{
      _payeesCount = await cashierRemote.totalStaff();
      _payeesAmount = await cashierRecordRemote.totalStaffAmount();
    }
    await _onload();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _records.clear();
    _chartData.clear();
    await _onload();
  }

  Future<void> _onload() async {
    IFissionMFCashierRecordRemote cashierRecordRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/record');
    dynamic records;
    if(_filter=='histories') {
      records = await cashierRecordRemote.pageAllStaffDetails(_limit, _offset);
    }else{
      records = await cashierRecordRemote.pageStaffDetails(_limit, _offset);
    }
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
      _chartData.add(
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
              title: Text('我是老板'),
              pinned: true,
              elevation: 0,
              titleSpacing: 0,
              actions: [
                FlatButton(
                  onPressed: () {
                    widget.context.forward('/wallet/fission/mf/become/boss');
                  },
                  textColor: Colors.green,
                  child: Text(
                    '发展伙伴',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
                      '伙伴',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '$_payeesCount人',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '收佣:${(_payeesAmount / 100.00).toStringAsFixed(2)}元',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        var filter = await showCupertinoModalPopup(
                            context: context,
                            builder: (ctx) {
                              return CupertinoActionSheet(
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                    child: Text(
                                      '现有伙伴',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(
                                        ctx,
                                        'current',
                                      );
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(
                                      '所有伙伴',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(
                                        ctx,
                                        'histories',
                                      );
                                    },
                                  ),
                                ],
                                cancelButton: FlatButton(
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(
                                      ctx,
                                      'cancel',
                                    );
                                  },
                                ),
                              );
                            });
                        if (StringUtil.isEmpty(filter)) {
                          return;
                        }
                        _filter = filter;
                        _onRefresh();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_renderFilter()}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.filter_alt,
                            size: 25,
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
                  onTap: () {
                    // widget.context..forward('/person/view', arguments: {'official': '${e.person.id}@gbera.netos'});
                    widget.context.forward('/wallet/fission/mf/person',
                        arguments: {
                          'person': e.person,
                          'amount': e.amount,
                          'direct': 'commission'
                        });
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 10),
                        constraints: BoxConstraints.tightForFinite(
                          width: double.maxFinite,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder:
                                  'lib/portals/gbera/images/default_watting.gif',
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
                                        '${TimelineUtil.format(
                                          parseStrTime(e.ctime, len: 17)
                                              .millisecondsSinceEpoch,
                                          locale: 'zh',
                                          dayFormat: DayFormat.Full,
                                        )}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '(加我为伙伴)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${e.count ?? 0}次',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '(为我赚取佣金)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints.tightForFinite(
                                      width: double.maxFinite,
                                    ),
                                    child: Row(
                                      children: _renderPersonInfo(e),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '¥-${(e.amount / 100.00).toStringAsFixed(2)}',
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

  List<Widget> _renderPersonInfo(StaffOR staff) {
    FissionMFPerson person = staff.person;
    var items = <TextSpan>[];
    if (!StringUtil.isEmpty(person.province)) {
      items.add(
        TextSpan(
          text: '${person.province}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    if (!StringUtil.isEmpty(person.city)) {
      items.add(
        TextSpan(
          text: '·${person.city}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    if (!StringUtil.isEmpty(person.district)) {
      items.add(
        TextSpan(
          text: '·${person.district}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    return [
      Expanded(
        child: Text.rich(
          TextSpan(
            text: '',
            children: items,
          ),
        ),
      ),
      SizedBox(
        width: 5,
      ),
    ];
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
      title: ChartTitle(text: '伙伴入场分布'),

      /// X axis as date time axis placed here.
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        majorGridLines: MajorGridLines(width: 0),
        interval: 1,
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        dateFormat: intl.DateFormat('M/d'),
        maximum: _maxTime == null ? null : _maxTime.add(Duration(days: 1)),
        minimum: _minTime == null ? null : _minTime.subtract(Duration(days: 1)),
        // title: AxisTitle(text: '时间'),
      ),
      primaryYAxis: NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
        minimum: (_minNum / 100.00),
        maximum: ((_maxNum + _cashierOR.cacAverage) / 100.00),
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
        //               placeholder: 'lib/portals/gbera/images/default_watting.gif',
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
          dataSource: _chartData,
          xValueMapper: (ChartSampleData data, _) => data.x,
          yValueMapper: (ChartSampleData data, _) => data.yValue,
          color: const Color.fromRGBO(232, 84, 84, 1))
    ];
  }

  _renderFilter() {
    switch (_filter) {
      case 'current':
        return '现有伙伴';
      case 'histories':
        return '所有伙伴';
      default:
        return '';
    }
  }
}

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData({
    this.x,
    this.y,
    this.xValue,
    this.yValue,
    this.secondSeriesYValue,
    this.thirdSeriesYValue,
    this.pointColor,
    this.size,
    this.text,
    this.open,
    this.close,
    this.low,
    this.high,
    this.volume,
    this.person,
  });

  final StaffOR person;

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color pointColor;

  /// Holds size of the datapoint
  final num size;

  /// Holds datalabel/text value mapper of the datapoint
  final String text;

  /// Holds open value of the datapoint
  final num open;

  /// Holds close value of the datapoint
  final num close;

  /// Holds low value of the datapoint
  final num low;

  /// Holds high value of the datapoint
  final num high;

  /// Holds open value of the datapoint
  final num volume;
}
