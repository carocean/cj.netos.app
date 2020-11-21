import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/load_indicator.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
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
  String _originPerson;
  Person _current;

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _originPerson = widget.context.parameters['person'];
    if (StringUtil.isEmpty(_originPerson)) {
      _originPerson = _channel.owner;
    }
    () async {
      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
      _current = await personService.getPerson(_originPerson);
      if (mounted) {
        setState(() {});
      }
    }();
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
        title: Text('下游网关'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0.0,
        titleSpacing: 0,
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
                      text: '${_channel.name}:',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      children: [
                        TextSpan(text: '${_current?.nickName ?? ''}'),
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
  int _limit = 20;
  int _offset = 0;
  List<Person> _persons = [];
  bool _isAddingPersons = false;
  String _originPerson;

  @override
  void initState() {
    this._offset = 0;
    _channel = widget.context.parameters['channel'];
    _originPerson = widget.context.parameters['person'];
    if (StringUtil.isEmpty(_originPerson)) {
      _originPerson = _channel.owner;
    }
    _loadPersons().then((list) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    this._channel = null;
    this._offset = 0;
    _persons.clear();
    super.dispose();
  }

  _refresh() {
    _persons.clear();
    _offset = 0;
    _loadPersons().then((list) {
      setState(() {});
    });
  }

  Future<void> _loadPersons() async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    // IChannelService channelService =
    //     widget.context.site.getService('/netflow/channels');
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    // IPersonService personService =
    //     widget.context.site.getService('/gbera/persons');
    PinPersonsSettingsStrategy strategy =
        await pinService.getOutputPersonSelector(_channel.id);
    if (strategy != PinPersonsSettingsStrategy.only_select) {
      print('不支持的输出公众选择策略:$strategy');
      return;
    }
    var persons = await channelRemote.pageOutputPersonOf(
        _channel.id, _originPerson, _limit, _offset);
    if (persons.isEmpty) {
      return;
    }
    _offset += persons.length;
    _persons.addAll(persons);
  }

  Future<bool> _isAllowPerson(official) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var person = await personService.getPerson(official);
    if(person==null){
      return false;
    }
    if (person.rights == 'denyDownstream' || person.rights == 'denyBoth') {
      return false;
    }
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    var o = await pinService.getOutputPerson(person.official, _channel.id);
    if (o == null) {
      return false;
    }
    return (StringUtil.isEmpty(o.rights) || o.rights == 'allow') ? true : false;
  }

  Future<void> _addOutputPersons(List<String> list) async {
    setState(() {
      _isAddingPersons = true;
    });
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    for (var official in list) {
      await pinService.addOutputPersonBy(
          _originPerson,
          ChannelOutputPerson(
            '${MD5Util.MD5(Uuid().v1())}',
            _channel.id,
            official,
            'allow',
            DateTime.now().millisecondsSinceEpoch,
            widget.context.principal.person,
          ));
    }
    if (mounted) {
      setState(() {
        _isAddingPersons = false;
      });
    }
    _refresh();
  }

  Future<void> _removePersons(list) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');

    for (var official in list) {
      await pinService.removeOutputPerson(official, _channel.id);
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    for (var person in _persons) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context
                .forward("/netflow/channel/portal/person", arguments: {
              'person': person,
            });
          },
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: getAvatarWidget(person.avatar, widget.context),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                '${person.nickName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: (!StringUtil.isEmpty(_originPerson) &&
                        _originPerson != widget.context.principal.person)
                    ? SizedBox(
                        width: 0,
                        height: 0,
                      )
                    : FutureBuilder<bool>(
                        future: _isAllowPerson(person.official),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState !=
                                  ConnectionState.done ||
                              snapshot.data) {
                            return SizedBox(
                              width: 0,
                              height: 0,
                            );
                          }
                          return Icon(
                            Icons.security,
                            size: 14,
                            color: Colors.red,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    }
    if (widget.context.principal.person == _originPerson) {
      items.add(
        _renderSecurityOutputPersonButton(),
      );
      items.add(
        _renderRemoveOutputPersonButton(),
      );
    }
    items.add(
      _renderAddOutputPersonButton(),
    );
    if (_isAddingPersons) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Center(
            child: Text(
              '正在处理，请稍候...',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 10,
      ),
      constraints: BoxConstraints.expand(),
      alignment: Alignment.topLeft,
      child: LoadIndicator(
        child: Wrap(
          children: items,
        ),
        load: () async {
          await _loadPersons();
        },
      ),
    );
  }

  Widget _renderRemoveOutputPersonButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            widget.context.forward('/netflow/channel/outsite/persons_removes',
                arguments: {
                  'channel': _channel,
                  'person': _originPerson,
                }).then((list) {
              if (list == null) {
                return;
              }
              _removePersons(list);
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 5,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.grey[300],
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _renderSecurityOutputPersonButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            widget.context
                .forward('/netflow/channel/outsite/persons_rights', arguments: {
              'channel': _channel,
              'person': _originPerson,
            }).then((value) {
              _refresh();
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 5,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.grey[300],
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.security,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _renderAddOutputPersonButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            widget.context
                .forward('/netflow/channel/outsite/persons_adds', arguments: {
              'channel': _channel,
              'person': _originPerson,
            }).then((v) {
              if (v == null) {
                return;
              }
              var list = v as List<String>;
              _addOutputPersons(list);
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 5,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.grey[300],
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
