import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/operation_screen.dart';

class ScreenMain extends StatefulWidget {
  PageContext context;

  ScreenMain({this.context});

  @override
  _ScreenMainPanelState createState() => _ScreenMainPanelState();
}

class _ScreenMainPanelState extends State<ScreenMain> {
  StreamController _controller = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Future<void> _addSubject() {
    widget.context.forward('/operation/screen/create').then((value) {
      _controller?.sink?.add('createSubject');
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _clearScreen() async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    await screenRemote.clearScreen();
    _controller?.sink?.add('clearScreen');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];
    actions.add(
      FlatButton(
        onPressed: () {
          _clearScreen();
        },
        child: Text(
          '清除',
        ),
      ),
    );
    actions.add(
      FlatButton(
        onPressed: () {
          widget.context.forward('/desktop/screen');
        },
        child: Text(
          '预览',
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('桌面弹屏'),
        elevation: 0,
        actions: actions,
      ),
      body: Column(
        children: [
          _ScreenMainPanel(
            context: widget.context,
            controller: _controller,
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              bottom: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '主体',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _addSubject();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 2,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: _SubjectList(
              context: widget.context,
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectList extends StatefulWidget {
  PageContext context;
  StreamController controller;

  _SubjectList({
    this.context,
    this.controller,
  });

  @override
  __SubjectListState createState() => __SubjectListState();
}

class __SubjectListState extends State<_SubjectList> {
  List<ScreenSubjectOR> _subjects = [];
  int _limit = 20, _offset = 0;
  EasyRefreshController _controller = EasyRefreshController();
  ScreenResultOR _screenResultOR;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamSubscription = widget.controller.stream.listen((event) async {
      if ('createSubject' != event &&
          'updateSubject' != event &&
          'clearScreen' != event) {
        return;
      }
      IScreenRemote screenRemote =
          widget.context.site.getService('/operation/screen');
      _screenResultOR = await screenRemote.getCurrent();
      _refresh();
    });
    () async {
      IScreenRemote screenRemote =
          widget.context.site.getService('/operation/screen');
      _screenResultOR = await screenRemote.getCurrent();
      await _load();
    }();

    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SubjectList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _refresh() async {
    _subjects.clear();
    _offset = 0;
    await _load();
  }

  Future<void> _load() async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    var subjects = await screenRemote.pageSubject(_limit, _offset);
    if (subjects.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += subjects.length;
    _subjects.addAll(subjects);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _putOn(ScreenSubjectOR subject) async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    var rules = await screenRemote.listPopupRule();
    var items = <Widget>[];
    for (var r in rules) {
      items.add(
        InkWell(
          onTap: () {
            widget.context.backward(result: r.code);
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
              left: 15,
              right: 15,
            ),
            child: Row(
              children: [
                Text(
                  '${r.name ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
        ),
      );
    }
    var result = await showDialog(
      context: context,
      child: SimpleDialog(
        title: Text('弹屏规则'),
        elevation: 0,
        children: items,
      ),
    );
    if (result == null) {
      return;
    }
    var rule = result;
    await screenRemote.putOnScreen(subject.id, rule);
    widget.controller.add('refresh');
    _screenResultOR = await screenRemote.getCurrent();
    await _refresh();
  }

  Future<void> _putOnNone(subject) async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    await screenRemote.putOnScreen(subject.id, 'none');
    widget.controller.add('refresh');
    _screenResultOR = await screenRemote.getCurrent();
    await _refresh();
  }

  Future<void> _removeSubject(subject) async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    await screenRemote.removeSubject(subject.id);
    _subjects.removeWhere((element) {
      return element.id == subject.id;
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _moveDown(subject) async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    await screenRemote.moveDownSubject(subject.id);
    await _refresh();
  }

  Future<void> _moveUp(subject) async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    await screenRemote.moveUpSubject(subject.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 20,
        right: 20,
      ),
      child: EasyRefresh(
        controller: _controller,
        onLoad: _load,
        header: easyRefreshHeader(),
        footer: easyRefreshFooter(),
        child: ListView(
          padding: EdgeInsets.all(0),
          children: _renderItems(),
        ),
      ),
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    if (_subjects.isEmpty) {
      return items;
    }
    for (var subject in _subjects) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: StringUtil.isEmpty(subject.leading)
                    ? Image.asset('lib/portals/gbera/images/default_image.png')
                    : FadeInImage.assetNetwork(
                        placeholder:
                            'lib/portals/gbera/images/default_watting.gif',
                        image:
                            '${subject.leading}?accessToken=${widget.context.principal.accessToken}',
                        fit: BoxFit.contain,
                      ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        widget.context.forward(
                          '/operation/screen/view',
                          arguments: {'subject': subject},
                        ).then((value) {
                          widget.controller?.sink?.add('updateSubject');
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${subject.title ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 0,
                            ),
                            child: Text(
                              '${subject.subTitle ?? ''}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            _removeSubject(subject);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Icon(
                              Icons.clear,
                              size: 14,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _moveUp(subject);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Icon(
                              Icons.upload_rounded,
                              size: 14,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _moveDown(subject);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              size: 14,
                            ),
                          ),
                        ),
                        ..._renderActions(subject),
                      ],
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
        ),
      );
    }
    return items;
  }

  List<Widget> _renderActions(ScreenSubjectOR subject) {
    var items = <Widget>[];
    if (_screenResultOR == null ||
        _screenResultOR.subject == null ||
        _screenResultOR.subject.id != subject.id ||
        (_screenResultOR.subject.id == subject.id &&
            _screenResultOR.rule.code == 'none')) {
      items.add(
        InkWell(
          onTap: () {
            _putOn(subject);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Text(
              '上屏',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    } else {
      items.add(
        InkWell(
          onTap: () {
            _putOnNone(subject);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            child: Text(
              '不再上屏',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }
}

class _ScreenMainPanel extends StatefulWidget {
  PageContext context;
  StreamController controller;

  _ScreenMainPanel({this.context, this.controller});

  @override
  __ScreenMainState createState() => __ScreenMainState();
}

class __ScreenMainState extends State<_ScreenMainPanel> {
  ScreenResultOR _screenResultOR;
  bool _isLoading = true;
  InAppWebViewController _controller;
  bool _isLoadingWebview = false;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamSubscription = widget.controller.stream.listen((event) async {
      if ('refresh' != event &&
          'updateSubject' != event &&
          'clearScreen' != event) {
        return;
      }
      await _load();
      try {
        if (_screenResultOR?.subject?.href != null) {
          await _controller?.loadUrl(url: _screenResultOR?.subject?.href);
        }
      } catch (e) {}
    });
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    _screenResultOR = await screenRemote.getCurrent();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text('正在加载...'),
        ),
      );
    }
    if (_screenResultOR == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    var subject = _screenResultOR.subject;
    var rule = _screenResultOR.rule;
    if (subject == null || rule == null || rule.code == 'none') {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _renderScreen(
          subject,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: 15,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${subject.title ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${subject.subTitle ?? ''}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '弹出规则：',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          '${rule.name ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderScreen(ScreenSubjectOR subject) {
    var items = <Widget>[
      InAppWebView(
        initialUrl: subject.href,
        onWebViewCreated: (InAppWebViewController controller) async {
          this._controller = controller;
        },
        onLoadStart: (controller, url) {
          if (mounted) {
            setState(() {
              _isLoadingWebview = true;
            });
          }
        },
        onLoadStop: (controller, url) async {
          if (mounted) {
            setState(() {
              _isLoadingWebview = false;
            });
          }
        },
      ),
    ];
    if (_isLoadingWebview) {
      items.add(
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              '正在加载...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      height: (Adapt.screenH() - 86) / 2,
      width: (Adapt.screenW() + 10) / 2,
      margin: EdgeInsets.only(
        left: 20,
        right: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400],
            blurRadius: 2,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: items,
      ),
    );
  }
}
