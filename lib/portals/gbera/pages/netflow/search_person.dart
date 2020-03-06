import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/portals/gbera/store/pics/downloads.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class _PersonInfo {
  String person;
  String uid;
  String accountCode;
  String nickName;
  String realName;
  String signature;
  String avatar;
  String appid;
  Map domains;
  Map groups;
  Map fields;

  String tenantid;

  void load(obj) {
    person = obj['person'];
    uid = obj['uid'];
    accountCode = obj['accountCode'];
    nickName = obj['nickName'];
    realName = obj['realName'];
    signature = obj['signature'];
    avatar = obj['avatar'];
    appid = obj['appid'];
    domains = obj['domains'];
    groups = obj['groups'];
    fields = obj['fields'];
    int pos = appid.lastIndexOf('.');
    tenantid = pos > -1 ? appid.substring(pos + 1) : '';
  }
}

class PersonSearchDelegate extends SearchDelegate<String> {
  PageContext context;

  PersonSearchDelegate(this.context)
      : super(
          searchFieldLabel: '公号/统一号/手机号等',
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    //右侧显示内容 这里放清除按钮
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //左侧显示内容 这里放了返回按钮
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResultList(
      query: query,
      context: this.context,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _PersonSuggestions(query: query, context: this.context);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      textTheme: TextTheme(
        title: TextStyle(
          fontSize: 14,
        ),
      ),
      primaryColor: Theme.of(context).primaryColor,
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        textTheme: Theme.of(context).appBarTheme.textTheme,
        color: Theme.of(context).appBarTheme.color,
        actionsIconTheme: Theme.of(context).appBarTheme.actionsIconTheme,
        brightness: Theme.of(context).appBarTheme.brightness,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
    );
  }
}

class SearchResultList extends StatefulWidget {
  String query;
  PageContext context;

  SearchResultList({this.query, this.context});

  @override
  _SearchResultListState createState() => _SearchResultListState();
}

class _SearchResultListState extends State<SearchResultList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _findPersons(),
      builder: (ctx, snapshort) {
        if (snapshort.connectionState != ConnectionState.done) {
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshort.hasError) {
          throw FlutterError(snapshort.error);
        }
        if (!snapshort.hasData) {
          return Center(
            child: Text('没有数据'),
          );
        }
        var _items = <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
              ),
              child: Text(
                '搜索结果',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ];
        for (var p in snapshort.data) {
          _items.add(
            SliverToBoxAdapter(
              child: _PersonCard(context: widget.context, person: p),
            ),
          );
        }
        return CustomScrollView(
          shrinkWrap: true,
          slivers: _items,
        );
      },
    );
  }

  Future<List<_PersonInfo>> _findPersons() async {
    var url = widget.context.site.getService('@.prop.ports.uc.person');
    List<_PersonInfo> _persons = [];
    await widget.context.ports(
      'get $url netos/1.0',
      restCommand: 'searchPersons',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'keywords': widget.query,
      },
      onsucceed: ({rc, response}) {
        var json = rc['dataText'];
        var list = jsonDecode(json);
        for (var obj in list) {
          var person = _PersonInfo();
          person.load(obj);
          _persons.add(person);
        }
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
    return _persons;
  }
}

class _PersonSuggestions extends StatefulWidget {
  String query;
  PageContext context;

  _PersonSuggestions({this.query, this.context});

  @override
  __PersonSuggestionsState createState() => __PersonSuggestionsState();
}

class __PersonSuggestionsState extends State<_PersonSuggestions> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      shrinkWrap: true,
      controller: _controller,
      onRefresh: _onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
            ),
            child: Text(
              '推荐',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
//        SliverToBoxAdapter(
//          child: _PersonCard(context:widget.context),
//        ),
//        SliverToBoxAdapter(
//          child: _PersonCard(context:widget.context),
//        ),
//        SliverToBoxAdapter(
//          child: _PersonCard(context:widget.context),
//        ),
//        SliverToBoxAdapter(
//          child: _PersonCard(context:widget.context),
//        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    return;
  }
}

class _PersonCard extends StatefulWidget {
  PageContext context;
  _PersonInfo person;

  _PersonCard({this.context, this.person});

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  _PersonInfo _person;
  var _hitsGz = false;
  var _hitsQx = false;
  @override
  void initState() {
    _person = widget.person;
    super.initState();
  }

  @override
  void dispose() {
    _person = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(_PersonCard oldWidget) {
    if (oldWidget.person != widget.person) {
      _person = oldWidget.person;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Image.network(
                  '${_person?.avatar}?accessToken=${widget.context.principal.accessToken}',
                  fit: BoxFit.cover,
                  width: 140,
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${_person?.nickName}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${_person?.person}',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${_person?.signature ?? ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 15,
          child: Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.grey[300],
                  ),
                  Text(
                    '2km',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              FutureBuilder<bool>(
                future: _isAddedPerson(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container(
                      height: 0,
                      width: 0,
                    );
                  }
                  if (snapshot.hasError) {
                    return Container(
                      height: 0,
                      width: 0,
                    );
                  }
                  var isAdded = snapshot.data;
                  if (isAdded != null && isAdded) {

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _hitsQx
                          ? null
                          : () {
                              _hitsQx = true;
                              setState(() {});
                              _removePerson();
                            },
                      child: Text(
                        _hitsQx?'取消中...':'不再关注',
                        style: TextStyle(
                          color: _hitsQx ? Colors.grey[400] : Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _hitsGz
                        ? null
                        : () {
                            _hitsGz = true;
                            setState(() {});
                            _savePerson();
                          },
                    child: Text(
                      _hitsGz?'关注中...':'关注',
                      style: TextStyle(
                        color: _hitsGz ? Colors.grey[400] : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _isAddedPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.existsPerson(_person.person);
  }

  _savePerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var dio = widget.context.site.getService('@.http');

    Person person = Person(
        Uuid().v1(),
        _person.person,
        _person.uid,
        _person.person,
        _person.accountCode,
        _person.appid,
        _person.tenantid,
        await Downloads.downloadPersonAvatar(
            dio: dio,
            avatarUrl:
                '${_person.avatar}?accessToken=${widget.context.principal.accessToken}'),
        null,
        _person.nickName,
        _person.signature,
        PinyinHelper.getPinyin(_person.nickName),
        widget.context.principal.person);
    await personService.addPerson(person);
    _hitsGz=false;
    _hitsQx=false;
    setState(() {});
  }

  _removePerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(_person.person);
    _hitsGz=false;
    _hitsQx=false;
    setState(() {});
  }
}
