import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class OutsitePersonsSettings extends StatefulWidget {
  PageContext context;

  OutsitePersonsSettings({this.context});

  @override
  _OutsitePersonsSettingsState createState() => _OutsitePersonsSettingsState();
}

class _OutsitePersonsSettingsState extends State<OutsitePersonsSettings> {
  PinPersonsSettingsStrategy _selected_outsite_persons_strategy;
  Channel _channel;
  IChannelPinService _pinService;
  int _persons_limit = 20;
  int _persons_offset = 0;
  List<Person> _persons = [];

  @override
  void initState() {
    _selected_outsite_persons_strategy =
        PinPersonsSettingsStrategy.all_except;
    _channel = widget.context.parameters['channel'];
    _pinService = widget.context.site.getService('/channel/pin');
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _selected_outsite_persons_strategy = null;
    _channel = null;
    _persons_offset = 0;
    super.dispose();
  }

  _load() async {
    _selected_outsite_persons_strategy =
        await _pinService.getOutputPersonSelector(_channel.code);
    List<ChannelOutputPerson> outputPersons =
        await _pinService.listOutputPerson(_channel.code);
    var personList = <String>[];
    for (ChannelOutputPerson p in outputPersons) {
      personList.add(p.person);
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    switch (_selected_outsite_persons_strategy) {
      case PinPersonsSettingsStrategy.only_select:
        //求剩余未被选择的公众
        var personObjs = await personService.pagePersonWithout(
            personList, _persons_limit, _persons_offset);
        if (!personObjs.isEmpty) {
          this._persons_offset += personObjs.length;
        }
        for (var p in personObjs) {
          _persons.add(p);
        }
        break;
      case PinPersonsSettingsStrategy.all_except:
        // 求被排除的公众
        var personObjs = await personService.listPersonWith(personList);
        for (var p in personObjs) {
          _persons.add(p);
        }
        break;
    }
    setState(() {});
  }

  _reloadPersons() async {
    _persons.clear();
    _load();
  }

  Future<void> _onSwipeUp() async {
    await _load();
  }

  Future<void> _onSwipeDown() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('权限'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    _selected_outsite_persons_strategy =
                        PinPersonsSettingsStrategy.all_except;
                    await _pinService.setOutputPersonSelector(
                        _channel.code, _selected_outsite_persons_strategy);
                    _persons_offset = 0;
                    await _reloadPersons();
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        '所有公众除了',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Radio(
                          value: PinPersonsSettingsStrategy.all_except,
                          groupValue: _selected_outsite_persons_strategy,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    _selected_outsite_persons_strategy =
                        PinPersonsSettingsStrategy.only_select;
                    await _pinService.setOutputPersonSelector(
                        _channel.code, _selected_outsite_persons_strategy);
                    _persons_offset = 0;
                    await _reloadPersons();
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        '仅限选定的公众',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Radio(
                          value: PinPersonsSettingsStrategy.only_select,
                          groupValue: _selected_outsite_persons_strategy,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: _persons.isEmpty
                ? Container(
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '无',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _selected_outsite_persons_strategy ==
                        PinPersonsSettingsStrategy.only_select
                    ? SwipeRefreshLayout(
                        onSwipeDown: _onSwipeDown,
                        onSwipeUp: _onSwipeUp,
                        child: _listview(),
                      )
                    : _listview(),
          ),
        ],
      ),
    );
  }

  Widget _listview() {
    int index = 0;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      children: _persons.map((p) {
        if (index < _persons.length) {
          index++;
        }
        return _SelectPerson(
          person: p,
          selected_outsite_persons_strategy: _selected_outsite_persons_strategy,
          pageContext: widget.context,
          channel: _channel,
          isBottomPerson: index >= _persons.length,
        );
      }).toList(),
    );
  }
}

class _SelectPerson extends StatefulWidget {
  Person person;
  PageContext pageContext;
  Channel channel;
  PinPersonsSettingsStrategy selected_outsite_persons_strategy;
  bool isBottomPerson;

  _SelectPerson({
    this.person,
    this.selected_outsite_persons_strategy,
    this.pageContext,
    this.channel,
    this.isBottomPerson,
  });

  @override
  __SelectPersonState createState() => __SelectPersonState();
}

class __SelectPersonState extends State<_SelectPerson> {
  bool _is_seleted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _is_seleted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CardItem(
          leading: Image.file(
            File(widget.person.avatar),
            fit: BoxFit.fitWidth,
            width: 30,
            height: 30,
          ),
          paddingBottom: 10,
          paddingTop: 10,
          title: '${widget.person.nickName ?? widget.person.accountName}',
          tail: _getIcon(),
          onItemTap: () {
            _doSelect();
          },
        ),
        widget.isBottomPerson
            ? Container(
                width: 0,
                height: 0,
              )
            : Divider(
                height: 1,
                indent: 40,
              ),
      ],
    );
  }

  _getIcon() {
    switch (widget.selected_outsite_persons_strategy) {
      case PinPersonsSettingsStrategy.only_select:
        return _is_seleted
            ? Icon(Icons.check)
            : Container(
                width: 0,
                height: 0,
              );
      case PinPersonsSettingsStrategy.all_except:
        return _is_seleted
            ? Icon(Icons.clear)
            : Container(
                width: 0,
                height: 0,
              );
    }
    return Container(
      width: 0,
      height: 0,
    );
  }

  void _doSelect() async {
    IChannelPinService pinService =
        widget.pageContext.site.getService('/channel/pin');
    var isSeleted = _is_seleted;
    var official =
        '${widget.person.accountName}@${widget.person.appid}.${widget.person.tenantid}';
    switch (widget.selected_outsite_persons_strategy) {
      case PinPersonsSettingsStrategy.only_select:
        if (isSeleted) {
          //从输出公众表中移除
          await pinService.removeOutputPerson(
              official, widget.channel.code);
        } else {
          //添加到输出公众表
          await pinService.addOutputPerson(
            ChannelOutputPerson(
              '${Uuid().v1()}',
              widget.channel.code,
              official,
              widget.pageContext.principal.person,
            ),
          );
        }
        break;
      case PinPersonsSettingsStrategy.all_except:
        if (isSeleted) {
          await pinService.addOutputPerson(
            ChannelOutputPerson(
              '${Uuid().v1()}',
              widget.channel.code,
              official,
              widget.pageContext.principal.person,
            ),
          );
        } else {
          await pinService.removeOutputPerson(
              official, widget.channel.code);
        }
        break;
    }

    _is_seleted = !isSeleted;
    setState(() {});
  }
}
