import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_helper.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';

class HelpFeedback extends StatefulWidget {
  PageContext context;

  HelpFeedback({this.context});

  @override
  _HelpFeedbackState createState() => _HelpFeedbackState();
}

class _HelpFeedbackState extends State<HelpFeedback> {
  EasyRefreshController _controller;
  List<WOTypeOR> _types = [];
  List<HelpFormOR> _helpForms = [];
  int _limit = 20, _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IWOFlowRemote flowRemote =
        await widget.context.site.getService('/feedback/woflow');
    var types = await flowRemote.listWOTypes();
    for (var type in types) {
      _types.add(type);
    }
    await _loadHelpForms();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadHelpForms() async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    var helpers = await helperRemote.pageHelpForm(_limit, _offset);
    if (helpers.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += helpers.length;
    _helpForms.addAll(helpers);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, v) {
          return _renderSlivers();
        },
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                children: [
                  Text(
                    '帮助',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: EasyRefresh(
                  controller: _controller,
                  onLoad: _loadHelpForms,
                  child: ListView(
                    shrinkWrap: true,
                    children: _renderHelps(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderSlivers() {
    var slivers = <Widget>[
      SliverAppBar(
        title: Text('帮助与反馈'),
        pinned: true,
        elevation: 0,
        centerTitle: true,
      ),
      SliverToBoxAdapter(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/system/wo/form');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                alignment: Alignment.centerRight,
                image: AssetImage('lib/portals/gbera/images/feedback.jpg'),
              ),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 20,
              bottom: 20,
            ),
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '提交问题',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    '已有明确问题，为您提供产品故障排查等技术支持',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 20,
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Row(
            children: [
              Text(
                '问题',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 10,
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          child: Column(
            children: _renderWOs(),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 10,
        ),
      ),
    ];

    return slivers;
  }

  List<Widget> _renderWOs() {
    var items = <Widget>[];
    for (var type in _types) {
      items.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.context.forward('/system/wo/list', arguments: {'type': type});
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${type.title}'),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ));
      items.add(
        Divider(
          height: 1,
          indent: 20,
        ),
      );
    }
    return items;
  }

  List<Widget> _renderHelps() {
    var items = <Widget>[];
    if (_helpForms.isEmpty) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Center(
          child: Text(
            '没有帮助',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var form in _helpForms) {
      items.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.context.forward('/system/fq/view', arguments: {'form': form});
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${form.title}'),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ));
      items.add(
        Divider(
          height: 1,
          indent: 20,
        ),
      );
    }
    return items;
  }
}
