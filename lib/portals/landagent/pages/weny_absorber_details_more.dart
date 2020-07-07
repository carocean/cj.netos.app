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
  _WenyAbsorberDetailsMorePageState createState() => _WenyAbsorberDetailsMorePageState();
}

class _WenyAbsorberDetailsMorePageState extends State<WenyAbsorberDetailsMorePage> {
  AbsorberOR _absorberOR;
  @override
  void initState() {
    _absorberOR=widget.context.page.parameters['absorber'];
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
                tipsText: '${_absorberOR.currentTimes ?? '-'}',
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
                '¥${_absorberOR.currentAmount.toStringAsFixed(14)}',
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
                title: '过期时间',
                subtitle: Text(
                  '过期后自动停用该洇取器',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                tipsText:
                '${_absorberOR.exitExpire <= 0 ? '永不过期' : intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(
                  parseStrTime(_absorberOR.ctime).add(
                    Duration(
                      milliseconds: _absorberOR.exitExpire,
                    ),
                  ),
                )}',
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
                title: '最大金额',
                subtitle: Text(
                  '到达最大金额后自动停用该洇取器',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                tipsText:
                '${_absorberOR.exitAmount <= 0 ? '不限制' : (_absorberOR.exitAmount / 100).toStringAsFixed(2)}',
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
                title: '最大次数',
                subtitle: Text(
                  '到达最大次数后自动停用该洇取器',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                tipsText:
                '${_absorberOR.exitTimes <= 0 ? '不限制' : (_absorberOR.exitTimes / 100).toStringAsFixed(2)}',
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
                '${_absorberOR.maxRecipients <= 0 ? '不限制' : (_absorberOR.maxRecipients)}',
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
