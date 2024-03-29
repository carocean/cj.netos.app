import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/landagent/remote/wybank.dart';

class AbsorberDesktopApplyPage extends StatefulWidget {
  PageContext context;

  AbsorberDesktopApplyPage({this.context});

  @override
  _AbsorberDesktopApplyPageState createState() => _AbsorberDesktopApplyPageState();
}

class _AbsorberDesktopApplyPageState extends State<AbsorberDesktopApplyPage> {
  double _radius = 0.0;
  double _maxRadius = 0.0;
  double _minRadius = 0.0;
  double _recipients = 0.0;
  double _maxRecipients = 1000;
  double _minRecipients = 0.0;
  String _address;
  String _label = '';
  bool _isLoaded = false;
  String _districtCode;
  String _bankid;
  String _title;
  int _absorbUsage;
  dynamic _absorbabler;
  LatLng _location;

  @override
  void initState() {
    _title = widget.context.parameters['title'];
    _absorbUsage = widget.context.parameters['usage'];
    _absorbabler = widget.context.parameters['absorbabler'];
    _maxRadius = widget.context.parameters['radius'];
    if (_maxRadius >= 200) {
      _minRadius = 200;
    } else {
      _minRadius = _maxRadius;
    }
    _radius = _minRadius;
    _load().then((value) {
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<void> _load() async {
    var location = await geoLocation.location;
    _location=location.latLng;
    _address = location.address;
    _districtCode = location.adCode;
    _label = '洇金发放中心';
    _bankid = 'c18baf5393884b5046759df2786d83f2';//此为固定的虚拟银行，裂变游戏提现发放洇金全由它接收
  }

  Future<void> _createAbsorber() async {
    _isLoaded = false;
    if (mounted) {
      setState(() {});
    }
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    await robotRemote.createGeoAbsorber(
        _bankid, _title, _absorbUsage, _absorbabler, _location, _radius);

    widget.context.backward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('开通招财猫'),
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        actions: [
          FlatButton(
            onPressed: !_isLoaded
                ? null
                : () {
                    _createAbsorber().then((value) {
                      _isLoaded = true;
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  },
            child: Text(
              '开通',
              style: TextStyle(
                color: _isLoaded ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _renderHeaderCard(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: _renderBodyCard(),
          ),
        ],
      ),
    );
  }

  Widget _renderHeaderCard() {
    var title = widget.context.parameters['title'];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 10,
        bottom: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'lib/portals/gbera/images/cat-grey.gif',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${title ?? ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  '地理洇取器',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderBodyCard() {
    String absorbabler = widget.context.parameters['absorbabler'];
    var location = widget.context.parameters['location'];
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 0,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: 15,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,size: 20,color: Colors.grey,),
                            SizedBox(width: 10,),
                            Text(
                              '位置',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${_address ?? ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      CardItem(
                        title: '半径',
                        paddingRight: 15,
                        tail: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: 20,
                              ),
                              child: Text(
                                '${_radius.toStringAsFixed(0)}米',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SliderTheme(
                              data: theme.sliderTheme.copyWith(
                                activeTrackColor: Colors.greenAccent,
                                inactiveTrackColor: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                                activeTickMarkColor: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                inactiveTickMarkColor:
                                    theme.colorScheme.surface.withOpacity(0.7),
                                overlayColor: theme.colorScheme.onSurface
                                    .withOpacity(0.12),
                                thumbColor: Colors.redAccent,
                                valueIndicatorColor: Colors.deepPurpleAccent,
                                thumbShape: _CustomThumbShape(),
                                valueIndicatorShape:
                                    _CustomValueIndicatorShape(),
                                valueIndicatorTextStyle:
                                    theme.accentTextTheme.body2.copyWith(
                                        color: theme.colorScheme.onSurface),
                              ),
                              child: Slider(
                                label: '${_radius.toStringAsFixed(0)}米',
                                value: _radius,
                                min: _minRadius,
                                max: _maxRadius,
                                divisions: (_maxRadius - _minRadius).floor(),
                                onChanged: (v) {
                                  setState(() {
                                    _radius = v * 1.0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      CardItem(
                        title: '人数限制',
                        paddingRight: 15,
                        tail: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: 20,
                              ),
                              child: Text(
                                '${_recipients == 0 ? '无限制' : '${_recipients.toStringAsFixed(0)}人'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SliderTheme(
                              data: theme.sliderTheme.copyWith(
                                activeTrackColor: Colors.greenAccent,
                                inactiveTrackColor: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                                activeTickMarkColor: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                inactiveTickMarkColor:
                                    theme.colorScheme.surface.withOpacity(0.7),
                                overlayColor: theme.colorScheme.onSurface
                                    .withOpacity(0.12),
                                thumbColor: Colors.redAccent,
                                valueIndicatorColor: Colors.deepPurpleAccent,
                                thumbShape: _CustomThumbShape(),
                                valueIndicatorShape:
                                    _CustomValueIndicatorShape(),
                                valueIndicatorTextStyle:
                                    theme.accentTextTheme.body2.copyWith(
                                        color: theme.colorScheme.onSurface),
                              ),
                              child: Slider(
                                label: '${_recipients.toStringAsFixed(0)}人',
                                value: _recipients,
                                min: _minRecipients,
                                max: _maxRecipients,
                                divisions:
                                    ((_maxRecipients - _minRecipients) / 10)
                                        .floor(),
                                onChanged: (v) {
                                  setState(() {
                                    _recipients = v * 1.0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '说明： \n',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '- 开通招财猫平台会向你的招财猫内的用户发钱。用户进入你的招财猫的方式有很多，如：点赞、评论、连接你的网流管道、在猫的感知半径内、发码片、消费码片等等。\r\n',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text:
                        '- 招财猫帮你拓广人脉，也方便你经营你的人脉。\r\n',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text:
                            '- 猫随时会饿，绿猫就表示饿了，变绿后平台便不再发钱给它，除非把猫喂成红猫，一般喂个1元钱就会变红，如果还不行可以多喂几次。',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  static const double _thumbSize = 4.0;
  static const double _disabledThumbSize = 3.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return isEnabled
        ? const Size.fromRadius(_thumbSize)
        : const Size.fromRadius(_disabledThumbSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledThumbSize,
    end: _thumbSize,
  );

  @override
  void paint(PaintingContext context, Offset thumbCenter,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double value,
      double textScaleFactor,
      Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final double size = _thumbSize * sizeTween.evaluate(enableAnimation);
    final Path thumbPath = _downTriangle(size, thumbCenter);
    canvas.drawPath(
        thumbPath, Paint()..color = colorTween.evaluate(enableAnimation));
  }
}

class _CustomValueIndicatorShape extends SliderComponentShape {
  static const double _indicatorSize = 4.0;
  static const double _disabledIndicatorSize = 3.0;
  static const double _slideUpHeight = 40.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? _indicatorSize : _disabledIndicatorSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledIndicatorSize,
    end: _indicatorSize,
  );

  @override
  void paint(PaintingContext context, Offset thumbCenter,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double value,
      double textScaleFactor,
      Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    final Tween<double> slideUpTween = Tween<double>(
      begin: 0.0,
      end: _slideUpHeight,
    );
    final double size = _indicatorSize * sizeTween.evaluate(enableAnimation);
    final Offset slideUpOffset =
        Offset(0.0, -slideUpTween.evaluate(activationAnimation));
    final Path thumbPath = _upTriangle(size, thumbCenter + slideUpOffset);
    final Color paintColor = enableColor
        .evaluate(enableAnimation)
        .withAlpha((255.0 * activationAnimation.value).round());
    canvas.drawPath(
      thumbPath,
      Paint()..color = paintColor,
    );
    canvas.drawLine(
        thumbCenter,
        thumbCenter + slideUpOffset,
        Paint()
          ..color = paintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);
    labelPainter.paint(
        canvas,
        thumbCenter +
            slideUpOffset +
            Offset(-labelPainter.width / 2.0, -labelPainter.height - 4.0));
  }
}

Path _upTriangle(double size, Offset thumbCenter) =>
    _downTriangle(size, thumbCenter, invert: true);

Path _downTriangle(double size, Offset thumbCenter, {bool invert = false}) {
  final Path thumbPath = Path();
  final double height = math.sqrt(3.0) / 2.0;
  final double centerHeight = size * height / 3.0;
  final double halfSize = size / 2.0;
  final double sign = invert ? -1.0 : 1.0;
  thumbPath.moveTo(
      thumbCenter.dx - halfSize, thumbCenter.dy + sign * centerHeight);
  thumbPath.lineTo(thumbCenter.dx, thumbCenter.dy - 2.0 * sign * centerHeight);
  thumbPath.lineTo(
      thumbCenter.dx + halfSize, thumbCenter.dy + sign * centerHeight);
  thumbPath.close();
  return thumbPath;
}
