import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class PlatformWenyBankInfoPage extends StatefulWidget {
  PageContext context;

  PlatformWenyBankInfoPage({this.context});

  @override
  _PlatformWenyBankInfoPageState createState() => _PlatformWenyBankInfoPageState();
}

class _PlatformWenyBankInfoPageState extends State<PlatformWenyBankInfoPage> {
  BankInfo _bank;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
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
        title: Text('福利中心'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 10,
              bottom: 20,
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: FadeInImage.assetNetwork(
                      placeholder:
                          'lib/portals/gbera/images/default_watting.gif',
                      image:
                          '${_bank.icon}?accessToken=${widget.context.principal.accessToken}',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 2,
                  children: <Widget>[
                    Text(
                      '${_bank.title}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_bank.districtTitle}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      '${_bank.state == 0 ? '营业中' : '已停业'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.context.part(
              '/weny/parameters',
              context,
              arguments: {
                'bank': _bank,
                'isEmbed':true,
              },
            ),
          ),
        ],
      ),
    );
  }
}
