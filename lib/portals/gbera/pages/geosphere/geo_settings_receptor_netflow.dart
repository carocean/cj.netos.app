import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

import 'geo_entities.dart';

class GeosphereReceptorNetflowGateway extends StatefulWidget {
  PageContext context;

  GeosphereReceptorNetflowGateway({this.context});

  @override
  _GeosphereReceptorNetflowGatewayState createState() =>
      _GeosphereReceptorNetflowGatewayState();
}

class _GeosphereReceptorNetflowGatewayState
    extends State<GeosphereReceptorNetflowGateway> {
  List<ChannelOR> _channels = [];
  bool _isLoad = false;
  ReceptorInfo _receptor;

  @override
  void initState() {
    _receptor = widget.context.parameters['receptor'];
    _loadChannels().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _receptor = null;
    _channels.clear();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    _isLoad = false;
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    var pofList = await receptorRemote.listReceptorChannels();
    if (pofList.isEmpty) {
      _isLoad = true;
      return;
    }
    _channels.addAll(pofList);
    _isLoad = true;
  }

  Future<void> _removeChannelOutGeo(ChannelOR ch) async {
    IChannelPinService pinService =
    widget.context.site.getService('/channel/pin');
    await pinService.setOutputGeoSelector(ch.channel, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page.title,
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 8,
              left: 15,
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              '我的网流管道',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              children: _getNetworkChannels(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getNetworkChannels() {
    var list = <Widget>[];
    if (_channels.isEmpty) {
      if (_isLoad) {
        list.add(
          Center(
            child: Text('没有发现'),
          ),
        );
        return list;
      }
      list.add(
        Center(
          child: Text('加载中...'),
        ),
      );
      return list;
    }
    for (var ch in _channels) {
      var leading = ch.leading;
      var leadingImg;
      if (StringUtil.isEmpty(leading)) {
        leadingImg = Image.asset(
          'lib/portals/gbera/images/netflow.png',
          width: 40,
          height: 40,
        );
      } else if (leading.startsWith('/')) {
        leadingImg = Image.file(
          File(leading),
          width: 40,
          height: 40,
        );
      } else {
        leadingImg = Image.network(
          '$leading?accessToken=${widget.context.principal.accessToken}',
          width: 40,
          height: 40,
        );
      }
      var actions = <Widget>[];
      bool isDiTuiChannel = ch.channel == 'd99bf0e3b662b062d8328b9477e6df16';
      if (!isDiTuiChannel) {
        actions.add(
          IconSlideAction(
            caption: '删除',
            icon: Icons.delete_sweep,
            onTap: () {
              _removeChannelOutGeo(ch).then(
                (v) {
                  _channels.removeWhere((or) {
                    if (ch.channel == or.channel) {
                      return true;
                    }
                    return false;
                  });
                  setState(() {});
                },
              );
            },
          ),
        );
      }
      list.add(
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Slidable(
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: actions,
                child: CardItem(
                  leading: leadingImg,
                  title: ch.title ?? '',
                  tipsText: !isDiTuiChannel ? '左滑移除' : '不可移除',
                  tail: Icon(
                    !isDiTuiChannel ? Icons.arrow_back : Icons.remove,
                    color: Colors.grey[500],
                    size: 14,
                  ),
                ),
              ),
              Divider(
                height: 1,
                indent: 50,
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }
}
