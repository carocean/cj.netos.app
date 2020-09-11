import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

class GeoAbsorberDetailsPage extends StatefulWidget {
  PageContext context;

  GeoAbsorberDetailsPage({this.context});

  @override
  _AbsorberDetailsState createState() => _AbsorberDetailsState();
}

class _AbsorberDetailsState extends State<GeoAbsorberDetailsPage> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  StreamController _streamController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _streamSubscription = Stream.periodic(
        Duration(
          seconds: 5,
        ), (count) async {
      await _refresh();
    }).listen((event) {});
    () async {
      await _refresh();
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var absorber = widget.context.parameters['absorber'];
    _absorberResultOR = await robotRemote.getAbsorber(absorber);
    if (_absorberResultOR == null) {
      return;
    }
    _bulletin =
        await robotRemote.getDomainBucket(_absorberResultOR.absorber.bankid);
    _streamController
        .add({'absorber': _absorberResultOR, 'bulletin': _bulletin});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, index) {
          var slivers = <Widget>[
            SliverAppBar(
              pinned: true,
              elevation: 0,
              actions: [
                FlatButton(
                  onPressed: () {
                    widget.context.forward('/absorber/invest/details',
                        arguments: {'absorber': _absorberResultOR});
                  },
                  child: Text('小喵流水'),
                ),
              ],
//              backgroundColor: Colors.white,
            ),
            SliverToBoxAdapter(
              child: _HeaderCard(
                context: widget.context,
                stream: _streamController.stream.asBroadcastStream(),
              ),
            ),
            _absorberResultOR == null
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 0,
                      width: 0,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                        top: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Stack(
                        overflow: Overflow.visible,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '¥${((_absorberResultOR.bucket.wInvestAmount + _absorberResultOR.bucket.pInvestAmount) / 100.00).toStringAsFixed(14)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('=',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      )),
                                  Text(
                                      '¥${(_absorberResultOR.bucket.pInvestAmount / 100.00).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      )),
                                  Text('+',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      )),
                                  Text(
                                      '¥${(_absorberResultOR.bucket.pInvestAmount / 100.00).toStringAsFixed(14)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Text(
                              '已发',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            _absorberResultOR == null
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 0,
                      width: 0,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 4,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '发现',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Expanded(
                            child: Text(
                              '半径${_absorberResultOR.absorber.radius}米',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return _InvestPopupWidget(
                                    context: widget.context,
                                    absorberResultOR: _absorberResultOR,
                                    bulletin: _bulletin,
                                  );
                                },
                              ).then((value) {
                                if (value != null) {
//                                  _reloadAbsorber();
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 0,
                                top: 3,
                              ),
                              child: Text(
                                '+喵喵',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ];
          return slivers;
        },
        body: Container(
          color: Colors.white,
          constraints: BoxConstraints.expand(),
          child: _GeoRecipientsCard(
            context: widget.context,
            stream: _streamController.stream.asBroadcastStream(),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatefulWidget {
  PageContext context;
  Stream stream;

  _HeaderCard({
    this.context,
    this.stream,
  });

  @override
  __HeaderCardState createState() => __HeaderCardState();
}

class __HeaderCardState extends State<_HeaderCard> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamSubscription = widget.stream.listen((event) {
      _absorberResultOR = event['absorber'];
      _bulletin = event['bulletin'];
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _renderHeaderCard();
  }

  Widget _renderHeaderCard() {
    if (_absorberResultOR == null) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    var rangeWidth = 130.0;
    var waaPrice = _bulletin.bucket.waaPrice;
    var abPrice = _absorberResultOR.bucket.price;
    var totalPrice = waaPrice + abPrice;
    var initRatio = 1.0;
    totalPrice = totalPrice == 0 ? initRatio : totalPrice;
    var perWidth = rangeWidth / totalPrice;
    double waaWidth = waaPrice * perWidth;
    double abWidth = abPrice * perWidth;
    return Container(
//      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 10,
        bottom: 30,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: abPrice >= waaPrice
                ? Image.asset(
                    'lib/portals/gbera/images/cat-red.gif',
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    'lib/portals/gbera/images/cat-green.gif',
                    fit: BoxFit.fill,
                  ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_absorberResultOR.absorber.title ?? ''}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  '地理洇取器',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '域指 ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        waaWidth == 0
                            ? Container(
                                height: 10,
                                width: 1,
                                color: Colors.grey[600],
                              )
                            : Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${waaPrice.toStringAsFixed(14)}',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                      width: waaWidth,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Row(
                      children: [
                        Text(
                          '洇指 ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        abWidth == 0
                            ? Container(
                                height: 10,
                                width: 1,
                                color: Colors.grey,
                              )
                            : Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${abPrice.toStringAsFixed(14)}',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: abPrice >= waaPrice
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                      width: abWidth,
                                      color: abPrice >= waaPrice
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                      ],
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
}

class _GeoRecipientsCard extends StatefulWidget {
  PageContext context;
  Stream stream;

  _GeoRecipientsCard({this.context, this.stream});

  @override
  _GeoRecipientsCardState createState() => _GeoRecipientsCardState();
}

class _GeoRecipientsCardState extends State<_GeoRecipientsCard> {
  EasyRefreshController _controller;
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  StreamSubscription _streamSubscription;
  List<RecipientsOR> _recipients = [];
  int _limit = 40, _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _streamSubscription = widget.stream.listen((event) async {
      _absorberResultOR = event['absorber'];
      DomainBulletin bulletin = event['bulletin'];
      if (mounted &&
          (_bulletin == null ||
              _bulletin.bucket.waaPrice != bulletin.bucket.waaPrice)) {
        _bulletin = bulletin;
        await _onRefresh();
        return;
      }
      _bulletin = bulletin;
    });

    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _recipients.clear();
    _offset = 0;
    await _onLoad();
  }

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    List<RecipientsOR> recipients = await robotRemote.pageRecipients(
        _absorberResultOR.absorber.id, _limit, _offset);
    if (recipients.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += recipients.length;
    _recipients.addAll(recipients);
    if (mounted) {
      setState(() {});
    }
  }

  Future<double> _totalRecipientsRecordById(String recipientsId) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.totalRecipientsRecordById(recipientsId);
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_recipients.isEmpty) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 20,
          ),
          child: Center(
            child: Text(
              '没有成员',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    for (var item in _recipients) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/weny/recipients/records/geo',
                arguments: {'recipients': item, 'absorber': _absorberResultOR});
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              padding: EdgeInsets.only(
                                right: 10,
                              ),
                              child: FutureBuilder<Person>(
                                future: _getPerson(
                                    widget.context.site, item.person),
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return Image.asset(
                                      'lib/portals/gbera/images/default_watting.gif',
                                      width: 40,
                                      height: 40,
                                    );
                                  }
                                  var person = snapshot.data;
                                  var avatar = person.avatar;
                                  if (StringUtil.isEmpty(avatar)) {
                                    return Image.asset(
                                      'lib/portals/gbera/images/default_avatar.png',
                                      width: 40,
                                      height: 40,
                                    );
                                  }
                                  if (avatar.startsWith('/')) {
                                    return Image.file(
                                      File(avatar),
                                      width: 40,
                                      height: 40,
                                    );
                                  }
                                  return FadeInImage.assetNetwork(
                                    placeholder:
                                        'lib/portals/gbera/images/default_watting.gif',
                                    image:
                                        '${person.avatar}?accessToken=${widget.context.principal.accessToken}',
                                    width: 40,
                                    height: 40,
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                direction: Axis.vertical,
                                spacing: 5,
                                runSpacing: 5,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${item.personName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${item.person}',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  _absorberResultOR.absorber.type == 0
                                      ? SizedBox(
                                          height: 0,
                                          width: 0,
                                        )
                                      : Text(
                                          '距中心: ${item.distance?.toStringAsFixed(2)}米',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                  Text(
                                    '激励原因: ${item.encourageCause ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${intl.DateFormat('yyyy年M月d日 HH:mm:ss').format(parseStrTime(item.ctime))}',
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
                    ),
                    Row(
                      children: <Widget>[
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: <Widget>[
                            Text(
                              '${item.weight.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            FutureBuilder<double>(
                              future: _totalRecipientsRecordById(item.id),
                              builder: (ctx, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                                var v = snapshot.data;
                                if (v == null) {
                                  v = 0.00;
                                }
                                return Text(
                                  '¥${(v / 100.00).toStringAsFixed(14)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 55,
              ),
            ],
          ),
        ),
      );
    }
    return EasyRefresh(
      onLoad: _onLoad,
      onRefresh: _onRefresh,
      controller: _controller,
      child: ListView(
        shrinkWrap: true,
        children: items,
      ),
    );
  }
}

class _InvestPopupWidget extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberResultOR;
  DomainBulletin bulletin;

  _InvestPopupWidget({this.context, this.absorberResultOR, this.bulletin});

  @override
  __InvestPopupWidgetState createState() => __InvestPopupWidgetState();
}

class __InvestPopupWidgetState extends State<_InvestPopupWidget> {
  int _amount = 100;

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
        "serviceid": "geosphere",
        "serviceName": "地圈",
        "note": "谢谢"
      },
      '谢谢',
    );
    widget.context.backward(result: {'succeed': true});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
      children: <Widget>[
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
        SizedBox(
          height: 10,
        ),
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

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
