import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'dart:math' as math;

class AbsorberSettingsPage extends StatefulWidget {
  PageContext context;

  AbsorberSettingsPage({this.context});

  @override
  _AbsorberSettingsPageState createState() => _AbsorberSettingsPageState();
}

class _AbsorberSettingsPageState extends State<AbsorberSettingsPage> {
  AbsorberResultOR _absorberResultOR;
  int _radius = 20;
  int _minRadius = 20;
  int _maxRadius = 2000;
  Person _creator;
  String _address;

  @override
  void initState() {
    _absorberResultOR = widget.context.page.parameters['absorber'];
    _radius = _absorberResultOR.absorber.radius;
    () async {
      _creator = await _getPerson(
          widget.context.site, _absorberResultOR.absorber.creator);
      var location = _absorberResultOR.absorber.location;
      var recode = await AmapSearch.searchReGeocode(location);
      _address = await recode.formatAddress;
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  Future<void> _updateAbsorberState() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var absorber = _absorberResultOR.absorber;
    if (absorber.state == 1) {
      await robotRemote.startAbsorber(absorber.id);
      return;
    }
    if (absorber.state == 0) {
      await robotRemote.stopAbsorber(absorber.id, absorber.exitCause);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var absorber = _absorberResultOR.absorber;
    var bucket = _absorberResultOR.bucket;
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('基本信息'),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Column(
                children: [
                  CardItem(
                    title: '状态',
                    tipsText:
                        '${_absorberResultOR.absorber.state == 1 ? '运行中' : '停用'}',
                    tail: widget.context.principal.person != absorber.creator
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : SizedBox(
                            height: 20,
                            child: Switch.adaptive(
                              value: absorber.state == 1,
                              onChanged: (v) async {
                                if (v) {
                                  absorber.state = 1;
                                  absorber.exitCause = null;
                                } else {
                                  absorber.state = 0;
                                  absorber.exitCause = '创建者强制关停';
                                }
                                await _updateAbsorberState();
                                setState(() {});
                              },
                            ),
                          ),
                  ),
                  absorber.state == 1
                      ? SizedBox(
                          width: 0,
                          height: 0,
                        )
                      : CardItem(
                          title: '停用原因',
                          paddingLeft: 30,
                          tipsText: '${absorber.exitCause ?? '-'}',
                          tail: SizedBox(
                            width: 0,
                            height: 0,
                          ),
                        ),
                  Divider(
                    height: 1,
                  ),
                  CardItem(
                    title: '位置',
                    paddingBottom: 0,
                    tail: SizedBox(
                      width: 0,
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.context
                                .forward('/gbera/location', arguments: {
                              'location': _absorberResultOR.absorber.location,
                              'label': '半径${_absorberResultOR.absorber.radius}米'
                            });
                          },
                          child: Text(
                            '${_address ?? ''}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: 18,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.my_location,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '半径:${absorber.radius}米',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          widget.context.principal.person != absorber.creator
                              ? SizedBox(
                                  height: 0,
                                  width: 0,
                                )
                              : SliderTheme(
                                  data: theme.sliderTheme.copyWith(
                                    activeTrackColor: Colors.greenAccent,
                                    inactiveTrackColor: theme
                                        .colorScheme.onSurface
                                        .withOpacity(0.5),
                                    activeTickMarkColor: theme
                                        .colorScheme.onSurface
                                        .withOpacity(0.7),
                                    inactiveTickMarkColor: theme
                                        .colorScheme.surface
                                        .withOpacity(0.7),
                                    overlayColor: theme.colorScheme.onSurface
                                        .withOpacity(0.12),
                                    thumbColor: Colors.redAccent,
                                    valueIndicatorColor:
                                        Colors.deepPurpleAccent,
                                    thumbShape: _CustomThumbShape(),
                                    valueIndicatorShape:
                                        _CustomValueIndicatorShape(),
                                    valueIndicatorTextStyle:
                                        theme.accentTextTheme.body2.copyWith(
                                            color: theme.colorScheme.onSurface),
                                  ),
                                  child: Slider(
                                    label: '$_radius米',
                                    value: _radius * 1.0,
                                    min: _minRadius * 1.0,
                                    max: _maxRadius * 1.0,
                                    divisions: ((_maxRadius - _minRadius) / 10)
                                        .floor(),
                                    onChangeEnd: (v) async {
                                      _radius = v.floor();
                                      IRobotRemote robotRemote = widget
                                          .context.site
                                          .getService('/remote/robot');
                                      await robotRemote.updateAbsorberRadius(
                                          absorber.id, _radius);
                                      absorber.radius = _radius;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    onChanged: (v) async {
                                      _radius = v.floor();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    height: 1,
                  ),
                  CardItem(
                    title: '创建人',
                    tipsText: '${_creator?.nickName ?? ''}',
                    onItemTap: () async {
                      widget.context.forward('/person/view',
                          arguments: {'person': _creator});
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Column(
                children: [
                  CardItem(
                    title: '进食次数',
                    tipsText: '${bucket.times}',
                    tail: SizedBox(
                      height: 0,
                      width: 0,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  CardItem(
                    title: '最多人数',
                    tipsText:
                        '${absorber.maxRecipients == 0 ? '无限制' : absorber.maxRecipients}',
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Column(
                children: [
                  CardItem(
                    title: '指向',
                    tail: Column(
                      children: [
                        Text(
                          '${absorber.absorbabler}',
                          style: TextStyle(
                            fontSize: 12,
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

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
