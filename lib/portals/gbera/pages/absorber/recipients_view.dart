import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math' as math;

class AbsorberRecipientsViewPage extends StatefulWidget {
  PageContext context;

  AbsorberRecipientsViewPage({this.context});

  @override
  _AbsorberRecipientsViewPageState createState() =>
      _AbsorberRecipientsViewPageState();
}

class _AbsorberRecipientsViewPageState
    extends State<AbsorberRecipientsViewPage> {
  AbsorberResultOR _absorberResultOR;
  RecipientsOR _recipientsOR;

  @override
  void initState() {
    _absorberResultOR = widget.context.parameters['absorber'];
    _recipientsOR = widget.context.parameters['recipients'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {}

  Future<double> _totalRecipientsRecordWhere(String recipientsId) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.totalRecipientsRecordWhere(
        _absorberResultOR.absorber.id, recipientsId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _renderHeaderCard(),
          SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder<double>(
                future: _totalRecipientsRecordWhere(_recipientsOR.id),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Text(
                      '-',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    );
                  }
                  var v = snapshot.data;
                  if (v == null) {
                    v = 0.00;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '共获得洇金',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        '¥${(v / 100.00).toStringAsFixed(14)}',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Text(
                '激励原因: ${_recipientsOR.encourageCause ?? ''}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: _renderRecords(),
          ),
        ],
      ),
    );
  }

  Widget _renderHeaderCard() {
    return Container(
//      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 10,
        bottom: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Person>(
            future: _getPerson(widget.context.site, _recipientsOR.person),
            builder: (ctx, snapshot) {
              double size = 60;
              if (snapshot.connectionState != ConnectionState.done) {
                return Image.asset(
                  'lib/portals/gbera/images/default_watting.gif',
                  width: size,
                  height: size,
                );
              }
              var person = snapshot.data;
              var avatar = person.avatar;
              if (StringUtil.isEmpty(avatar)) {
                return Image.asset(
                  'lib/portals/gbera/images/default_avatar.png',
                  width: size,
                  height: size,
                );
              }
              var child;
              if (avatar.startsWith('/')) {
                child = Image.file(
                  File(avatar),
                  width: size,
                  height: size,
                );
              } else {
                child = FadeInImage.assetNetwork(
                  placeholder: 'lib/portals/gbera/images/default_watting.gif',
                  image:
                      '${person.avatar}?accessToken=${widget.context.principal.accessToken}',
                  width: size,
                  height: size,
                );
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.context.forward('/person/view',
                      arguments: {'person': snapshot.data});
                },
                child: child,
              );
            },
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_recipientsOR.personName ?? ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 5,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: '权重: ',
                        children: [
                          TextSpan(
                            text: '${_recipientsOR.weight?.toStringAsFixed(4)}',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return _UpdateWeightPopupWidget(
                                      context: widget.context,
                                      recipientsOR: _recipientsOR,
                                    );
                                  },
                                ).then((value) {
                                  if (value != null) {}
                                });
                              },
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    _absorberResultOR.absorber.type == 0
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Text(
                            '距中心: ${_recipientsOR.distance?.toStringAsFixed(2)}米',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                    Text(
                      '${intl.DateFormat('yyyy年M月d日 HH:mm:ss').format(parseStrTime(_recipientsOR.ctime))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderRecords() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      constraints: BoxConstraints.expand(),
      child: Column(
        children: [
          CardItem(
            title: '他的洇取记录',
            onItemTap: () {
              widget.context.forward('/absorber/recipient/records', arguments: {
                'absorber': _absorberResultOR,
                'recipients': _recipientsOR,
              });
            },
          ),
        ],
      ),
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}

class _UpdateWeightPopupWidget extends StatefulWidget {
  PageContext context;
  RecipientsOR recipientsOR;

  _UpdateWeightPopupWidget({
    this.context,
    this.recipientsOR,
  });

  @override
  __UpdateWeightPopupWidgetState createState() =>
      __UpdateWeightPopupWidgetState();
}

class __UpdateWeightPopupWidgetState extends State<_UpdateWeightPopupWidget> {
  @override
  Widget build(BuildContext context) {
    var recipients = widget.recipientsOR;
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('调整权重'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '1.00',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
              height: 100,
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Text(
                    '调整',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SliderTheme(
                      data: theme.sliderTheme.copyWith(
                        activeTrackColor: Colors.greenAccent,
                        inactiveTrackColor:
                            theme.colorScheme.onSurface.withOpacity(0.5),
                        activeTickMarkColor:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                        inactiveTickMarkColor:
                            theme.colorScheme.surface.withOpacity(0.7),
                        overlayColor:
                            theme.colorScheme.onSurface.withOpacity(0.12),
                        thumbColor: Colors.redAccent,
                        valueIndicatorColor: Colors.deepPurpleAccent,
                        thumbShape: _CustomThumbShape(),
                        valueIndicatorShape: _CustomValueIndicatorShape(),
                        valueIndicatorTextStyle: theme.accentTextTheme.body2
                            .copyWith(color: theme.colorScheme.onSurface),
                      ),
                      child: Slider(
                        label: '${recipients.weight.toStringAsFixed(4)}',
                        value: recipients.weight * 1.0,
                        min: 1.0000,
                        max: 100 * 1.0000,
                        divisions: ((100 - 1.0000) / 1).floor(),
                        onChangeEnd: (v) async {
                          recipients.weight = v;
                          IRobotRemote robotRemote =
                              widget.context.site.getService('/remote/robot');
                          await robotRemote.updateRecipientsWeights(recipients.id,recipients.weight);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        onChanged: (v) async {
                          recipients.weight = v;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
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
