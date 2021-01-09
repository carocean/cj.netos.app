import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/remotes/operation_screen.dart';
import 'package:intl/intl.dart' as intl;

class PopupRulePage extends StatefulWidget {
  PageContext context;

  PopupRulePage({this.context});

  @override
  _PopupRulePageState createState() => _PopupRulePageState();
}

class _PopupRulePageState extends State<PopupRulePage> {
  List<PopupRuleOR> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    var rules = await screenRemote.listPopupRule();
    _rules.addAll(rules);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic body;
    if (_isLoading) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('正在加载...'),
          ),
        ],
      );
    } else {
      body = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _renderItems(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('弹屏规则参数设置'),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: body,
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    if (_rules.isEmpty) {
      items.add(
        SizedBox(
          height: 60,
          child: Align(
            alignment: Alignment.center,
            child: Text('没有规则'),
          ),
        ),
      );
      return items;
    }
    for (var i = 0; i < _rules.length; i++) {
      var r = _rules[i];
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                color: Colors.black54,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r.name ?? ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '标识: ${r.code ?? ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    StringUtil.isEmpty(r.args)
                        ? SizedBox(
                            width: 0,
                            height: 0,
                          )
                        : Text('${r.args ?? ''}'),
                  ],
                ),
              ),
              r.code != 'begin_time'
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : InkWell(
                      onTap: () async {
                        var time = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.parse('2050-12-20'),
                        );
                        var map = {};
                        map['display'] =
                            '${intl.DateFormat('yyyy-MM-dd HH:mm:ss').format(time)}';
                        map['time']=time.millisecondsSinceEpoch;
                        var args = jsonEncode(map);
                        IScreenRemote screenRemote =
                            widget.context.site.getService('/operation/screen');
                        await screenRemote.updatePopupRuleArgs(r.code, args);
                        r.args = args;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 10,
                          left: 10,
                        ),
                        child: Icon(
                          Icons.settings,
                          size: 14,
                        ),
                      ),
                    )
            ],
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
        ),
      );
    }
    return items;
  }
}
