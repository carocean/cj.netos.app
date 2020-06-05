import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class ProfileMore extends StatefulWidget {
  PageContext context;

  ProfileMore({this.context});

  @override
  _ProfileMoreState createState() => _ProfileMoreState();
}

class _ProfileMoreState extends State<ProfileMore> {
  List<_DomainGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups().then((v) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _groups.clear();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.platform')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listDomainGroup',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      onsucceed: ({rc, response}) async {
        var json = rc['dataText'];
        var info = jsonDecode(json);
        _groups.clear();
        for (var g in info) {
          _groups.add(
            _DomainGroup(
              groupId: g['groupId'],
              groupName: g['groupName'],
            ),
          );
        }
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var personInfo =
        widget.context.parameters['personInfo'] as Map<String, dynamic>;
    var domains = personInfo['domains'];
    print(domains);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: _groups.map((g) {
                return _GroupWidget(
                  group: g,
                  context: widget.context,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupWidget extends StatefulWidget {
  _DomainGroup group;
  PageContext context;

  _GroupWidget({this.context, this.group});

  @override
  __GroupWidgetState createState() => __GroupWidgetState();
}

class __GroupWidgetState extends State<_GroupWidget> {
  List<_DomainField> _fields = [];

  @override
  void initState() {
    super.initState();
    _loadFields().then((v) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fields.clear();
    super.dispose();
  }

  Future<void> _loadValues() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listDomainValueOfGroup',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'groupId': widget.group.groupId,
      },
      onsucceed: ({rc, response}) async {
        var json = rc['dataText'];
        var info = jsonDecode(json);
        for (var v in info) {
          var content = v['content'];
          var fieldid = v['fieldId'];
          for (var f in _fields) {
            if (f.fieldId == fieldid) {
              f.content = content;
              break;
            }
          }
        }
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  Future<void> _loadFields() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.platform')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listDomainField',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'groupId': widget.group.groupId,
      },
      onsucceed: ({rc, response}) async {
        var json = rc['dataText'];
        var info = jsonDecode(json);
        _fields.clear();
        for (var f in info) {
          _fields.add(
            _DomainField(
              fieldId: f['fieldId'],
              fieldName: f['fieldName'],
              fieldDesc: f['fieldDesc'],
            ),
          );
        }
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
    await _loadValues();
  }

  @override
  Widget build(BuildContext context) {
    var index = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 10,
            left: 10,
            right: 10,
          ),
          child: Text(
            '${widget.group.groupName ?? ''}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          ),
          child: Column(
            children: _fields.map((f) {
              index++;
              return Column(
                children: <Widget>[
                  _FieldItem(
                    field: f,
                    context: widget.context,
                  ),
                  index < _fields.length?
                    Divider(
                      height: 1,
                    ):Container(height: 0,width: 0,),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FieldItem extends StatefulWidget {
  _DomainField field;
  PageContext context;

  _FieldItem({
    this.field,
    this.context,
  });

  @override
  __FieldItemState createState() => __FieldItemState();
}

class __FieldItemState extends State<_FieldItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _setFieldValue(v) async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'setDomainValue',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'fieldId': widget.field.fieldId,
        'content': v,
      },
      onsucceed: ({rc, response}) async {
        widget.field.content = v;
        setState(() {});
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            right: 10,
            top: 15,
            bottom: 15,
          ),
          child: Text(
            widget.field.fieldName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: _GberaTextField(
            initContent: StringUtil.isEmpty(widget.field.content)
                ? '请输入${widget.field.fieldDesc ?? ''}'
                : widget.field.content,
            onSubmit: (v) {
              _setFieldValue(v);
            },
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class _GberaTextField extends StatefulWidget {
  String initContent;
  Function(String value) onSubmit;

  _GberaTextField({this.initContent, this.onSubmit});

  @override
  __GberaTextFieldState createState() => __GberaTextFieldState();
}

class __GberaTextFieldState extends State<_GberaTextField> {
  int _index = 0;
  String _content;
  TextEditingController _valueController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _content = widget.initContent;
    _valueController = TextEditingController(text: widget.initContent);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_GberaTextField oldWidget) {
    if (oldWidget.initContent != widget.initContent) {
      _content = widget.initContent;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      alignment: Alignment.centerLeft,
      index: _index,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _index = 1;
            setState(() {});
          },
          child: Container(
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Text.rich(
              TextSpan(text: '${_content ?? ''}'),
              style: TextStyle(
                fontSize: 14,
              ),
              softWrap: true,
            ),
          ),
        ),
        TextField(
          controller: _valueController,
          minLines: 1,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: '请输入',
            border: InputBorder.none,
            suffix: _index == 0
                ? null
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _index = 0;
                      _content = _valueController.text;
                      if (widget.onSubmit != null) {
                        widget.onSubmit(_content);
                      }
                      setState(() {});
                    },
                    child: Icon(
                      Icons.check,
                      color: Colors.red,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _DomainGroup {
  String groupId;
  String groupName;

  _DomainGroup({
    this.groupId,
    this.groupName,
  });
}

class _DomainField {
  String fieldId;
  String fieldName;
  String fieldDesc;
  String content;

  _DomainField({this.fieldId, this.fieldName, this.fieldDesc, this.content});
}
