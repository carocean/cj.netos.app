import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class OutsitePersons extends StatefulWidget {
  PageContext context;

  OutsitePersons({this.context});

  @override
  _OutsitePersonsState createState() => _OutsitePersonsState();
}

class _OutsitePersonsState extends State<OutsitePersons> {
  Channel _channel;

  PinPersonsSettingsStrategy _strategy;
  int _limit = 20;
  int _offset = 0;
  List<Person> _persons = [];

  @override
  void initState() {
    this._offset = 0;
    _channel = widget.context.parameters['channel'];
    super.initState();
  }

  @override
  void dispose() {
    this._channel = null;
    this._offset = 0;
    _persons.clear();
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
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
                  Text.rich(
                    TextSpan(
                      text: '${_channel.name}: ',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      children: [
                        TextSpan(
                            text:
                                '${widget.context.principal.nickName ?? widget.context.principal.accountCode}>'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Person>>(
              future: _loadPerson(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  print('${snapshot.error}');
                }
                if (snapshot.data == null) {
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }
                switch (_strategy) {
                  case PinPersonsSettingsStrategy.only_select:
                    return _PersonListRegion(
                      context: widget.context,
                      persons: snapshot.data,
                      resetPersons: resetPersons,
                      outsitePersonsSettingStrategy: _strategy,
                      channel: _channel,
                    );
                  case PinPersonsSettingsStrategy.all_except:
                    return SwipeRefreshLayout(
                      onSwipeDown: _onSwipeDown,
                      onSwipeUp: _onSwipeUp,
                      child: _PersonListRegion(
                        context: widget.context,
                        persons: snapshot.data,
                        resetPersons: resetPersons,
                        outsitePersonsSettingStrategy: _strategy,
                        channel: _channel,
                      ),
                    );
                  default:
                    return Container(
                      width: 0,
                      height: 0,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  resetPersons() {
    _persons.clear();
    _offset = 0;
  }

  Future<void> _onSwipeDown() async {}

  Future<void> _onSwipeUp() async {
    await _loadPerson();
    setState(() {});
  }

  Future<List<Person>> _loadPerson() async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    PinPersonsSettingsStrategy strategy =
        await pinService.getOutputPersonSelector(_channel.code);
    this._strategy = strategy;
    List<Person> personObjs;
    switch (strategy) {
      case PinPersonsSettingsStrategy.only_select:
        var out_persons = await pinService.listOutputPerson(_channel.code);
        var persons = <String>[];
        for (var op in out_persons) {
          persons.add(op.person);
        }
        personObjs = await personService.listPersonWith(persons);
        break;
      case PinPersonsSettingsStrategy.all_except:
        var out_persons = await pinService.listOutputPerson(_channel.code);
        var persons = <String>[];
        for (var op in out_persons) {
          persons.add(op.person);
        }
        personObjs =
            await personService.pagePersonWithout(persons, _limit, _offset);
        if (!personObjs.isEmpty) {
          _offset += personObjs.length;
        }
        break;
    }
    for (var p in personObjs) {
      _persons.add(p);
    }
    return _persons;
  }

  _getPopupMenu() {
    return PopupMenuButton<String>(
      offset: Offset(
        0,
        50,
      ),
      onSelected: (value) async {
        if (value == null) return;
        switch (value) {
          case '/netflow/channel/outsite/persons_settings':
            widget.context.forward('/netflow/channel/outsite/persons_settings',
                arguments: {'channel': _channel, }).then((obj){
                  if(resetPersons!=null) {
                    resetPersons();
                  }
            });
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: '/netflow/channel/outsite/persons_settings',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.grey[500],
                  size: 15,
                ),
              ),
              Text(
                '出口权限',
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

class _PersonListRegion extends StatefulWidget {
  List<Person> persons;
  PageContext context;
  Channel channel;
  PinPersonsSettingsStrategy outsitePersonsSettingStrategy;
  Function() resetPersons;

  _PersonListRegion(
      {this.persons,
      this.context,
      this.outsitePersonsSettingStrategy,
      this.resetPersons,
      this.channel});

  @override
  __PersonListRegionState createState() => __PersonListRegionState();
}

class __PersonListRegionState extends State<_PersonListRegion> {
  @override
  Widget build(BuildContext context) {
    if (widget.persons.isEmpty) {
      return Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        height: 40,
        color: Colors.white,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            text: '无，请通过',
            style: TextStyle(
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: '【出口权限】',
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    widget.context.forward(
                        '/netflow/channel/outsite/persons_settings',
                        arguments: {
                          'channel': widget.channel,
                        }).then((obj){
                          if(widget.resetPersons!=null) {
                            widget.resetPersons();
                          }

                    });
                  },
              ),
              TextSpan(text: '设置公众。'),
            ],
          ),
        ),
      );
    }
    return ListView(
      shrinkWrap: true,
      children: widget.persons.map((p) {
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              color: Colors.white,
              child: Dismissible(
                key: ObjectKey(Uuid().v1()),
                direction: DismissDirection.endToStart,
                child: CardItem(
                  title: '${p.nickName ?? p.accountName}',
                  leading: Image.file(
                    File(p.avatar),
                    width: 40,
                    height: 40,
                  ),
                  onItemTap: () {
                    widget.context.forward('/netflow/channel/pin/see_persons', arguments: {
                      'person': p,'pinType':'downstream','channel':widget.channel,'direction_tips':'${widget.context.principal.nickName ?? widget.context.principal.accountCode}>'
                    }).then((obj) {
                      if (widget.resetPersons != null) {
                        widget.resetPersons();
                      }
                    });
                  },
                ),
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
                  if (direction != DismissDirection.endToStart) {
                    return;
                  }
                  _removeFromPersonList(p);
                },
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        );
      }).toList(),
    );
  }

  Future<String> _showConfirmationDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text.rich(
          TextSpan(
            text: widget.outsitePersonsSettingStrategy ==
                    PinPersonsSettingsStrategy.all_except
                ? '是否排除？'
                : '是否移除？',
            children: [
              TextSpan(text: '\r\n'),
              TextSpan(
                text: widget.outsitePersonsSettingStrategy ==
                        PinPersonsSettingsStrategy.all_except
                    ? '排除后可在权限设置中找回'
                    : '移除后可在权限设置中找回',
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

  _removeFromPersonList(Person person) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    switch (widget.outsitePersonsSettingStrategy) {
      case PinPersonsSettingsStrategy.only_select:
        pinService
            .removeOutputPerson(
                '${person.accountName}@${person.appid}.${person.tenantid}',
                widget.channel.code)
            .whenComplete(() {
          widget.persons.remove(person);
          setState(() {});
        });
        break;
      case PinPersonsSettingsStrategy.all_except:
        pinService
            .addOutputPerson(
          ChannelOutputPerson(
            '${Uuid().v1()}',
            widget.channel.code,
            '${person.accountName}@${person.appid}.${person.tenantid}',
            widget.context.principal.person,
          ),
        )
            .whenComplete(() {
          widget.persons.remove(person);
          setState(() {});
        });
        break;
    }
  }
}
