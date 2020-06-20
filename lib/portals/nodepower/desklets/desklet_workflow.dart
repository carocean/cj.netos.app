import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class WorkflowDesklet extends StatefulWidget {
  PageContext context;
  Portlet portlet;
  Desklet desklet;

  WorkflowDesklet({this.context, this.portlet, this.desklet});

  @override
  _WorkflowDeskletState createState() => _WorkflowDeskletState();
}

class _WorkflowDeskletState extends State<WorkflowDesklet> {
  int _index_pannel = 0; //0待办；1已办；2发件
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                    bottom: 5,
                  ),
                  child: Image.network(
                    '${widget.portlet.imgSrc}?accessToken=${widget.context.principal.accessToken}',
                    width: 16,
                    height: 16,
                  ),
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_index_pannel == 0) {
                          return;
                        }
                        _index_pannel = 0;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        color: _index_pannel == 0 ? Colors.white : null,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Text(
                          '待办',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _index_pannel == 0 ? Colors.red : null,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_index_pannel == 1) {
                          return;
                        }
                        _index_pannel = 1;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        color: _index_pannel == 1 ? Colors.white : null,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Text(
                          '已办',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _index_pannel == 1 ? Colors.red : null,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_index_pannel == 2) {
                          return;
                        }
                        _index_pannel = 2;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        color: _index_pannel == 2 ? Colors.white : null,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Text(
                          '发件',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _index_pannel == 2 ? Colors.red : null,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: 400,
            padding: EdgeInsets.all(15),
            child: IndexedStack(
              index: _index_pannel,
              children: <Widget>[
                _TodoListWorkitemWidget(context: widget.context),
                _DoneListWorkitemWidget(context: widget.context),
                _CreatedInstWorkitemWidget(context: widget.context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoListWorkitemWidget extends StatefulWidget {
  PageContext context;

  _TodoListWorkitemWidget({this.context});

  @override
  __TodoListWorkitemWidgetState createState() =>
      __TodoListWorkitemWidgetState();
}

class __TodoListWorkitemWidgetState extends State<_TodoListWorkitemWidget> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _workitems.clear();
    await _onload();
  }

  Future<void> _onload() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    List<WorkItem> list = await workflowRemote.pageMyWorkItem(_limit, _offset);
    if (list.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      return;
    }
    _offset += list.length;
    _workitems.addAll(list);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      controller: _controller,
      onLoad: _onload,
      onRefresh: _onRefresh,
      slivers: _renderWorkitemList(),
    );
  }

  List<Widget> _renderWorkitemList() {
    var workitems = <Widget>[];
    if (_workitems.isEmpty) {
      workitems.add(
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Text(
                '没有工作项',
              ),
            ),
          ),
        ),
      );
    }
    for (var item in _workitems) {
      var inst = item.workInst;
      var event = item.workEvent;
//      var data=jsonDecode(event.data);
      workitems.add(
        SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _showForm(widget.context, context, item);
            },
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: SizedBox(
                        width: 35,
                        height: 35,
                        child: Center(
                          child: Image.network(
                            '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${inst.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${TimelineUtil.formatByDateTime(
                                  parseStrTime(event.ctime),
                                  dayFormat: DayFormat.Full,
                                )}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '件号:${event.id}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          _renderData(item),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '待处理: ',
                                    children: [
                                      TextSpan(
                                        text: '${event.title}',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n发送人: ${event.sender}',
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '',
                                    children: [
                                      TextSpan(
                                        text: '当前是第',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${event.stepNo + 1}',
                                      ),
                                      TextSpan(
                                        text: '步',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                  child: Divider(
                    height: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return workitems;
  }

  void _showForm(PageContext pageContext, BuildContext context, WorkItem item) {
    var inst = item.workInst;
    switch (inst.workflow) {
      case 'workflow.isp.apply':
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return pageContext.part(
              '/work/workitem/adoptISP',
              context,
              arguments: {'workitem': item},
            );
          },
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      case 'workflow.la.apply':
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return pageContext.part(
              '/work/workitem/adoptLA',
              context,
              arguments: {'workitem': item},
            );
          },
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      case 'workflow.wybank.apply':
        widget.context.forward(
          '/work/workitem/adoptWybank',
          arguments: {'workitem': item},
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      default:
        break;
    }
  }

  Widget _renderData(WorkItem item) {
    var inst = item.workInst;
    var event = item.workEvent;
    var children = <InlineSpan>[];
    switch (inst.workflow) {
      case 'workflow.isp.apply':
        var data = event.data;
        var form = jsonDecode(data);
        children.add(
          TextSpan(
            text: '公司:${form['cropName']}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '运营区域:${form['bussinessAreaTitle']}\n',
          ),
        );

        children.add(
          TextSpan(
            text: '运营期限:${form['operatePeriod']}个月\n',
          ),
        );
        children.add(
          TextSpan(
            text:
                '服务费:¥${((form['fee'] as int) / 1000000).toStringAsFixed(2)}万元\n',
          ),
        );
        children.add(
          TextSpan(
            text:
                '支付凭证:${StringUtil.isEmpty(form['payEvidence']) ? '无' : '已上传'}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '\n申请人:${inst.creator}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '真实名:${form['masterRealName']}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '电话:${form['masterPhone']}',
          ),
        );
        break;
      default:
        children.add(
          TextSpan(
            text: '暂不支持对本步骤的处理',
          ),
        );
        break;
    }
    return Text.rich(
      TextSpan(
        text: '',
        children: children,
      ),
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
      ),
    );
  }
}

class _DoneListWorkitemWidget extends StatefulWidget {
  PageContext context;

  _DoneListWorkitemWidget({this.context});

  @override
  __DoneListWorkitemWidgetState createState() =>
      __DoneListWorkitemWidgetState();
}

class __DoneListWorkitemWidgetState extends State<_DoneListWorkitemWidget> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _workitems.clear();
    await _onload();
  }

  Future<void> _onload() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    List<WorkItem> list =
        await workflowRemote.pageMyWorkItemByFilter(1, _limit, _offset);
    if (list.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      return;
    }
    _offset += list.length;
    _workitems.addAll(list);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      controller: _controller,
      onLoad: _onload,
      onRefresh: _onRefresh,
      slivers: _renderWorkitemList(),
    );
  }

  List<Widget> _renderWorkitemList() {
    var workitems = <Widget>[];
    if (_workitems.isEmpty) {
      workitems.add(
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Text(
                '没有工作项',
              ),
            ),
          ),
        ),
      );
    }
    for (var item in _workitems) {
      var inst = item.workInst;
      var event = item.workEvent;
//      var data=jsonDecode(event.data);
      workitems.add(
        SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _showForm(widget.context, context, item);
            },
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: SizedBox(
                        width: 35,
                        height: 35,
                        child: Center(
                          child: Image.network(
                            '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${inst.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${TimelineUtil.formatByDateTime(
                                  parseStrTime(event.ctime),
                                  dayFormat: DayFormat.Full,
                                )}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '件号:${event.id}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          _renderData(item),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '待处理: ',
                                    children: [
                                      TextSpan(
                                        text: '${event.title}',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n发送人: ${event.sender ?? '-'}',
                                      ),
                                      TextSpan(
                                        text:
                                            '\n处理人: ${event.recipient ?? '-'}',
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '',
                                    children: [
                                      TextSpan(
                                        text: '当前是第',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${event.stepNo + 1}',
                                      ),
                                      TextSpan(
                                        text: '步',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                  child: Divider(
                    height: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return workitems;
  }

  void _showForm(PageContext pageContext, BuildContext context, WorkItem item) {
    var inst = item.workInst;
    switch (inst.workflow) {
      case 'workflow.isp.apply':
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return pageContext.part(
              '/work/workitem/adoptISP',
              context,
              arguments: {'workitem': item},
            );
          },
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      case 'workflow.la.apply':
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return pageContext.part(
              '/work/workitem/adoptLA',
              context,
              arguments: {'workitem': item},
            );
          },
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      default:
        break;
    }
  }

  Widget _renderData(WorkItem item) {
    var inst = item.workInst;
    var event = item.workEvent;
    var children = <InlineSpan>[];
    switch (inst.workflow) {
      case 'workflow.isp.apply':
        var data = event.data;
        var form = jsonDecode(data);
        children.add(
          TextSpan(
            text: '公司:${form['cropName']}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '运营区域:${form['bussinessAreaTitle']}\n',
          ),
        );

        children.add(
          TextSpan(
            text: '运营期限:${form['operatePeriod']}个月\n',
          ),
        );
        children.add(
          TextSpan(
            text:
                '服务费:¥${((form['fee'] as int) / 1000000).toStringAsFixed(2)}万元\n',
          ),
        );
        children.add(
          TextSpan(
            text:
                '支付凭证:${StringUtil.isEmpty(form['payEvidence']) ? '无' : '已上传'}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '\n申请人:${inst.creator}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '真实名:${form['masterRealName']}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '电话:${form['masterPhone']}',
          ),
        );
        break;
      default:
        children.add(
          TextSpan(
            text: '暂不支持对本步骤的处理',
          ),
        );
        break;
    }
    return Text.rich(
      TextSpan(
        text: '',
        children: children,
      ),
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
      ),
    );
  }
}

class _CreatedInstWorkitemWidget extends StatefulWidget {
  PageContext context;

  _CreatedInstWorkitemWidget({this.context});

  @override
  __CreatedInstWorkitemWidgetState createState() =>
      __CreatedInstWorkitemWidgetState();
}

class __CreatedInstWorkitemWidgetState
    extends State<_CreatedInstWorkitemWidget> {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<WorkItem> _workitems = [];

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _workitems.clear();
    await _onload();
  }

  Future<void> _onload() async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    List<WorkItem> list =
        await workflowRemote.pageMyWorkItemByFilter(2, _limit, _offset);
    if (list.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      return;
    }
    _offset += list.length;
    _workitems.addAll(list);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      controller: _controller,
      onLoad: _onload,
      onRefresh: _onRefresh,
      slivers: _renderWorkitemList(),
    );
  }

  List<Widget> _renderWorkitemList() {
    var workitems = <Widget>[];
    if (_workitems.isEmpty) {
      workitems.add(
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Text(
                '没有工作项',
              ),
            ),
          ),
        ),
      );
    }
    for (var item in _workitems) {
      var inst = item.workInst;
      var event = item.workEvent;
//      var data=jsonDecode(event.data);
      workitems.add(
        SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _showForm(widget.context, context, item);
            },
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: SizedBox(
                        width: 35,
                        height: 35,
                        child: Center(
                          child: Image.network(
                            '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${inst.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${TimelineUtil.formatByDateTime(
                                  parseStrTime(event.ctime),
                                  dayFormat: DayFormat.Full,
                                )}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '件号:${event.id}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          _renderData(item),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '待处理: ',
                                    children: [
                                      TextSpan(
                                        text: '${event.title}',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n发送人: ${event.sender}',
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '',
                                    children: [
                                      TextSpan(
                                        text: '当前是第',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${event.stepNo + 1}',
                                      ),
                                      TextSpan(
                                        text: '步',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                  child: Divider(
                    height: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return workitems;
  }

  void _showForm(PageContext pageContext, BuildContext context, WorkItem item) {
    var inst = item.workInst;
    switch (inst.workflow) {
      case 'workflow.isp.apply':
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return pageContext.part(
              '/work/workitem/adoptISP',
              context,
              arguments: {'workitem': item},
            );
          },
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      case 'workflow.la.apply':
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return pageContext.part(
              '/work/workitem/adoptLA',
              context,
              arguments: {'workitem': item},
            );
          },
        ).then((value) async {
          if (StringUtil.isEmpty(value)) {
            return;
          }
          _workitems.clear();
          _offset = 0;
          _onload();
        });
        break;
      default:
        break;
    }
  }

  Widget _renderData(WorkItem item) {
    var inst = item.workInst;
    var event = item.workEvent;
    var children = <InlineSpan>[];
    switch (inst.workflow) {
      case 'workflow.isp.apply':
        var data = event.data;
        var form = jsonDecode(data);
        children.add(
          TextSpan(
            text: '公司:${form['cropName']}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '运营区域:${form['bussinessAreaTitle']}\n',
          ),
        );

        children.add(
          TextSpan(
            text: '运营期限:${form['operatePeriod']}个月\n',
          ),
        );
        children.add(
          TextSpan(
            text:
                '服务费:¥${((form['fee'] as int) / 1000000).toStringAsFixed(2)}万元\n',
          ),
        );
        children.add(
          TextSpan(
            text:
                '支付凭证:${StringUtil.isEmpty(form['payEvidence']) ? '无' : '已上传'}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '\n申请人:${inst.creator}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '真实名:${form['masterRealName']}\n',
          ),
        );
        children.add(
          TextSpan(
            text: '电话:${form['masterPhone']}',
          ),
        );
        break;
      default:
        children.add(
          TextSpan(
            text: '暂不支持对本步骤的处理',
          ),
        );
        break;
    }
    return Text.rich(
      TextSpan(
        text: '',
        children: children,
      ),
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
      ),
    );
  }
}
