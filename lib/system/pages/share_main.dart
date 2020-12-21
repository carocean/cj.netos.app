import 'dart:io';

import 'package:accept_share/accept_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:html/parser.dart' show parse;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:netos_app/common/single_media_widget.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

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
  InAppWebViewController controller;

  @override
  void initState() {
    AcceptShare.setCallback((MethodCall call) async {
      if ('shareCapture' != call.method) {
        return;
      }
      var content = call.arguments;
      if (StringUtil.isEmpty(content)) {
        return;
      }
      _parseHref(content);
      if (controller != null) {
        controller.loadUrl(url: _href);
      }
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
    //由于一些网站喜欢将内容放在iframe里，所以摘要还是不要了，但仍保留只是不显示
    var doc = parse(html);
    var img = doc.querySelector('body img');
    var src;
    if (img?.attributes != null) {
      src = img?.attributes['src'];
    }
    if (!StringUtil.isEmpty(src) && _isImage(src)) {
      _leading = src;
    }
    _summary = doc.querySelector('body')?.text;
    if (!StringUtil.isEmpty(_summary)) {
      int pos = _summary.indexOf(_title);
      if (pos > -1) {
        _summary = _summary.substring(_title.length);
        while (_summary.startsWith(' ')) {
          _summary = _summary.substring(1);
        }
      }
      var list = _summary.split(' ');
      for (var seg in list) {
        if (StringUtil.isEmpty(seg)) {
          continue;
        }
        if (seg.length > 20) {
          _summary = seg;
          break;
        }
      }
    }
  }

  bool _isImage(String src) {
    return src.indexOf('.php') < 0 &&
        src.indexOf('.jsp') < 0 &&
        src.indexOf('.asp') < 0 &&
        src.indexOf('.aspx') < 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地微'),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () async {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
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
                          (InAppWebViewController controller) async {
                        this.controller = controller;
                      },
                      onLoadStop: (controller, url) async {
                        _isParsed = false;
                        if (mounted) {
                          setState(() {});
                        }
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
                          var pngBytes = await controller.takeScreenshot();
                          Directory dir =
                              await getApplicationDocumentsDirectory();
                          var fn = '${dir.path}/${MD5Util.MD5(_title)}.png';
                          var file = File(fn);
                          if (file.existsSync()) {
                            file.deleteSync();
                          }
                          file.writeAsBytesSync(pngBytes);
                          // await ImageGallerySaver.saveFile(fn);
                          _leading = fn;
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
                      color: Theme.of(context).backgroundColor,
                      constraints: BoxConstraints.expand(),
                      child: Text('正在解析，请稍候...'),
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
                          SizedBox(
                            height: 30,
                          ),
                          renderShareCard(
                            context: widget.context,
                            title: _title,
                            href: _href,
                            leading: _leading,
                            summary: _summary,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  constraints: BoxConstraints.tightForFinite(
                                    width: double.maxFinite,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '分享到',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              AcceptShare.forwardEasyTalk(
                                                arguments: {
                                                  'summary': _summary,
                                                  'leading': _leading,
                                                  'title': _title,
                                                  'href': _href
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[300],
                                                    spreadRadius: 3,
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              height: 60,
                                              width: 60,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '平聊',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              AcceptShare.forwardNetflow(
                                                arguments: {
                                                  'summary': _summary,
                                                  'leading': _leading,
                                                  'title': _title,
                                                  'href': _href
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[300],
                                                    spreadRadius: 3,
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              height: 60,
                                              width: 60,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '网流',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              AcceptShare.forwardGeosphere(
                                                arguments: {
                                                  'summary': _summary,
                                                  'leading': _leading,
                                                  'title': _title,
                                                  'href': _href
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[300],
                                                    spreadRadius: 3,
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              height: 60,
                                              width: 60,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '地圈',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  AcceptShare.forwardTiptool(
                                    arguments: {
                                      'summary': _summary,
                                      'leading': _leading,
                                      'title': _title,
                                      'href': _href
                                    },
                                  );
                                },
                                child: Text(
                                  '分享给桌面提示栏',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
