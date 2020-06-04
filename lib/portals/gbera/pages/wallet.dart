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
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
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
              onTap: () => widget.context.forward('/wallet/absorb'),
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
              onTap: () => widget.context.forward('/wallet/onorder'),
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
              onTap: () => widget.context.forward('/wallet/receivables'),
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
              onTap: () => widget.context.forward('/wallet/payables'),
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
        ],
      ),
    );
    var card_zq;
    if (_myWallet?.banks == null) {
      card_zq = Container(
        width: 0,
        height: 0,
      );
    } else {
      card_zq = Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: _myWallet.banks.map((bank) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        widget.context.forward('/wallet/weny', arguments: {
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
                            color: widget.context
                                .style('/profile/list/item-icon.color'),
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
              ],
            );
          }).toList(),
        ),
      );
    }
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[
            SliverAppBar(
              title: Text(
                widget.context.page?.title,
              ),
              titleSpacing: 0,
              elevation: 0.0,
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
//            SliverToBoxAdapter(
//              child: Padding(
//                padding: EdgeInsets.only(
//                  bottom: 10,
//                ),
//                child: card_op,
//              ),
//            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  bottom: 2,
                ),
                child: Text(
                  '纹银账户',
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: card_zq,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
