import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/load_indicator.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';

class OutsitePersonsRemovesPage extends StatefulWidget {
  PageContext context;

  OutsitePersonsRemovesPage({this.context});

  @override
  _OutsitePersonsRemovesPageState createState() =>
      _OutsitePersonsRemovesPageState();
}

class _OutsitePersonsRemovesPageState extends State<OutsitePersonsRemovesPage> {
  List<Person> _persons = [];
  List<String> _selectedPersons = [];
  Channel _channel;
  int _limit = 20, _offset = 0;
  String _originPerson;

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _originPerson = widget.context.parameters['person'];
    if (StringUtil.isEmpty(_originPerson)) {
      _originPerson = _channel.owner;
    }
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    var persons = await channelRemote.pageOutputPersonOf(
        _channel.id, _originPerson, _limit, _offset);
    if (persons.isEmpty) {
      return;
    }
    _offset += persons.length;
    _persons.addAll(persons);
    return _persons;
  }

  Future<void> _done() async {
    widget.context.backward(result: _selectedPersons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('移除公众'),
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
            '没有成员',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var person in _persons) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selectedPersons.contains(person.official)) {
              _selectedPersons.remove(person.official);
            } else {
              _selectedPersons.add(person.official);
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
                        value: _selectedPersons.contains(person.official),
                        groupValue: true,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          if (v) {
                            _selectedPersons.add(person.official);
                          } else {
                            _selectedPersons.remove(person.official);
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
                          child: getAvatarWidget(person.avatar, widget.context),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            person.nickName,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward("/netflow/channel/portal/person",
                          arguments: {
                            'person': person,
                          });
                    },
                    child: Icon(
                      Icons.info,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 15,
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
      for (var creator in _persons) {
        if (creator.official == person) {
          found = creator;
          break;
        }
      }
      if (found == null) {
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
