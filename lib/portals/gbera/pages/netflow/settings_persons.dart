import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class SettingsPersons extends StatefulWidget {
  PageContext context;

  SettingsPersons({this.context});

  @override
  _SettingsPersonsState createState() => _SettingsPersonsState();
}

class _SettingsPersonsState extends State<SettingsPersons> {
  _Refresher __refresher = _Refresher();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    __refresher = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.context.page.title),
        automaticallyImplyLeading: true,
        centerTitle: false,
        elevation: 0.0,
        titleSpacing: 0,
        actions: <Widget>[
          _getPopupMenu(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 5,
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                  child: Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
                FutureBuilder(
                  future: _onLoadPersonCount(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Text('...');
                    }
                    return Text.rich(
                      TextSpan(
                        text: '${snapshot.data}人',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        children: [],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: PersonsView(
              context: widget.context,
              refresher: __refresher,
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _onLoadPersonCount() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    int count = await personService.count();
    return count;
  }

  _getPopupMenu() {
    return PopupMenuButton<String>(
      offset: Offset(
        0,
        50,
      ),
      onSelected: (value) async {
        if (value == null) return;
        var arguments = <String, Object>{};
        switch (value) {
          case '/netflow/manager/search_person':
//            widget.context.forward(value, arguments: null);
            showSearch(
              context: context,
              delegate: PersonSearchDelegate(widget.context),
            ).then((v) {
              __refresher.fireRefresh();
            });
            break;
          case '/netflow/manager/scan_person':
            String cameraScanResult = await scanner.scan(widget.context);
            if (cameraScanResult == null) break;
            arguments['qrcode'] = cameraScanResult;
            widget.context.forward(value, arguments: arguments);
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: '/netflow/manager/search_person',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  widget.context
                      .findPage('/netflow/manager/search_person')
                      ?.icon,
                  color: Colors.grey[500],
                  size: 15,
                ),
              ),
              Text(
                '搜索以添加',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: '/netflow/manager/scan_person',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  widget.context.findPage('/netflow/manager/scan_person')?.icon,
                  color: Colors.grey[500],
                  size: 15,
                ),
              ),
              Text(
                '扫码以添加',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Refresher {
  Function() callback;

  void fireRefresh() {
    if (callback != null) {
      callback();
    }
  }
}

class PersonsView extends StatefulWidget {
  PageContext context;
  _Refresher refresher;

  PersonsView({this.context, this.refresher});

  @override
  _PersonsViewState createState() => _PersonsViewState();
}

class _PersonsViewState extends State<PersonsView> {
  int limit = 20;
  int offset = 0;
  EasyRefreshController _controller;
  List<Person> _persons = [];

  @override
  void initState() {
    widget.refresher.callback = () {
      _refresh();
    };
    _controller = EasyRefreshController();
    _onLoadPersons().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _persons.clear();
    super.dispose();
  }

  Future<void> _refresh() async {
    offset = 0;
    _persons.clear();
    _onLoadPersons().then((v) {
      setState(() {});
    });
  }

  Future<void> _onLoadPersons([String director = 'up']) async {
    if (director == 'down') {
      return;
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<Person> persons = await personService.pagePerson(limit, offset);
    if (persons.length == 0) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    offset += persons.length;
    _persons.addAll(persons);
  }

  _removePerson(Person p) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(p.official);
    _persons.remove(p);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: easyRefreshHeader(),
      footer: easyRefreshFooter(),
      controller: _controller,
      onLoad: () async {
        await _onLoadPersons('up');
        setState(() {});
      },
      child: ListView(
        children: _persons.map((item) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: '删除',
                      foregroundColor: Colors.grey[500],
                      icon: Icons.delete,
                      onTap: () {
                        _removePerson(item);
                      },
                    ),
                  ],
                  child: CardItem(
                    title: item.nickName,
                    subtitle: Text(
                      item.official,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    leading: Image.file(
                      File(item.avatar),
                      width: 40,
                      height: 40,
                    ),
                    onItemTap: () {
                      if (widget.context.parameters['personViewer'] ==
                          'chasechain') {
                        widget.context.forward('/person/view',
                            arguments: {'person': item});
                        return;
                      }
                      widget.context.forward('/site/personal',
                          arguments: {'person': item}).then((v) {
                        _refresh();
                      });
                    },
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<String> _showConfirmationDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text.rich(
          TextSpan(
            text: '是否移除？',
            children: [
              TextSpan(text: '\r\n'),
              TextSpan(
                text: '从管道移除后可在我的公众中找回',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 'no');
            },
          ),
          FlatButton(
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 'yes');
            },
          ),
        ],
      ),
    );
  }
}
