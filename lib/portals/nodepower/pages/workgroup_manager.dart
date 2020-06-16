import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:netos_app/portals/nodepower/remote/workgroup_remote.dart';

class WorkgroupManager extends StatefulWidget {
  PageContext context;

  WorkgroupManager({this.context});

  @override
  _WorkgroupManagerState createState() => _WorkgroupManagerState();
}

class _WorkgroupManagerState extends State<WorkgroupManager> {
  List<Workgroup> _workgroupList = [];
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _loadWorkflow();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadWorkflow() async {
    IWorkgroupRemote workgroupRemote =
        widget.context.site.getService('/remote/org/workgroup');
    List<Workgroup> workgroups =
        await workgroupRemote.pageWorkgroup(_limit, _offset);
    if (workgroups.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _workgroupList.addAll(workgroups);
    _offset += workgroups.length;
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _deleteWorkgroup(Workgroup workgroup)async{
    IWorkgroupRemote workgroupRemote =
    widget.context.site.getService('/remote/org/workgroup');
    await workgroupRemote.removeWorkgroup(workgroup.code);
  }
  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[];
    if (_workgroupList.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          child: Center(
            child: Text(
              '没有工作组',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    for (var workgroup in _workgroupList) {
      slivers.add(
        SliverToBoxAdapter(child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: '删除',
              foregroundColor: Colors.grey[500],
              icon: Icons.delete,
              onTap: () async {
                await _deleteWorkgroup(workgroup);
                _workgroupList.removeWhere((e) {
                  return e.code == workgroup.code;
                });
                setState(() {});
              },
            ),
          ],
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/work/workgroup/details',
                  arguments: {'workgroup': workgroup});
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 20,
                bottom: 20,
              ),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${workgroup.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              StringUtil.isEmpty(workgroup.ctime)
                                  ? ''
                                  : '${TimelineUtil.formatByDateTime(
                                parseStrTime(
                                  workgroup.ctime,
                                  len: 17,
                                ),
                                dayFormat: DayFormat.Full,
                              )}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        StringUtil.isEmpty(workgroup.note)
                            ? SizedBox(
                          width: 0,
                          height: 0,
                        )
                            : Text(
                          '${workgroup.note ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),),
      );
      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 10,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('工作组管理'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              widget.context
                  .forward(
                '/work/createWorkgroup',
              )
                  .then((value) {
                if (value == null) {
                  return;
                }
                var map = value as Map;
                _workgroupList.add(map['workgroup']);
                _offset++;
                setState(() {});
              });
            },
          )
        ],
      ),
      body: EasyRefresh.custom(
        shrinkWrap: true,
        onLoad: _loadWorkflow,
        controller: _controller,
        slivers: slivers,
      ),
    );
  }
}
