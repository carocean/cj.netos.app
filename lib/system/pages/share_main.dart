import 'package:accept_share/accept_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:html/parser.dart' show parse;
import 'package:native_screenshot/native_screenshot.dart';
import 'package:netos_app/common/single_media_widget.dart';

class AcceptShareMain extends StatefulWidget {
  PageContext context;

  AcceptShareMain({this.context});

  @override
  _AcceptShareMainState createState() => _AcceptShareMainState();
}

class _AcceptShareMainState extends State<AcceptShareMain> {
  String _href;
  String _title;
  String _summary;
  String _leading;
  bool _isParsed = false;

  @override
  void initState() {
    AcceptShare.setCallback((MethodCall call) async {
      if ('share' != call.method) {
        return;
      }
      var content = call.arguments;
      if (StringUtil.isEmpty(content)) {
        return;
      }
      _parseHref(content);
      // WidgetsBinding.instance.addPostFrameCallback((d) {
      //   widget.context.forward(
      //     "/public/entrypoint?share=accept",
      //     clearHistoryByPagePath: '.',
      //     arguments: {'content': call.arguments},
      //   );
      // });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _parseHref(String content) {
    int pos = content.indexOf('http://');
    if (pos < 0) {
      pos = content.indexOf('https://');
    }
    var remaining = content.substring(pos, content.length);
    pos = remaining.indexOf(' ');
    if (pos > -1) {
      remaining = remaining.substring(0, pos);
    }
    _href = remaining;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _parseHtml(String html) async {
    var doc = parse(html);
    var img = doc.querySelector('body img');
    var src;
    if (img?.attributes != null) {
      src = img?.attributes['src'];
    }
    if (!StringUtil.isEmpty(src)) {
      _leading = src;
    }
    _summary = doc.querySelector('body')?.text;
    if (!StringUtil.isEmpty(_summary)) {
      if (_summary.length > 100) {
        _summary = _summary.substring(0, 100);
      }
      int pos = _summary.indexOf(_title);
      if (pos > -1) {
        _summary.substring(_title.length);
        while (_summary.startsWith(' ')) {
          _summary = _summary.substring(1);
        }
        pos = _summary.indexOf(' ');
        if (pos > 0) {
          _summary = _summary.substring(pos + 1);
          while (_summary.startsWith(' ')) {
            _summary = _summary.substring(1);
          }
        }
        pos = _summary.indexOf(' ');
        if (pos > 0) {
          _summary = _summary.substring(pos + 1);
          while (_summary.startsWith(' ') || _summary.startsWith('　')) {
            _summary = _summary.substring(1);
          }
        }
      }
      pos = _summary.indexOf(' ');
      if (pos > 0) {
        _summary = _summary.substring(0, pos);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地微'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            StringUtil.isEmpty(_href)
                ? SizedBox(
                    width: 0,
                    height: 0,
                  )
                : SizedBox(
                    height: 100,
                    width: 100,
                    child: InAppWebView(
                      initialUrl: _href,
                      onWebViewCreated:
                          (InAppWebViewController controller) async {},
                      onLoadStop: (controller, url) async {
                        var html = await controller.getHtml();
                        _title = await controller.getTitle();
                        if (!StringUtil.isEmpty(_title)) {
                          while (_title.startsWith(' ') ||
                              _title.startsWith('　')) {
                            _title = _title.substring(1);
                          }
                        }
                        await _parseHtml(html);
                        if (StringUtil.isEmpty(_leading)) {
                          var capture = await NativeScreenshot.takeScreenshot();
                          _leading = capture;
                        }
                        _isParsed = true;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
            !_isParsed
                ? Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints.expand(),
                      child: Container(
                        color: Colors.white24,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 20,
                          bottom: 20,
                        ),
                        child: Text('正在准备，请稍候...'),
                      ),
                    ),
                  )
                : Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30,),
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _rendContentPanel(),
                          ),
                          SizedBox(height: 30,),
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints.expand(),
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.only(left: 20,right: 20,),
                                constraints: BoxConstraints.tightForFinite(
                                  width: double.maxFinite,
                                ),
                                height: 50,
                                child: RaisedButton(
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  disabledTextColor: Colors.white70,
                                  disabledColor: Colors.grey[400],
                                  onPressed: (){
                                      widget.context.forward(
                                        "/public/entrypoint?share=accept",
                                        clearHistoryByPagePath: '.',
                                        arguments: {'summary': _summary,'leading':_leading,'title':_title,'href':_href},
                                      );
                                  },
                                  child: Text('分享'),
                                ),
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

  Widget _rendContentPanel() {
    if (!_isParsed) {
      return Container(
        padding: EdgeInsets.only(top: 40, bottom: 40),
        alignment: Alignment.center,
        child: Text('正在解析内容...'),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: SingleMediaWidget(
            context: widget.context,
            image: _leading,
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
                '${_title ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '${_summary ?? ''}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
