import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'dart:math' as math;

import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class CreateSlicesPage extends StatefulWidget {
  PageContext context;

  CreateSlicesPage({this.context});

  @override
  _CreateSlicesPageState createState() => _CreateSlicesPageState();
}

class _CreateSlicesPageState extends State<CreateSlicesPage> {
  int _sliceCount = 1;
  int _maxAbsorbers = 0; //最大的猫数是参与的+在圈的,且没有发过码片的
  int _createdSliceAbsorbers = 0;
  SliceTemplateOR _selectedSliceTemplate;
  LatLng _location;
  String _address;
  int _radius = 500;
  AbsorberOR _originAbsorber;
  Map<String, AbsorberResultOR> _absorbers = {};
  String _progressTips = '准备搜索招财猫...';
  bool _searchAbsorbersDone = false;

  @override
  void initState() {
    _originAbsorber=widget.context.parameters['originAbsorber'];
    () async {
      await _loadTemplate();
      await _fetchLocation();
      await _searchAbsorbers();
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadTemplate() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    _selectedSliceTemplate = await robotRemote.getQrcodeSliceTemplate('normal');
    if (mounted) setState(() {});
  }

  Future<void> _fetchLocation() async {
    if (_originAbsorber == null) {
      //如果不是自指定的猫创建，则取当前用户位置
      var location = await AmapLocation.fetchLocation();
      _location = await location.latLng;
      _address = await location.address;
      return;
    }
    _location = _originAbsorber.location;
    _radius = _originAbsorber.radius;
    ReGeocode regeo =
        await AmapSearch.searchReGeocode(_location, radius: _radius * 1.0);
    _address = await regeo.formatAddress;
  }

  Future<void> _searchAbsorbers() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var totalWeight = _selectedSliceTemplate.ingeoWeight +
        _selectedSliceTemplate.ownerWeight +
        _selectedSliceTemplate.participWeight;
    var per = _selectedSliceTemplate.maxAbsorbers / totalWeight;
    var myAbsorberCount = _selectedSliceTemplate.ownerWeight * per;
    if (mounted) {
      setState(() {
        _progressTips = '准备发现当前的招财猫...';
      });
    }
    var myAbsorbers =
        await robotRemote.pageMyAbsorberByUsage(-1, myAbsorberCount.floor(), 0);
    for (var o in myAbsorbers) {
      _absorbers[o.absorber.id] = o;
    }
    if (mounted) {
      setState(() {
        _progressTips = '已发现当前的招财猫${myAbsorbers.length}个';
      });
    }
    var joininAbsorberCount = _selectedSliceTemplate.participWeight * per;
    if (mounted) {
      setState(() {
        _progressTips = '准备发现其参与的招财猫...';
      });
    }
    var joininAbsorbers = await robotRemote.pageJioninAbsorberByUsage(
        -1, joininAbsorberCount.floor(), 0);
    for (var o in joininAbsorbers) {
      if (_absorbers.containsKey(o.absorber.id)) {
        continue;
      }
      bool exists = await robotRemote.existsPubSliceRecipients(o.absorber.id);
      if (exists) {
        _createdSliceAbsorbers++;
        continue;
      }
      _absorbers[o.absorber.id] = o;
      _maxAbsorbers++;
    }
    if (mounted) {
      setState(() {
        _progressTips = '已发现其参与的招财猫${joininAbsorbers.length}个';
      });
    }
    var geoAbsorberCount = _selectedSliceTemplate.ingeoWeight * per;
    if (mounted) {
      setState(() {
        _progressTips = '准备发现附近的招财猫...';
      });
    }
    var ingeoAbsorbers = <AbsorberResultOR>[];
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    List<GeoPOI> pois = await receptorRemote.searchAroundLocation(
        _location, _radius, null, geoAbsorberCount.floor(), 0);
    for (var poi in pois) {
      var receptor = poi.receptor;
      var absorbabler = '${receptor.category}/${receptor.id}';
      var absorber = await robotRemote.getAbsorberByAbsorbabler(absorbabler);
      if (absorber == null) {
        continue;
      }
      var usage = absorber.absorber.usage;
      if (usage != 1) {
        continue;
      }
      ingeoAbsorbers.add(absorber);
    }
    for (var o in ingeoAbsorbers) {
      if (_absorbers.containsKey(o.absorber.id)) {
        continue;
      }
      bool exists = await robotRemote.existsPubSliceRecipients(o.absorber.id);
      if (exists) {
        _createdSliceAbsorbers++;
        continue;
      }
      _absorbers[o.absorber.id] = o;
      _maxAbsorbers++;
    }
    if (mounted) {
      setState(() {
        _progressTips = '已发现我附近的招财猫${ingeoAbsorbers.length}个';
      });
    }
    print(
        '-----我的猫${myAbsorbers.length}---我参与的${joininAbsorbers.length}----我附近的${ingeoAbsorbers.length}');
    _searchAbsorbersDone = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('生成码片'),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return widget.context
                                .part('/robot/slice/templates', context);
                          }).then((value) {
                        if (value == null) {
                          return;
                        }
                        _selectedSliceTemplate = value;
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '${_selectedSliceTemplate?.name ?? ''}',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          FontAwesomeIcons.filter,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: AspectRatio(
                      aspectRatio: Adapt.screenW() / Adapt.screenH(),
                      child: widget.context.part(
                        '/robot/slice/template',
                        context,
                        arguments: {
                          'selectedSliceTemplate': _selectedSliceTemplate
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 1,
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      _renderOrigin(),
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: !_searchAbsorbersDone
                      ? Text('$_progressTips')
                      : Text.rich(
                          TextSpan(
                            text: '',
                            children: [
                              TextSpan(text: '搜索完成，共发现'),
                              TextSpan(
                                text: '  ${_absorbers.length}个  ',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: '招财猫'),
                            ],
                          ),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                ),
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                child: RenderSlider(theme),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: !_searchAbsorbersDone || _maxAbsorbers < 1
                    ? null
                    : () {
                        widget.context.forward(
                          '/robot/createSlices/progress',
                          arguments: {
                            'template': _selectedSliceTemplate,
                            'location': _location,
                            'radius': _radius,
                            'originAbsorber': _originAbsorber,
                            'count': _sliceCount,
                            'absorbers': _absorbers,
                          },
                        );
                      },
                child: Container(
                  color: !_searchAbsorbersDone || _maxAbsorbers < 1
                      ? Colors.grey
                      : Colors.green,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                  ),
                  child: Text(
                    '${!_searchAbsorbersDone || _maxAbsorbers < 1 ? '稍候点生成...' : '生成码片'}',
                    style: TextStyle(
                      color: !_searchAbsorbersDone || _maxAbsorbers < 1
                          ? Colors.grey[400]
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderOrigin() {
    if (_originAbsorber == null) {
      var avatar = widget.context.principal.avatarOnRemote;
      return Row(
        children: [
          FadeInImage.assetNetwork(
            placeholder: 'lib/portals/gbera/images/default_watting.gif',
            image:
                '$avatar?accessToken=${widget.context.principal.accessToken}',
            width: 30,
            height: 30,
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.context.principal.nickName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      size: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        '${_address ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      '半径 ${getFriendlyDistance(_radius * 1.0)}',
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
      );
    }
    return Row(
      children: [
        Icon(
          IconData(
            0xe6b2,
            fontFamily: 'absorber',
          ),
          size: 30,
          color: Colors.grey,
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_originAbsorber.title}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 14,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      '${_address ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '半径 ${getFriendlyDistance(_radius * 1.0)}',
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
    );
  }

  Widget RenderSlider(ThemeData theme) {
    if (!_searchAbsorbersDone) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    if (_maxAbsorbers == 0&&_createdSliceAbsorbers==0) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 0,
          bottom: 20,
        ),
        child: Text(
          '不能生成码片，没有发现到招财猫',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      );
    }
    if (_maxAbsorbers == 0) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 0,
          bottom: 20,
        ),
        child: Text(
          '不符合生成码片的条件，已有$_createdSliceAbsorbers个猫被装载过码片了',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      );
    }

    if (_maxAbsorbers == 1) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 0,
          bottom: 20,
        ),
        child: Text(
          '可以生成1张码片',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '码片数 ',
            children: [
              TextSpan(
                text: '$_sliceCount张',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 4,
        ),
        SliderTheme(
          data: theme.sliderTheme.copyWith(
            activeTrackColor: Colors.greenAccent,
            inactiveTrackColor: theme.colorScheme.onSurface.withOpacity(0.5),
            activeTickMarkColor: theme.colorScheme.onSurface.withOpacity(0.7),
            inactiveTickMarkColor: theme.colorScheme.surface.withOpacity(0.7),
            overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
            thumbColor: Colors.redAccent,
            valueIndicatorColor: Colors.deepPurpleAccent,
            thumbShape: _CustomThumbShape(),
            valueIndicatorShape: _CustomValueIndicatorShape(),
            valueIndicatorTextStyle: theme.accentTextTheme.body2
                .copyWith(color: theme.colorScheme.onSurface),
          ),
          child: Slider(
            label: '$_sliceCount张',
            value: _sliceCount * 1.0,
            min: 1.0,
            max: _maxAbsorbers * 1.0,
            divisions: _maxAbsorbers - 1,
            onChanged: (v) {
              setState(() {
                _sliceCount = v.floor();
              });
            },
          ),
        )
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
