import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
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

  toPerson() {
    return Person(person, uid, accountCode, appid, avatar, null, nickName,
        signature, null, null);
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

class _SearchResultListState extends State<SearchResultList>
    with AutomaticKeepAliveClientMixin {
  List<_PersonInfo> _persons = [];

  @override
  void initState() {
    () async {
      var list = await _findPersons();
      _persons.addAll(list);
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //必须加上这个，否则无效
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
    for (var p in _persons) {
      _items.add(
        SliverToBoxAdapter(
          child: _PersonCard(context: widget.context, person: p),
        ),
      );
    }
    return CustomScrollView(
      slivers: _items,
    );
  }

  Future<List<_PersonInfo>> _findPersons() async {
    var url = widget.context.site.getService('@.prop.ports.uc.person');
    List<_PersonInfo> _persons = [];
    await widget.context.ports.callback(
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

  @override
  bool get wantKeepAlive {
    return true;
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
  bool _isSearching = false;
  int _radius = 2000;
  int _limit = 20, _offset = 0;
  LatLng _location;
  List<GeoPOI> _pois = [];
  Map<String, bool> _hasPerson = {};

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PersonSuggestions oldWidget) {
    if (oldWidget.query != widget.query) {
      oldWidget.query = widget.query;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onRefresh() async {
    return;
  }

  Future<void> _load() async {
    if (_isSearching) {
      return;
    }
    _isSearching = true;
    var location = await AmapLocation.fetchLocation();
    _location = await location.latLng;
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    var items = await receptorRemote.searchAroundLocation(
        _location, _radius, 'mobiles', _limit /*各类取2个*/, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(
        success: true,
        noMore: true,
      );
      _isSearching = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += items.length;
    for (var poi in items) {
      if (poi.creator == null ||
          poi.receptor.creator == widget.context.principal.person) {
        continue;
      }
      if (_hasPerson.containsKey(poi.creator.official)) {
        continue;
      }
      _hasPerson[poi.creator.official] = true;
      _pois.add(poi);
    }
    _isSearching = false;
    if (mounted) {
      setState(() {});
    }
  }

  _goPersonView(person) {
    widget.context.forward('/person/view',
        arguments: {'person': person}).then((value) {});
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
              top: 20,
              bottom: 5,
            ),
            child: Text(
              '附近',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
        ..._renderContent(),
      ],
    );
  }

  List<Widget> _renderContent() {
    var items = <SliverToBoxAdapter>[];
    if (_isSearching) {
      items.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              top: 40,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '正在搜索附近的人...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
      return items;
    }
    for (var i = 0; i < _pois.length; i++) {
      var poi = _pois[i];
      var creator = poi.creator;
      var distance = poi.distance;
      var avatar;
      if (StringUtil.isEmpty(creator.avatar)) {
        avatar = Image.asset('lib/portals/gbera/images/default_avatar.png');
      } else if (creator.avatar.startsWith('/')) {
        avatar = Image.file(File(creator.avatar));
      } else {
        avatar = FadeInImage.assetNetwork(
            placeholder: 'lib/portals/gbera/images/default_watting.gif',
            image:
                '${creator.avatar}?accessToken=${widget.context.principal.accessToken}');
      }
      items.add(
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _goPersonView(creator);
                        },
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: avatar,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _goPersonView(creator);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${creator.nickName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${creator.signature ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(
                            '${getFriendlyDistance(distance)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          _OperatorButtonBox(
                            person: creator,
                            context: widget.context,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 40,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }
}

class _OperatorButtonBox extends StatefulWidget {
  PageContext context;
  Person person;

  _OperatorButtonBox({this.context, this.person});

  @override
  __OperatorButtonBoxState createState() => __OperatorButtonBoxState();
}

class __OperatorButtonBoxState extends State<_OperatorButtonBox> {
  bool _isExists = false;
  bool _isWorking = false;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _OperatorButtonBox oldWidget) {
    if (oldWidget.person != widget.person) {
      oldWidget.person = widget.person;
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _isExists = await personService.existsPerson(widget.person.official);
    if (mounted) setState(() {});
  }

  Future<void> _addPerson() async {
    setState(() {
      _isWorking = true;
    });
    var person = widget.person;
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.addPerson(person, isOnlyLocal: true);
    _load();
    if (mounted) {
      setState(() {
        _isWorking = false;
      });
    }
  }

  Future<void> _removePerson() async {
    setState(() {
      _isWorking = true;
    });
    var person = widget.person;
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(
      person.official,
    );
    _load();
    if (mounted) {
      setState(() {
        _isWorking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isExists) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isWorking
            ? null
            : () {
                _removePerson();
              },
        child: SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _isWorking ? '不再关注...' : '不再关注',
              style: TextStyle(
                color: Colors.blueGrey,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isWorking
          ? null
          : () {
              _addPerson();
            },
      child: SizedBox(
        height: 20,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Text(
            _isWorking ? '关注...' : '关注',
            style: TextStyle(
              color: Colors.blueGrey,
              decoration: TextDecoration.underline,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatefulWidget {
  PageContext context;
  _PersonInfo person;
  double distance;

  _PersonCard({this.context, this.person, this.distance});

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
      oldWidget.distance = widget.distance;
    }
    super.didUpdateWidget(oldWidget);
  }

  _goPersonView() {
    widget.context.forward('/person/view',
        arguments: {'person': _person.toPerson()}).then((value) {});
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
          constraints: BoxConstraints(
            minHeight: 150,
          ),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _goPersonView();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Image.network(
                    '${_person?.avatar}?accessToken=${widget.context.principal.accessToken}',
                    fit: BoxFit.cover,
                    width: 140,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _goPersonView();
                        },
                        child: Text(
                          '${_person?.nickName}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
              widget.distance == null
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[300],
                        ),
                        Text(
                          '${getFriendlyDistance(widget.distance)}',
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
                  if (_person.person == widget.context.principal.person) {
                    return Container(
                      child: Text(
                        '我',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
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
                        _hitsQx ? '取消中...' : '不再关注',
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
                      _hitsGz ? '关注中...' : '关注',
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
        _person.person,
        _person.uid,
        _person.accountCode,
        _person.appid,
        await downloadPersonAvatar(
            dio: dio,
            avatarUrl:
                '${_person.avatar}?accessToken=${widget.context.principal.accessToken}'),
        null,
        _person.nickName,
        _person.signature,
        PinyinHelper.getPinyin(_person.nickName),
        widget.context.principal.person);
    await personService.addPerson(person);
    _hitsGz = false;
    _hitsQx = false;
    if (mounted) {
      setState(() {});
    }
  }

  _removePerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(_person.person);
    _hitsGz = false;
    _hitsQx = false;
    if (mounted) {
      setState(() {});
    }
  }
}
