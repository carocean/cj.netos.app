import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class WorkflowManager extends StatefulWidget {
  PageContext context;

  WorkflowManager({this.context});

  @override
  _WorkflowManagerState createState() => _WorkflowManagerState();
}

class _WorkflowManagerState extends State<WorkflowManager> {
  List<Workflow> _workflowList = [];
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
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    List<Workflow> workflows =
        await workflowRemote.pageWorkflow(_limit, _offset);
    if (workflows.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _workflowList.addAll(workflows);
    _offset += workflows.length;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[];
    if (_workflowList.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          child: Center(
            child: Text(
              '没有流程',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    for (var workflow in _workflowList) {
      slivers.add(
        SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/work/workflow/details',
                  arguments: {'workflow': workflow});
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
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        '${workflow.icon}?accessToken=${widget.context.principal.accessToken}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                                '${workflow.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${TimelineUtil.formatByDateTime(
                                parseStrTime(
                                  workflow.ctime,
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
                        StringUtil.isEmpty(workflow.note)
                            ? SizedBox(
                                width: 0,
                                height: 0,
                              )
                            : Text(
                                '${workflow.note ?? ''}',
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
        ),
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
        title: Text('工作流管理'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              widget.context
                  .forward(
                '/work/createWorkflow',
              )
                  .then((value) {
                if (value == null) {
                  return;
                }
                var map = value as Map;
                _workflowList.add(map['workflow']);
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
