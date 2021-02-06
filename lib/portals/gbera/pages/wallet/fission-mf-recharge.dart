import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';

class FissionMfRechargePage extends StatefulWidget {
  PageContext context;

  FissionMfRechargePage({this.context});

  @override
  _FissionMfRechargePageState createState() => _FissionMfRechargePageState();
}

class _FissionMfRechargePageState extends State<FissionMfRechargePage> {
  int _amount = 100;
  MyWallet _myWallet;
  StreamController _rechargeController;
  StreamSubscription _rechargeHandler;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    super.initState();
  }

  @override
  void dispose() {
    _rechargeHandler?.cancel();
    _rechargeController?.close();
    super.dispose();
  }

  bool _demandRecharge() {
    return _myWallet.change < _amount;
  }

  Future<void> _recharge() async {
    if (_rechargeController == null) {
      _rechargeController = StreamController();
      _rechargeHandler = _rechargeController.stream.listen((event) async {
        // print('---充值返回---$event');
        IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
        var location=await geoLocation.location;
        var _districtCode=location.adCode;
        var purchaseInfo = await purchaserRemote.getPurchaseInfo(_districtCode);
        if (purchaseInfo.bankInfo == null) {
          return;
        }
        if (purchaseInfo.myWallet.change >= _amount) {
          _amount=purchaseInfo.myWallet.change;
          _myWallet.change=purchaseInfo.myWallet.change;
          _myWallet.total=purchaseInfo.myWallet.total;
          if (mounted) {
            setState(() {});
          }
          return;
        }
      });
    }
    widget.context.forward('/wallet/change/deposit',
        arguments: {'changeController': _rechargeController,'initAmount':(_amount-_myWallet.change)});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('充钱到红包'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
            ),
            color: _demandRecharge() ? null : Colors.green,
            onPressed: _demandRecharge()
                ? null
                : () {
                    widget.context.backward(result: {'amount': _amount});
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 30,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._renderPanel(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: Colors.grey[300],
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '选择充值金额',
                            children: [],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite),
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
                              valueIndicatorTextStyle: theme
                                  .accentTextTheme.body2
                                  .copyWith(color: theme.colorScheme.onSurface),
                            ),
                            child: Slider(
                              label: '${(_amount / 100.00).toStringAsFixed(2)}',
                              value: _amount / 100.00,
                              min: 1.0,
                              max: 2000.00,
                              divisions: 1999,
                              onChanged: (v) {
                                setState(() {
                                  _amount = (v * 100).floor();
                                });
                              },
                              onChangeEnd: (v) {},
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: '可用零钱: ',
                                  children: [
                                    TextSpan(
                                      text:
                                          '¥${((_myWallet.change - _amount) / 100.00).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
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
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Column(
                      children: [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderPanel() {
    var items = <Widget>[];
    if (!_demandRecharge()) {
      items.addAll(
        <Widget>[
          Text(
            '金额',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: '¥',
                  children: [
                    TextSpan(
                      text: '${((_amount) / 100.00).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      //充值
      items.add(
        RaisedButton(
          onPressed: () {
            _recharge();
          },
          color: Colors.green,
          textColor: Colors.white,
          disabledTextColor: Colors.white54,
          child: Text(
            '请充值',
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
