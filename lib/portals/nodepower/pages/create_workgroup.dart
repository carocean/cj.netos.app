import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:netos_app/portals/nodepower/remote/workgroup_remote.dart';

class CreateWorkgroup extends StatefulWidget {
  PageContext context;

  CreateWorkgroup({this.context});

  @override
  _CreateWorkgroupState createState() => _CreateWorkgroupState();
}

class _CreateWorkgroupState extends State<CreateWorkgroup> {
  TextEditingController _code;
  TextEditingController _name;
  TextEditingController _note;
  bool _saving = false;

  @override
  void initState() {
    _code = TextEditingController();
    _name = TextEditingController();
    _note = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _code?.dispose();
    _name?.dispose();
    _note?.dispose();
    super.dispose();
  }

  bool _checkDoneButtonEnabled() {
    return !_saving &&
        !StringUtil.isEmpty(_code.text) &&
        !StringUtil.isEmpty(_name.text) ;
  }

  Future<void> _createWorkgroup() async {
    _saving = true;
    setState(() {});
    IWorkgroupRemote workgroupRemote =
        widget.context.site.getService('/remote/org/workgroup');
    var workgroup = await workgroupRemote.createWorkgroup(
        _code.text, _name.text, _note.text);
    widget.context.backward(result: {'workgroup': workgroup});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建工作组'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton(
            child: Text(
              _saving ? '处理中...' : '完成',
            ),
            onPressed: !_checkDoneButtonEnabled()
                ? null
                : () {
                    _createWorkgroup();
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
                    controller: _code,
                    decoration: InputDecoration(
                      labelText: '组标识',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                      hintText: '输入组标识，为英文，以.号分词',
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
                      labelText: '组名',
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
