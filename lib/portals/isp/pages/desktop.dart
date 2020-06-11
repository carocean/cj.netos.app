import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class IspDesktop extends StatefulWidget {
  PageContext context;

  IspDesktop({this.context});

  @override
  _IspDesktopState createState() => _IspDesktopState();
}

class _IspDesktopState extends State<IspDesktop>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List<_TabPageView> tabPageViews;

  @override
  void initState() {
    this.tabPageViews = [
      _TabPageView(
        title: '直营',
        view: _BankList(context: widget.context,),
      ),
      _TabPageView(
        title: '地商',
        view: _BankList(context: widget.context,),
      ),
    ];
    this.tabController =
        TabController(length: tabPageViews.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, s) {
        return [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            title: Text(
              '运营商(ISP)',
            ),
            actions: <Widget>[
              PopupMenuButton(
                onSelected: (String value) {
                  switch(value) {
                    case 'logout':
                      widget.context.forward('/public/login', scene: '/');
                      break;
                  }
                },

//                  padding: EdgeInsets.all(10),
                offset: Offset(0, 40),
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  PopupMenuItem(
                    value: "logout",
                    child: new Text("退出系统"),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 30,
                right: 40,
                top: 20,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Image.network(
                          'http://47.105.165.186:7100/app/chatroom/39ef96a0-7d9a-11ea-f435-4118afc463ec.jpg?accessToken=${widget.context.principal.accessToken}',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 2,
                          children: <Widget>[
                            Text(
                              '郑州福源集团',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: '分账余额:',
                                children: [
                                  TextSpan(text: '¥28383.23'),
                                ],
                              ),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _OperatorEvent(
                  eventLeading: Icon(
                    Icons.widgets,
                    size: 20,
                  ),
                  eventDetails: '通讯纹银市场已审批通过！',
                  eventName: '平台通知',
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return widget.context.part('/event/details', context);
                        });
                  },
                ),
                _OperatorEvent(
                  eventLeading: Icon(
                    Icons.widgets,
                    size: 20,
                  ),
                  eventDetails: '本周财报',
                  eventName: '运营商通知',
                ),
                _OperatorEvent(
                  eventLeading: Icon(
                    Icons.widgets,
                    size: 20,
                  ),
                  eventDetails: '平台理财新知识！',
                  eventName: '节点动力培训学院',
                  isBottom: true,
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBar(
              child: TabBar(
                labelColor: Colors.black,
                controller: this.tabController,
                tabs: tabPageViews.map((v) {
                  return Tab(
                    text: v.title,
                  );
                }).toList(),
              ),
              color: Colors.white,
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: this.tabController,
        children: tabPageViews.map((v) {
          if (v.view == null) {
            return Container(
              width: 0,
              height: 0,
            );
          }
          return v.view;
        }).toList(),
      ),
    );
  }
}

class _TabBar extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final Color color;

  _TabBar({@required this.child, @required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: this.child,
      color: color,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}

class _TabPageView {
  String title;
  Widget view;

  _TabPageView({
    this.title,
    this.view,
  });
}

class _OperatorEvent extends StatelessWidget {
  String eventName;
  String eventDetails;
  Widget eventLeading;
  bool isBottom;
  Function() onTap;

  _OperatorEvent({
    this.eventName,
    this.eventDetails,
    this.eventLeading,
    this.isBottom = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                  child: eventLeading,
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 4,
                          children: <Widget>[
                            Text(
                              eventName ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              eventDetails ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: isBottom
                  ? SizedBox(
                width: 0,
                height: 0,
              )
                  : Divider(
                height: 1,
                indent: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankList extends StatefulWidget {
  PageContext context;

  _BankList({this.context});

  @override
  __BankListState createState() => __BankListState();
}

class __BankListState extends State<_BankList> {
  EasyRefreshController _controller;
  @override
  void initState() {
    _controller=EasyRefreshController();
    super.initState();
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  Future<void> _onLoad()async{}
  @override
  Widget build(BuildContext context) {
    return  Container(
      constraints: BoxConstraints.expand(),
      color: Colors.white,
      child: EasyRefresh(
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
                  property: 0,
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
                  property: 0,
                  creator: 'cj@gbera.netos',
                ),
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
              onTap: () => this.context.forward('/wallet/weny', arguments: {
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
                                  width: 35,
                                  padding: EdgeInsets.only(
                                    right: 4,
                                  ),
                                  child: Text(
                                    '买入:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₩${bank.stock}',
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

