import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/single_media_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget renderShareCard({
  PageContext context,
  String href,
  String title,
  String summary,
  String leading,
  Color background,
  double fontSize,
  EdgeInsets margin,
}) {
  var widget=Container(
    margin:margin==null? EdgeInsets.only(
      left: 20,
      right: 20,
    ):margin,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: background == null ? Colors.grey[200] : background,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: SingleMediaWidget(
            context: context,
            image: leading,
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
                '${title ?? ''}',
                style: TextStyle(
                  fontSize:fontSize==null? 16:fontSize,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              /*
              SizedBox(
                height: 5,
              ),
              Text(
                '${_summary ?? ''}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

               */
            ],
          ),
        ),
      ],
    ),
  );
  if(context!=null&&context.principal!=null&&!StringUtil.isEmpty(context.principal.person)){
    return InkWell(
      onTap: (){
        showDialog(context: context.context,child: ShareWebviewDialog(
          context: context,
          data: ShareData(
            summary: summary,
            leading: leading,
            href: href,
            title: title,
          ),
        ),);
      },
      child: widget,
    );
  }
  return widget;
}

Widget renderShareEditor({
  PageContext context,
  String href,
  String title,
  String summary,
  String leading,
  Color background,
  int maxLines,
  TextEditingController controller,
  void Function(String) onChanged,
}) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20,right: 20,),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '你怎么看...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
                maxLines: maxLines??4,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      renderShareCard(
        summary: summary,
        leading: leading,
        href: href,
        title: title,
        context: context,
        background: background,
      ),
    ],
  );
}

class ShareData{
  String title;
  String href;
  String leading;
  String summary;

  ShareData({this.title, this.href, this.leading, this.summary});
}

class ShareWebviewDialog extends StatefulWidget {
  PageContext context;
  ShareData data;

  ShareWebviewDialog({this.context, this.data});

  @override
  _ShareWebviewDialogState createState() => _ShareWebviewDialogState();
}

class _ShareWebviewDialogState extends State<ShareWebviewDialog> {
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
    var doc = widget.data;
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
