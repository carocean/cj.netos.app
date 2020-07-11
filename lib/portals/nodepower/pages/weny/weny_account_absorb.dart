import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

class PlatformAbsorbWenyAccount extends StatefulWidget {
  PageContext context;

  PlatformAbsorbWenyAccount({this.context});

  @override
  _PlatformAbsorbWenyAccountState createState() => _PlatformAbsorbWenyAccountState();
}

class _PlatformAbsorbWenyAccountState extends State<PlatformAbsorbWenyAccount> {
  BankInfo _bank;
  ShuntBuckets _shuntBuckets;
  double _hubTails = 0.00;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _shuntBuckets = widget.context.parameters['shuntBuckets'];
    _load().then((v) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    _hubTails = await robotRemote.getHubTails(_bank.id);
  }

  @override
  Widget build(BuildContext context) {
    var card_main = Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              '网络洇金',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 3,
                ),
                child: Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${((_shuntBuckets?.absorbsAmount ?? 0.0) / 100.00).toStringAsFixed(2)}',
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
    var card_actions = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _getCardItem(
          title: '派发中心',
          tips: '¥${(_hubTails/100).toStringAsFixed(14)}',
          onTap: () {
            widget.context
                .forward('/weny/robot', arguments: {'bank': _bank});
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
//        title: Text(
//          widget.context.page?.title,
//        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              widget.context.forward(
                '/weny/bill/shunt',
                arguments: {'bank': _bank, 'shunter': 'absorbs'},
              );
            },
            child: Text('明细'),
          ),
        ],
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
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
            Expanded(
              child: card_main,
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: card_actions,
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
