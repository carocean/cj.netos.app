import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FissionMFBecomeBossPage extends StatefulWidget {
  PageContext context;

  FissionMFBecomeBossPage({this.context});

  @override
  _FissionMFBecomeBossPageState createState() =>
      _FissionMFBecomeBossPageState();
}

class _FissionMFBecomeBossPageState extends State<FissionMFBecomeBossPage> {
  var qrcodeKey = GlobalKey();

  Future<void> _share() async {
    RenderRepaintBoundary boundary =
        qrcodeKey.currentContext.findRenderObject();
    var image = await boundary.toImage(
      pixelRatio: 8,
    );
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    ///本来应该保存到相册，但相册是手机的共享目录，得找第三方插件才能实现,下面先保存到应用目录，用户是看不到的。
    var dir = await getApplicationDocumentsDirectory();
    var f = File('${dir.path}/${widget.context.principal.person}.png');
    f.writeAsBytesSync(pngBytes);
    await ImageGallerySaver.saveFile(f.path);
    //弹出对话框
    await fluwx.shareToWeChat(
      fluwx.WeChatShareImageModel(
        fluwx.WeChatImage.binary(pngBytes),
        scene: fluwx.WeChatScene.TIMELINE,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('老板'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {
              _share();
            },
            child: Text('分享'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _renderCard(),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Text(
                    '说明',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '成为老板，让别人为你赚钱！',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '把二维码分享到微信群或朋友圈，别人通过扫你的二维码抢红包就算是你的员工了，而且是永久员工。这样他抢的红包在每次提现时都有你的分账，爽歪歪吧，快来做老板吧！',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderCard() {
    return Container(
      margin: EdgeInsets.only(
        left: 30,
        right: 30,
        top: 40,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 6,
            spreadRadius: 3,
            offset: Offset(
              0,
              0,
            ),
          ),
        ],
      ),
      child: RepaintBoundary(
        key: qrcodeKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(
                  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F06%2F20150806163705_uexWK.thumb.700_0.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1618422083&t=b5673e5c28212ac84d1c8a089247c4ca'),
              fit: BoxFit.fill,
            ),
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: getAvatarWidget(
                          widget.context.principal.avatarOnRemote,
                          widget.context,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.context.principal.nickName ?? ''}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                '红包',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  '¥2392.23',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '邀请你抢红包!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                decoration: BoxDecoration(
                  color: Color(0xbbFFFFFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_right,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            '红包收入¥23.35',
                            style: TextStyle(
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
                        Icon(
                          Icons.arrow_right,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            '获得了：¥58.38元佣金',
                            style: TextStyle(
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
                        Icon(
                          Icons.arrow_right,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            '认识了：23个朋友',
                            style: TextStyle(
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
                        Icon(
                          Icons.arrow_right,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            '分享了：15个朋友',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 5,
                        bottom: 10,
                        right: 10,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                  offset: Offset(
                                    0,
                                    0,
                                  ),
                                ),
                              ],
                            ),
                            child: QrImage(
                              ///二维码数据
                              data:
                                  'http://nodespower.com/fission-mf-website/?person=${widget.context.principal.person}',
                              version: QrVersions.auto,
                              size: 80.0,
                              gapless: false,
                              padding: EdgeInsets.all(0),
                              // embeddedImage: FileImage(
                              //   File(
                              //     this.context.principal.avatarOnLocal,
                              //   ),
                              // ),
                              // embeddedImageStyle: QrEmbeddedImageStyle(
                              //   size: Size(40, 40),
                              // ),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '邀请码',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 45,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '共38人加他',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                              height: 10,
                              width: 150,
                              child: Divider(
                                height: 1,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: _renderGroupMembersPanel(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _renderGroupMembersPanel() {
    var items = <Widget>[];
    for (var i = 0; i < 5; i++) {
      items.add(
        ClipRRect(
          child: SizedBox(
            width: 20,
            height: 20,
            child: getAvatarWidget(
              widget.context.principal.avatarOnRemote,
              widget.context,
            ),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      );
      items.add(
        SizedBox(
          width: 5,
        ),
      );
    }
    return items;
  }
}
