import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class Wallet extends StatefulWidget {
  PageContext context;

  Wallet({this.context});

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  MyWallet _myWallet;

  @override
  void initState() {
    _loadAccounts().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    IWalletAccountRemote walletAccountService =
        widget.context.site.getService('/wallet/accounts');
    _myWallet = await walletAccountService.getAllAcounts();
  }

  Future<int> _totalPersonCard() async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    return await payChannelRemote.totalPersonCard();
  }

  @override
  Widget build(BuildContext context) {
    if (_myWallet == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('钱包'),
          titleSpacing: 0,
          elevation: 0,
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    }

    var card_header = Container(
      constraints: BoxConstraints.expand(
        height: 100,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 2,
              left: 20,
              right: 20,
            ),
            child: Text(
              '¥${_myWallet?.totalYan ?? '-'}',
              overflow: TextOverflow.visible,
              softWrap: true,
              style: widget.context.style('/wallet/banner/total-value.text'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(),
            child: Text(
              '总资产',
              style: widget.context.style('/wallet/banner/total-label.text'),
            ),
          ),
        ],
      ),
    );

    var card_mymony = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/change', arguments: {
                'wallet': _myWallet,
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      FontAwesomeIcons.yenSign,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '零钱',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text('¥${_myWallet?.changeYan ?? '-'}'),
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
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/fission/mf', arguments: {
                'wallet': _myWallet,
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.share_outlined,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '裂变游戏·交个朋友',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text('¥${_myWallet.fissionMFYan??'-'}'),
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
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/trial', arguments: {
                'wallet': _myWallet,
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.wb_auto,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '体验金',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text('¥${_myWallet?.trialYan ?? '-'}'),
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
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/absorb', arguments: {
                'wallet': _myWallet,
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.blur_linear,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '洇金',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text('¥${_myWallet?.absorbYan ?? '-'}'),
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

          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  widget.context.forward('/wallet/onorder', arguments: {
                'wallet': _myWallet,
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.av_timer,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '在订单',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text('¥${_myWallet?.onorderYan ?? '-'}'),
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
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/cards', arguments: {
                'wallet': _myWallet,
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.credit_card,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '公众卡',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: FutureBuilder<int>(
                                future: _totalPersonCard(),
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return SizedBox(
                                      width: 0,
                                      height: 0,
                                    );
                                  }
                                  var count = snapshot.data ?? 0;
                                  return Text('$count 张');
                                },
                              ),
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
        ],
      ),
    );
    var card_op = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/receivables',arguments: {'wallet':_myWallet}),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      FontAwesomeIcons.sprayCan,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '收款',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(''),
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
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/payables',arguments: {'wallet':_myWallet}),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      FontAwesomeIcons.paypal,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '付款',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(''),
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
          /*
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.context.forward('/wallet/card'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      FontAwesomeIcons.creditCard,
                      size: 30,
                      color:
                          widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '银行卡',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(''),
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

           */
        ],
      ),
    );
    var card_apply = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //申请
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward(
                  '/market/request/landagent',
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      IconData(0xe62d, fontFamily: 'geo_locations'),
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '成为地商',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 40,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward(
                  '/market/request/isp',
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.developer_board,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '成为运营商',
                          style: widget.context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text(
                widget.context.page?.title,
              ),
              titleSpacing: 0,
              elevation: 0.0,
              pinned: true,
              automaticallyImplyLeading: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: card_header,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: card_mymony,
              ),
            ),
//第一阶段暂不实现
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: card_op,
              ),
            ),
            /*
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: card_apply,
              ),
            ),
             ..._renderWenyPanel(),
             */
          ],
        ),
      ),
    );
  }
  /*
  List<Widget> _renderWenyPanel(){
    var items=<Widget>[];
    if (_myWallet?.banks == null || _myWallet?.banks?.isEmpty) {
      return items;
    }
    items.add(SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          left: 15,
          bottom: 2,
          right: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '纹银账户',
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _loadAccounts().then((value) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: 4,
                  right: 2,
                ),
                child: Icon(
                  Icons.refresh,
                  size: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    ),);
    var card_zq = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: _myWallet.banks.map((bank) {
          return WenyItemWidget(
            context: widget.context,
            bank: bank,
          );
        }).toList(),
      ),
    );
    items.add(SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 10,
        ),
        child: card_zq,
      ),
    ),);
    return items;
  }

   */
}

class WenyItemWidget extends StatefulWidget {
  PageContext context;
  WenyBank bank;

  WenyItemWidget({this.context, this.bank});

  @override
  _WenyItemWidgetState createState() => _WenyItemWidgetState();
}

class _WenyItemWidgetState extends State<WenyItemWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(WenyItemWidget oldWidget) {
    if (widget.bank.bank != oldWidget.bank.bank) {
      oldWidget.bank = widget.bank;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var bank = widget.bank;
    var icon = bank.info.icon;
    Widget iconWidget;
    if (StringUtil.isEmpty(icon)) {
      iconWidget = Icon(
        FontAwesomeIcons.image,
        size: 30,
        color: widget.context.style('/profile/list/item-icon.color'),
      );
    } else {
      if (icon.startsWith('/')) {
        iconWidget = Image.file(
          File(icon),
          width: 30,
          height: 30,
        );
      } else {
        iconWidget = FadeInImage.assetNetwork(
          placeholder: 'lib/portals/gbera/images/default_watting.gif',
          image: '$icon?accessToken=${widget.context.principal.accessToken}',
          width: 30,
          height: 30,
        );
      }
    }

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.context.forward('/wallet/weny', arguments: {
              'bank': bank,
            }).then((value) {
              if (mounted) {
                setState(() {});
              }
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
                  child: iconWidget,
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
                                    color: bank.change > 0
                                        ? Colors.red
                                        : bank.change < 0 ? Colors.green : null,
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
                                  '涨跌:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                '${bank.change.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: bank.change > 0
                                      ? Colors.red
                                      : bank.change < 0 ? Colors.green : null,
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
      ],
    );
  }
}
