import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/portals/nodepower/pages/search_person_of_app.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;
import 'package:objectdb/objectdb.dart';
import 'package:uuid/uuid.dart';

import 'weny_robot_absorbers.dart';

class AbsorberDetails extends StatefulWidget {
  PageContext context;

  AbsorberDetails({this.context});

  @override
  _AbsorberDetailsState createState() => _AbsorberDetailsState();
}

class _AbsorberDetailsState extends State<AbsorberDetails> {
  AbsorberResultOR _absorberOR;

  Future<Person> _future_creator;

  @override
  void initState() {
    _absorberOR = widget.context.parameters['absorber'];
    _future_creator =
        _getPerson(widget.context.site, _absorberOR.absorber.creator);
    super.initState();
  }

  @override
  void dispose() {
    _future_creator = null;
    super.dispose();
  }

  Future<void> _updateAbsorberState() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    var absorber = _absorberOR.absorber;
    if (absorber.state == 1) {
      await robotRemote.startAbsorber(absorber.id);
      return;
    }
    if (absorber.state == 0) {
      await robotRemote.stopAbsorber(absorber.id, absorber.exitCause);
      return;
    }
  }

  Future<void> _reloadAbsorber() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    AbsorberResultOR absorberOR =
        await robotRemote.getAbsorber(_absorberOR.absorber.id);
    _absorberOR.updateBy(absorberOR);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var absorber = _absorberOR.absorber;
    var bucket = _absorberOR.bucket;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (cxt, v) {
          return [
            SliverAppBar(
              pinned: true,
              title: Text('${absorber.title}'),
              elevation: 0,
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    widget.context.forward(
                      '/weny/records/invest',
                      arguments: {
                        'absorber': _absorberOR,
                      },
                    );
                  },
                  child: Text('明细'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                child: Container(
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CardItem(
                        title: '类别',
                        tipsText: '${getAbsorberCategory(absorber.category)}',
                        paddingLeft: 20,
                        paddingRight: 20,
                        tail: SizedBox(
                          width: 0,
                          height: 0,
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      CardItem(
                        title: '类型',
                        tipsText: ' ${absorber.type == 1 ? '地理洇取器' : '简单洇取器'}',
                        paddingLeft: 20,
                        paddingRight: 20,
                        tail: absorber.type == 1
                            ? null
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        onItemTap: absorber.type == 0
                            ? null
                            : () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (ctx) {
                                      return widget.context.part(
                                          '/weny/absorber/location', context,
                                          arguments: {'absorber': _absorberOR});
                                    });
                              },
                      ),
                      Divider(
                        height: 1,
                      ),
                      CardItem(
                        title: '指数',
                        tipsText: '${bucket.price.toStringAsFixed(14)}',
                        paddingLeft: 20,
                        paddingRight: 20,
                        tail: SizedBox(
                          width: 0,
                          height: 0,
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      CardItem(
                        title: '创建人',
                        paddingLeft: 20,
                        paddingRight: 20,
                        tail: FutureBuilder<Person>(
                          future: _future_creator,
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Text('-');
                            }
                            var person = snapshot.data;
                            return Text(
                              '${person.nickName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      CardItem(
                        title: '状态',
                        tipsText: '${absorber.state == 1 ? '运行中' : '停用'}',
                        paddingLeft: 20,
                        paddingRight: 20,
                        tail: SizedBox(
                          height: 20,
                          child: Switch.adaptive(
                            value: absorber.state == 1,
                            onChanged: (v) async {
                              if (v) {
                                absorber.state = 1;
                                absorber.exitCause = null;
                              } else {
                                absorber.state = 0;
                                absorber.exitCause = '地商强制关停';
                              }
                              await _updateAbsorberState();
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      absorber.state == 1
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : CardItem(
                              title: '停用原因',
                              tipsText: '${absorber.exitCause ?? '-'}',
                              paddingLeft: 40,
                              paddingRight: 20,
                              tail: SizedBox(
                                width: 0,
                                height: 0,
                              ),
                            ),
                      Divider(
                        height: 1,
                      ),
                      Container(
                        color: Colors.white,
                        child: CardItem(
                          title: '更多',
                          paddingRight: 20,
                          paddingLeft: 20,
                          onItemTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) {
                                return widget.context.part(
                                    '/weny/robot/absorbers/details/more',
                                    context,
                                    arguments: {'absorber': _absorberOR});
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _DemoHeader(
                height: 55,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: '洇取人',
                              children: [],
                            ),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return _InvestPopupWidget(
                                        context: widget.context,
                                        absorberOR: _absorberOR,
                                      );
                                    },
                                  ).then((value) {
                                    if (value != null) {
                                      _reloadAbsorber();
                                    }
                                  });
                                },
                                child: Text(
                                  '投资',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15,right: 15,),
                      child: Row(
                        children: [
                          Text(
                            '¥${((bucket.pInvestAmount + bucket.wInvestAmount) / 100.00).toStringAsFixed(14)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '=',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '¥${((bucket.pInvestAmount) / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '+',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '¥${((bucket.wInvestAmount) / 100.00).toStringAsFixed(14)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: absorber.type == 1
              ? _GeoAbsorberRecipients(
                  context: widget.context,
                  absorberOR: _absorberOR,
                )
              : _SimpleAbsorberRecipients(
                  context: widget.context,
                  absorberOR: _absorberOR,
                ),
        ),
      ),
    );
  }
}

class _GeoAbsorberRecipients extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberOR;

  _GeoAbsorberRecipients({this.context, this.absorberOR});

  @override
  __GeoAbsorberRecipientsState createState() => __GeoAbsorberRecipientsState();
}

class __GeoAbsorberRecipientsState extends State<_GeoAbsorberRecipients> {
  AbsorberResultOR _absorberOR;
  EasyRefreshController _controller;
  List<RecipientsOR> _recipients = [];
  int _limit = 40, _offset = 0;

  @override
  void initState() {
    _absorberOR = widget.absorberOR;
    _controller = EasyRefreshController();
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_GeoAbsorberRecipients oldWidget) {
    if (oldWidget.absorberOR.absorber.id != widget.absorberOR.absorber.id) {
      widget.absorberOR = oldWidget.absorberOR;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onRefresh() async {
    _recipients.clear();
    _offset = 0;
    await _onLoad();
  }

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    List<RecipientsOR> recipients = await robotRemote.pageRecipients(
        _absorberOR.absorber.id, _limit, _offset);
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
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    return await robotRemote.totalRecipientsRecordById(recipientsId);
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_recipients.isEmpty) {
      items.add(
        Center(
          child: Text('没有成员'),
        ),
      );
    }
    for (var item in _recipients) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/weny/recipients/records/geo',
                arguments: {'recipients': item, 'absorber': _absorberOR});
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
                                  _absorberOR.absorber.type == 0
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

class _SimpleAbsorberRecipients extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberOR;

  _SimpleAbsorberRecipients({this.context, this.absorberOR});

  @override
  __SimpleAbsorberRecipientsState createState() =>
      __SimpleAbsorberRecipientsState();
}

class __SimpleAbsorberRecipientsState extends State<_SimpleAbsorberRecipients> {
  AbsorberResultOR _absorberOR;
  EasyRefreshController _controller;
  List<RecipientsSummaryOR> _recipients = [];
  int _limit = 40, _offset = 0;

  @override
  void initState() {
    _absorberOR = widget.absorberOR;
    _controller = EasyRefreshController();
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SimpleAbsorberRecipients oldWidget) {
    if (oldWidget.absorberOR.absorber.id != widget.absorberOR.absorber.id) {
      widget.absorberOR = oldWidget.absorberOR;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onRefresh() async {
    _recipients.clear();
    _offset = 0;
    await _onLoad();
  }

  Future<void> _onLoad() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    List<RecipientsSummaryOR> recipients = await robotRemote
        .pageSimpleRecipients(_absorberOR.absorber.id, _limit, _offset);
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

  Future<double> _totalRecipientsRecord(String absorber, person) async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    return await robotRemote.totalRecipientsRecord(absorber, person);
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_recipients.isEmpty) {
      items.add(
        Center(
          child: Text('没有成员'),
        ),
      );
    }
    for (var item in _recipients) {
      items.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.context.forward('/weny/recipients/records/simple',
              arguments: {'recipients': item, 'absorber': _absorberOR});
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
                              future:
                                  _getPerson(widget.context.site, item.person),
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
                                Text(
                                  '激励原因: ${item.encourageCauses ?? ''}',
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
                            '${item.weights.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: _totalRecipientsRecord(
                                item.absorber, item.person),
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
                                return Text(
                                  '¥0.00',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                              return Text(
                                '¥${(v / 100.0).toStringAsFixed(14)}',
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
      ));
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

class _DemoHeader extends SliverPersistentHeaderDelegate {
  PreferredSize preferredSize;

  _DemoHeader({Widget child, double height}) {
    preferredSize = PreferredSize(
      child: child,
      preferredSize: Size.fromHeight(
        height,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: preferredSize,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return preferredSize.preferredSize.height;
  } // 最大高度

  @override
  double get minExtent => preferredSize.preferredSize.height; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}

class _InvestPopupWidget extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberOR;

  _InvestPopupWidget({this.context, this.absorberOR});

  @override
  __InvestPopupWidgetState createState() => __InvestPopupWidgetState();
}

class __InvestPopupWidgetState extends State<_InvestPopupWidget> {
  bool _enableInvestSaveButton = false;
  TextEditingController _amountText;

  @override
  void initState() {
    _amountText = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _amountText?.dispose();
    super.dispose();
  }

  Future<void> _investAbsorber() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    double amount = double.parse(_amountText.text);
    await robotRemote.investAbsorber(
      (amount * 100).floor(),
      1,
      <String, dynamic>{
        "payeeCode": "${widget.absorberOR.absorber.id}",
        "payeeName": "${widget.absorberOR.absorber.title}",
        "payeeType": "absorber",
        "orderno": "${new Uuid().v1()}",
        "orderTitle": "地商派发",
        "serviceid": "la.netos",
        "serviceName": "地商系统",
        "note": "欢迎惠顾"
      },
      '地商派发',
    );
    widget.context.backward(result: {'succeed': true});
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('投资'),
      elevation: 0,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: '输入金额，单位元',
                hintStyle: TextStyle(
                  fontSize: 12,
                ),
              ),
              controller: _amountText,
              onChanged: (v) {
                if (!StringUtil.isEmpty(v)) {
                  int pos = v.indexOf('.');
                  if (pos < 0) {
                    _enableInvestSaveButton = true;
                  } else {
                    var tails = v.substring(pos + 1);
                    if (tails.length == 2) {
                      _enableInvestSaveButton = true;
                    } else {
                      _enableInvestSaveButton = false;
                    }
                  }
                } else {
                  _enableInvestSaveButton = false;
                }
                setState(() {});
              },
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: FlatButton(
            child: Text('保存'),
            onPressed: !_enableInvestSaveButton
                ? null
                : () {
                    _enableInvestSaveButton = false;
                    setState(() {});
                    _investAbsorber();
                  },
            disabledTextColor: Colors.grey[300],
            disabledColor: Colors.grey[200],
            color: Colors.green,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
