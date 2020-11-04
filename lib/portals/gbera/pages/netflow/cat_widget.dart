import 'dart:async';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';

class CatWidget extends StatefulWidget {
  PageContext context;
  String channelId;
  double size;
  Widget tipsWidget;
  bool canTap;
  CatWidget({
    this.context,
    this.channelId,
    this.size,
    this.tipsWidget,
    this.canTap,
  });

  @override
  _CatWidgetState createState() => _CatWidgetState();
}

class _CatWidgetState extends State<CatWidget> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  bool _isLoaded = false, _isRefreshing = false;
  StreamController _streamController;
  StreamSubscription _streamSubscription;
  Channel _channel;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _isLoaded = false;
    _load().then((value) {
      _isLoaded = true;
      if (mounted) setState(() {});
    });
    _streamSubscription = Stream.periodic(
        Duration(
          seconds: 5,
        ), (count) async {
      if (!_isRefreshing && mounted) {
        return await _refresh();
      }
    }).listen((event) async {
      var v = await event;
      if (v == null) {
        return;
      }
      if (v && !_streamController.isClosed) {
        _streamController
            .add({'absorber': _absorberResultOR, 'bulletin': _bulletin});
      }
      if (mounted) {
        setState(() {});
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

  Future<bool> _refresh() async {
    _isRefreshing = true;
    var diff = await _load();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
    return diff;
  }

  Future<bool> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    _channel = await channelService.getChannel(widget.channelId);
    if (_channel == null) {
      return false;
    }
    var absorbabler = '${_channel.owner}/${_channel.id}';
    var absorberResultOR =
        await robotRemote.getAbsorberByAbsorbabler(absorbabler);
    if (absorberResultOR == null) {
      return false;
    }
    var bulletin =
        await robotRemote.getDomainBucket(absorberResultOR.absorber.bankid);
    bool diff = (_absorberResultOR == null ||
        (_absorberResultOR.bucket.price != absorberResultOR.bucket.price) ||
        (_bulletin.bucket.waaPrice != bulletin.bucket.waaPrice));
    _bulletin = bulletin;
    _absorberResultOR = absorberResultOR;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _channel == null||_absorberResultOR == null) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    //存在
    var items=<Widget>[];
    if(widget.tipsWidget!=null) {
      items.add(widget.tipsWidget);
      items.add(SizedBox(width: 5,),);
    }
    var cat=Icon(
      IconData(
        0xe6b2,
        fontFamily: 'absorber',
      ),
      size: widget.size??20,
      color: _absorberResultOR.bucket.price >= _bulletin.bucket.waaPrice
          ? Colors.red
          : Colors.green,
    );
    if(widget.canTap) {
      items.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          widget.context.forward('/absorber/details/simple', arguments: {
            'absorber': _absorberResultOR.absorber.id,
            'stream': _streamController.stream.asBroadcastStream(),
            'initAbsorber': _absorberResultOR,
            'initBulletin': _bulletin,
          });
        },
        child: cat,
      ));
    }else{
      items.add(cat);
    }
    items.add(SizedBox(width: 5,),);
    return Row(
      children: items,
    );
  }
}
