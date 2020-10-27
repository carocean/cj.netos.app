import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_bills.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';

class OnorderBill extends StatefulWidget {
  PageContext context;

  OnorderBill({this.context});

  @override
  _OnorderBillState createState() => _OnorderBillState();
}

class _OnorderBillState extends State<OnorderBill> {
  MyWallet _wallet;
  int _limit = 50, _offset = 0;
  List<OnorderBillOR> _bills = [];
  EasyRefreshController _controller;

  @override
  void initState() {
    _wallet = widget.context.parameters['wallet'];
    _controller = EasyRefreshController();
    _loadBills();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _bills.clear();
    super.dispose();
  }

  Future<void> _loadBills() async {
    IWalletBillRemote billRemote =
        widget.context.site.getService('/wallet/bills');
    List<OnorderBillOR> list =
        await billRemote.pageOnorderBill(_limit, _offset);
    if (list.isEmpty) {
      return;
    }
    _bills.addAll(list);
    _offset += list.length;
    if (mounted) {
      setState(() {});
    }
  }

  _forwardDetails(OnorderBillOR bill) async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');

    switch (bill.order) {
      case 2: //提现
        var withdraw = await recordRemote.getWithdrawRecord(bill.refsn);
        widget.context.forward(
          '/wallet/withdraw/details',
          arguments: {'withdraw': withdraw, 'wallet': _wallet},
        );
        break;
      case 7: //提现撤销
        var withdraw = await recordRemote.getWithdrawRecord(bill.refsn);
        widget.context.forward(
          '/wallet/withdraw/cancel',
          arguments: {'withdraw': withdraw, 'wallet': _wallet},
        );
        break;
      case 8: //申购
        var purch = await recordRemote.getPurchaseRecord(bill.refsn);
        var bank;
        for (var b in _wallet.banks) {
          if (b.bank == purch.bankid) {
            bank = b;
            break;
          }
        }
        widget.context.forward(
          '/wybank/purchase/details',
          arguments: {'purch': purch, 'bank': bank},
        );
        break;

      default:
        throw FlutterError('onorderBill:未知的订单类型');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _itemBuilder(BuildContext context, int index) {
      var bill = _bills[index];
      return Container(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: 10,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _forwardDetails(bill);
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        '${bill.order == 2 ? '提现预扣款-' : bill.order == 8 ? '申购预扣款-' : ''}${bill.title}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        '订单:${bill.refsn}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    Text(
                      '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(parseStrTime(bill.ctime))}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child:
                        Text('¥${(bill.amount / 100.00).toStringAsFixed(2)}'),
                  ),
                  Text(
                    '余额 ¥${(bill.balance / 100.00).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _separatorBuilder(BuildContext context, int index) {
      return Divider(
        height: 1,
        indent: 10,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '账单明细',
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: EasyRefresh(
          controller: _controller,
          onLoad: _loadBills,
          child: ListView.separated(
            itemBuilder: _itemBuilder,
            itemCount: _bills.length,
            separatorBuilder: _separatorBuilder,
          ),
        ),
      ),
    );
  }
}
