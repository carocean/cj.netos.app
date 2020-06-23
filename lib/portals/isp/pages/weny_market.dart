import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class WenyMarket extends StatefulWidget {
  PageContext context;

  WenyMarket({this.context});

  @override
  _WenyMarketState createState() => _WenyMarketState();
}

class _WenyMarketState extends State<WenyMarket> {
  EasyRefreshController _controller;
  int _index_panel = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onLoad() async {}

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
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: 30,
                bottom: 30,
              ),
              alignment: Alignment.center,
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
                    '¥20293.23',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _DemoHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                            left: 5,
                            bottom: 6,
                          ),
                          child: Icon(
                            FontAwesomeIcons.wonSign,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_index_panel == 0) {
                                    return;
                                  }
                                  _index_panel=0;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  color:_index_panel!=0?null: Colors.white,
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    '直营',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:_index_panel!=0?null: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_index_panel == 1) {
                                    return;
                                  }
                                  _index_panel=1;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  color: _index_panel!=1?null:Colors.white,
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    '伙伴',
                                    style: TextStyle(
                                      color: _index_panel!=1?null:Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          ),
        ];
      },
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: IndexedStack(
          index: _index_panel,
          children: <Widget>[
            EasyRefresh(
              controller: _controller,
              onLoad: _onLoad,
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  _WenyBank(
                    context: widget.context,
                    bank: WenyBank(
                      bank: 'xxxxx',
                      stock: 2388382.3332238883,
                      freezen: 2303,
                      profit: 23983,
                      price: 0.00233248848484,
                      info: BankInfo(
                        title: '农业发展',
                        ctime: '20200603122816333',
                        id: 'xxxx',
                        state: 1,
                        icon: '',
                        creator: 'cj@gbera.netos',
                      ),
                    ),
                  ),
                  _WenyBank(
                    context: widget.context,
                    bank: WenyBank(
                      bank: 'xxxxx',
                      stock: 2388382.3332238883,
                      freezen: 2303,
                      profit: 23983,
                      price: 0.00233248848484,
                      info: BankInfo(
                        title: '农业发展',
                        ctime: '20200603122816333',
                        id: 'xxxx',
                        state: 1,
                        icon: '',
                        creator: 'cj@gbera.netos',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            EasyRefresh(
              controller: _controller,
              onLoad: _onLoad,
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  _WenyBank(
                    context: widget.context,
                    bank: WenyBank(
                      bank: 'xxxxx',
                      stock: 2388382.3332238883,
                      freezen: 2303,
                      profit: 23983,
                      price: 0.00233248848484,
                      info: BankInfo(
                        title: '农业发展',
                        ctime: '20200603122816333',
                        id: 'xxxx',
                        state: 1,
                        icon: '',
                        creator: 'cj@gbera.netos',
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
  }
}

class _WenyBank extends StatelessWidget {
  PageContext context;
  WenyBank bank;
  bool isBottom;

  _WenyBank({this.context, this.bank, this.isBottom = false});

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
              onTap: () => this.context.forward('/wenybank', arguments: {
                'bank': bank,
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
                    child: Icon(
                      FontAwesomeIcons.image,
                      size: 30,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${bank.info.title}',
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
                                    '¥${bank.price}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  padding: EdgeInsets.only(
                                    right: 4,
                                  ),
                                  child: Text(
                                    '日申购:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥299288.23',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                  '¥${(bank.stock * bank.price / 100.0).toStringAsFixed(2)}'),
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
          isBottom
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
}

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;
  double height = 30;

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
    return height;
  } // 最大高度

  @override
  double get minExtent => height; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}
