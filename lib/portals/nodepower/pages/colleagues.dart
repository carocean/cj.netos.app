import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/nodepower/remote/uc_remote.dart';

class ColleaguePage extends StatefulWidget {
  PageContext context;

  ColleaguePage({this.context});

  @override
  _ColleaguePageState createState() => _ColleaguePageState();
}

class _ColleaguePageState extends State<ColleaguePage>
    with AutomaticKeepAliveClientMixin {
  EasyRefreshController _controller;
  int _limit = 20, _offset = 0;
  List<AppAcountOL> _accounts = [];

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onload() async {
    IAppRemote appRemote = widget.context.site.getService('/uc/app');
    var accounts = await appRemote.pageAccount(_limit, _offset);
    if (accounts.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _accounts.addAll(accounts);
    _offset += accounts.length;
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
            title: Text('同事'),
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
            slivers: _getColleagueWidgets(),
          ),
        ),
      ],
    );
  }

  List<Widget> _getColleagueWidgets() {
    var widgets = <Widget>[];
    for (var item in _accounts) {
      widgets.add(
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                CardItem(
                  title: '${item.nickName}',
                  leading: StringUtil.isEmpty(item.avatar)
                      ? SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                            'lib/portals/gbera/images/default_avatar.png',
                            fit: BoxFit.fill,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: FadeInImage.assetNetwork(
                            placeholder:
                                'lib/portals/gbera/images/default_watting.gif',
                            image:
                                '${item.avatar}?accessToken=${widget.context.principal.accessToken}',
                            width: 40,
                            height: 40,
                            fit: BoxFit.fill,
                          ),
                        ),
                  subtitle:
                      item.signature == null ? null : Text('${item.signature}'),
                  paddingRight: 15,
                  paddingLeft: 15,
                  onItemTap: () {
                    widget.context
                        .forward('/viewer/colleague', arguments: {'account': item});
                  },
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
