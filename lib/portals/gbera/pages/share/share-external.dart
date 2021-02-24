import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluwx/fluwx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareExternalDialog extends StatefulWidget {
  PageContext context;

  ShareExternalDialog({this.context});

  @override
  _ShareExternalDialogState createState() => _ShareExternalDialogState();
}

class _ShareExternalDialogState extends State<ShareExternalDialog> {
  String _title;
  String _desc;
  WeChatImage _imgSrc;
  String _link;

  @override
  void initState() {
    Map<String, dynamic> args = widget.context.partArgs;
    _title = args['title'];
    _desc = args['desc'];
    var leading = args['imgSrc'];
    _link = args['link'];

    if (leading.startsWith('/')) {
      _imgSrc = WeChatImage.file(File('$leading'));
    } else {
      _imgSrc = WeChatImage.network(
          '$leading?accessToken=${widget.context.principal.accessToken}');
    }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  await shareToWeChat(
                    WeChatShareWebPageModel(
                      _link,
                      scene: WeChatScene.SESSION,
                      title: _title,
                      description: _desc ?? '',
                      thumbnail: _imgSrc,
                    ),
                  );
                  widget.context.backward();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: 60,
                  height: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconData(0xe642, fontFamily: 'webshare'),
                        color: Colors.green,
                        size: 30,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '微信',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async{
                 await shareToWeChat(
                    WeChatShareWebPageModel(
                      _link,
                      scene: WeChatScene.TIMELINE,
                      title: _desc,
                      thumbnail: _imgSrc,
                    ),
                  );
                  widget.context.backward();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: 60,
                  height: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconData(0xe611, fontFamily: 'webshare'),
                        size: 30,
                        color: Colors.green,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '朋友圈',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  var v = await showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text(
                        '分享',
                      ),
                      content: Text(
                        '将以浏览器打开，请使用浏览器的分享功能向微信朋友圈和好友分享该内容',
                        style: TextStyle(fontSize: 12,),
                      ),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            widget.context.backward();
                          },
                          child: Text(
                            '取消',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            widget.context.backward(result: 'yes');
                          },
                          child: Text(
                            '确认',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if(v==null){
                    return;
                  }
                  if(v=='yes'){
                    widget.context.backward();
                    if(await canLaunch(_link)){
                      await launch(_link);
                    }
                  }
                  widget.context.backward();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: 60,
                  height: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconData(0xe514, fontFamily: 'webshare'),
                        size: 30,
                        color: Colors.green,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '浏览器',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
