import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MicroAppWidget extends StatefulWidget {
  PageContext context;

  MicroAppWidget({this.context});

  @override
  _MicroAppWidgetState createState() => _MicroAppWidgetState();
}

class _MicroAppWidgetState extends State<MicroAppWidget> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    var params = widget.context.parameters;
    var title = '';
    if (params != null) {
      title = params['selected'];
      if (title == null) {
        title = '';
      }
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 70,
            ),
            child: WebView(
              initialUrl: 'https://3g.163.com/touch/',
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              // TODO(iskakaushik): Remove this when collection literals makes it to stable.
              // ignore: prefer_collection_literals
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $request}');
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            left: 0,
            height: 70,
            child: Container(
              child: _TitleBar(
                title: title,
                context: widget.context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}

class _TitleBar extends StatelessWidget {
  String title = '';
  PageContext context;

  _TitleBar({this.title, this.context});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    EdgeInsets padding = data.padding;
    // Bottom padding has been consumed - i.e. by the keyboard
    if (data.padding.bottom == 0.0 && data.viewInsets.bottom != 0.0)
      padding = padding.copyWith(bottom: data.viewPadding.bottom);
    return Container(
      margin: EdgeInsets.only(top: padding.top),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: PopupMenuButton(
                    offset: Offset(0, 60),
                    icon: Icon(
                      FontAwesomeIcons.ellipsisH,
                      color: Colors.grey[800],
                      size: 18,
                    ),
                    itemBuilder: (context) {
                      return <PopupMenuItem>[
                        PopupMenuItem(
                          child: Text('关于'),
                        ),
                        PopupMenuItem(
                          child: Text('转让'),
                        ),
                      ];
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen_exit),
                  onPressed: () {
                    this.context.backward();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
