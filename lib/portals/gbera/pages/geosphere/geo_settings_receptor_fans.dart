import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/gbera_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

import 'geo_entities.dart';

class GeosphereReceptorFans extends StatefulWidget {
  PageContext context;

  GeosphereReceptorFans({this.context});

  @override
  _GeosphereReceptorFansState createState() => _GeosphereReceptorFansState();
}

class _GeosphereReceptorFansState extends State<GeosphereReceptorFans> {
  EasyRefreshController _controller;
  List<GeoPOF> _pofList = [];
  bool _isLoad = false;
  int _limit = 15, _offset = 0;
  ReceptorInfo _receptor;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _receptor = widget.context.parameters['receptor'];
    _onloadFans().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _receptor = null;
    _controller?.dispose();
    _pofList.clear();
    super.dispose();
  }

  Future<void> _onloadFans() async {
    _isLoad = false;
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    var pofList = await receptorRemote.pageReceptorFans(
      receptor: _receptor.id,
      limit: _limit,
      offset: _offset,
    );
    if (pofList.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      _isLoad = true;
      return;
    }
    _offset += pofList.length;
    _pofList.addAll(pofList);
    _isLoad = true;
  }

  Future<void> _allowFollowSpeak(GeoPOF follow) async {
    IGeoReceptorRemote receptorRemote =
    widget.context.site.getService('/remote/geo/receptors');
    await receptorRemote.allowFollowSpeak(_receptor.id, follow.person);
    follow.rights = 'allowSpeak';
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _denyFollowSpeak(GeoPOF follow) async {
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    await receptorRemote.denyFollowSpeak(_receptor.id, follow.person);
    follow.rights = 'denySpeak';
    if (mounted) {
      setState(() {});
    }
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
          Expanded(
            child: EasyRefresh(
              header: easyRefreshHeader(),
              footer: easyRefreshFooter(),
              onLoad: _onloadFans,
              controller: _controller,
              child: ListView(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                children: _getFansWidgets(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getFansWidgets() {
    var list = <Widget>[];
    if (_pofList.isEmpty) {
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
    for (var follow in _pofList) {
      dynamic card=CardItem(
        leading: SizedBox(
          height: 40,
          width: 40,
          child: getAvatarWidget(
            follow.person?.avatar,
            widget.context,
          ),
        ),
        title: '${follow.person.nickName}',
        subtitle: Text(
          '${follow.person.signature ?? ''}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        tipsText: '距中心：${getFriendlyDistance(follow.distance)}',
        onItemTap: () {
          widget.context.forward('/person/view',
              arguments: {'person': follow.person});
        },
      );
      if(_receptor.creator==widget.context.principal.person) {
        card=Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: follow.rights == 'denySpeak' ? '不再禁止发言' : '不再充许发言',
              foregroundColor:follow.rights == 'denySpeak' ? Colors.grey[500]:Colors.green,
              icon: follow.rights == 'denySpeak' ?Icons.block:Icons.speaker,
              onTap: () {
                if (follow.rights == 'denySpeak') {
                  _allowFollowSpeak(follow);
                } else {
                  _denyFollowSpeak(follow);
                }
              },
            ),
          ],
          child: card,
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
              card,
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
