import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FissionMFPayeesPage extends StatefulWidget {
  PageContext context;

  FissionMFPayeesPage({this.context});

  @override
  _FissionMFPayeesPageState createState() => _FissionMFPayeesPageState();
}

class _FissionMFPayeesPageState extends State<FissionMFPayeesPage> {
  EasyRefreshController _easyRefreshController;
  int _limit = 20, _offset = 0;
  List<PayPersonOR> _records = [];
  final List<ChartSampleData> chartData = <ChartSampleData>[];
  int _maxNum = 0, _minNum = 0;
  CashierOR _cashierOR;

  @override
  void initState() {
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

  Future<void> _onload() async {
    IFissionMFCashierRecordRemote cashierRecordRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/record');
    var records = await cashierRecordRemote.pagePayeeDetails(_limit, _offset);
    if (records.isEmpty) {
      _easyRefreshController.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += _records.length;
    for (var record in records) {
      if (record.amount > _maxNum) {
        _maxNum = record.amount;
      }
      if (record.amount < _minNum) {
        _minNum = record.amount;
      }
      var time = parseStrTime(record.ctime, len: 17);
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
              title: Text('群拉新'),
              pinned: true,
              elevation: 0,
              titleSpacing: 0,
            ),
            _renderChart(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            _renderTags(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: EasyRefresh(
            controller: _easyRefreshController,
            onLoad: _onload,
            child: ListView(
              children: [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderChart() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _DemoHeader(
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          color: Colors.white,
          child: _getLabelDateTimeAxisChart(),
        ),
      ),
    );
  }

  Widget _renderTags() {
    return SliverToBoxAdapter(
      child: Container(),
    );
  }

  /// Returns the scatter chart with datatime axis label format.
  SfCartesianChart _getLabelDateTimeAxisChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: '用户进群分布'),

      /// X axis as date time axis placed here.
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.hours,
        majorGridLines: MajorGridLines(width: 0),
        interval: 1,
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        dateFormat: intl.DateFormat('M/d HH:mm'),
        // title: AxisTitle(text: '时间'),
      ),
      primaryYAxis: NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
        minimum: (_minNum / 100.00),
        maximum: (_maxNum / 100.00),
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

  final PayPersonOR person;

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

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;

  _DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: child,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return 250;
  } // 最大高度

  @override
  double get minExtent => 250.0; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}
