import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class ImportPersons extends StatefulWidget {
  PageContext context;

  ImportPersons({this.context});

  @override
  _ImportPersonsState createState() => _ImportPersonsState();
}

class _ImportPersonsState extends State<ImportPersons> {
  TextEditingController _controller;
  String _query = '';
  List<String> _selectedPersons;

  @override
  void initState() {
    _selectedPersons = [];
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _query = '';
    _selectedPersons.clear();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _importPersons() async {
    if (_selectedPersons.isEmpty) {
      return;
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<Person> persons = await personService.listPersonWith(_selectedPersons);
    IFriendService friendService =
        widget.context.site.getService('/gbera/friends');
    for (var person in persons) {
      if (await friendService.exists(person.official)) {
        continue;
      }
      await friendService.addFriend(
        Friend(
          Uuid().v1(),
          person.official,
          'person',
          person.uid,
          person.accountid,
          person.accountName,
          person.appid,
          person.tenantid,
          person.avatar,
          person.rights,
          person.nickName,
          person.signature,
          person.pyname,
          widget.context.principal.person,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: TextField(
          controller: _controller,
          onChanged: (v) {
            _query = v;
            setState(() {});
          },
          onSubmitted: (v) {
            _query = v;
            setState(() {});
          },
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            hintText: '公众',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _controller.clear();
              _query = '';
              setState(() {});
            },
            icon: Icon(
              Icons.clear_all,
            ),
          ),
          IconButton(
            onPressed: () {
              _importPersons().then((v) {
                widget.context.backward();
              });
            },
            icon: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: PersonList(
          query: _query,
          context: widget.context,
          selectedPersons: _selectedPersons,
        ),
      ),
    );
  }
}

class PersonList extends StatefulWidget {
  String query;
  PageContext context;
  List<String> selectedPersons;

  PersonList({
    this.query,
    this.context,
    this.selectedPersons,
  });

  @override
  _PersonListState createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> {
  List<Person> _persons;
  int _limit = 20;
  int _offset = 0;
  EasyRefreshController _controller;

  @override
  void didUpdateWidget(PersonList oldWidget) {
    if (oldWidget.query != widget.query) {
      _offset = 0;
      _persons.clear();
      _onLoad().then((v) {
        setState(() {});
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _persons = [];
    _controller = EasyRefreshController();
    _onLoad().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _offset = 0;
    _persons.clear();
    _controller.dispose();
    super.dispose();
  }

  Future<List<Person>> _onLoad() async {
    IPersonService personService =
        widget.context.site.getService("/gbera/persons");
    List<Person> persons;
    persons = await personService.pagePersonLikeName(
        '${widget.query}%', _limit, _offset);
    if (persons.isEmpty) {
      _controller.finishLoad(noMore: true, success: true);
      return _persons;
    }
    _offset += persons.length;
    _persons.addAll(persons);
    return _persons;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          padding: EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 0,
            right: 15,
          ),
          alignment: Alignment.center,
          child: Text(
            '长按公众选中',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
        EasyRefresh.custom(
          controller: _controller,
          onLoad: () async {
            _onLoad().then((v) {
              setState(() {});
            });
          },
          shrinkWrap: true,
          slivers: _persons.map((person) {
            var _avatar = person.avatar;
            var avatarImage;
            if (StringUtil.isEmpty(_avatar)) {
              avatarImage = Image.asset(
                'lib/portals/gbera/images/avatar.png',
                width: 35,
                height: 35,
              );
            } else if (_avatar.startsWith("/")) {
              avatarImage = Image.file(
                File(_avatar),
                width: 35,
                height: 35,
              );
            } else {
              avatarImage = Image.network(
                '${person.avatar}',
                fit: BoxFit.cover,
                width: 35,
                height: 35,
              );
            }
            var official = PersonUtil.officialBy(person);
            return SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    CardItem(
                      title: person.nickName ?? person.accountName,
                      paddingLeft: 15,
                      paddingRight: 15,
                      paddingBottom: 10,
                      paddingTop: 10,
                      leading: ClipRRect(
                        child: avatarImage,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      onItemTap: () {
                        widget.context.forward('/site/personal',
                            arguments: {'person': person});
                      },
                      tipsIconData: widget.selectedPersons.contains(official)
                          ? Icons.check
                          : IconData(
                              0x00,
                            ),
                      onItemLongPress: () {
                        if (widget.selectedPersons.contains(official)) {
                          widget.selectedPersons.remove(official);
                        } else {
                          widget.selectedPersons.add(official);
                        }
                        setState(() {});
                      },
                    ),
                    Divider(height: 1, indent: 60),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
