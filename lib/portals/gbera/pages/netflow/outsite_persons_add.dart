import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/load_indicator.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class OutsitePersonsAddsPage extends StatefulWidget {
  PageContext context;

  OutsitePersonsAddsPage({this.context});

  @override
  _OutsitePersonsAddsPageState createState() => _OutsitePersonsAddsPageState();
}

class _OutsitePersonsAddsPageState extends State<OutsitePersonsAddsPage> {
  PinPersonsSettingsStrategy _selected_outsite_persons_strategy;
  Channel _channel;
  IChannelPinService _pinService;
  int _persons_limit = 20;
  int _persons_offset = 0;
  List<Person> _persons = [];
  List<String> _selectedPersons = [];
  String _originPerson;
  List<Person> _cached;

  @override
  void initState() {
    _selected_outsite_persons_strategy = PinPersonsSettingsStrategy.only_select;
    _channel = widget.context.parameters['channel'];
    _pinService = widget.context.site.getService('/channel/pin');
    _originPerson = widget.context.parameters['person'];
    if (StringUtil.isEmpty(_originPerson)) {
      _originPerson = _channel.owner;
    }
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

  Future<void> _load() async {
    _selected_outsite_persons_strategy =
        await _pinService.getOutputPersonSelector(_channel.id);
    if (_selected_outsite_persons_strategy !=
        PinPersonsSettingsStrategy.only_select) {
      print('不支持的输出公众选择策略:$_selected_outsite_persons_strategy');
      return;
    }
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    if (_cached == null) {
      _cached = await channelRemote.pageOutputPersonOf(
          _channel.id, _originPerson, 500, 0);
    }
    // List<ChannelOutputPerson> outputPersons =
    // await _pinService.listOutputPerson(_channel.id);

    var personList = <String>[];
    for (var p in _cached) {
      if(p.official==_channel.owner){
        continue;
      }
      personList.add(p.official);
    }
    //求剩余未被选择的公众
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var persons = await personService.pagePersonWithout(
        personList, _persons_limit, _persons_offset);
    if (persons.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }
    this._persons_offset += persons.length;
    persons.removeWhere((element) => element.official==_channel.owner);
    _persons.addAll(persons);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _done() async {
    widget.context.backward(result: _selectedPersons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加公众'),
        elevation: 0,
        centerTitle: true,
        actions: [
          _selectedPersons.isEmpty
              ? SizedBox(
                  width: 0,
                  height: 0,
                )
              : Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    right: 15,
                  ),
                  child: RaisedButton(
                    onPressed: () {
                      _done();
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text(
                      '完成(${_selectedPersons.length})',
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          _renderSelected(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: LoadIndicator(
                load: _load,
                child: Column(
                  children: _renderMembers(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderMembers() {
    var items = <Widget>[];
    if (_persons.isEmpty) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 20,
          ),
          alignment: Alignment.center,
          child: Text(
            '没有公众',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var friend in _persons) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selectedPersons.contains(friend.official)) {
              _selectedPersons.remove(friend.official);
            } else {
              _selectedPersons.add(friend.official);
            }
            if (mounted) {
              setState(() {});
            }
          },
          child: Container(
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    margin: EdgeInsets.only(
                      left: 15,
                    ),
                    child: Center(
                      child: Radio(
                        value: _selectedPersons.contains(friend.official),
                        groupValue: true,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          if (v) {
                            _selectedPersons.add(friend.official);
                          } else {
                            _selectedPersons.remove(friend.official);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          child: getAvatarWidget(friend.avatar, widget.context),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            friend.nickName,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 50,
        ),
      );
    }
    return items;
  }

  Widget _renderSelected() {
    var items = <Widget>[];
    if (_selectedPersons.isEmpty) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }

      for (var person in _selectedPersons) {
        var found;
        for (var friend in _persons) {
          if (friend.official == person) {
            found=friend;
            break;
          }
        }
        if(found==null) {
          continue;
        }
        items.add(
          Container(
            width: 40,
            height: 40,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context
                    .forward('/person/view', arguments: {'person': found});
              },
              onLongPress: () {
                _selectedPersons.removeWhere((p) {
                  return p == person;
                });
                setState(() {});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: getAvatarWidget(found.avatar, widget.context),
              ),
            ),
          ),
        );
      }
    if (items.isNotEmpty) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/netflow/channel/outsite/persons_select',
                arguments: {'selected': _selectedPersons});
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 1,
                color: Colors.grey[400],
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}
