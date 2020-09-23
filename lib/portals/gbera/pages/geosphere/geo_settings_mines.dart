import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'dart:math' as math;

class GeoSettingsMines extends StatefulWidget {
  PageContext context;

  GeoSettingsMines({this.context});

  @override
  _GeoSettingsMinesState createState() => _GeoSettingsMinesState();
}

class _GeoSettingsMinesState extends State<GeoSettingsMines> {
  ReceptorInfo _receptor;
  String _poiTitle;
  GeoCategoryMoveableMode _moveMode;
  bool _switchMessageATipMode = false;

  @override
  void initState() {
    _receptor = widget.context.page.parameters['receptor'];
    _switchMessageATipMode = _receptor.isAutoScrollMessage;

    var mode = widget.context.page.parameters['moveMode'];
    switch (mode) {
      case 'unmoveable':
        _moveMode = GeoCategoryMoveableMode.unmoveable;
        break;
      case 'moveableSelf':
        _moveMode = GeoCategoryMoveableMode.moveableSelf;
        break;
      case 'moveableDependon':
        _moveMode = GeoCategoryMoveableMode.moveableDependon;
        break;
    }
    _loadLocation().then((v) {
      setState(() {});
    });
    geoLocation.listen('receptor.settings', 1, _updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('receptor.settings');
    _receptor = null;
    super.dispose();
  }

  Future<void> _loadLocation() async {
    var list = await AmapSearch.searchAround(_receptor.latLng,
        radius: 2000, type: amapPOIType);
    if (list == null || list.isEmpty) {
      return;
    }
    _poiTitle = await list[0].title;
  }

  Future<void> _updateLocation(Location location) async {
    if (_moveMode == 'unmoveable') {
      return;
    }
//    _poiAddress = await location.address;
    setState(() {});
  }

  Future<void> _updateMessageArrivedMode() async {
    _receptor.isAutoScrollMessage = _switchMessageATipMode;
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    await receptorService.setAutoScrollMessage(
        _receptor.id, _receptor.isAutoScrollMessage);
    if (_receptor.onSettingsChanged != null) {
      await _receptor.onSettingsChanged(
        OnReceptorSettingsChangedEvent(
          action: 'scrollMessageMode',
          args: {
            'isAutoScrollMessage': _receptor.isAutoScrollMessage,
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        _getUDistanceItem(),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '位置',
                          tipsText: '${_poiTitle ?? ''}附近',
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: () {
                            widget.context
                                .forward('/gbera/location', arguments: {
                              'location': _receptor.latLng,
                              'label':
                                  '半径:${getFriendlyDistance(_receptor.radius)}'
                            });
                          },
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
                                        '半径:${getFriendlyDistance(_receptor.radius * 1.0)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SliderTheme(
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
                                    label:
                                        '${getFriendlyDistance(_receptor.radius)}',
                                    value: _receptor.radius,
                                    min: 200 * 1.0,
                                    max: 2000 * 1.0,
                                    divisions: ((2000 - 200) / 100).floor(),
                                    onChangeEnd: (v) async {
                                      _receptor.radius = v.floor() * 1.0;
                                      IGeoReceptorService receptorService =
                                          widget.context.site.getService(
                                              '/geosphere/receptors');
                                      await receptorService.updateRadius(
                                          _receptor.id, _receptor.radius);
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    onChanged: (v) async {
                                      _receptor.radius = v.floor() * 1.0;
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
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '实时成员',
                          tipsText: '能相互收到对方消息',
                          leading: Icon(
                            Icons.cached,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/receptor/settings/links/discovery_receptors',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '粉丝',
                          tipsText: '能收到本感知器消息',
                          leading: Icon(
                            Icons.supervisor_account,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/receptor/settings/links/fans',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                        _moveMode != GeoCategoryMoveableMode.moveableSelf
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Divider(
                                height: 1,
                                indent: 35,
                              ),
                        _moveMode != GeoCategoryMoveableMode.moveableSelf
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : CardItem(
                                title: '网流消息接收网关',
                                tipsText: '能接收网流消息到感知器',
                                leading: Icon(
                                  Icons.security,
                                  color: Colors.grey,
                                  size: 23,
                                ),
                                onItemTap: () {
                                  widget.context.forward(
                                      '/geosphere/receptor/settings/links/netflow_gateway');
                                },
                              ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '我的动态',
//                          tipsText: '发表210篇',
                          leading: Icon(
                            FontAwesomeIcons.font,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/portal.owner',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '本地动态',
//                          tipsText: '发表210篇',
                          leading: Icon(
                            FontAwesomeIcons.history,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                              '/geosphere/hostories',
                              arguments: {
                                'receptor': _receptor,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        CardItem(
                          title: '背景设置',
                          tipsText: '',
                          leading: Icon(
                            Icons.settings_ethernet,
                            color: Colors.grey,
                            size: 25,
                          ),
                          onItemTap: () {
                            widget.context.forward(
                                '/geosphere/receptor/settings/background',
                                arguments: {'receptor': _receptor});
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 35,
                        ),
                        CardItem(
                          title: '消息到达模式',
                          tipsText: '自动滚屏还是接收为提示消息',
                          leading: Icon(
                            Icons.refresh,
                            color: Colors.grey,
                            size: 25,
                          ),
                          tail: SizedBox(
                            height: 25,
                            child: Switch.adaptive(
                              value: _switchMessageATipMode,
                              onChanged: (v) {
                                _switchMessageATipMode = v;
                                _updateMessageArrivedMode();
                                setState(() {});
                              },
                            ),
                          ),
                          onItemTap: () {
                            _switchMessageATipMode = !_switchMessageATipMode;
                            _updateMessageArrivedMode();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getUDistanceItem() {
    var title;
    var tips;
    var tail;
    bool enableButton = false;
    switch (_moveMode) {
      case GeoCategoryMoveableMode.unmoveable:
        title = '固定感知器';
        tail = Icon(
          Icons.remove,
          size: 16,
          color: Colors.white,
        );
        break;
      case GeoCategoryMoveableMode.moveableSelf:
        title = '移动感知器';
        tips = '更新距离：${getFriendlyDistance(_receptor.uDistance * 1.0)}';
        enableButton = true;
        break;
      case GeoCategoryMoveableMode.moveableDependon:
        title = '依赖感知器';
        tips = '该感知器依赖于我的地圈的位置更新通知';
        tail = Icon(
          Icons.remove,
          size: 16,
          color: Colors.white,
        );
        break;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: !enableButton ? null : () {},
      child: CardItem(
        title: title,
        tipsText: tips,
        leading: Icon(
          Icons.category,
          color: Colors.grey,
          size: 24,
        ),
        tail: tail,
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
