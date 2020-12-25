import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'dart:math' as math;

import 'package:netos_app/system/local/entities.dart';

class AroundFriendsPage extends StatefulWidget {
  PageContext context;

  AroundFriendsPage({this.context});

  @override
  _AroundFriendsPageState createState() => _AroundFriendsPageState();
}

class _AroundFriendsPageState extends State<AroundFriendsPage> {
  LatLng _location;
  bool _isSearching = false;
  List<GeoPOI> _pois = [];
  Map<String, bool> _hasPersons = {};
  int _limit = 20, _offset = 0;
  String _geoType = 'mobiles';
  EasyRefreshController _controller;
  int _radius = 100;
  bool _isLoading = false;
  List<String> _selectedFriends = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    () async {
      _isLoading = true;
      if (mounted) {
        setState(() {});
      }
      var location = await geoLocation.location;
      _location = location.latLng;
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
    List<String> selected = widget.context.parameters['selected'];
    for (var poi in items) {
      var creator = poi.creator;
      if (creator == null ||
          creator.official == widget.context.principal.person) {
        continue;
      }
      if (_hasPersons.containsKey(creator.official)) {
        continue;
      }
      _pois.add(poi);
      _hasPersons[creator.official] = true;
      if (selected != null && selected.contains(creator.official)) {
        _selectedFriends.add(creator.official);
      }
    }
    _isSearching = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _pois.clear();
    _hasPersons.clear();
    await _load();
  }

  Future<void> _done() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IFriendService friendService =
        widget.context.site.getService('/gbera/friends');
    for (var poi in _pois) {
      var person = poi.creator;
      for (var official in _selectedFriends) {
        if (person.official != official) {
          continue;
        }
        if (!(await personService.existsPerson(official))) {
          await personService.addPerson(person, isOnlyLocal: true);
          if (mounted) {
            setState(() {});
          }
        }
        if (!(await friendService.exists(official))) {
          await friendService.addFriend(Friend.formPerson(person));
          if (mounted) {
            setState(() {});
          }
        }
      }
    }
    widget.context.backward(result: _selectedFriends);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '附近的人建群',
        ),
        titleSpacing: 0,
        elevation: 0.0,
        actions: [
          _selectedFriends.isEmpty
              ? SizedBox(
                  width: 0,
                  height: 0,
                )
              : Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    right: 15,
                  ),
                  child: RaisedButton(
                    onPressed: () {
                      _done();
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text(
                      '完成(${_selectedFriends.length})',
                    ),
                  ),
                ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _renderSelected(),
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
                  Expanded(
                    child: Row(
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
                        Expanded(
                          child: Column(
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
                                  valueIndicatorColor: Colors.deepPurpleAccent,
                                  thumbShape: _CustomThumbShape(),
                                  valueIndicatorShape:
                                      _CustomValueIndicatorShape(),
                                  valueIndicatorTextStyle:
                                      theme.accentTextTheme.body2.copyWith(
                                          color: theme.colorScheme.onSurface),
                                ),
                                child: Slider(
                                  label:
                                      '${getFriendlyDistance(_radius * 1.0)}',
                                  value: _radius * 1.0,
                                  min: 50.0,
                                  max: 400.0,
                                  divisions: ((400 - 50) / 50).floor(),
                                  onChanged: (v) {
                                    setState(() {
                                      _radius = v.floor();
                                    });
                                  },
                                  onChangeEnd: (v){
                                    _onRefresh();
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

  Widget _renderSelected() {
    var items = <Widget>[];
    if (_selectedFriends.isEmpty) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    for (var poi in _pois) {
      var creator = poi.creator;
      for (var person in _selectedFriends) {
        if (creator.official != person) {
          continue;
        }
        items.add(
          Container(
            width: 40,
            height: 40,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context
                    .forward('/person/view', arguments: {'person': creator});
              },
              onLongPress: () {
                _selectedFriends.removeWhere((p) {
                  return p == person;
                });
                setState(() {});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: getAvatarWidget(creator.avatar, widget.context),
              ),
            ),
          ),
        );
      }
    }
    if (items.isNotEmpty) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/contacts/friend/selected',
                arguments: {'selected': _selectedFriends});
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 1,color: Colors.grey[400],),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items,
            ),
          ),
        ],
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
      var person = poi.creator;
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selectedFriends.contains(person.official)) {
              _selectedFriends.remove(person.official);
            } else {
              _selectedFriends.add(person.official);
            }
            setState(() {});
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  margin: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Center(
                    child: Radio(
                      value: _selectedFriends.contains(person.official),
                      groupValue: true,
                      activeColor: Colors.green,
                      onChanged: (v) {
                        if (v) {
                          _selectedFriends.add(person.official);
                        } else {
                          _selectedFriends.remove(person.official);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: getAvatarWidget(person.avatar, widget.context),
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
                        '${person.nickName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${getFriendlyDistance(poi.distance)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    _StateRender(
                      person: person,
                      context: widget.context,
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

class _StateRender extends StatefulWidget {
  PageContext context;
  Person person;

  _StateRender({this.context, this.person});

  @override
  __StateRenderState createState() => __StateRenderState();
}

class __StateRenderState extends State<_StateRender> {
  int _state = 0; //0什么都不是；1是公众；2是朋友
  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(_StateRender oldWidget) {
    if (oldWidget.person != widget.person) {
      oldWidget.person = widget.person;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    var person = widget.person;
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IFriendService friendService =
        widget.context.site.getService('/gbera/friends');
    _state = await personService.existsPerson(person.official) ? 1 : _state;
    if (_state == 1) {
      _state = await friendService.exists(person.official) ? 2 : _state;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var widget;
    var style = TextStyle(
      fontSize: 12,
      color: Colors.grey,
    );
    switch (_state) {
      case 1:
        widget = Text(
          '已是公众',
          style: style,
        );
        break;
      case 2:
        widget = Text(
          '已是好友',
          style: style,
        );
        break;
      default:
        return SizedBox(
          width: 0,
          height: 0,
        );
    }
    return Align(
      alignment: Alignment.bottomRight,
      child: widget,
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
