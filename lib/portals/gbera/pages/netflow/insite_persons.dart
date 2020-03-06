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

class InsitePersons extends StatefulWidget {
  PageContext context;

  InsitePersons({this.context});

  @override
  _InsitePersonsState createState() => _InsitePersonsState();
}

class _InsitePersonsState extends State<InsitePersons> {
  Channel _channel;
  _Refresher __refresher = _Refresher();

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    super.initState();
  }

  @override
  void dispose() {
    __refresher = null;
    this._channel = null;
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
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
                        TextSpan(text: '${widget.context.principal.nickName}>'),
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
          case '/netflow/channel/insite/persons_settings':
            widget.context.forward('/netflow/channel/insite/persons_settings',
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
          value: '/netflow/channel/insite/persons_settings',
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
                '进口权限',
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
    _controller = EasyRefreshController();
    this._offset = 0;
    _channel = widget.context.parameters['channel'];
    _loadPersons().then((persons) {
      setState(() {});
    });
    widget.refresher.callback = () async{
      resetPersons();
      await _loadPersons();
      setState(() {});
    };
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    this._channel = null;
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
        await pinService.getInputPersonSelector(_channel.code);
    this._strategy = strategy;
    List<Person> personObjs;
    switch (strategy) {
      case PinPersonsSettingsStrategy.only_select:
        break;
      case PinPersonsSettingsStrategy.all_except:
        var in_persons = await pinService.listInputPerson(_channel.code);
        var persons = <String>[];
        for (var op in in_persons) {
          persons.add(op.person);
        }
        personObjs =
            await personService.pagePersonWithout(persons, _limit, _offset);
        if (!personObjs.isEmpty) {
          _offset += personObjs.length;
        } else {
          _controller.finishLoad(success: true, noMore: true);
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
            .removeInputPerson(
                '${person.accountName}@${person.appid}.${person.tenantid}',
                _channel.code)
            .whenComplete(() {
          _persons.remove(person);
          setState(() {});
        });
        break;
      case PinPersonsSettingsStrategy.all_except:
        pinService
            .addInputPerson(
          ChannelInputPerson(
            '${Uuid().v1()}',
            _channel.code,
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
                text: '【进口权限】',
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    widget.context.forward(
                        '/netflow/channel/insite/persons_settings',
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
    switch (_strategy) {
      case PinPersonsSettingsStrategy.all_except:
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
                          widget.context.forward(
                              '/netflow/channel/pin/see_persons',
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
      case PinPersonsSettingsStrategy.only_select:
      default:
        return Container(
          width: 0,
          height: 0,
        );
    }
  }
}
