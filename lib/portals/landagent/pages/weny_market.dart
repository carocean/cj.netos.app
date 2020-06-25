import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

class WenyMarket extends StatefulWidget {
  PageContext context;

  WenyMarket({this.context});

  @override
  _WenyMarketState createState() => _WenyMarketState();
}

class _WenyMarketState extends State<WenyMarket> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<BankInfo> _banks = [];
  StreamController _streamController;
  Timer _timer;
  bool _isFetching = false;
  int _laAmount = -1;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _streamController = StreamController.broadcast();
    _onLoad().then((value) {
      _timer = Timer.periodic(
          Duration(
            seconds: 5,
          ), (timer) {
        _updateManager();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _streamController?.close();
    super.dispose();
  }

  Future<void> _updateManager() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    _laAmount = 0;
    IWyBankRemote bankRemote = widget.context.site.getService('/wybank/remote');
    IWyBankRemote wyBankRemote =
        widget.context.site.getService('/wybank/remote');
    for (var bank in _banks) {
      BusinessBuckets businessBuckets =
          await bankRemote.getBusinessBucketsOfBank(bank.id);
      ShuntBuckets shuntBuckets =
          await bankRemote.getShuntBucketsOfBank(bank.id);
      BulletinBoard bulletinBoard =
          await wyBankRemote.getBulletinBoard(bank.id, DateTime.now());

      _streamController.add({
        'bank': bank,
        'businessBuckets': businessBuckets,
        'shuntBuckets': shuntBuckets,
        'board': bulletinBoard
      });
      _laAmount += shuntBuckets.laAmount;
    }
    if (mounted) {
      setState(() {});
    }
    _isFetching = false;
  }

  Future<void> _onLoad() async {
    IWyBankRemote bankRemote = widget.context.site.getService('/wybank/remote');
    List<BankInfo> banks = await bankRemote.pageWyBankOnUser(_limit, _offset);
    if (banks.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
    }
    _offset += banks.length;
    _banks.addAll(banks);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            title: Text(
              '纹银市场',
            ),
            actions: <Widget>[],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _DemoHeader(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: 20,
                      ),
                      child: Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        runSpacing: 5,
                        children: <Widget>[
                          Text(
                            '账金余额',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            _laAmount < 0
                                ? '-'
                                : '¥${(_laAmount / 100).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ];
      },
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: EasyRefresh(
          controller: _controller,
          onLoad: _onLoad,
          child: ListView(
            padding: EdgeInsets.all(0),
            children: _banks.map((bank) {
              return _WenyBank(
                context: widget.context,
                bank: bank,
                isBottom: false,
                stream: _streamController.stream,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _WenyBank extends StatefulWidget {
  PageContext context;
  BankInfo bank;
  bool isBottom;
  Stream stream;

  _WenyBank({
    this.context,
    this.bank,
    this.isBottom = false,
    this.stream,
  });

  @override
  __WenyBankState createState() => __WenyBankState();
}

class __WenyBankState extends State<_WenyBank> {
  StreamSubscription _streamSubscription;
  BusinessBuckets _businessBuckets;
  ShuntBuckets _shuntBuckets;
  BulletinBoard _bulletinBoard;

  Color _changeColor;

  @override
  void initState() {
    _streamSubscription = widget.stream.listen((event) {
      BankInfo bank = event['bank'];
      if (bank.id != widget.bank.id) {
        return;
      }
      _businessBuckets = event['businessBuckets'];
      _shuntBuckets = event['shuntBuckets'];
      _bulletinBoard = event['board'];
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
  void didUpdateWidget(_WenyBank oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bank.id != widget.bank.id ||
        oldWidget.isBottom != widget.isBottom) {
      oldWidget.bank = widget.bank;
      oldWidget.isBottom = widget.isBottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wenybank', arguments: {
                'bank': widget.bank,
                'stream': widget.stream.asBroadcastStream(),
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder:
                          'lib/portals/gbera/images/default_watting.gif',
                      image:
                          '${widget.bank.icon}?accessToken=${widget.context.principal.accessToken}',
                      width: 30,
                      height: 30,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${widget.bank.title}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 35,
                                      padding: EdgeInsets.only(
                                        right: 4,
                                      ),
                                      child: Text(
                                        '现价:',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '¥${_businessBuckets?.price ?? '0.00'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 35,
                                    padding: EdgeInsets.only(
                                      right: 4,
                                    ),
                                    child: Text(
                                      '涨跌:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_getChange().toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _changeColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                  '¥${((_shuntBuckets?.laAmount ?? 0) / 100).toStringAsFixed(2)}'),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.isBottom
              ? SizedBox(
                  width: 0,
                  height: 0,
                )
              : Divider(
                  height: 1,
                ),
        ],
      ),
    );
  }

  double _getChange() {
    if (_bulletinBoard == null || _businessBuckets == null) {
      return 0.0;
    }
    double value = ((_businessBuckets.price - _bulletinBoard.closePrice) /
            _bulletinBoard.closePrice) *
        100.00;
    if (value > 0) {
      _changeColor = Colors.red;
    } else if (value == 0) {
      _changeColor = null;
    } else {
      _changeColor = Colors.green;
    }
    return value;
  }
}

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;

  _DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: child,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return 90;
  } // 最大高度

  @override
  double get minExtent => 70; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}
