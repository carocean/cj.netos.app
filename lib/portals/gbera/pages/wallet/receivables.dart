import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/framework.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receivables extends StatefulWidget {
  PageContext context;

  Receivables({this.context});

  @override
  _ReceivablesState createState() => _ReceivablesState();
}

class _ReceivablesState extends State<Receivables> {
  bool has_result = false; //控制显示返回结果
  bool has_clear = true; //返回结果被清除
  _PayeeInfo _payeeInfo;
  var qrcodeKey = GlobalKey();
  Map<String, dynamic> _qrcodeData;
  GlobalKey<ScaffoldState> __globalKey = GlobalKey();
  Timer _timer;
  MyWallet _myWallet;

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _qrcodeData = {
      'itis': 'wallet.receivables',
      'data': null,
    };
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _setQrcode(Map v) async {
    has_result = true;
    has_clear = false;
    setState(() {});
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    String evidence = await tradeRemote.genReceivableEvidence(1 * 60 * 1000, 1);
    this._payeeInfo = _PayeeInfo(
      evidence: evidence,
      note: v['memo'],
      amount: (double.parse(v['amount'] + '') * 100.0).floor(),
    );
    this._qrcodeData['data'] = jsonEncode(_payeeInfo.toMap());
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

  @override
  Widget build(BuildContext context) {
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
              Text('二维码收款'),
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
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                  top: 20,
                ),
                child: Text(
                  '地微扫一扫，向我付钱',
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
              has_clear
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 15,
                            ),
                            child: Text(
                              '¥${((_payeeInfo?.amount ?? 0) / 100.0).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                            ),
                          ),
                          Text(
                            _payeeInfo?.note ?? '',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    !has_result
                        ? FlatButton(
                            child: Text(
                              '设置金额',
                              style: TextStyle(
                                color: Colors.blueGrey,
                              ),
                            ),
                            onPressed: () {
                              var result = widget.context
                                  .forward('/wallet/receivables/settings');
                              result.then((v) async {
                                if (v is Map) {
                                  _setQrcode(v);
                                }
                              });
                            },
                          )
                        : FlatButton(
                            child: Text(
                              '清除金额',
                              style: TextStyle(
                                color: Colors.blueGrey,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                has_clear = true;
                                has_result = false;
                                _payeeInfo = null;
                                this._qrcodeData['data'] = null;
                              });
                            },
                          ),
                    Container(
                      height: 16,
                      padding: EdgeInsets.only(
                        top: 2,
                        bottom: 2,
                      ),
                      child: VerticalDivider(
                        color: Colors.grey[400],
                      ),
                    ),
                    FlatButton(
                      onPressed: has_clear
                          ? null
                          : () async {
                              if (_payeeInfo == null) {
                                __globalKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text('未设置金额'),
                                  ),
                                );
                                return;
                              }
                              RenderRepaintBoundary boundary =
                                  qrcodeKey.currentContext.findRenderObject();
                              var image = await boundary.toImage();
                              var byteData = await image.toByteData(
                                  format: ImageByteFormat.png);
                              var pngBytes = byteData.buffer.asUint8List();

                              ///本来应该保存到相册，但相册是手机的共享目录，得找第三方插件才能实现,下面先保存到应用目录，用户是看不到的。
                              Directory dir =
                                  await getApplicationDocumentsDirectory();
                              File('${dir.path}/qr_code.png')
                                  .writeAsBytes(pngBytes);
                              await ImageGallerySaver.saveFile(
                                  '${dir.path}/qr_code.png');
                              __globalKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text('保存成功'),
                                ),
                              );
                            },
                      child: Text(
                        '保存收款码',
                        style: TextStyle(
                          color: has_clear ? Colors.grey[300] : Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],
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
                  widget.context.forward('/wallet/receivables/record',
                      arguments: {
                        'wallet': widget.context.parameters['wallet']
                      });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    bottom: 10,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.assignment,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text('收款记录'),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      key: __globalKey,
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
              child: card_body,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayeeInfo {
  String evidence; //收款凭证
  int amount; //要收款项
  String note;

  _PayeeInfo({this.evidence, this.amount, this.note}); //备注

  Map toMap() {
    return {
      'evidence': evidence,
      'amount': amount,
      'type': 1,
      'note': note,
    };
  }
}

void registerQrcodeAction(PageContext context) {
  if (!qrcodeScanner.actions.containsKey('wallet.receivables')) {
    qrcodeScanner.actions['wallet.receivables'] = QrcodeAction(
      doit: (info) async {
        IWalletTradeRemote tradeRemote =
            context.site.getService('/wallet/trades');
        try {
          await tradeRemote.payToEvidence(info.props['evidence'],
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
            title: '付款给',
            isHidenNoButton: false,
            isHidenYesButton: true,
            itis: 'wallet.receivables',
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
                    child: Text('验证收款凭证异常:$e'),
                  ),
                ],
              ),
            ),
          );
        }
        if (evidence == null) {
          return QrcodeInfo(
            title: '付款给',
            isHidenNoButton: false,
            isHidenYesButton: true,
            itis: 'wallet.receivables',
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
          title: '付款给',
          isHidenNoButton: false,
          isHidenYesButton: false,
          itis: 'wallet.receivables',
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
                Wrap(
                  direction: Axis.vertical,
                  spacing: 10,
                  children: <Widget>[
                    Text(
                      '${person.nickName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '¥${((props['amount'] as int) / 100.00).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.red,
                      ),
                    )
                  ],
                )
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

class ReceivableResultPage extends StatefulWidget {
  PageContext context;

  ReceivableResultPage({
    this.context,
  });

  @override
  _ReceivableResultPageState createState() => _ReceivableResultPageState();
}

class _ReceivableResultPageState extends State<ReceivableResultPage> {
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
        title: Text('付款结果'),
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
