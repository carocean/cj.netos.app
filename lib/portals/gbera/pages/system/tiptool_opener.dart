import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_helper.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart' as intl;

var tiptoolOpener = _TipToolOpener();

class _TipToolOpener {
  Future<void> open(String id,
      {PageContext context, CustomPopupMenuController controller}) async {
    ITipToolRemote tipToolRemote = context.site.getService('/feedback/tiptool');
    var doc = await tipToolRemote.getTipsDoc(id);
    if (doc == null) {
      return;
    }
    var pos = doc.href.indexOf('://');
    var protocol = doc.href.substring(0, pos);
    switch (protocol) {
      case 'help':
        var helpId = doc.href.substring(pos + 3);
        await _openHelp(helpId, context);
        controller?.hideMenu();
        break;
      case 'http':
      case 'https':
        await _openWebview(doc, context);
        controller?.hideMenu();
        break;
      case 'tiptool':
        await _openTipDocViewer(doc, context);
        controller?.hideMenu();
        break;
      default:
        break;
    }
  }

  Future<void> _openHelp(String helpId, PageContext context) async {
    IHelperRemote helperRemote = context.site.getService('/feedback/helper');
    var helpForm = await helperRemote.getHelpForm(helpId);
    context.forward('/system/fq/view', arguments: {'form': helpForm});
  }

  Future<void> _openTipDocViewer(TipsDocOR doc, PageContext context) async {
    showDialog(
      context: context.context,
      child: _TipDocViewer(
        context: context,
        doc: doc,
      ),
    );
  }

  Future<void> _openWebview(TipsDocOR doc, PageContext context) async {
    showDialog(
      context: context.context,
      child: _WebviewDialog(
        context: context,
        doc: doc,
      ),
    );
  }
}

class _TipDocViewer extends StatefulWidget {
  PageContext context;
  TipsDocOR doc;

  _TipDocViewer({this.context, this.doc});

  @override
  __TipDocViewerState createState() => __TipDocViewerState();
}

class __TipDocViewerState extends State<_TipDocViewer> {
  Person _creator;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _creator = await personService.fetchPerson(widget.doc.creator);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var doc = widget.doc;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      // resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text(
                '${doc.title ?? ''}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _creator == null
                    ? SizedBox(
                        width: 0,
                        height: 0,
                      )
                    : Text('${_creator.nickName}'),
                SizedBox(
                  width: 20,
                ),
                Text(
                  '${intl.DateFormat('yyyy/M/d HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(doc.ctime))}',
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: '${doc.summary ?? ''}',
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            MediaWidget(
              [
                MediaSrc(
                  id: Uuid().v1(),
                  type: 'image',
                  text: '',
                  sourceType: 'image',
                  src: doc.leading,
                ),
              ],
              widget.context,
            ),
          ],
        ),
      ),
    );
  }
}

class _WebviewDialog extends StatefulWidget {
  PageContext context;
  TipsDocOR doc;

  _WebviewDialog({this.context, this.doc});

  @override
  __WebviewDialogState createState() => __WebviewDialogState();
}

class __WebviewDialogState extends State<_WebviewDialog> {
  WebViewController controller;

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var doc = widget.doc;
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      // ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 70,
            ),
            child: WebView(
              initialUrl: doc.href,
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              onWebViewCreated: (WebViewController webViewController) {
                controller = webViewController;
              },
              // TODO(iskakaushik): Remove this when collection literals makes it to stable.
              // ignore: prefer_collection_literals
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) {
                // if (request.url.startsWith('https://www.youtube.com/')) {
                //   print('blocking navigation to $request}');
                //   return NavigationDecision.prevent;
                // }
                // print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                controller.evaluateJavascript("document.title");
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            left: 0,
            height: 70,
            child: Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: _TitleBar(
                title: '${doc.title}',
                context: widget.context,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                /*
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
                      ];
                    },
                  ),
                ),

                 */
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
