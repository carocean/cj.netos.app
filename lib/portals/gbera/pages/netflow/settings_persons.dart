import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:uuid/uuid.dart';

class SettingsPersons extends StatefulWidget {
  PageContext context;

  SettingsPersons({this.context});

  @override
  _SettingsPersonsState createState() => _SettingsPersonsState();
}

class _SettingsPersonsState extends State<SettingsPersons> {
  List<CardItem> personCardItems = [];
  int limit = 20;
  int offset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    personCardItems.clear();
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
            child: FutureBuilder(
              future: _onLoadPersons('up'),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.grey[600]),
                    ),
                  );
                }
                return PersonsView(
                  personCardItems: personCardItems,
                  onLoadPersons: _onLoadPersons,
                );
              },
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

  Future<void> _onLoadPersons([String director = 'up']) async {
    if (director == 'down') {
      return;
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<Person> persons = await personService.pagePerson(limit, offset);
    if (persons.length == 0) {
      return;
    }
    offset += persons.length;
    for (var person in persons) {
      var item = CardItem(
        title: person.accountName,
        leading: Image.file(
          File(person.avatar),
          width: 40,
          height: 40,
        ),
        onItemTap: () {
          widget.context
              .forward('/site/personal', arguments: {'person': person});
        },
      );
      this.personCardItems.add(item);
    }
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
            ).then((result){
              print('----$result');
            });
            break;
          case '/netflow/manager/scan_person':
            String cameraScanResult = await scanner.scan();
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

class PersonsView extends StatefulWidget {
  List<CardItem> personCardItems;
  Future<void> Function(String director) onLoadPersons;

  PersonsView({this.personCardItems, this.onLoadPersons});

  @override
  _PersonsViewState createState() => _PersonsViewState();
}

class _PersonsViewState extends State<PersonsView> {
  @override
  Widget build(BuildContext context) {
    return SwipeRefreshLayout(
      onSwipeDown: () async {
        await widget.onLoadPersons('down');
      },
      onSwipeUp: () async {
        await widget.onLoadPersons('up');
        setState(() {});
      },
      child: ListView(
        children: widget.personCardItems.map((item) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                color: Colors.white,
                child: Dismissible(
                  key: Key('key_${Uuid().v1()}'),
                  child: item,
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await _showConfirmationDialog(context) == 'yes';
                    }
                    return false;
                  },
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete_sweep,
                      size: 16,
                    ),
                  ),
                  background: Container(),
                  onDismissed: (direction) {
                    switch (direction) {
                      case DismissDirection.endToStart:
                        print('---------do deleted');
                        break;
                      case DismissDirection.vertical:
                        // TODO: Handle this case.
                        break;
                      case DismissDirection.horizontal:
                        // TODO: Handle this case.
                        break;
                      case DismissDirection.startToEnd:
                        // TODO: Handle this case.
                        break;
                      case DismissDirection.up:
                        // TODO: Handle this case.
                        break;
                      case DismissDirection.down:
                        // TODO: Handle this case.
                        break;
                    }
                  },
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
