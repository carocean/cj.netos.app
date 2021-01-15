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
  bool isLoading = true;
  var _url;

  @override
  void initState() {
    _qrcodeSliceOR = widget.context.parameters['slice'];
    _url = '${_qrcodeSliceOR.href}?id=${_qrcodeSliceOR.id}';
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
              initialUrl: _url,
              onPageStarted: (url){
                print('---');
              },
              onWebResourceError: (err){
                print('---${err.errorCode} ${err.description}');
              },
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              onPageFinished: (ctr){
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
            ),
            isLoading
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      constraints: BoxConstraints.expand(),
                      child: Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
