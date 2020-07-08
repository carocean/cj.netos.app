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
  List<AbsorberOR> _absorbers = [];
  int _limit = 50, _offset = 0;
  int _selectType = 0;

  @override
  void initState() {
    _bank = widget.context.parameters['bank'];
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _absorbers.clear();
    _offset = 0;
    await _onload();
  }

  Future<void> _onload() async {
    IRobotRemote robotRemote = widget.context.site.getService('/wybank/robot');
    List<AbsorberOR> absorbers =
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
    for (var abosrber in _absorbers) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward(
              '/weny/robot/absorbers/details',
              arguments: {'absorber': abosrber},
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
                                      ' ${getAbsorberCategory(abosrber.category)}',
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
                                '${abosrber.state == 0 ? '运行中' : '关停'}',
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
                                  text: '权重:',
                                  children: [
                                    TextSpan(
                                      text: '${abosrber.weight}',
                                      style: TextStyle(
                                        color: Colors.red,
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
                              Text.rich(
                                TextSpan(
                                  text: '洇取次数:',
                                  children: [
                                    TextSpan(
                                      text: '${abosrber.currentTimes}',
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
                                  text: '洇取约:',
                                  children: [
                                    TextSpan(
                                      text:
                                          '¥${(abosrber.currentAmount / 100).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.red,
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
        ));
  }
}

getAbsorberCategory(String category) {
  switch (category) {
    case 'fountain':
      return '金证喷泉';
    case 'shop':
      return '实体店';
    case 'netflow':
      return '网流';
    case 'geosphere':
      return '地圈';
    case 'chasingchain':
      return '追链';
  }
  return category;
}
