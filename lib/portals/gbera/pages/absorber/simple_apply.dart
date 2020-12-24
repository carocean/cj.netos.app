import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/landagent/remote/wybank.dart';

class AbsorberSimpleApplyPage extends StatefulWidget {
  PageContext context;

  AbsorberSimpleApplyPage({this.context});

  @override
  _AbsorberSimpleApplyPageState createState() => _AbsorberSimpleApplyPageState();
}

class _AbsorberSimpleApplyPageState extends State<AbsorberSimpleApplyPage> {
  double _recipients = 0.0;
  double _maxRecipients = 1000;
  double _minRecipients = 0.0;
  String _label = '';
  bool _isLoaded = false;
  String _licenceId;
  String _bankid;
  String _title;
  int _absorbUsage;
  dynamic _absorbabler;
  String _districtCode;
  @override
  void initState() {
    _title = widget.context.parameters['title'];
    _absorbUsage = widget.context.parameters['usage'];
    _absorbabler = widget.context.parameters['absorbabler'];
    _load().then((value) {
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<void> _load() async {
    var location = await AmapLocation.instance.fetchLocation(
      needAddress: true,
    );
    _districtCode = location.adCode;
    IWyBankRemote wyBankRemote =
        widget.context.site.getService('/remote/wybank');
    var bank =
        await wyBankRemote.getAndAutoCreateWenyBankByDistrict(_districtCode);
    _label = bank.title;
    _licenceId = bank.licence;
    _bankid = bank.id;
  }

  Future<void> _createAbsorber() async {
    _isLoaded = false;
    if (mounted) {
      setState(() {});
    }
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    await robotRemote.createSimpleAbsorber(
        _bankid, _title, _absorbUsage, _absorbabler,_maxRecipients.floor());

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
                  '简单洇取器',
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 0,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CardItem(
                        title: '当地服务商',
                        paddingRight: 15,
                        tipsText:
                            '${!_isLoaded ? '正在搜寻当地的服务商...' : (StringUtil.isEmpty(_districtCode) ? '没找到当地服务商，因此无法提供发布服务' : _label)}',
                        onItemTap: () {
                          widget.context.forward('/viewer/licenceById',
                              arguments: {'licenceId': _licenceId});
                        },
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
                    text: '说明： ',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '开通招财猫可以让给你点赞过或评论过的用户享受当地服务商提供的免费洇金服务，帮你拓广人脉。洇金可以持续发给你的用户。\r\n',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text:
                            '    要学会养猫，它饿的时候要喂食，当然，不喂它有时也会兴奋，但有时间喂喂食可以提高本猫招财的速度和概率。',
                        style: TextStyle(
                          color: Colors.grey,
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
