import 'dart:async';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class ShowSliceAbsorbersPage extends StatefulWidget {
  PageContext context;

  ShowSliceAbsorbersPage({this.context});

  @override
  _ShowSliceAbsorbersPageState createState() => _ShowSliceAbsorbersPageState();
}

class _ShowSliceAbsorbersPageState extends State<ShowSliceAbsorbersPage> {
  Map<String, AbsorberResultOR> _absorbers;
  StreamController _streamController;
  StreamSubscription _streamSubscription;
  @override
  void initState() {
    _streamController=StreamController.broadcast();
    _absorbers = widget.context.parameters['absorbers'];
    if (_absorbers == null) {
      _absorbers = {};
    }
    _streamSubscription= Stream.periodic(Duration(seconds: 5,),(count){
      _streamController.add({});
    }).listen((event) {

    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
              child: Text(
                '我的招财猫',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              child: _rendMyAbsorbers(),
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
              child: Text(
                '他人的招财猫',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: _renderOthersAbsobers(),
            ),
          ],
        ),
      ),
    );
  }

  _rendMyAbsorbers() {
    var items = <Widget>[];
    var me = widget.context.principal.person;
    bool hasMyAbsorbers = false;
    for (var a in _absorbers.values) {
      if (a.absorber.creator == me) {
        continue;
      }
      hasMyAbsorbers = true;
      items.add(
          _AbsorberItemPannel(
            context: widget.context,
            absorberResultOR: a,
            stream: _streamController.stream,
          ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 50,
        ),
      );
    }
    if (!hasMyAbsorbers) {
      items.add(
        Center(
          child: Text(
            '没有招财猫',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Column(
      children: items,
    );
  }

  _renderOthersAbsobers() {
    var items = <Widget>[];
    var me = widget.context.principal.person;
    bool hasMyAbsorbers = false;
    for (var a in _absorbers.values) {
      if (a.absorber.creator != me) {
        continue;
      }
      hasMyAbsorbers = true;
      items.add(
        _AbsorberItemPannel(
          context: widget.context,
          absorberResultOR: a,
          stream: _streamController.stream,
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 50,
        ),
      );
    }
    if (!hasMyAbsorbers) {
      items.add(
        Center(
          child: Text(
            '没有招财猫',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Column(
      children: items,
    );
  }
}

class _AbsorberItemPannel extends StatefulWidget {
  PageContext context;
  AbsorberResultOR absorberResultOR;
  Stream stream;

  _AbsorberItemPannel({this.context, this.absorberResultOR, this.stream});

  @override
  __AbsorberItemPannelState createState() => __AbsorberItemPannelState();
}

class __AbsorberItemPannelState extends State<_AbsorberItemPannel> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  double _myAbsorbAmount = 0.00;
  StreamSubscription _streamSubscription;
  StreamController _streamController;

  bool get isRed {
    return _absorberResultOR.bucket.price >= _bulletin.bucket.waaPrice;
  }

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _absorberResultOR = widget.absorberResultOR;
    _load();
    _streamSubscription = widget.stream.listen((event) async {
      await _load();
      if (!_streamController.isClosed) {
        _streamController
            .add({'absorber': _absorberResultOR, 'bulletin': _bulletin});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AbsorberItemPannel oldWidget) {
    if (oldWidget.absorberResultOR.absorber.id !=
        widget.absorberResultOR.absorber.id) {
      oldWidget.absorberResultOR = widget.absorberResultOR;
      _absorberResultOR = widget.absorberResultOR;
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    _absorberResultOR =
    await robotRemote.getAbsorber(_absorberResultOR.absorber.id);
    _bulletin =
    await robotRemote.getDomainBucket(_absorberResultOR.absorber.bankid);
    _myAbsorbAmount = await robotRemote.totalRecipientsRecord(
        _absorberResultOR.absorber.id, widget.context.principal.person);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bulletin == null) {
      return SizedBox(
        height: 80,
        width: 0,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_absorberResultOR.absorber.type == 0) {
          widget.context.forward('/absorber/details/simple', arguments: {
            'absorber': _absorberResultOR.absorber.id,
            'stream': _streamController.stream.asBroadcastStream(),
            'initAbsorber': _absorberResultOR,
            'initBulletin': _bulletin,
          });
          return;
        }
        widget.context.forward('/absorber/details/geo', arguments: {
          'absorber': _absorberResultOR.absorber.id,
          'stream': _streamController.stream.asBroadcastStream(),
          'initAbsorber': _absorberResultOR,
          'initBulletin': _bulletin,
        });
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            Row(
              children: [
                Image.asset(
                  isRed
                      ? 'lib/portals/gbera/images/cat-red.gif'
                      : 'lib/portals/gbera/images/cat-green.gif',
                  width: 40,
                  height: 40,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_absorberResultOR.absorber.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${_getTypeLabel()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${_absorberResultOR.absorber.state == 1 ? '运行中' : '已关停'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¥${((_myAbsorbAmount ?? 0.00) / 100.00).toStringAsFixed(14)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    // color: isRed?Colors.red:Colors.green,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  _getTypeLabel() {
    switch (_absorberResultOR.absorber.type) {
      case 0:
        return '简易洇取器';
      case 1:
        return '地理洇取器';
      case 2:
        return '余额洇取器';
      default:
        return '';
    }
  }
}