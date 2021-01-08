import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/portals/gbera/store/remotes/operation_screen.dart';

class ScreenPopupPage extends StatefulWidget {
  PageContext context;

  ScreenPopupPage({this.context});

  @override
  _ScreenPopupPageState createState() => _ScreenPopupPageState();
}

class _ScreenPopupPageState extends State<ScreenPopupPage> {
  ScreenResultOR _screen;
  bool _isLoading = true;
  InAppWebViewController _controller;
  bool _isLoadingWebview = true;
  Color _backgroundColor;
  @override
  void initState() {
    _backgroundColor = widget.context.parameters['backgroundColor'];
    if(_backgroundColor==null&&widget.context.partArgs!=null) {
      _backgroundColor =widget.context.partArgs['backgroundColor'];
    }
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/desktop/screen');
    if(screenRemote==null) {
      screenRemote=widget.context.site.getService('/operation/screen');
    }
    _screen = await screenRemote.getCurrent();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _renderWebview(),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                 NotificationListener(
                   child:  _SubjectButtion(
                     context: widget.context,
                   ),
                   onNotification: (notification){
                     if(notification is _MyNotification) {
                       _controller?.loadUrl(url: notification.subject.href);
                     }
                     return false;
                   },
                 ),
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: _backgroundColor,
                    ),
                    onPressed: () {
                      widget.context.backward();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderWebview() {
    if (_isLoading) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    if(_screen==null||_screen.rule.code=='none'){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('没有弹屏',style: TextStyle(color: Colors.grey,fontSize: 12,),),
        ],
      );
    }
    return InAppWebView(
      initialUrl: _screen.subject.href,
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
    );
  }
}

class _SubjectButtion extends StatefulWidget {
  PageContext context;
  _SubjectButtion({this.context});

  @override
  __SubjectButtionState createState() => __SubjectButtionState();
}

class __SubjectButtionState extends State<_SubjectButtion> {
  Color _backgroundColor;
  List<ScreenSubjectOR> _subjects = [];
  int _limit = 20, _offset = 0;
  EasyRefreshController _controller = EasyRefreshController();
  bool _isLoading = true;

  @override
  void initState() {
    _backgroundColor = widget.context.parameters['backgroundColor'];
    _load().then((value) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _subjects.isEmpty) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    return IconButton(
      icon: Icon(
        Icons.more_horiz,
        color: _backgroundColor,
      ),
      onPressed: () {
        showDialog(
          context: context,
          child: Scaffold(
            appBar: AppBar(
              title: Text('选择主体'),
              elevation: 0,
              centerTitle: true,
            ),
            body: EasyRefresh(
              controller: _controller,
              onLoad: _load,
              header: easyRefreshHeader(),
              footer: easyRefreshFooter(),
              child: ListView(
                children: _renderSubjects(),
              ),
            ),
          ),
        ).then((value){
          if(value==null) {
            return;
          }
          _MyNotification(value).dispatch(context);
        });
      },
    );
  }

  List<Widget> _renderSubjects() {
    var items = <Widget>[];
    for (var subject in _subjects) {
      items.add(
        InkWell(
          onTap: () {
            widget.context.backward(result: subject);
          },
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
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
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subject.title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${subject.subTitle ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),),
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
    return items;
  }
}
class _MyNotification extends Notification{
  ScreenSubjectOR subject;

  _MyNotification(this.subject);
}