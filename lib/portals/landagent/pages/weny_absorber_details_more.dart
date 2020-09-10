import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:intl/intl.dart' as intl;

class WenyAbsorberDetailsMorePage extends StatefulWidget {
  PageContext context;

  WenyAbsorberDetailsMorePage({this.context});

  @override
  _WenyAbsorberDetailsMorePageState createState() =>
      _WenyAbsorberDetailsMorePageState();
}

class _WenyAbsorberDetailsMorePageState
    extends State<WenyAbsorberDetailsMorePage> {
  AbsorberResultOR _absorberOR;

  @override
  void initState() {
    _absorberOR = widget.context.page.parameters['absorber'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var absorber = _absorberOR.absorber;
    var bucket = _absorberOR.bucket;
    return Scaffold(
      appBar: AppBar(
        title: Text('更多'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        child: Container(
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CardItem(
                title: '已洇次数',
                tipsText: '${bucket.times ?? '-'}',
                paddingLeft: 20,
                paddingRight: 20,
                tail: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              Divider(
                height: 1,
              ),
              CardItem(
                title: '已洇资金',
                tipsText:
                    '¥${((bucket.pInvestAmount + bucket.wInvestAmount) / 100).toStringAsFixed(14)}',
                paddingLeft: 20,
                paddingRight: 20,
                tail: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              Divider(
                height: 1,
              ),
              CardItem(
                title: '最多人数',
                tipsText:
                    '${absorber.maxRecipients <= 0 ? '不限制' : (absorber.maxRecipients)}',
                paddingLeft: 20,
                paddingRight: 20,
                tail: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              Divider(
                height: 1,
              ),
              CardItem(
                title: '指代类别',
                tipsText: '${absorber.category ?? '-'}',
                paddingLeft: 20,
                paddingRight: 20,
                tail: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              Divider(
                height: 1,
              ),
              CardItem(
                title: '指代对象',
                tipsText: '${absorber.proxy ?? '-'}',
                paddingLeft: 20,
                paddingRight: 20,
                tail: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
