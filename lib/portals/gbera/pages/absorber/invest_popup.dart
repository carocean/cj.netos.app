import 'dart:async';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

class InvestPopupWidget extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberResultOR;
  DomainBulletin bulletin;

  InvestPopupWidget({this.context, this.absorberResultOR, this.bulletin});

  @override
  _InvestPopupWidgetState createState() => _InvestPopupWidgetState();
}

class _InvestPopupWidgetState extends State<InvestPopupWidget> {
  int _amount = 100;
  PurchaseInfo _purchaseInfo;
  bool _isLoading = false;
  StreamController _rechargeController;
  StreamSubscription _rechargeHandler;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _rechargeHandler?.cancel();
    _rechargeController?.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    _purchaseInfo = await _getPurchaseInfo();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<PurchaseInfo> _getPurchaseInfo() async {
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var result = await AmapLocation.instance.fetchLocation();
    var districtCode = result.adCode;
    var purchaseInfo = await purchaserRemote.getPurchaseInfo(districtCode);
    return purchaseInfo;
  }

  Future<void> _investAbsorber() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    Person creator = await _getPerson(
        widget.context.site, widget.absorberResultOR.absorber.creator);
    await robotRemote.investAbsorber(
      _amount,
      1,
      <String, dynamic>{
        "payeeCode": "${widget.absorberResultOR.absorber.id}",
        "payeeName": "${widget.absorberResultOR.absorber.title}",
        "payeeType": "absorber",
        "orderno": "${MD5Util.MD5(Uuid().v1())}",
        "orderTitle":
            "${widget.context.principal.nickName}喂了${creator?.nickName}的喵",
        "serviceid": "netflow",
        "serviceName": "网流",
        "note": "谢谢"
      },
      '谢谢',
    );
    widget.context.backward(result: {'succeed': true});
  }

  bool _hasEnoghtChange() {
    return _purchaseInfo.myWallet.change >= _amount;
  }

  Future<void> _doRecharge() async {
    if (_rechargeController == null) {
      _rechargeController = StreamController();
      _rechargeHandler = _rechargeController.stream.listen((event) async {
        // print('---充值返回---$event');
        _purchaseInfo = await _getPurchaseInfo();
        if (mounted) {
          setState(() {});
        }
      });
    }
    widget.context.forward('/wallet/change/deposit',
        arguments: {'changeController': _rechargeController});
  }

  @override
  Widget build(BuildContext context) {
    var rows = <Widget>[];
    if (widget.absorberResultOR.bucket.price >=
        widget.bulletin.bucket.waaPrice) {
      rows.add(
        Image.asset(
          'lib/portals/gbera/images/cat-red.gif',
          fit: BoxFit.fill,
          height: 50,
          width: 50,
        ),
      );
      rows.add(
        SizedBox(
          width: 10,
        ),
      );
      rows.add(
        Expanded(
          child: Text(
            '喂喂我吧，虽然我不是很饿',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      );
    } else {
      rows.add(
        Image.asset(
          'lib/portals/gbera/images/cat-green.gif',
          fit: BoxFit.fill,
          height: 50,
          width: 50,
        ),
      );
      rows.add(
        SizedBox(
          width: 10,
        ),
      );
      rows.add(
        Expanded(
          child: Text(
            '喂喂我吧，我饿了',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    return SimpleDialog(
      title: Row(
        children: rows,
      ),
      elevation: 0,
      children: _renderContent(),
    );
  }

  List<Widget> _renderContent() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 40,
          ),
          child: Center(
            child: Text(
              '准备中...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
      return items;
    }
    final ThemeData theme = Theme.of(context);
    items.add(
      Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              Text(
                '¥${(_amount / 100.00).toStringAsFixed(2)}',
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
                  overlayColor: theme.colorScheme.onSurface.withOpacity(0.12),
                  thumbColor: Colors.redAccent,
                  valueIndicatorColor: Colors.deepPurpleAccent,
                  thumbShape: _CustomThumbShape(),
                  valueIndicatorShape: _CustomValueIndicatorShape(),
                  valueIndicatorTextStyle: theme.accentTextTheme.body2
                      .copyWith(color: theme.colorScheme.onSurface),
                ),
                child: Slider(
                  label: '¥${(_amount / 100.00).toStringAsFixed(2)}',
                  value: _amount * 1.0,
                  min: 100.0,
                  max: 50000.0,
                  divisions: ((50000 - 100) / 100).floor(),
                  onChanged: (v) {
                    setState(() {
                      _amount = v.floor();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (_hasEnoghtChange()) {
      items.add(
        SizedBox(
          height: 10,
        ),
      );
      items.add(
        Center(
          child: FlatButton(
            child: Text('确认'),
            disabledTextColor: Colors.grey[300],
            disabledColor: Colors.grey[200],
            color: Colors.green,
            textColor: Colors.white,
            onPressed: () {
              _investAbsorber();
            },
          ),
        ),
      );
    } else {
      items.add(
        Center(
          child: Column(
            children: [
              Text(
                '当前余额不足，剩余¥${_purchaseInfo.myWallet.changeYan}元，请充值！',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.only(left: 45,right: 45,),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '提示:',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        '充值后该窗口会自动关闭，但系统并不会自动喂猫，请再次打开窗口以喂食。',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Center(
          child: FlatButton(
            child: Text('充值'),
            disabledTextColor: Colors.grey[300],
            disabledColor: Colors.grey[200],
            color: Colors.green,
            textColor: Colors.white,
            onPressed: () {
              _doRecharge();
            },
          ),
        ),
      );
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

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
