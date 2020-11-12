import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/market/org_licence.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

class ViewLicencePage extends StatefulWidget {
  PageContext context;

  ViewLicencePage({this.context});

  @override
  _ViewLicencePageState createState() => _ViewLicencePageState();
}

class _ViewLicencePageState extends State<ViewLicencePage> {
  BankInfo _bank;
  OrgLicenceOL _licenceOL;
  bool _isLoading = false;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    var bankid = widget.context.parameters['bankid'];
    IWyBankRemote wyBankRemote =
        widget.context.site.getService('/remote/wybank');
    _bank = await wyBankRemote.getWenyBank(bankid);
    ILicenceRemote licenceRemote =
        widget.context.site.getService('/remote/org/licence');
    _licenceOL = await licenceRemote.getLicenceByID(_bank.licence);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: SizedBox(
          width: 0,
          height: 0,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 15,
            ),
            child: FlatButton(
              textColor: Colors.green,
              onPressed: () {
                widget.context.forward('/robot/createSlices',
                    arguments: {}).then((value) {});
              },
              child: Text('发码'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 20,
              bottom: 20,
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: getAvatarWidget(
                    _bank.icon,
                    widget.context,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_bank.title}',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '服务区域',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${_bank.districtTitle}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 30,
                  top: 20,
                ),
                child: OrgLicenceCard(
                  context: widget.context,
                  organ: _licenceOL?.organ,
                  type: _licenceOL?.privilegeLevel,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () {
                    widget.context.forward(
                      '/market/request/landagent',
                    );
                  },
                  child: Text(
                    '我也申请成为地商',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
