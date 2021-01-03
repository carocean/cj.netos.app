import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Payables extends StatefulWidget {
  PageContext context;

  Payables({this.context});

  @override
  _PayablesState createState() => _PayablesState();
}

class _PayablesState extends State<Payables> {
  var qrcodeKey = GlobalKey();
  List<PayChannel> _payChannels = [];
  PayChannel _selectedChannel;
  Map<String, dynamic> _qrcodeData;
  _PayerInfo __payerInfo;
  MyWallet _myWallet;
  Timer _timer;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _qrcodeData = {
      'itis': 'wallet.payables',
      'data': null,
    };
    _setQrcode();
    _loadPayChannels();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _setQrcode() async {
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    String evidence = await tradeRemote.genPayableEvidence(1 * 60 * 1000, 1);
    this.__payerInfo = _PayerInfo(
      evidence: evidence,
    );
    this._qrcodeData['data'] = jsonEncode(__payerInfo.toMap());
    if (mounted) {
      setState(() {});
    }
    await _watchAction(evidence);
  }

  Future<void> _watchAction(evidence) async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var record = await recordRemote.getP2PRecordByEvidence(evidence);
      if (record != null && record.state == 1) {
        //已完成，但不一定正确
        _timer.cancel();
        if (mounted) {
          widget.context.forward(
            '/wallet/p2p/details',
            arguments: {'p2p': record, 'wallet': _myWallet},
          );
        }
      }
    });
  }

  _loadPayChannels() async {
    _payChannels.add(
      PayChannel(
        code: 'gberaPay',
        name: '零钱',
        note: '节点动力钱包',
      ),
    );
    _payChannels.add(
      PayChannel(
        code: 'alipay',
        name: '支付宝',
        note: '',
      ),
    );
    _payChannels.add(
      PayChannel(
        code: 'wechat',
        name: '微信',
        note: '',
      ),
    );
    _selectedChannel = _payChannels[0];
  }

  @override
  Widget build(BuildContext context) {
    var pay_method = Container(
      padding: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                  child: Image.asset(
                    'lib/portals/gbera/images/gbera_op.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: Text(
                        '${_selectedChannel?.name ?? ''}',
                        style: widget.context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '付款到对方零钱',
              style: widget.context
                  .style('/wallet/change/deposit/method/arrow-label.text'),
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   mainAxisSize: MainAxisSize.min,
            //   children: <Widget>[
            //     Padding(
            //       padding: EdgeInsets.only(
            //         right: 5,
            //       ),
            //       child: Text(
            //         '其它付款方式',
            //         style: widget.context.style(
            //             '/wallet/change/deposit/method/arrow-label.text'),
            //       ),
            //     ),
            //     Icon(
            //       Icons.keyboard_arrow_right,
            //       size: 20,
            //       color: widget.context
            //           .style('/wallet/change/deposit/method/arrow.icon'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );

    var card_head = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: Row(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  Icons.monetization_on,
                  size: 14,
                  color: Colors.grey[500],
                ),
              ),
              Text('二维码付款'),
            ],
          ),
        ],
      ),
    );
    var card_body = Container(
      constraints: BoxConstraints.expand(),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 20,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
                top: 20,
              ),
              child: Text(
                '让他人扫一扫，付款给他人',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: RepaintBoundary(
                key: qrcodeKey,
                child: QrImage(
                  ///二维码数据
                  data: jsonEncode(_qrcodeData),
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  embeddedImage:
                      FileImage(File(widget.context.principal.avatarOnLocal)),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(40, 40),
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                    context: context, builder: _builderModalBottomSheet);
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: 15,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: pay_method,
              ),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            card_head,
            Expanded(
              child: _selectedChannel == null
                  ? Center(
                      child: Text('加载中...'),
                    )
                  : card_body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _builderModalBottomSheet(BuildContext context) {
    var item_change = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Image.asset(
                    'lib/portals/gbera/images/gbera_op.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: Text(
                        '零钱',
                        style: widget.context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var item_alipay = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.alipay,
                    size: 25,
                    color: Colors.blueAccent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: Text(
                        '支付宝',
                        style: widget.context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var item_weixin = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.weixin,
                    size: 25,
                    color: Colors.green,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: Text(
                        '微信',
                        style: widget.context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var item_goPayMethod = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Icon(
                    FontAwesomeIcons.paypal,
                    size: 25,
                    color: Colors.redAccent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        '添加付款方式',
                        style: widget.context
                            .style('/wallet/change/deposit/method/title.text'),
                      ),
                    ),
                    Text(
                      '银行卡、交通卡、比特币等',
                      style: widget.context
                          .style('/wallet/change/deposit/method/subtitle.text'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 5,
              bottom: 15,
            ),
            child: Center(
              child: Text(
                '选择付款方式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
          item_change,
          Divider(
            height: 1,
          ),
          item_alipay,
          Divider(
            height: 1,
            indent: 40,
          ),
          item_weixin,
          Divider(
            height: 1,
            indent: 40,
          ),
          item_goPayMethod,
        ],
      ),
    );
  }
}

class _PayerInfo {
  String evidence; //付款凭证
  String note;

  _PayerInfo({this.evidence, this.note}); //备注

  Map toMap() {
    return {
      'evidence': evidence,
      'type': 1,
      'note': note,
    };
  }
}

void registerQrcodeAction(PageContext context) {
  if (!qrcodeScanner.actions.containsKey('wallet.payables')) {
    qrcodeScanner.actions['wallet.payables'] = QrcodeAction(
      doit: (info) async {
        IWalletTradeRemote tradeRemote =
            context.site.getService('/wallet/trades');
        try {
          if (info.props['amount'] == null || info.props['amount'] == 0) {
            throw FlutterError('未输入正确的金额');
          }
          await tradeRemote.receiveFromEvidence(info.props['evidence'],
              info.props['amount'], info.props['type'], info.props['note']);

          WidgetsBinding.instance.addPostFrameCallback((d) {
            context.forward(
              '/payables/result',
              arguments: {'evidence': info.props['evidence']},
            );
          });
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((d) {
            context.forward(
              '/payables/result',
              arguments: {
                'status': 500,
                'message': e,
                'evidence': info.props['evidence']
              },
            );
          });
        }
      },
      parse: (itis, data) async {
        Map<String, dynamic> props = jsonDecode(data);
        IWalletTradeRemote tradeRemote =
            context.site.getService('/wallet/trades');
        P2PEvidence evidence;
        try {
          evidence = await tradeRemote.checkEvidence(props['evidence']);
        } catch (e) {
          return QrcodeInfo(
            title: '收款自',
            isHidenNoButton: false,
            isHidenYesButton: true,
            itis: 'wallet.payables',
            props: props,
            tips: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text('验证付款凭证异常:$e'),
                  ),
                ],
              ),
            ),
          );
        }
        if (evidence == null) {
          return QrcodeInfo(
            title: '收款自',
            isHidenNoButton: false,
            isHidenYesButton: true,
            itis: 'wallet.payables',
            props: props,
            tips: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text('系统未发现该收款凭证'),
                  ),
                ],
              ),
            ),
          );
        }
        var person = await _getPerson(context.site, evidence.principal);
        var avatar = person.avatar;
        var img;
        if (StringUtil.isEmpty(avatar)) {
          img = Image.asset('lib/portals/gbera/images/default_avatar.png');
        } else {
          if (avatar.startsWith('/')) {
            img = Image.file(File(avatar));
          } else {
            img = FadeInImage.assetNetwork(
              placeholder: 'lib/portals/gbera/images/default_watting.gif',
              image: '${avatar}?accessToken=${context.principal.accessToken}',
            );
          }
        }

        return QrcodeInfo(
          title: '收款自',
          isHidenNoButton: false,
          isHidenYesButton: false,
          itis: 'wallet.payables',
          props: props,
          tips: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: img,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${person.nickName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
                        decoration: InputDecoration(
                          hintText: '输入金额,单位元。如:2.35',
                          hintStyle: TextStyle(
                            fontSize: 12,
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        onChanged: (v) {
                          double amount = 0.00;
                          if (!StringUtil.isEmpty(v)) {
                            amount = double.parse(v);
                          }
                          props['amount'] = (amount * 100).floor();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}

class PayableResultPage extends StatefulWidget {
  PageContext context;

  PayableResultPage({
    this.context,
  });

  @override
  _PayableResultPageState createState() => _PayableResultPageState();
}

class _PayableResultPageState extends State<PayableResultPage> {
  bool _isProcessing = true;
  String message;
  int status;
  Timer _timer;

  @override
  void initState() {
    var evidence = widget.context.parameters['evidence'];
    var message = widget.context.parameters['message'];
    message = message ?? 'ok';
    var status = widget.context.parameters['status'];
    status = status ?? 200;
    _watchAction(evidence);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _watchAction(evidence) async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var record = await recordRemote.getP2PRecordByEvidence(evidence);
      if (record != null && record.state == 1) {
        //已完成，但不一定正确
        _timer.cancel();
        message = record.message;
        status = record.status;
        _isProcessing = false;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收款结果'),
        elevation: 0,
      ),
      body: Center(
        child: Text('${_getResultText()}',style: TextStyle(color: Colors.red),),
      ),
    );
  }

  _getResultText() {
    if (_isProcessing) {
      return '处理中...';
    }
    if (status == 200) {
      return '交易成功';
    }
    return '交易失败: $status $message';
  }
}
