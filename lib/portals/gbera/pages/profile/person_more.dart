import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class PersonProfileViewMore extends StatefulWidget {
  PageContext context;

  PersonProfileViewMore({this.context});

  @override
  _PersonProfileViewMoreState createState() => _PersonProfileViewMoreState();
}

class _PersonProfileViewMoreState extends State<PersonProfileViewMore> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '更多详情',
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
    var personInfo=widget.context.parameters['personInfo'];
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listDomainValueOfPerson',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'groupId': widget.group.groupId,
        'person':personInfo['person'],
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
                  index < _fields.length
                      ? Divider(
                          height: 1,
                        )
                      : Container(
                          height: 0,
                          width: 0,
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15,bottom: 15,),
      child: Row(
        children: <Widget>[
          Text(
            widget.field.fieldName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Text('${widget.field.content ?? ''}'),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
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
