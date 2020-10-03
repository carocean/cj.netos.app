import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:intl/intl.dart' as intl;

class PlatformFundPage extends StatefulWidget {
  PageContext context;

  PlatformFundPage({this.context});

  @override
  _PlatformFundPageState createState() => _PlatformFundPageState();
}

class _PlatformFundPageState extends State<PlatformFundPage> {
  List<ChannelAccountOR> _accounts = [];
  int _limit = 20, _offset = 0;
  EasyRefreshController _controller;
  bool _isLoading = false;
  int _allAccountBalance = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    () async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      await _onLoad();
      await _totalAccountBalance();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _accounts.clear();
    _offset = 0;
    await _onLoad();
  }

  Future<void> _onLoad() async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    var list = await payChannelRemote.pageAccount(_limit, _offset);
    if (list.isEmpty) {
      _controller.finishLoad(
        success: true,
        noMore: true,
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _accounts.addAll(list);
    _offset += list.length;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _totalAccountBalance() async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    _allAccountBalance = await payChannelRemote.totalAccountBalance(null);
  }

  Future<PayChannel> _loadChannel(code) async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    return await payChannelRemote.getPayChannel(code);
  }

  Future<void> _onDeleteAccount(accountid) async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    await payChannelRemote.removeAccount(accountid);
    for (var i = 0; i < _accounts.length; i++) {
      var account = _accounts[i];
      if (account == null) {
        continue;
      }
      if (account.id == accountid) {
        _accounts.removeAt(i);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('资金'),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 15,
            ),
            child: Column(
              children: [
                Text(
                  '现账余额',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _isLoading
                    ? Text('正在统计...')
                    : Text(
                        '¥${(_allAccountBalance / 100.00).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('全部'),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.list,
                  size: 18,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: _rendAccounts(),
          ),
        ],
      ),
    );
  }

  Widget _rendAccounts() {
    if (_isLoading) {
      return Text('正在加载...');
    }
    if (_accounts.isEmpty) {
      return Text('没有支付账户');
    }
    var list = <Widget>[];
    for (var account in _accounts) {
      list.add(
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: '删除',
              foregroundColor: Colors.grey[500],
              icon: Icons.delete,
              onTap: () {
                _onDeleteAccount(account.id);
              },
            ),
          ],
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: FutureBuilder<PayChannel>(
              future: _loadChannel(account.channel),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text('...');
                }
                var ch = snapshot.data;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/claf/channel/account',
                        arguments: {'account': account, 'payChannel': ch});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '账户',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                '${account.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '渠道',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${ch.name}',
                                    style: TextStyle(
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text('(${ch.code})'),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        '¥${(account.balanceAmount / 100.00).toStringAsFixed(2)}'),
                                    Text(
                                      '${intl.DateFormat('yyyy-HH-mm hh:mm:ss').format(
                                        parseStrTime(
                                          account.balanceUtime,
                                          len: 17,
                                        ),
                                      )}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    return EasyRefresh(
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      controller: _controller,
      child: ListView(
        shrinkWrap: true,
        children: list,
      ),
    );
  }
}
