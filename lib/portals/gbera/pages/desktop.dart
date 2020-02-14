import 'dart:io';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';
import 'package:intl/intl.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/portlet_market.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class Desktop extends StatefulWidget {
  PageContext context;

  Desktop({
    this.context,
  });

  @override
  _DesktopState createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> with AutomaticKeepAliveClientMixin {
  bool use_wallpapper = false;

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: desktopManager.getInstalledPortlets(widget.context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw FlutterError(snapshot.error.toString());
        }
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }

        use_wallpapper = widget.context.parameters['use_wallpapper'];

        var onProfileTap = () {
          widget.context.forward('/profile');
        };
        var url = widget.context.page.parameters['From-Page-Url'];
        var scaffold =
            widget.context.findPage('$url');

        var _slivers = <Widget>[
          SliverPersistentHeader(
            floating: false,
            pinned: true,
            delegate: GberaPersistentHeaderDelegate(
              title: Text(
                scaffold?.title ?? '',
              ),
              titleSpacing: 10,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  // Use the FontAwesomeIcons class for the IconData
                  icon: new Icon(Icons.crop_free),
                  onPressed: () async {
                    String cameraScanResult = await scanner.scan();
                    showDialog(
                      context: context,
                      barrierDismissible: true, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('扫好友、扫地物、支付、收款等'),
                          content: Text(cameraScanResult),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('YES'),
                              onPressed: () {
                                print('yes...');
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text('NO'),
                              onPressed: () {
                                print('no...');
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                          backgroundColor: Colors.yellowAccent,
                          elevation: 20,
                          semanticLabel: '哈哈哈哈',
                          // 设置成 圆角
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  // Use the FontAwesomeIcons class for the IconData
                  icon: new Icon(
                    widget.context.findPage('/desktop/lets/settings')?.icon,
                  ),
                  onPressed: () {
                    widget.context.forward(
                      '/desktop/lets/settings',
                      arguments: {
                        'back_button': true,
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 30,
                    bottom: 30,
                  ),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onProfileTap,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: CircleAvatar(
                            backgroundImage: FileImage(
                              File('${widget.context.principal.avatarOnLocal}'),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onProfileTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${widget.context.principal?.nickName}',
                              softWrap: true,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!StringUtil.isEmpty(
                                widget.context.principal.signature))
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 3,
                                ),
                                child: Text(
                                  '${widget.context.principal.signature}',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                /*
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 20),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.context.forward(
                              '/wallet/ty',
                              arguments: {
                                'back_button': true,
                              },
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '5400.03',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  '帑银资产',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: Colors.red,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 10),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.context.forward(
                              '/wallet/wy',
                              arguments: {
                                'back_button': true,
                              },
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '201.88',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  '纹银资产',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                */
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 2),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      '桌面',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

        var widgets = <Widget>[];

        var _portlets = snapshot.data;
        if (_portlets != null) {
          for (Portlet portlet in _portlets) {
            var desklet = portlet.build(
              context: widget.context,
            );
            widgets.add(desklet);
          }
        }
        var lets_region = SliverToBoxAdapter(
          child: Container(
//            margin: EdgeInsets.only(left: 10,right: 10,),
            child: Column(
              children: widgets,
            ),
          ),
        );
        _slivers.add(lets_region);

        var myarea = CustomScrollView(
          slivers: _slivers,
        );
        return myarea;
      },
    );
  }
}

class CustomAxisTickFormatters extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  CustomAxisTickFormatters(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory CustomAxisTickFormatters.withSampleData() {
    return new CustomAxisTickFormatters(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Formatter for numeric ticks using [NumberFormat] to format into currency
    ///
    /// This is what is used in the [NumericAxisSpec] below.
    final simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            new NumberFormat.compactSimpleCurrency());

    /// Formatter for numeric ticks that uses the callback provided.
    ///
    /// Use this formatter if you need to format values that [NumberFormat]
    /// cannot provide.
    ///
    /// To see this formatter, change [NumericAxisSpec] to use this formatter.
    // final customTickFormatter =
    //   charts.BasicNumericTickFormatterSpec((num value) => 'MyValue: $value');

    return new charts.TimeSeriesChart(seriesList,
        animate: animate,
        // Sets up a currency formatter for the measure axis.
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickFormatterSpec: simpleCurrencyFormatter),

        /// Customizes the date tick formatter. It will print the day of month
        /// as the default format, but include the month and year if it
        /// transitions to a new month.
        ///
        /// minute, hour, day, month, and year are all provided by default and
        /// you can override them following this pattern.
        domainAxis: new charts.DateTimeAxisSpec(
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                day: new charts.TimeFormatterSpec(
                    format: 'd', transitionFormat: 'MM/dd/yyyy'))));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<MyRow, DateTime>> _createSampleData() {
    final data = [
      new MyRow(new DateTime(2017, 9, 25), 6),
      new MyRow(new DateTime(2017, 9, 26), 8),
      new MyRow(new DateTime(2017, 9, 27), 6),
      new MyRow(new DateTime(2017, 9, 28), 9),
      new MyRow(new DateTime(2017, 9, 29), 11),
      new MyRow(new DateTime(2017, 9, 30), 15),
      new MyRow(new DateTime(2017, 10, 01), 25),
      new MyRow(new DateTime(2017, 10, 02), 33),
      new MyRow(new DateTime(2017, 10, 03), 27),
      new MyRow(new DateTime(2017, 10, 04), 31),
      new MyRow(new DateTime(2017, 10, 05), 23),
    ];

    return [
      new charts.Series<MyRow, DateTime>(
        id: 'Cost',
        domainFn: (MyRow row, _) => row.timeStamp,
        measureFn: (MyRow row, _) => row.cost,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int cost;

  MyRow(this.timeStamp, this.cost);
}
