import 'package:flutter/material.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:intl/intl.dart' as intl;

class ChannelAccountDetailsPage extends StatefulWidget {
  PageContext context;

  ChannelAccountDetailsPage({this.context});

  @override
  _ChannelAccountDetailsPageState createState() =>
      _ChannelAccountDetailsPageState();
}

class _ChannelAccountDetailsPageState extends State<ChannelAccountDetailsPage> {
  ChannelAccountOR _accountOR;
  PayChannel _payChannel;

  @override
  void initState() {
    _accountOR = widget.context.parameters['account'];
    _payChannel = widget.context.parameters['payChannel'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('渠道账户'),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              top: 10,
              bottom: 20,
            ),
            child: Text(
              '¥${(_accountOR.balanceAmount / 100.00).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Text(
              '${intl.DateFormat('yyyy-HH-mm hh:mm:ss').format(parseStrTime(_accountOR.balanceUtime))}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('账户'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text('${_accountOR.id}'),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('支付渠道'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text('${_payChannel?.name}'),
                              SizedBox(
                                width: 10,
                              ),
                              Text('${_payChannel?.code}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('应用'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text('${_accountOR.appId}'),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('服务地址'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text('${_accountOR.serviceUrl}'),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('key过期时间'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              '${_accountOR.keyExpire == 0 ? '无限制' : _accountOR.keyExpire}'),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('充值限制'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              '${_accountOR.limitAmount == 0 ? '无限制' : _accountOR.limitAmount}'),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('异步通知地址'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text('${_accountOR.notifyUrl}'),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Text('私钥'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              '${_accountOR.privateKey}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Text('公钥'),
                            width: 60,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              '${_accountOR.publicKey}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
              right: 10,
              left: 10,
            ),
            color: Colors.white,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/claf/channel/account/bill',arguments: {'account':_accountOR});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '账单',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
