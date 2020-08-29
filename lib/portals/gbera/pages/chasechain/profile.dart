import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';

class RecommenderProfilePage extends StatefulWidget {
  PageContext context;

  RecommenderProfilePage({this.context});

  @override
  _RecommenderProfilePageState createState() => _RecommenderProfilePageState();
}

class _RecommenderProfilePageState extends State<RecommenderProfilePage> {
  RecommenderConfig _recommenderConfig;
  bool _isChanged = false;
  bool _isSaving = false;
  var _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _loadConfig().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadConfig() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _recommenderConfig = await recommender.getPersonRecommenderConfig();
    if (_recommenderConfig == null) {
      _recommenderConfig = RecommenderConfig(
        maxRecommendItemCount: 20,
        townRecommendWeight: 1,
        districtRecommendWeight: 1,
        cityRecommendWeight: 1,
        provinceRecommendWeight: 1,
        normalRecommendWeight: 1,
        countryRecommendWeight: 1,
        weightCapacity: 0,
      );
    }
  }

  Future<void> _doConfig() async {
    _isChanged = false;
    _isSaving = true;
    if (mounted) setState(() {});
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    await recommender.configPersonRecommender(
      _recommenderConfig.maxRecommendItemCount,
      _recommenderConfig.countryRecommendWeight,
      _recommenderConfig.normalRecommendWeight,
      _recommenderConfig.provinceRecommendWeight,
      _recommenderConfig.cityRecommendWeight,
      _recommenderConfig.districtRecommendWeight,
      _recommenderConfig.townRecommendWeight,
    );
    _isSaving = false;
    if (mounted) {
      setState(() {});
    }
    _globalKey.currentState.showSnackBar(
      SnackBar(
        content: Text('配置成功'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('偏好设置'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            onPressed: !_isChanged
                ? null
                : () {
                    _doConfig();
                  },
            icon: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _recommenderConfig == null
            ? SizedBox(
                height: 0,
                width: 0,
              )
            : Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: _renderLayout(),
              ),
      ),
    );
  }

  _renderLayout() {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            !_isSaving
                ? SizedBox(
                    height: 0,
                    width: 0,
                  )
                : Center(
                    child: Text(
                      '正在保存...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '每次推荐的最大内容条目数：${_recommenderConfig.maxRecommendItemCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label: '${_recommenderConfig.maxRecommendItemCount}',
                value: _recommenderConfig.maxRecommendItemCount * 1.0,
                min: 10.0,
                max: 30.0,
                divisions: 20,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.maxRecommendItemCount = v.floor();
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '国家级流量池的推荐权重：${_recommenderConfig.countryRecommendWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label:
                    '${_recommenderConfig.countryRecommendWeight.toStringAsFixed(2)}',
                value: _recommenderConfig.countryRecommendWeight * 1.0,
                min: 1.0,
                max: 100.00,
                divisions: 500,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.countryRecommendWeight = v;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '省级流量池的推荐权重：${_recommenderConfig.provinceRecommendWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label:
                    '${_recommenderConfig.provinceRecommendWeight.toStringAsFixed(2)}',
                value: _recommenderConfig.provinceRecommendWeight * 1.0,
                min: 1.0,
                max: 100.00,
                divisions: 500,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.provinceRecommendWeight = v;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '市级流量池的推荐权重：${_recommenderConfig.cityRecommendWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label:
                    '${_recommenderConfig.cityRecommendWeight.toStringAsFixed(2)}',
                value: _recommenderConfig.cityRecommendWeight * 1.0,
                min: 1.0,
                max: 100.00,
                divisions: 500,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.cityRecommendWeight = v;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '区县级流量池的推荐权重：${_recommenderConfig.districtRecommendWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label:
                    '${_recommenderConfig.districtRecommendWeight.toStringAsFixed(2)}',
                value: _recommenderConfig.districtRecommendWeight * 1.0,
                min: 1.0,
                max: 100.00,
                divisions: 500,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.districtRecommendWeight = v;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '乡镇或街道级流量池的推荐权重：${_recommenderConfig.townRecommendWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label:
                    '${_recommenderConfig.townRecommendWeight.toStringAsFixed(2)}',
                value: _recommenderConfig.townRecommendWeight * 1.0,
                min: 1.0,
                max: 100.00,
                divisions: 500,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.townRecommendWeight = v;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Text(
                '常规流量池的推荐权重：${_recommenderConfig.normalRecommendWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor:
                    theme.colorScheme.onSurface.withOpacity(0.5),
                activeTickMarkColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                inactiveTickMarkColor:
                    theme.colorScheme.surface.withOpacity(0.7),
                overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                thumbColor: Colors.redAccent,
                valueIndicatorColor: Colors.deepPurpleAccent,
                thumbShape: _CustomThumbShape(),
                valueIndicatorShape: _CustomValueIndicatorShape(),
                valueIndicatorTextStyle: theme.accentTextTheme.body2
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              child: Slider(
                label:
                    '${_recommenderConfig.normalRecommendWeight.toStringAsFixed(2)}',
                value: _recommenderConfig.normalRecommendWeight * 1.0,
                min: 1.0,
                max: 100.00,
                divisions: 500,
                onChanged: (v) {
                  _isChanged = true;
                  setState(() {
                    _recommenderConfig.normalRecommendWeight = v;
                  });
                },
              ),
            ),
          ],
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
  void paint(
    PaintingContext context,
    Offset thumbCenter, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
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
  void paint(
    PaintingContext context,
    Offset thumbCenter, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
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
