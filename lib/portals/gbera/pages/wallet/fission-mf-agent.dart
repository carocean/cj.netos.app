import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class FissionMFFindAgentPage extends StatefulWidget {
  PageContext context;

  FissionMFFindAgentPage({this.context});

  @override
  _FissionMFFindAgentPageState createState() => _FissionMFFindAgentPageState();
}

class _FissionMFFindAgentPageState extends State<FissionMFFindAgentPage> {
  TextEditingController _personController;
  Person _person;

  @override
  void initState() {
    _personController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _personController?.dispose();
    super.dispose();
  }

  Future<void> _showSearch() async {
    var offical = await showSearch(
      context: context,
      delegate: _PersonSearchDelegate(widget.context),
    );
    if (StringUtil.isEmpty(offical)) {
      return;
    }
    _personController.text = offical;
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _person = await personService.getPerson(
      offical,
      isDownloadAvatar: false,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _qrscan() async {
    String cameraScanResult = await scanner.scan(widget.context);
    if (StringUtil.isEmpty(cameraScanResult)) {
      return 'no';
    }
    String itis;
    String data;
    if (cameraScanResult.startsWith('{')) {
      var map = jsonDecode(cameraScanResult);
      itis = map['itis'];
      data = map['data'];
    } else {
      data = cameraScanResult;
      itis = 'unknown';
    }
    if('profile.person'!=itis){
      return;
    }
    var official=data;
    _personController.text = official;
    IPersonService personService =
    widget.context.site.getService('/gbera/persons');
    _person = await personService.getPerson(
      official,
      isDownloadAvatar: false,
    );
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _saveAgent()async{
    IFissionMFCashierRemote cashierRemote =
    widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setSalesman(_person.official);
    widget.context.backward();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查找代理人'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.crop_free,
            ),
            onPressed: () {
              _qrscan();
            },
          ),
          FlatButton(
            onPressed: _person == null
                ? null
                : () {
                    _saveAgent();
                  },
            textColor: Colors.green,
            child: Text(
              '确定',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: TextField(
              controller: _personController,
              keyboardType: TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              onTap: () {
                _showSearch();
              },
              decoration: InputDecoration(
                hintText: '输入地微公号/用户号/手机号...',
                hintStyle: TextStyle(
                  fontSize: 16,
                ),
                fillColor: Colors.white,
                filled: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
              ),
              onChanged: (v) {
                _showSearch();
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          _person == null
              ? SizedBox.shrink()
              : Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 15,
                    bottom: 15,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.context.forward('/person/view',
                                arguments: {'person': _person});
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: getAvatarWidget(
                                    _person.avatar, widget.context),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${_person.nickName ?? ''}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _PersonSearchDelegate extends SearchDelegate<String> {
  PageContext context;

  _PersonSearchDelegate(this.context)
      : super(
          searchFieldLabel: '地微公号/用户号/手机号',
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
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _PersonSuggestions(
      query: query,
      context: this.context,
      onselected: (String query) {
        close(context, query);
      },
    );
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

class _PersonSuggestions extends StatefulWidget {
  PageContext context;
  String query;
  Function(String query) onselected;

  _PersonSuggestions({this.context, this.query, this.onselected});

  @override
  __PersonSuggestionsState createState() => __PersonSuggestionsState();
}

class __PersonSuggestionsState extends State<_PersonSuggestions> {
  Person _person;
  bool _isSearched = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(_PersonSuggestions oldWidget) {
    _person = null;
    _isSearched = false;
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _searchPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var key = widget.query;
    int pos = key.lastIndexOf('@');
    if (pos < 0) {
      key = '${widget.query}@gbera.netos';
    }
    _person = await personService.getPerson(
      key,
      isDownloadAvatar: false,
    );
    if (mounted) {
      setState(() {
        _isSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StringUtil.isEmpty(widget.query)
            ? SizedBox.shrink()
            : InkWell(
                onTap: () {
                  // widget.onselected(widget.query);
                  _searchPerson();
                },
                child: Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 15,
                    top: 15,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        '搜索:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.query ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        SizedBox(
          height: 10,
        ),
        _renderResult(),
      ],
    );
  }

  _renderResult() {
    if (!_isSearched) {
      return SizedBox.shrink();
    }
    if (_person == null) {
      return Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 15,
          bottom: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '用户不存在',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: 15,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                widget.context
                    .forward('/person/view', arguments: {'person': _person});
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: getAvatarWidget(_person.avatar, widget.context),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${_person.nickName ?? ''}',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          FlatButton(
            onPressed: () {
              widget.onselected(_person.official);
            },
            child: Text(
              '选择',
            ),
          ),
        ],
      ),
    );
  }
}
