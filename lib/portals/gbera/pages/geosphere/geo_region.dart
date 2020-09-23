import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'dart:math' as math;
import 'geo_utils.dart';

///区域市场
class GeoRegion extends StatefulWidget {
  PageContext context;

  GeoRegion({this.context});

  @override
  _GeoRegionState createState() => _GeoRegionState();
}

class _GeoRegionState extends State<GeoRegion> {
  LatLng _location;
  bool _isSearching = false;
  List<GeoPOI> _pois = [];
  int _limit = 4, _offset = 0;
  String _geoType;
  EasyRefreshController _controller;
  int _radius = 2000;
  bool _isLoading = false;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _location = widget.context.page.parameters['location'];
    () async {
      _isLoading = true;
      if (mounted) {
        setState(() {});
      }
      await _load();
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_isSearching) {
      return;
    }
    _isSearching = true;
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    var items = await receptorRemote.searchAroundLocation(
        _location, _radius, _geoType, _limit /*各类取2个*/, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(
        success: true,
        noMore: true,
      );
      _isSearching = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += items.length;
    for (var poi in items) {
      if (poi.creator == null ||
          poi.receptor.creator == widget.context.principal.person) {
        continue;
      }
      _pois.add(poi);
    }
    _isSearching = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _pois.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '发现',
        ),
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 15,
                left: 15,
                top: 10,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 16,
                        color: Colors.black54,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        children: [
                          Text(
                            '${getFriendlyDistance(_radius * 1.0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
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
                              overlayColor:
                                  theme.colorScheme.onSurface.withOpacity(0.12),
                              thumbColor: Colors.redAccent,
                              valueIndicatorColor: Colors.deepPurpleAccent,
                              thumbShape: _CustomThumbShape(),
                              valueIndicatorShape: _CustomValueIndicatorShape(),
                              valueIndicatorTextStyle: theme
                                  .accentTextTheme.body2
                                  .copyWith(color: theme.colorScheme.onSurface),
                            ),
                            child: Slider(
                              label: '${getFriendlyDistance(_radius * 1.0)}',
                              value: _radius * 1.0,
                              min: 200.0,
                              max: 25000.0,
                              divisions: ((25000 - 200) / 200).floor(),
                              onChanged: (v) {
                                setState(() {
                                  _radius = v.floor();
                                  _onRefresh();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return widget.context.part(
                                '/geosphere/filter', context,
                                arguments: {'category': null});
                          }).then((value) {
                        if (value == null) {
                          return;
                        }
                        if (value == 'clear') {
                          _geoType = null;
                          _onRefresh();
                          return;
                        }
                        _geoType = value['category'];
                        _onRefresh();
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '全部',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.apps,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: EasyRefresh(
                controller: _controller,
                onLoad: _load,
                onRefresh: _onRefresh,
                child: ListView(
                  shrinkWrap: true,
                  children: _renderReceptors(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderReceptors() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Column(
          children: [
            Text(
              '搜索中...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
      return items;
    }
    for (var i = 0; i < _pois.length; i++) {
      var poi = _pois[i];
      var img;
      if (StringUtil.isEmpty(poi.receptor.leading)) {
        img = Image.asset('lib/portals/gbera/images/netflow.png');
      } else {
        img = FadeInImage.assetNetwork(
          placeholder: 'lib/portals/gbera/images/default_watting.gif',
          image:
              '${poi.receptor.leading}?accessToken=${widget.context.principal.accessToken}',
        );
      }
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward(
              '/geosphere/view/receptor',
              arguments: {
                'receptor': poi.receptor,
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: img,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '${poi.receptor.title}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${poi.categoryOR.title}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  children: [
                    Text(
                      '${getFriendlyDistance(poi.distance)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (i < _pois.length - 1) {
        items.add(
          SizedBox(
            height: 20,
            child: Divider(
              height: 1,
              indent: 65,
            ),
          ),
        );
      }
    }
    return items;
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
