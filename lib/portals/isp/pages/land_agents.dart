import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';

class LandAgentsPage extends StatefulWidget {
  PageContext context;

  LandAgentsPage({this.context});

  @override
  _LandAgentsPageState createState() => _LandAgentsPageState();
}

class _LandAgentsPageState extends State<LandAgentsPage>
    with AutomaticKeepAliveClientMixin {
  EasyRefreshController _controller;
  Map<String, OrgISPOL> _ispMap = {};
  int _limit = 20, _offset = 0;
  List<OrgLAOL> _laList = [];

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    _loadIspList().then((value) {
      _onload();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadIspList() async {
    IIspRemote ispRemote = widget.context.site.getService('/org/isp');
    List<OrgISPOL> ispList = await ispRemote.listMyOrgIsp();
    for (var isp in ispList) {
      _ispMap[isp.id] = isp;
    }
  }

  Future<void> _onload() async {
    ILaRemote laRemote = widget.context.site.getService('/org/la');
    List<OrgLAOL> laList =
        await laRemote.pageLaOfIspList(_ispMap.keys.toList(), _limit, _offset);
    if (laList.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _offset += laList.length;
    _laList.addAll(laList);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          context: context,
          child: AppBar(
            title: Text('辖区地商'),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            toolbarOpacity: 1,
            actions: <Widget>[],
          ),
        ),
        Expanded(
          child: EasyRefresh.custom(
            controller: _controller,
            onLoad: _onload,
            slivers: _rendList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _rendList() {
    var items = <Widget>[];
    if (_laList.isEmpty) {
      items.add(
        SliverFillRemaining(
          child: Container(
            alignment: Alignment.center,
            child: Text('正在加载'),
          ),
        ),
      );
    }
    items.add(
      SliverToBoxAdapter(
        child: Container(
          height: 5,
          color: Colors.white,
        ),
      ),
    );
    for (var i = 0; i < _laList.length; i++) {
      var la = _laList[i];
      items.add(
        SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/org/la', arguments: {'la': la});
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                      bottom: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      child: FadeInImage.assetNetwork(
                        placeholder:
                            'lib/portals/gbera/images/default_watting.gif',
                        image:
                            '${la.corpLogo}?accessToken=${widget.context.principal.accessToken}',
                        width: 40,
                        height: 40,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 2,
                      children: <Widget>[
                        Text(
                          '${la.corpSimple}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Wrap(
                          spacing: 5,
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: <Widget>[
                            Text(
                              '业主',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${la.masterPerson}(${la.masterRealName})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 5,
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: <Widget>[
                            Text(
                              '电话',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                var data = ClipboardData(
                                  text: la.masterPhone,
                                );
                                Clipboard.setData(data);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('复制电话号码成功'),
                                ));
                              },
                              child: Text(
                                '${la.masterPhone}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (i < _laList.length - 1) {
        items.add(
          SliverToBoxAdapter(
            child: Container(
              height: 10,
              color: Colors.white,
              child: Divider(
                height: 1,
                indent: 70,
              ),
            ),
          ),
        );
      }
    }
    items.add(
      SliverToBoxAdapter(
        child: Container(
          height: 5,
          color: Colors.white,
        ),
      ),
    );
    return items;
  }
}
