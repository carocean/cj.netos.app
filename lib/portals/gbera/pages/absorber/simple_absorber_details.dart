import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class SimpleAbsorberDetailsPage extends StatefulWidget {
  PageContext context;

  SimpleAbsorberDetailsPage({this.context});

  @override
  _AbsorberDetailsState createState() => _AbsorberDetailsState();
}

class _AbsorberDetailsState extends State<SimpleAbsorberDetailsPage> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  Stream _stream;
  StreamSubscription _streamSubscription;
  int _recipientsCount = 0;
  StreamController _reloadRecipientsController;

  @override
  void initState() {
    _stream = widget.context.parameters['stream'];
    _absorberResultOR = widget.context.parameters['initAbsorber'];
    _bulletin = widget.context.parameters['initBulletin'];
    _reloadRecipientsController = StreamController.broadcast();
    _streamSubscription = _stream.listen((event) {
      _absorberResultOR = event['absorber'];
      _bulletin = event['bulletin'];
      if (mounted) {
        setState(() {});
      }
    });
    () async {
      IRobotRemote robotRemote =
          widget.context.site.getService('/remote/robot');
      _recipientsCount =
          await robotRemote.countRecipients(_absorberResultOR.absorber.id);
    }();
    super.initState();
  }

  @override
  void dispose() {
    _reloadRecipientsController?.close();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _addRecipients(List<String> persons) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');

    for (var person in persons) {
      var exists = await robotRemote.existsRecipients(
          _absorberResultOR.absorber.id, person);
      if (exists) {
        continue;
      }
      var p = await _getPerson(widget.context.site, person);
      await robotRemote.addRecipients2(_absorberResultOR.absorber.id, person,
          p.nickName, 'pull-in', '管道主拉入', 0);
    }
    _reloadRecipientsController.add({});
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
                  child: Text('谁喂过我?'),
                ),
              ],
//              backgroundColor: Colors.white,
            ),
            SliverToBoxAdapter(
              child: _HeaderCard(
                context: widget.context,
                stream: _stream.asBroadcastStream(),
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
                    child: _DashBoard(
                      stream: _stream.asBroadcastStream(),
                      absorberResultOR: _absorberResultOR,
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
                : SliverPersistentHeader(
                    pinned: true,
                    delegate: _DemoHeader(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 4,
                        ),
                        height: 33,
                        color: Theme.of(context).backgroundColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '成员',
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
                                '$_recipientsCount个',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _absorberResultOR.absorber.creator !=
                                        widget.context.principal.person
                                    ? SizedBox(
                                        height: 0,
                                        width: 0,
                                      )
                                    : GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          widget.context.forward(
                                              '/absorber/details/selectRecipients',
                                              arguments: {
                                                'personViewer': 'chasechain',
                                                'action': 'select'
                                              }).then((value) {
                                            if (value == null) {
                                              return;
                                            }
                                            _addRecipients(value);
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                            right: 0,
                                            top: 3,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.person_add,
                                                size: 16,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(
                                                width: 0,
                                              ),
                                              Text(
                                                '加喵',
                                                style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 12,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
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
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          IconData(
                                            0xe6b2,
                                            fontFamily: 'absorber',
                                          ),
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(
                                          width: 0,
                                        ),
                                        Text(
                                          '喂喵',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
            stream: _stream.asBroadcastStream(),
            refreshRecipients:
                _reloadRecipientsController.stream.asBroadcastStream(),
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
  String _address;

  @override
  void initState() {
    _absorberResultOR = widget.context.parameters['initAbsorber'];
    _bulletin = widget.context.parameters['initBulletin'];
    _streamSubscription = widget.stream.listen((event) async {
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return widget.context.part(
                            '/absorber/settings/simple',
                            context,
                            arguments: {
                              'absorber': _absorberResultOR,
                            },
                          );
                        });
                  },
                  child: Text(
                    '${_absorberResultOR.absorber.title ?? ''}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text(
                      '${_absorberResultOR.absorber.state == 1 ? '运行中' : '已关停'}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
  Stream refreshRecipients;

  _GeoRecipientsCard({
    this.context,
    this.stream,
    this.refreshRecipients,
  });

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
  StreamSubscription _refreshRecipientsSubscription;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _absorberResultOR = widget.context.parameters['initAbsorber'];
    _bulletin = widget.context.parameters['initBulletin'];
    _onLoad().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    _streamSubscription = widget.stream.listen((event) async {
      _absorberResultOR = event['absorber'];
      _bulletin = event['bulletin'];
      await _onRefresh();
    });
    _refreshRecipientsSubscription = widget.refreshRecipients.listen((event) {
      _onRefresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshRecipientsSubscription?.cancel();
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

  Future<double> _totalRecipientsRecordWhere(String recipientsId) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.totalRecipientsRecordWhere(
        _absorberResultOR.absorber.id, recipientsId);
  }

  Future<void> _removeRecipients(RecipientsOR recipientsOR) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    await robotRemote.removeRecipients(
        recipientsOR.absorber, recipientsOR.person);
    for (var i = 0; i < _recipients.length; i++) {
      var o = _recipients[i];
      if (o.id == recipientsOR.id) {
        _recipients.removeAt(i);
        if (mounted) {
          setState(() {});
        }
        break;
      }
    }
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
            widget.context.forward('/absorber/recipient/view',
                arguments: {'recipients': item, 'absorber': _absorberResultOR});
          },
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '移除',
                foregroundColor: Colors.grey[500],
                icon: Icons.delete,
                onTap: () async {
                  _removeRecipients(item);
                },
              ),
            ],
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
//                                  Text(
//                                    '${item.person}',
//                                    style: TextStyle(
//                                      fontSize: 12,
//                                    ),
//                                  ),
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
                                        color: Colors.grey,
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
                                future: _totalRecipientsRecordWhere(item.id),
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
        "serviceid": "netflow",
        "serviceName": "网流",
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

class _DashBoard extends StatefulWidget {
  AbsorberResultOR absorberResultOR;
  Stream stream;

  _DashBoard({this.absorberResultOR, this.stream});

  @override
  __DashBoardState createState() => __DashBoardState();
}

class __DashBoardState extends State<_DashBoard> {
  StreamSubscription _streamSubscription;
  AbsorberResultOR _absorberResultOR;

  @override
  void initState() {
    _streamSubscription = widget.stream.listen((event) async {
      var absorberResultOR = event['absorber'];
      if (mounted &&
          (_absorberResultOR == null ||
              _absorberResultOR.bucket.price !=
                  absorberResultOR.bucket.price)) {
        _absorberResultOR = absorberResultOR;
        if (mounted) {
          setState(() {});
        }
        return;
      }
      _absorberResultOR = absorberResultOR;
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
    Widget content;
    if (_absorberResultOR == null) {
      _absorberResultOR = widget.absorberResultOR;
    }
    if (_absorberResultOR == null) {
      content = Center(
        child: Text('-'),
      );
    } else {
      content = Stack(
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
                      '¥${(_absorberResultOR.bucket.wInvestAmount / 100.00).toStringAsFixed(14)}',
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
      );
    }
    return Container(
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
      child: content,
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

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;
  double height = 33.0;

  _DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  } // 头部展示内容

  @override
  double get maxExtent {
    return height;
  } // 最大高度

  @override
  double get minExtent => height; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      false; // 因为所有的内容都是固定的，所以不需要更新
}
