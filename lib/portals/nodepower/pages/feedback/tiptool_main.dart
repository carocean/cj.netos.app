import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';

class TipToolMain extends StatefulWidget {
  PageContext context;

  TipToolMain({this.context});

  @override
  _TipToolMainState createState() => _TipToolMainState();
}

class _TipToolMainState extends State<TipToolMain> {
  EasyRefreshController _controller;
  List<TipsDocOR> _docs = [];
  int _limit = 30, _offset = 0;
  int _filter = 0; //0待办；1已上架;-1已下架;2为所有
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

  Future<void> _refresh() async {
    _offset = 0;
    _docs.clear();
    await _load();
  }

  Future<void> _load() async {
    ITipToolRemote tipToolRemote =
        widget.context.site.getService('/feedback/tiptool');
    var docs;
    if (_filter == 0) {
      docs = await tipToolRemote.pageOpenedTipsDoc(_limit, _offset);
    } else if (_filter == -1) {
      docs = await tipToolRemote.pageDownTipsDoc(_limit, _offset);
    } else if (_filter == 1) {
      docs = await tipToolRemote.pageReleasedTipsDoc(_limit, _offset);
    } else {
      docs = await tipToolRemote.pageAllTipsDoc(_limit, _offset);
    }
    if (docs.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      setState(() {});
      return;
    }
    _offset += docs.length;
    _docs.addAll(docs);
    setState(() {});
  }

  Future<void> _releaseTipsDoc(TipsDocOR doc) async {
    ITipToolRemote tipToolRemote =
        widget.context.site.getService('/feedback/tiptool');
    await tipToolRemote.releaseTipsDoc(doc.id);
    doc.state = 1;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _downTipsDoc(TipsDocOR doc) async {
    ITipToolRemote tipToolRemote =
        widget.context.site.getService('/feedback/tiptool');
    await tipToolRemote.downTipsDoc(doc.id);
    doc.state = -1;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('桌面提示'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.forward('/feedback/tiptool/creator').then((value) {
                // _offset=0;
                // _helpForms.clear();
                // _load();
              });
            },
            child: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 15,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showDialog(
                    context: context,
                    child: SimpleDialog(
                      title: Text('选择'),
                      children: [
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: 0);
                          },
                          text: '待审核',
                        ),
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: 1);
                          },
                          text: '已上架',
                        ),
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: -1);
                          },
                          text: '已下架',
                        ),
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: 2);
                          },
                          text: '全部',
                        ),
                      ],
                    ),
                  ).then((value) {
                    if (value == null) {
                      return;
                    }
                    _filter = value;
                    _refresh();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_getStateText(_filter)}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.filter,
                      size: 20,
                      color: Colors.black,
                    ),
                  ],
                ),
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
                  onLoad: _load,
                  child: ListView(
                    shrinkWrap: true,
                    children: _renderItems(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    if (_docs.isEmpty) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Center(
          child: Text(
            '没有提示',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var doc in _docs) {
      var actions = <Widget>[];
      switch (doc.state) {
        case 0:
          actions.add(
            FlatButton(
              onPressed: () {
                _releaseTipsDoc(doc);
              },
              child: Text(
                '上架',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
          actions.add(
            FlatButton(
              onPressed: () {
                _downTipsDoc(doc);
              },
              child: Text(
                '下架',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
          break;
        case 1:
          actions.add(
            FlatButton(
              onPressed: () {
                _downTipsDoc(doc);
              },
              child: Text(
                '下架',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
          break;
        case -1:
          actions.add(
            FlatButton(
              onPressed: () {
                _releaseTipsDoc(doc);
              },
              child: Text(
                '上架',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
          break;
      }
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            //doc.href的协议头判断：http://|https://是打开网页;help://为打开帮助
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                ),
                decoration: BoxDecoration(
                  color: Color(0xeef5f5f5),
                  borderRadius: BorderRadius.circular(8),
                  // color: Colors.white,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 55,
                      height: 55,
                      child: getAvatarWidget(
                        doc.leading,
                        widget.context,
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
                            '${doc.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${doc.summary}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 80,
                  right: 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '状态：',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 2,),
                          Text(
                            '${_getStateText(doc.state)}',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: actions,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 20,
        ),
      );
    }
    return items;
  }

  _getStateText(int state) {
    switch (state) {
      case 0:
        return '待审核';
      case 1:
        return '已上架';
      case -1:
        return '已下架';
      default:
        return '全部';
    }
  }
}
