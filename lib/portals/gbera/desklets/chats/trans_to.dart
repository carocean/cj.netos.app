import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/system/local/entities.dart';

class TranslateToPage extends StatefulWidget {
  PageContext context;

  TranslateToPage({this.context});

  @override
  _TranslateToPageState createState() => _TranslateToPageState();
}

class _TranslateToPageState extends State<TranslateToPage> {
  TextEditingController _controller;
  Friend _payee;
  String note;
  int _transToProgress = 0; //0为初始；1为处理中；2为处理完成
  StreamSubscription _streamSubscription;
  P2PRecordOR _p2pRecordOR;

  @override
  void initState() {
    _controller = TextEditingController();
    _payee = widget.context.partArgs['payee'];
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  bool _validAmount() {
    var v = _controller.text;
    if (StringUtil.isEmpty(v)) {
      return false;
    }

    int pos = v.indexOf('.');
    if (pos == 0) {
      return false;
    }
    if (pos > 0) {
      if (v.endsWith(('.'))) {
        return false;
      }
      var digital = v.substring(pos + 1, v.length);
      if (digital.length > 2) {
        return false;
      }
    }
    return true;
  }

  Future<void> _transTo() async {
    IWalletTradeRemote tradeRemote =
        widget.context.site.getService('/wallet/trades');
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    var amount = (double.parse(_controller.text) * 100).floor();
    var result = await tradeRemote.transTo(amount, _payee.official, 0, note);
    if (mounted) {
      setState(() {
        _transToProgress = 1;
      });
    }
    _streamSubscription = Stream.periodic(Duration(seconds: 1), (count) async {
      var record = await recordRemote.getP2PRecord(result.sn);
      _p2pRecordOR = record;
      return record;
    }).listen((event) async {
      event.then((value) {
        var record = value;
        if (record.state == 1) {
          _transToProgress = 2;
          if (record.status == 200) {
            widget.context.backward(result: _p2pRecordOR);
          } else {
            if (mounted) {
              setState(() {
              });
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('转账'),
        elevation: 0,
        titleSpacing: 0,
      ),
      resizeToAvoidBottomPadding: true,
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.file(
                  File('${widget.context.principal.avatarOnLocal}'),
                  width: 50,
                  height: 50,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${widget.context.principal.nickName}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              padding: EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
              ),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '转账金额',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
                    autofocus: true,
                    inputFormatters: [
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (v) {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                      prefix: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          '¥',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 45,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _renderPanel(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderPanel() {
    var items = <Widget>[];
    var button = Container(
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(
        bottom: 20,
      ),
      child: SizedBox(
        height: 60,
        child: FlatButton(
          color: Colors.green,
          onPressed: !_validAmount()
              ? null
              : () {
                  _transTo();
                },
          disabledColor: Colors.grey[400],
          disabledTextColor: Colors.grey[500],
          child: Text(
            '转账',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
    var tips = Container(
      padding: EdgeInsets.only(
        top: 40,
        bottom: 10,
      ),
      alignment: Alignment.center,
      child: Text('转账指令已发送，请稍候...'),
    );
    switch (_transToProgress) {
      case 0:
        items.add(button);
        break;
      case 1:
        items.add(tips);
        break;
      case 2:
        items.add(
          Container(
            padding: EdgeInsets.only(
              top: 40,
              bottom: 20,
            ),
            alignment: Alignment.center,
            child: Text('${_p2pRecordOR.status} ${_p2pRecordOR.message}',style: TextStyle(fontSize: 16,color: Colors.red,),),
          ),
        );
        break;
    }
    return items;
  }
}
