import 'dart:async';
import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';

class TrialPage extends StatefulWidget {
  PageContext context;

  TrialPage({this.context});

  @override
  _TrialPageState createState() => _TrialPageState();
}

class _TrialPageState extends State<TrialPage> {
  MyWallet _myWallet;
  bool _enableButton = false;
  String _buttonText = '查看明细';
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TrialFundsConfigOR _trialFundsConfig;
  bool _trialOn = false;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _enableButton = _myWallet.absorb.floor() > 0;
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IWalletAccountRemote walletAccountService =
        widget.context.site.getService('/wallet/accounts');
    _trialFundsConfig = await walletAccountService.getTrialConfig();
    _trialOn = _trialFundsConfig.state == 1 ? true : false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var card_main = Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              '我的体验金',
              style: widget.context.style('/wallet/change/mychange.text'),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 3,
                ),
                child: Text(
                  '¥',
                  style: widget.context.style('/wallet/change/money-sign.text'),
                ),
              ),
              Text(
                '${_myWallet?.trialYan ?? '0.00'}',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    var card_actions = Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
          ),
          child: SizedBox(
            width: 160,
            height: 36,
            child: RaisedButton(
              onPressed: !_enableButton
                  ? null
                  : () {
                      widget.context.forward('/wallet/trial/bill', arguments: {
                        'wallet': _myWallet,
                      });
                    },
              textColor:
                  widget.context.style('/wallet/change/deposit.textColor'),
              color: widget.context.style('/wallet/change/deposit.color'),
              highlightColor:
                  widget.context.style('/wallet/change/deposit.highlightColor'),
              child: Text(_buttonText),
            ),
          ),
        ),
      ],
    );

    var bb = widget.context.parameters['back_button'];

    return Scaffold(
      key: _key,
      appBar: AppBar(
//        title: Text(
//          widget.context.page?.title,
//        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              widget.context.forward('/wallet/trial/bill', arguments: {
                'wallet': _myWallet,
              });
            },
            child: Text('明细'),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            !_trialOn
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                      left: 15,
                      right: 15,
                    ),
                    child:  Row(
                      children: [
                        Icon(
                          Icons.run_circle_outlined,
                          size: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '体验金活动已暂停',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),

                          ],
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                      left: 15,
                      right: 15,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.run_circle_outlined,
                          size: 30,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(TextSpan(
                              children: [
                                TextSpan(
                                  text: '正在发放',style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                                ),
                                TextSpan(
                                  text: '体验金',
                                ),
                              ],
                            ), style: TextStyle(
                              fontSize: 12,
                            ),),
                            SizedBox(
                              height: 2,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: '赶快'),
                                  TextSpan(
                                    text: '发码',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap=(){
                                      widget.context.forward('/robot/createSlices').then((value) {
                                      });
                                    },
                                  ),
                                  TextSpan(text: '赚取'),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  card_main,
                  card_actions,
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 5,
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '- 体验金可用于在网流和地圈中发文，发文后即可见到申购单，便可以立即承兑得现金，也可以等待进一步升值再承兑得现金。',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    bottom: 10,
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '- 如想得到更多体验金，可去发码。你的码片每被一个新用户消费掉，则奖励您1元体验金。注意：那些已消费过码片的用户不算数的哦:)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        widget.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
