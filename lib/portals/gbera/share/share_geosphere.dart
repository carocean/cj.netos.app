import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/single_media_widget.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class GeosphereSharePage extends StatefulWidget {
  PageContext context;

  GeosphereSharePage({this.context});

  @override
  _GeosphereSharePageState createState() => _GeosphereSharePageState();
}

class _GeosphereSharePageState extends State<GeosphereSharePage> {
  String _href;
  String _title;
  String _summary;
  String _leading;
  List<GeoReceptor> _receptors = [];
  bool _isLoading = true;
  GeoReceptor _selector;
  EasyRefreshController _controller = EasyRefreshController();
  int _limit = 10, _offset = 0;

  @override
  void initState() {
    var args = widget.context.parameters;
    _href = args['href'];
    _title = args['title'];
    _summary = args['summary'];
    _leading = args['leading'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _loadReceptors();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReceptors() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var receptors = await receptorService.page(_limit, _offset);
    if (receptors.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset+=receptors.length;
    _receptors.addAll(receptors);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地圈发布'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            renderShareEditor(
              context: widget.context,
              title: _title,
              href: _href,
              leading: _leading,
              summary: _summary,
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 15,
                            bottom: 15,
                            left: 10,
                            right: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  right: 10,
                                ),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    Icons.spellcheck,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Text(
                                '购买该服务',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '零钱 ¥1.00',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 15,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 15,
                            bottom: 15,
                            left: 10,
                            right: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  right: 10,
                                ),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Text(
                                '所在位置',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '锦尚小区附近',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '分享给',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: _renderSelected(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                '地圈',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: EasyRefresh(
                                controller: _controller,
                                onLoad: _loadReceptors,
                                child: ListView(
                                  children: _renderReceptors(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLeading(GeoReceptor receptor) {
    Widget imgSrc = null;
    if (StringUtil.isEmpty(receptor.leading)) {
      imgSrc = Icon(
        IconData(
          0xe604,
          fontFamily: 'netflow2',
        ),
        size: 32,
        color: Colors.grey[500],
      );
    } else if (receptor.leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(receptor.leading),
        width: 40,
        height: 40,
      );
    } else {
      imgSrc = FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image:
            '${receptor.leading}?accessToken=${widget.context.principal.accessToken}',
        width: 40,
        height: 40,
      );
    }
    return imgSrc;
  }

  List<Widget> _renderReceptors() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Container(
          height: 60,
          alignment: Alignment.center,
          child: Text('正在加载...'),
        ),
      );
      return items;
    }
    if (_receptors.isEmpty) {
      items.add(
        Container(
          height: 60,
          alignment: Alignment.center,
          child: Text('没有地理感知器'),
        ),
      );
      return items;
    }
    for (var receptor in _receptors) {
      items.add(InkWell(
        onTap: () {
          _selector = receptor;
          if (mounted) {
            setState(() {});
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: _getLeading(receptor),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${receptor.title}',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              (_selector != null && _selector.id == receptor.id)
                  ? Icon(
                      Icons.check,
                      color: Colors.grey,
                      size: 18,
                    )
                  : SizedBox(
                      width: 0,
                      height: 0,
                    ),
            ],
          ),
        ),
      ));
      items.add(
        Divider(
          height: 1,
          indent: 40,
        ),
      );
    }
    return items;
  }

  List<Widget> _renderSelected() {
    var items = <Widget>[];
    if (_selector != null) {
      items.add(
        Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: _getLeading(_selector),
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '${_selector.title}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    return items;
  }
}
