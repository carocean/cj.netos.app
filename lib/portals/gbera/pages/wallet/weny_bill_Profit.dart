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

class ProfitWenyBill extends StatefulWidget {
  PageContext context;

  ProfitWenyBill({this.context});

  @override
  _WenyBillStockState createState() => _WenyBillStockState();
}

class _WenyBillStockState extends State<ProfitWenyBill> {
  WenyBank _bank;
  int _limit = 50, _offset = 0;
  List<ProfitBillOR> _bills = [];
  EasyRefreshController _controller;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
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
    List<ProfitBillOR> list =
        await billRemote.pageProfitBill(_bank.bank, _limit, _offset);
    if (list.isEmpty) {
      return;
    }
    _bills.addAll(list);
    _offset += list.length;
    if (mounted) {
      setState(() {});
    }
  }

  _forwardDetails(ProfitBillOR bill) async {
    IWalletRecordRemote recordRemote =
        widget.context.site.getService('/wallet/records');
    switch (bill.order) {
      case 8:
        var purch = await recordRemote.getPurchaseRecord(bill.refsn);
        widget.context.forward(
          '/wybank/purchase/details',
          arguments: {'purch': purch, 'bank': _bank},
        );
        break;
      case 9:
        var exchange = await recordRemote.getExchangeRecord(bill.refsn);
        widget.context.forward(
          '/wybank/exchange/details',
          arguments: {'exchange': exchange, 'bank': _bank},
        );
        break;
      default:
        throw FlutterError('stockBill:未知的订单类型');
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text(
                      '${bill.title}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
