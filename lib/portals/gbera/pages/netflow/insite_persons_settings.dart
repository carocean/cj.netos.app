import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class InsitePersonsSettings extends StatefulWidget {
  PageContext context;

  InsitePersonsSettings({this.context});

  @override
  _InsitePersonsSettingsState createState() => _InsitePersonsSettingsState();
}

class _InsitePersonsSettingsState extends State<InsitePersonsSettings> {
  PinPersonsSettingsStrategy _selected_insite_persons_strategy;
  Channel _channel;
  IChannelPinService _pinService;
  int _persons_limit = 20;
  int _persons_offset = 0;
  List<Person> _persons = [];

  @override
  void initState() {
    _selected_insite_persons_strategy = PinPersonsSettingsStrategy.all_except;
    _channel = widget.context.parameters['channel'];
    _pinService = widget.context.site.getService('/channel/pin');
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _selected_insite_persons_strategy = null;
    _channel = null;
    _persons_offset = 0;
    super.dispose();
  }

  _load() async {
    _selected_insite_persons_strategy =
        await _pinService.getInputPersonSelector(_channel.id);
    List<ChannelInputPerson> inputPersons =
        await _pinService.listInputPerson(_channel.id);
    var personList = <String>[];
    for (var p in inputPersons) {
      personList.add(p.person);
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    switch (_selected_insite_persons_strategy) {
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
              left: 15,
              right: 15,
              top: 10,
              bottom: 2,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              '拒绝从以下公众接收信息',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
                : _selected_insite_persons_strategy ==
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
          selected_insite_persons_strategy: _selected_insite_persons_strategy,
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
  PinPersonsSettingsStrategy selected_insite_persons_strategy;
  bool isBottomPerson;

  _SelectPerson({
    this.person,
    this.selected_insite_persons_strategy,
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
          title: '${widget.person.nickName}',
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
    switch (widget.selected_insite_persons_strategy) {
      case PinPersonsSettingsStrategy.only_select:
        return _is_seleted
            ? Icon(Icons.check)
            : Container(
                width: 0,
                height: 0,
              );
      case PinPersonsSettingsStrategy.all_except:
        return _is_seleted
            ? Icon(
                Icons.clear,
                color: Colors.grey[500],
              )
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
    switch (widget.selected_insite_persons_strategy) {
      case PinPersonsSettingsStrategy.only_select:
        if (isSeleted) {
          //从输出公众表中移除
          await pinService.removeInputPerson(
              widget.person.official, widget.channel.id);
        } else {
          await pinService.addInputPerson(
            ChannelInputPerson(
              '${Uuid().v1()}',
              widget.channel.id,
              widget.person.official,
              'allow',
              widget.pageContext.principal.person,
            ),
          );
        }
        break;
      case PinPersonsSettingsStrategy.all_except:
        if (isSeleted) {
          await pinService.addInputPerson(
            ChannelInputPerson(
              '${Uuid().v1()}',
              widget.channel.id,
              widget.person.official,
              'allow',
              widget.pageContext.principal.person,
            ),
          );
        } else {
          await pinService.removeInputPerson(
              widget.person.official, widget.channel.id);
        }
        break;
    }

    _is_seleted = !isSeleted;
    setState(() {});
  }
}
