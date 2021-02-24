import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';

class BuyWYArticle extends StatefulWidget {
  PageContext context;

  BuyWYArticle({this.context});

  @override
  _BuyWYArticleState createState() => _BuyWYArticleState();
}

class _BuyWYArticleState extends State<BuyWYArticle> {
  int _amount = 5000;
  int _method = 0; //0零钱；1体验金
  PurchaseInfo _purchaseInfo;

  @override
  void initState() {
    _purchaseInfo = widget.context.parameters['purchaseInfo'];
    _amount = widget.context.parameters['purchaseAmount'];
    _method = widget.context.parameters['purchaseMethod'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  bool _invalid(){
    if(_method==0) {
      return _purchaseInfo.myWallet.change < _amount;
    }
    return _purchaseInfo.myWallet.trial < _amount;
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          '购买该服务',
        ),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
            ),
            color:
            _invalid() ? null : Colors.green,
            onPressed:  _invalid()
                ? null
                : () {
                    widget.context.backward(result: {'amount':_amount,'method':_method});
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
                  Text(
                    '纹银',
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
                      Text(
                        '₩${((_purchaseInfo.bankInfo.principalRatio * _amount) / _purchaseInfo.businessBuckets.price).toStringAsFixed(14)}',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '现值 ',
                          children: [
                            TextSpan(
                              text:
                                  '¥${((_purchaseInfo.bankInfo.principalRatio * _amount) / 100.00).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
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
                  Row(
                    children: [
                      FadeInImage.assetNetwork(
                        placeholder:
                            'lib/portals/gbera/images/default_watting.gif',
                        image:
                            '${_purchaseInfo.bankInfo.icon}?accessToken=${widget.context.principal.accessToken}',
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_purchaseInfo.bankInfo.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text.rich(
                            TextSpan(
                              text: '现价: ',
                              children: [
                                TextSpan(
                                  text:
                                      '¥${(_purchaseInfo.businessBuckets.price / 100.00).toStringAsFixed(14)}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
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
                            text: '申购金: ',
                            children: [
                              TextSpan(
                                text:
                                    '¥${(_amount / 100.00).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 25,
                                ),
                              ),
                            ],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
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
                              min: 50.0,
                              max: 500.00,
                              divisions: 9,
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
                                  text: '扣除服务费: ',
                                  children: [
                                    TextSpan(
                                      text:
                                          '¥${(((_purchaseInfo.bankInfo.freeRatio + _purchaseInfo.bankInfo.reserveRatio) * _amount) / 100.00).toStringAsFixed(2)}',
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
                              SizedBox(
                                height: 5,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '冻结本金: ',
                                  children: [
                                    TextSpan(
                                      text:
                                          '¥${((_purchaseInfo.bankInfo.principalRatio * _amount) / 100.00).toStringAsFixed(2)}',
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
                  _renderSelectPayMethod(),
                  Expanded(
                    child: Column(
                      children: _rendTips(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '免责说明: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '发布服务是一项付费服务。',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text:
                            '不保证纹银会升值，纹银的升值空间是地商将收取的服务费的部分用于激励的结果。当前价格仅供参考，以实际发布时的现价为准，具体可在发布后在"钱包"的明细中查看\r\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  TextSpan(
                    text: '发布范围：\r\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '\t\t\t\t\t\t\t\t1.发布到网流管道或地理感知器\r\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: '\t\t\t\t\t\t\t\t2.发布到追链',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _rendTips() {
    var items = <Widget>[];
    if (_invalid()) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '申购金超出余额！',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }

  _selectPayMethods() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Scaffold(
          appBar: AppBar(
            title: Text('选择付款方式'),
            elevation: 0.0,
            titleSpacing: 0,
          ),
          body: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.backward(result: 0);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wallet_travel,
                          size: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '零钱',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '¥${_purchaseInfo.myWallet.changeYan}元',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              _method==0?Icons.check: Icons.arrow_forward_ios,
                              size: 18,
                              color:_method==0?Colors.red: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Divider(
                    height: 1,
                    indent: 40,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.backward(result: 1);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wb_auto,
                          size: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '体验金',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '¥${_purchaseInfo.myWallet.trialYan}元',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                             _method==1?Icons.check: Icons.arrow_forward_ios,
                              size: 18,
                              color:_method==1?Colors.red: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Divider(
                    height: 1,
                    indent: 40,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      if (mounted) {
        setState(() {
          _method = value;
        });
      }
    });
  }

  Widget _renderSelectPayMethod() {
    switch (_method) {
      case 0:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _selectPayMethods();
          },
          child: Row(
            children: [
              Icon(
                Icons.wallet_travel,
                size: 30,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '零钱',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '¥${_purchaseInfo.myWallet.changeYan}元',
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '其它付款方式',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        );
      case 1:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _selectPayMethods();
          },
          child: Row(
            children: [
              Icon(
                Icons.wb_auto,
                size: 30,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '体验金',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '¥${_purchaseInfo.myWallet.trialYan}元',
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '其它付款方式',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return SizedBox(
          width: 0,
          height: 0,
        );
    }
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
