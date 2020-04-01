import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
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
    _receptor=null;
    _controller?.dispose();
    _pofList.clear();
    super.dispose();
  }

  Future<void> _onloadFans() async {
    _isLoad=false;
    IGeoReceptorRemote receptorRemote =
    widget.context.site.getService('/remote/geo/receptors');
    var pofList = await receptorRemote.pageReceptorFans(
      categroy: _receptor.category,
      receptor: _receptor.id,
      limit: _limit,
      offset: _offset,
    );
    if (pofList.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      _isLoad=true;
      return;
    }
    _offset += pofList.length;
    _pofList.addAll(pofList);
    _isLoad=true;
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
      list.add(
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              CardItem(
                leading: Icon(
                  Icons.person,
                  size: 40,
                ),
                title: '${follow.person.nickName}',
                subtitle: Text(
                  '${follow.person.signature??''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                tipsText: '距中心：${getFriendlyDistance(follow.distance)}',
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
