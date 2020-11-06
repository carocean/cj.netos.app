import 'dart:async';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ChannelRouter extends StatefulWidget {
  PageContext context;

  ChannelRouter({this.context});

  @override
  _ChannelRouterState createState() => _ChannelRouterState();
}

class _ChannelRouterState extends State<ChannelRouter> {
  Channel _channel;
  Person _origin;
  Person _selected;
  List<Person> _routers = [];
  StreamController _streamController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _channel = widget.context.partArgs['channel'];
    _streamController = StreamController.broadcast();
    _streamSubscription = _streamController.stream.listen((event) {
      _selected = event['person'];
      if (!event.containsKey('notAdd')) {
        _routers.add(_selected);
      }
      ChanngeSelectedPersonNotification(person: _selected, channel: _channel)
          .dispatch(context);
      if (mounted) {
        setState(() {});
      }
    });
    () async {
      await _loadPerson();
      _selected = _origin;
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  Future<void> _loadPerson() async {
    String official = widget.context.partArgs['origin'];
    if (StringUtil.isEmpty(official)) {
      official = _channel.owner;
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _origin = await personService.getPerson(official);
  }

  @override
  Widget build(BuildContext context) {
    if (_selected == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Container(
      child: Column(
        children: [
          //导航
          SizedBox(
            height: 10,
          ),
          _renderNavigator(),
          SizedBox(
            height: 20,
            // child: Divider(height: 1,),
          ),
          SizedBox(
            height: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _UpstreamPersons(
                  context: widget.context,
                  channel: _channel,
                  person: _selected,
                  output: _streamController,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 60,
                  ),
                  child: VerticalDivider(
                    width: 1,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.green,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 1,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward("/netflow/channel/portal/person",
                            arguments: {
                              'person': _selected,
                            });
                      },
                      child: _renderSelectedPerson(),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Expanded(
                          //   child: VerticalDivider(
                          //     width: 1,
                          //     color: Colors.red,
                          //   ),
                          // ),
                          // Text(
                          //   '↓',
                          //   style: TextStyle(
                          //     color: Colors.red,
                          //     letterSpacing: 0,
                          //     height: 1,
                          //     fontSize: 12,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.green,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 60,
                  ),
                  child: VerticalDivider(
                    width: 1,
                  ),
                ),
                _DownstreamPersons(
                  context: widget.context,
                  channel: _channel,
                  person: _selected,
                  output: _streamController,
                ),
                // VerticalDivider(
                //   width: 1,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderNavigator() {
    var items = <Widget>[];
    for (var i = 0; i < _routers.length; i++) {
      var person = _routers[i];
      if (person == null) {
        continue;
      }
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _selected = person;
            for (var j = _routers.length - 1; j >= 0; j--) {
              var p = _routers[j];
              if (p == person) {
                break;
              }
              _routers.removeLast();
            }
            _streamController.add({'person': _selected, 'notAdd': true});
            setState(() {});
          },
          child: SizedBox(
            width: 30,
            height: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: getAvatarWidget(
                person.avatar,
                widget.context,
              ),
            ),
          ),
        ),
      );
      items.add(
        SizedBox(
          width: 5,
        ),
      );
    }
    var rightButtons = <Widget>[];
    if (_routers.isNotEmpty) {
      rightButtons.add(
        SizedBox(
          width: 10,
        ),
      );
      rightButtons.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _routers.removeLast();
            if (_routers.isEmpty) {
              _selected = _origin;
            } else {
              _selected = _routers.last;
            }
            _streamController.add({'person': _selected, 'notAdd': true});
            if (mounted) {
              setState(() {});
            }
          },
          child: Icon(
            Icons.arrow_back,
            size: 40,
            color: Colors.green,
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _selected = _origin;
                  _routers.clear();
                  _streamController.add({'person': _selected, 'notAdd': true});
                  setState(() {});
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: getAvatarWidget(
                      _origin.avatar,
                      widget.context,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.arrow_right,
                size: 18,
                color: Colors.grey,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...rightButtons,
      ],
    );
  }

  Widget _renderSelectedPerson() {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: getAvatarWidget(
              _selected.avatar,
              widget.context,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          width: 50,
          child: Center(
            child: Text(
              '${_selected.nickName}',
              style: TextStyle(
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _UpstreamPersons extends StatefulWidget {
  PageContext context;
  StreamController output;
  Channel channel;
  Person person;

  _UpstreamPersons({this.context, this.output, this.person, this.channel});

  @override
  __UpstreamPersonsState createState() => __UpstreamPersonsState();
}

class __UpstreamPersonsState extends State<_UpstreamPersons> {
  Person _person;
  Channel _channel;
  int _limit = 10, _offset = 0;
  List<Person> _persons = [];
  StreamController _output;

  @override
  void initState() {
    _output = widget.output;
    _person = widget.person;
    _channel = widget.channel;
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _UpstreamPersons oldWidget) {
    if (oldWidget.person != widget.person) {
      _person = widget.person;
      _output = widget.output;
      _channel = widget.channel;
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    _offset = 0;
    _persons.clear();
    await _loadPersons();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPersons() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var persons = await channelService.pageInputPersonOf(
        _channel.id, _person.official, _limit, _offset);
    if (persons.isEmpty) {
      return;
    }
    _offset += persons.length;
    for (var p in persons) {
      if (p.official == _person.official) {
        continue;
      }
      _persons.add(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 50,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
              widget.context.forward('/netflow/channel/insite/persons',
                  arguments: <String, Object>{'channel': _channel,'person':_person.official});
            },
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Icon(
                    Icons.info,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    '上游网关',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 10,
          ),
          Expanded(
            child: (_person == null || _persons.isEmpty)
                ? _renderEmpty()
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: _renderUpstreams(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _renderEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            '没有啦',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _renderUpstreams() {
    var items = <Widget>[];
    for (var i = 0; i < _persons.length; i++) {
      var person = _persons[i];
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _output.add({'person': person});
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: getAvatarWidget(
                      person.avatar,
                      widget.context,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Text(
                      '${person.nickName}',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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

class _DownstreamPersons extends StatefulWidget {
  PageContext context;
  StreamController output;
  Channel channel;
  Person person;

  _DownstreamPersons({this.output, this.context, this.channel, this.person});

  @override
  __DownstreamPersonsState createState() => __DownstreamPersonsState();
}

class __DownstreamPersonsState extends State<_DownstreamPersons> {
  Person _person;
  Channel _channel;
  int _limit = 10, _offset = 0;
  List<Person> _persons = [];
  StreamController _output;

  @override
  void initState() {
    _output = widget.output;
    _person = widget.person;
    _channel = widget.channel;
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DownstreamPersons oldWidget) {
    if (oldWidget.person != widget.person) {
      _person = widget.person;
      _output = widget.output;
      _channel = widget.channel;
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    _offset = 0;
    _persons.clear();
    await _loadPersons();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPersons() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var persons = await channelService.pageOutputPersonOf(
        _channel.id, _person.official, _limit, _offset);
    if (persons.isEmpty) {
      return;
    }
    _offset += persons.length;
    for (var p in persons) {
      if (p.official == _person.official) {
        continue;
      }
      _persons.add(p);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 50,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
              widget.context.forward('/netflow/channel/outsite/persons',
                  arguments: <String, Object>{'channel': _channel,'person':_person.official});
            },
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Icon(
                    Icons.info,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    '下游网关',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 10,
          ),
          Expanded(
            child: (_person == null || _persons.isEmpty)
                ? _renderEmpty()
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: _renderDownstreams(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _renderEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            '没有啦',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _renderDownstreams() {
    var items = <Widget>[];
    for (var i = 0; i < _persons.length; i++) {
      var person = _persons[i];
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _output.add({'person': person});
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: getAvatarWidget(
                      person.avatar,
                      widget.context,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Text(
                      '${person.nickName}',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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

class ChanngeSelectedPersonNotification extends Notification {
  ChanngeSelectedPersonNotification({
    @required this.person,
    @required this.channel,
  });

  final Person person;
  final Channel channel;
}
