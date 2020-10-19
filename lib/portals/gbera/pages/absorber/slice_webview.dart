import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SliceWebViewPage extends StatefulWidget {
  PageContext context;

  SliceWebViewPage({this.context});

  @override
  _SliceWebViewPageState createState() => _SliceWebViewPageState();
}

class _SliceWebViewPageState extends State<SliceWebViewPage> {
  QrcodeSliceOR _qrcodeSliceOR;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;

  @override
  void initState() {
    _qrcodeSliceOR = widget.context.parameters['slice'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地微码片'),
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            widget.context.backward();
          },
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: [
            WebView(
              initialUrl: '${_qrcodeSliceOR.href}?id=${_qrcodeSliceOR.id}',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              navigationDelegate: (NavigationRequest request) {
                setState(() {
                  isLoading = true; // 开始访问页面，更新状态
                });

                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false; // 页面加载完成，更新状态
                });
              },
            ),
            isLoading
                ? Container(
                  constraints: BoxConstraints.expand(),
                    child: Center(
                      child: SizedBox(height: 50,width: 50,child: CircularProgressIndicator(),),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
