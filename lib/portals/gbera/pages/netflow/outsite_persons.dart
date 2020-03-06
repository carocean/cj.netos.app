import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  _Refresher __refresher = _Refresher();

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    super.initState();
  }

  @override
  void dispose() {
    this._channel = null;
    __refresher = null;
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
          SliverFillRemaining(
            child: _PersonListRegion(
              context: widget.context,
              refresher: __refresher,
            ),
          ),
        ],
      ),
    );
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
                arguments: {
                  'channel': _channel,
                }).then((obj) {
              __refresher.fireRefresh();
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

class _Refresher {
  Function() callback;

  void fireRefresh() {
    if (callback != null) {
      callback();
    }
  }
}

class _PersonListRegion extends StatefulWidget {
  PageContext context;
  _Refresher refresher;

  _PersonListRegion({
    this.refresher,
    this.context,
  });

  @override
  __PersonListRegionState createState() => __PersonListRegionState();
}

class __PersonListRegionState extends State<_PersonListRegion> {
  Channel _channel;
  EasyRefreshController _controller;
  PinPersonsSettingsStrategy _strategy;
  int _limit = 20;
  int _offset = 0;
  List<Person> _persons = [];

  @override
  void initState() {
    this._offset = 0;
    _controller = EasyRefreshController();
    _channel = widget.context.parameters['channel'];
    _loadPersons().then((list) {
      setState(() {});
    });
    widget.refresher.callback = () {
      resetPersons();
      _loadPersons().then((v) {
        setState(() {});
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    this._channel = null;
    _controller.dispose();
    this._offset = 0;
    _persons.clear();
    super.dispose();
  }

  resetPersons() {
    _persons.clear();
    _offset = 0;
  }

  Future<void> _onSwipeUp() async {
    await _loadPersons();
    setState(() {});
  }

  Future<List<Person>> _loadPersons() async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    PinPersonsSettingsStrategy strategy =
        await pinService.getOutputPersonSelector(_channel.id);
    this._strategy = strategy;
    List<Person> personObjs;
    switch (strategy) {
      case PinPersonsSettingsStrategy.only_select:
        var out_persons = await pinService.listOutputPerson(_channel.id);
        var persons = <String>[];
        for (var op in out_persons) {
          persons.add(op.person);
        }
        personObjs = await personService.listPersonWith(persons);
        break;
      case PinPersonsSettingsStrategy.all_except:
        var out_persons = await pinService.listOutputPerson(_channel.id);
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

  _removeFromPersonList(Person person) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    switch (_strategy) {
      case PinPersonsSettingsStrategy.only_select:
        pinService
            .removeOutputPerson(person.official, _channel.id)
            .whenComplete(() {
          _persons.remove(person);
          setState(() {});
        });
        break;
      case PinPersonsSettingsStrategy.all_except:
        pinService
            .addOutputPerson(
          ChannelOutputPerson(
            '${Uuid().v1()}',
            _channel.id,
            person.official,
            widget.context.principal.person,
          ),
        )
            .whenComplete(() {
          _persons.remove(person);
          setState(() {});
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_persons.isEmpty) {
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
                          'channel': _channel,
                        }).then((obj) {
                      if (resetPersons != null) {
                        resetPersons();
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
    return EasyRefresh.custom(
      controller: _controller,
      onLoad: _onSwipeUp,
      shrinkWrap: true,
      slivers: _persons.map((p) {
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: '排除',
                      foregroundColor: Colors.grey[500],
                      icon: Icons.delete,
                      onTap: () {
                        _removeFromPersonList(p);
                      },
                    ),
                  ],
                  child: CardItem(
                    title: '${p.nickName ?? p.accountName}',
                    leading: Image.file(
                      File(p.avatar),
                      width: 40,
                      height: 40,
                    ),
                    onItemTap: () {
                      widget.context.forward('/netflow/channel/pin/see_persons',
                          arguments: {
                            'person': p,
                            'pinType': 'upstream',
                            'channel': _channel,
                            'direction_tips':
                                '${widget.context.principal.nickName}>'
                          }).then((obj) {
                        if (resetPersons != null) {
                          resetPersons();
                        }
                      });
                    },
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
