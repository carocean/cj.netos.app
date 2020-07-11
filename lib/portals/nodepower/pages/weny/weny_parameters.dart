import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

class PlatformWenyParametersPage extends StatefulWidget {
  PageContext context;

  PlatformWenyParametersPage({this.context});

  @override
  _PlatformWenyParametersPageState createState() => _PlatformWenyParametersPageState();
}

class _PlatformWenyParametersPageState extends State<PlatformWenyParametersPage> {
  BankInfo _bank;
  Map<String, dynamic> _shunters = {};
  List _ttmConfig = [];
  bool _isEmbed=false;
  @override
  void initState() {
    _bank = widget.context.page.parameters['bank'];
    if(_bank==null) {
      _bank=widget.context.parameters['bank'];
    }
    _isEmbed = widget.context.page.parameters['isEmbed'];
    _isEmbed=_isEmbed??false;
    _loadConfig().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadConfig() async {
    IWyBankRemote wyBankRemote =
        widget.context.site.getService('/wybank/remote');
    List shunters = await wyBankRemote.getShunters(_bank.id);
    List ttmConfig = await wyBankRemote.getTtmConfig(_bank.id);
    _ttmConfig.addAll(ttmConfig);
    for (var shunter in shunters) {
      switch (shunter['code']) {
        case 'absorbs':
          _shunters['absorbs'] = shunter['ratio'];
          break;
        case 'la':
          _shunters['la'] = shunter['ratio'];
          break;
        case 'isp':
          _shunters['isp'] = shunter['ratio'];
          break;
        case 'platform':
          _shunters['platform'] = shunter['ratio'];
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('经营参数'),
        elevation: 0,
        automaticallyImplyLeading: _isEmbed?false:true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 15,right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            top: 10,
                            left: 10,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            direction: Axis.vertical,
                            spacing: 5,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '投单金额(1.0000)=',
                                  children: [
                                    TextSpan(
                                      text:
                                      '本金率(${_bank.principalRatio.toStringAsFixed(4)})+',
                                    ),
                                    TextSpan(
                                      text:
                                      '费率(${(_bank.freeRatio + _bank.reserveRatio).toStringAsFixed(4)})',
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text:
                                  '费率(${(_bank.freeRatio + _bank.reserveRatio).toStringAsFixed(4)})=',
                                  children: [
                                    TextSpan(
                                      text:
                                      '准备率(${_bank.reserveRatio.toStringAsFixed(4)})+',
                                    ),
                                    TextSpan(
                                      text:
                                      '自由金率(${_bank.freeRatio.toStringAsFixed(4)})',
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 18,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        left: 2,
                        right: 2,
                      ),
                      child: Text(
                        '费率',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (_ttmConfig).map((ttm) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Text(
                                  '${ttm['ttm']} \n              ${ttm['minAmount']}/${ttm['maxAmount']}'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                              ),
                              child: Divider(
                                height: 1,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 18,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        left: 2,
                        right: 2,
                      ),
                      child: Text(
                        '市盈率',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('平        台 ${((_shunters['platform'] as double)??0.00).toStringAsFixed(4)}'),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('运  营  商 ${((_shunters['isp'] as double)??0.00).toStringAsFixed(4)}'),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('地        商 ${((_shunters['la'] as double)??0.00).toStringAsFixed(4)}'),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('网络洇金 ${((_shunters['absorbs'] as double)??0.00).toStringAsFixed(4)}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 18,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        left: 2,
                        right: 2,
                      ),
                      child: Text(
                        '账比设置',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
