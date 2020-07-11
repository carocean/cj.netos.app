import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class IspRobotPage extends StatefulWidget {
  PageContext context;

  IspRobotPage({this.context});

  @override
  _IspRobotPageState createState() => _IspRobotPageState();
}

class _IspRobotPageState extends State<IspRobotPage> {
  BankInfo _bank;
  double _hubTails = 0.00;
  bool _enableButton = false;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _load().then((value) {
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

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    _hubTails = await robotRemote.getHubTails(_bank.id);
    _enableButton = _hubTails.floor() > 0 ? true : false;
  }

  Future<void> _transToWallet() async {
    _enableButton = false;
    setState(() {});
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    await robotRemote.withdrawHubTails(_bank.id);
    await _load();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var card_main = Container(
      padding: EdgeInsets.only(bottom: 20,top: 20,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
            ),
            child: Text(
              '地商经营尾金',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                ),
                child: Text(
                  '¥${(_hubTails / 100).toStringAsFixed(14)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    var card_items = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _getCardItem(
          title: '洇取器管理',
          onTap: () {
            widget.context
                .forward('/weny/robot/absorbers', arguments: {'bank': _bank});
          },
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("派发中心"),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              widget.context.forward(
                '/weny/bill/hubTails',
                arguments: {
                  'bank': _bank,
                },
              );
            },
            child: Text('明细'),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            card_main,
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: card_items,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _getCardItem(
    {String title, String tips, Color color, Function() onTap}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.only(
        top: 18,
        bottom: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${title ?? ''}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${tips ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color ?? Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
