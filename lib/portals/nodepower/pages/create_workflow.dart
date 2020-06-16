import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class CreateWorkflow extends StatefulWidget {
  PageContext context;

  CreateWorkflow({this.context});

  @override
  _CreateWorkflowState createState() => _CreateWorkflowState();
}

class _CreateWorkflowState extends State<CreateWorkflow> {
  TextEditingController _id;
  TextEditingController _name;
  TextEditingController _note;
  String _icon;
  String _icon_local;
  bool _icon_uploading = false;
  int _upload_icon_i = 0, _upload_icon_j = 1;
  bool _saving = false;

  @override
  void initState() {
    _id = TextEditingController();
    _name = TextEditingController();
    _note = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _id?.dispose();
    _name?.dispose();
    _note?.dispose();
    super.dispose();
  }

  bool _checkDoneButtonEnabled() {
    return !_saving &&
        !StringUtil.isEmpty(_id.text) &&
        !StringUtil.isEmpty(_name.text) &&
        !StringUtil.isEmpty(_icon);
  }

  Future<void> _createWorkflow() async {
    _saving = true;
    setState(() {});
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    var workflow = await workflowRemote.createWorkflow(
        _id.text, _name.text, _icon, _note.text);
    widget.context.backward(result: {'workflow': workflow});
  }

  Future<void> _uploadIcon(avatar) async {
    _icon_local = avatar;
    _icon_uploading = true;
    setState(() {});
    var map = await widget.context.ports.upload('/app/org/workflow/', [avatar],
        onSendProgress: (i, j) {
      _upload_icon_i = i;
      _upload_icon_j = j;
      if (i == j) {
        _icon_uploading = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
    _icon = map[avatar];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建流程'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton(
            child: Text(
              _saving ? '处理中...' : '完成',
            ),
            onPressed: !_checkDoneButtonEnabled()
                ? null
                : () {
                    _createWorkflow();
                  },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        constraints: BoxConstraints.expand(),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              padding: EdgeInsets.all(15),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TextField(
                    controller: _id,
                    decoration: InputDecoration(
                      labelText: '流程标识',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                      hintText: '输入流程标识，为英文，以.号分词',
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: '流程名',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                      hintText: '输入流程名，中文名',
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '流程图标',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                widget.context
                                    .forward('/widgets/avatar', arguments: {
                                  'aspectRatio': -1.0,
                                }).then((avatar) {
                                  if (StringUtil.isEmpty(avatar)) {
                                    return;
                                  }
                                  _uploadIcon(avatar);
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  '上传',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        StringUtil.isEmpty(_icon_local)
                            ? SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Center(
                                child: Image.file(
                                  File(_icon_local),
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                        !_icon_uploading
                            ? SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                  top: 5,
                                ),
                                child: Text(
                                  '${((_upload_icon_i * 1.0 / _upload_icon_j) * 100.00).toStringAsFixed(0)}%',
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  TextField(
                    controller: _note,
                    decoration: InputDecoration(
                      labelText: '备注',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                      hintText: '输入备注',
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setState(() {});
                    },
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
