import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
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
  int _shareProgress = 0; //1为开始生成图片；2为正在保存图片；3正在分享；
  BossInfoOR _bossInfoOR;
  bool _isLoading = true;
  List<Person> _persons = [];

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    _bossInfoOR = await cashierRemote.getBossInfo();
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<String> list=_bossInfoOR.membersTop5.map((e) {
      return '$e@gbera.netos';
    }).toList();
    var persons = await personService.listPersonWith(list);
    _persons.addAll(persons);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _share() async {
    if (_shareProgress > 0) {
      return;
    }
    setState(() {
      _shareProgress = 1;
    });
    RenderRepaintBoundary boundary =
        qrcodeKey.currentContext.findRenderObject();
    var image = await boundary.toImage(
      pixelRatio: 8,
    );
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
    if (mounted) {
      setState(() {
        _shareProgress = 2;
      });
    }

    ///本来应该保存到相册，但相册是手机的共享目录，得找第三方插件才能实现,下面先保存到应用目录，用户是看不到的。
    var dir = await getApplicationDocumentsDirectory();
    var f = File('${dir.path}/${widget.context.principal.person}.png');
    f.writeAsBytesSync(pngBytes);
    await ImageGallerySaver.saveFile(f.path);
    if (mounted) {
      setState(() {
        _shareProgress = 3;
      });
    }
    //弹出对话框
    var action = await showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  '分享到微信群',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    ctx,
                    'share_to_session',
                  );
                },
              ),
              CupertinoActionSheetAction(
                child: Text(
                  '分享到朋友圈',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    ctx,
                    'share_to_timeline',
                  );
                },
              ),
            ],
            cancelButton: FlatButton(
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  ctx,
                  'cancel',
                );
              },
            ),
          );
        });
    if (action == null) {
      if (mounted) {
        setState(() {
          _shareProgress = 0;
        });
      }
      return;
    }
    switch (action) {
      case 'share_to_session':
        await fluwx.shareToWeChat(
          fluwx.WeChatShareImageModel(
            fluwx.WeChatImage.binary(pngBytes),
            scene: fluwx.WeChatScene.SESSION,
          ),
        );
        break;
      case 'share_to_timeline':
        await fluwx.shareToWeChat(
          fluwx.WeChatShareImageModel(
            fluwx.WeChatImage.binary(pngBytes),
            scene: fluwx.WeChatScene.TIMELINE,
          ),
        );
        break;
    }
    if (mounted) {
      setState(() {
        _shareProgress = 0;
      });
    }
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
            onPressed: _shareProgress > 0
                ? null
                : () {
                    _share();
                  },
            child: Text('${_renderShareProgress()}'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fill,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Adapt.screenW(),
                    maxHeight: Adapt.screenH() - 150,
                  ),
                  child: _renderCard(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
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

  String _renderShareProgress() {
    switch (_shareProgress) {
      case 0:
        return '分享';
      case 1:
        return '生成图片...';
      case 2:
        return '保存到相册...';
      case 3:
        return '开始分享...';
    }
  }

  Widget _renderCard() {
    if (_isLoading) {
      return SizedBox.expand();
    }
    return Container(
      // margin: EdgeInsets.only(
      //   left: 30,
      //   right: 30,
      //   top: 40,
      //   bottom: 30,
      // ),
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
      constraints: BoxConstraints.expand(),
      child: RepaintBoundary(
        key: qrcodeKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(
                  'http://www.nodespower.com:7100/app/fission/img/c-share.jpg?accessToken=${widget.context.principal.accessToken}'),
              fit: BoxFit.fill,
            ),
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 40,
                  right: 40,
                ),
                alignment: Alignment.center,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '红包',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  '¥${(_bossInfoOR.balance / 100.00).toStringAsFixed(2)}',
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
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '邀请你抢红包',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                margin: EdgeInsets.only(
                  left: 60,
                  right: 30,
                ),
                decoration: BoxDecoration(
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
                            '红包收入：¥${(_bossInfoOR.payeeAmount / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
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
                            '获得佣金：¥${(_bossInfoOR.commission / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
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
                            '认识了：${_bossInfoOR.payerCount}个朋友',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
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
                            '分享了：${_bossInfoOR.empCount}个朋友',
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
              Container(
                padding: EdgeInsets.only(
                  left: 45,
                  right: 45,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '共${_bossInfoOR.payeeCount}人加他',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _renderGroupMembersPanel(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 5,
                        bottom: 80,
                        right: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 40,
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
    for (var i = 0; i < _persons.length; i++) {
      var person=_persons[i];
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 5,
          ),
          child: ClipRRect(
            child: SizedBox(
              width: 20,
              height: 20,
              child: getAvatarWidget(
                person.avatar,
                widget.context,
              ),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
    return items;
  }
}
