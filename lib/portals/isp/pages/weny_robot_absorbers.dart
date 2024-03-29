import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:intl/intl.dart' as intl;

class RobotAbsorbersPage extends StatefulWidget {
  PageContext context;

  RobotAbsorbersPage({this.context});

  @override
  _RobotAbsorbersPageState createState() => _RobotAbsorbersPageState();
}

class _RobotAbsorbersPageState extends State<RobotAbsorbersPage> {
  BankInfo _bank;
  EasyRefreshController _controller;
  List<AbsorberResultOR> _absorbers = [];
  int _limit = 50, _offset = 0;
  int _selectType = -1;
  DomainBulletin _bulletin;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _refreshDomain();
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  Future<void> _refreshDomain()async{
    IRobotRemote robotRemote =
    widget.context.site.getService('/wybank/robot');
    _bulletin = await robotRemote.getDomainBucket(_bank.id);
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _onRefresh() async {
    _absorbers.clear();
    _offset = 0;
    await _refreshDomain();
    await _onload();
  }

  Future<void> _onload() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    List<AbsorberResultOR> absorbers =
        await robotRemote.pageAbsorber(_bank.id, _selectType, _limit, _offset);
    if (absorbers.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += absorbers.length;
    _absorbers.addAll(absorbers);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_absorbers.isEmpty) {
      items.add(
        Center(
          child: Text('没有洇取器'),
        ),
      );
    }
    for (var abosrberResult in _absorbers) {
      var abosrber = abosrberResult.absorber;
      var bucket = abosrberResult.bucket;
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward(
              '/weny/robot/absorbers/details',
              arguments: {'absorber': abosrberResult},
            );
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: '${abosrber.title ?? ''}',
                              children: [
                                TextSpan(
                                  text:
                                      ' ${getUsageDesc(abosrber.usage)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${intl.DateFormat('M月d日 HH:mm:ss').format(parseStrTime(abosrber.ctime))}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                '${abosrber.state == 1 ? '运行中' : '关停'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '指数:',
                            children: [
                              TextSpan(
                                text: '${bucket.price.toStringAsFixed(14)}',
                                style: TextStyle(
                                  color:
                                      bucket.price >= _bulletin.bucket.waaPrice
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.start,
                            spacing: 5,
                            runSpacing: 5,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '类型:',
                                  children: [
                                    TextSpan(
                                      text:
                                          '${abosrber.type == 1 ? '地理洇取器' : '简单洇取器'}',
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Text.rich(
                                TextSpan(
                                  text: '创建:',
                                  children: [
                                    TextSpan(
                                      text: '${abosrber.creator}',
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '洇取次数:',
                            children: [
                              TextSpan(
                                text: '${bucket.times}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 5,),
                        Text.rich(
                          TextSpan(
                            text: '洇取:',
                            children: [
                              TextSpan(
                                text:
                                '¥${((bucket.wInvestAmount + bucket.pInvestAmount) / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('洇取器'),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              widget.context.forward(
                '/weny/records/withdraw',
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
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Container(
                  child: Text(
                    '域指',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${_bulletin == null ? '-' : _bulletin.bucket.waaPrice.toStringAsFixed(14)}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: EasyRefresh(
                controller: _controller,
                onRefresh: _onRefresh,
                onLoad: _onload,
                firstRefresh: true,
                child: ListView(
                  shrinkWrap: true,
                  children: items,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

getUsageDesc(int usage) {
//    用途：
//    0网流管道
//    1地理感知器
//    2街道
//    3金证喷泉
//    4抢元宝
  switch (usage) {
    case 0:
      return '网流管道';
    case 1:
      return '地理感知器';
    case 2:
      return '街道';
    case 3:
      return '金证喷泉';
    case 4:
      return '抢元宝';
    default:
      return '-';
  }
}