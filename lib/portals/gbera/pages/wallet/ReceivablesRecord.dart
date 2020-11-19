import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_bills.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
class ReceivablesRecord extends StatefulWidget {
  PageContext context;

  ReceivablesRecord({this.context});

  @override
  _ReceivablesRecordState createState() => _ReceivablesRecordState();
}

class _ReceivablesRecordState extends State<ReceivablesRecord> {
  MyWallet _wallet;
  int _limit = 50, _offset = 0;
  List<BalanceBillOR> _bills = [];
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
    List<BalanceBillOR> list =
        await billRemote.pageBalanceBillByOrder(3, _limit, _offset);
    if (list.isEmpty) {
      return;
    }
    for(var bill in list) {
      if(bill.title.startsWith('收款自:')){
        _bills.add(bill);
      }
    }
    _offset += list.length;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        child: EasyRefresh(
          onLoad: _loadBills,
          child: ListView(
            shrinkWrap: true,
            children: _bills.map((bill) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 10,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async{
                        IWalletRecordRemote recordRemote =
                        widget.context.site.getService('/wallet/records');
                        var p2pRecord = await recordRemote.getP2PRecord(bill.refsn);
                        widget.context.forward(
                          '/wallet/p2p/details',
                          arguments: {'p2p': p2pRecord, 'wallet': _wallet},
                        );
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
                                  '${bill.title??''}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                '${intl.DateFormat("yyyy-MM-dd hh:mm:ss").format(parseStrTime(bill.ctime,len: 17))}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text('¥${(bill.amount/100.00).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

}
