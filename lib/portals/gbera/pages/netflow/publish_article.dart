import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import 'article_entities.dart';

class ChannelPublishArticle extends StatefulWidget {
  PageContext context;

  ChannelPublishArticle({this.context});

  @override
  _ChannelPublishArticleState createState() => _ChannelPublishArticleState();
}

class _ChannelPublishArticleState extends State<ChannelPublishArticle> {
  GlobalKey<_MediaShowerState> shower_key;
  bool _isVideoCompressing = false;
  TextEditingController _contentController;
  Channel _channel;
  var _type;
  bool _isLoaded = false;
  String _districtCode;
  String _districtTitle;
  int _purchse_amount = 100; //单位为分
  String _label = '';
  PurchaseInfo _purchaseInfo;
  bool _canPublish = false;
  bool _isEnoughMoney = true;
  StreamController _rechargeController;
  StreamSubscription _rechargeHandler;

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _type = widget.context.parameters['type'];
    shower_key = GlobalKey<_MediaShowerState>();
    _contentController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _rechargeHandler?.cancel();
    _rechargeController?.close();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    var result = await AmapLocation.fetchLocation();
    _districtCode = await result.adCode;
    _districtTitle = await result.district;
    var purchaseInfo = await _getPurchaseInfo();
    if (purchaseInfo.bankInfo == null) {
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _purchaseInfo = purchaseInfo;
    if (purchaseInfo.myWallet.change < _purchse_amount) {
      _isEnoughMoney = false;
      var balance='¥${(purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元';
      var least = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
      _label = '余额:$balance，至少:$least，请到钱包中充值';
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _label = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
    _canPublish = true;
    _isLoaded = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<PurchaseInfo> _getPurchaseInfo() async {
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var purchaseInfo = await purchaserRemote.getPurchaseInfo(_districtCode);
    return purchaseInfo;
  }

  Future<void> _buywy() async {
    if (!_isEnoughMoney) {
      _rechargeController = StreamController();
      _rechargeHandler = _rechargeController.stream.listen((event) async {
        // print('---充值返回---$event');
        var purchaseInfo = await _getPurchaseInfo();
        if (purchaseInfo.bankInfo == null) {
          return;
        }
        if (purchaseInfo.myWallet.change >= _purchse_amount) {
          _isEnoughMoney = true;
          _label = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
          if (mounted) {
            setState(() {});
          }
          return ;
        }
        var balance='¥${(purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元';
        var least = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
        _label = '余额:$balance，至少:$least，请到钱包中充值';
      });
      widget.context.forward('/wallet/change/deposit',
          arguments: {'changeController': _rechargeController});
      return;
    }
    widget.context.forward('/channel/article/buywy', arguments: {
      'purchaseInfo': _purchaseInfo,
      'purchaseAmount': _purchse_amount
    }).then((value) async {
      if (value == null) {
        return;
      }

      var purchaseInfo = await _getPurchaseInfo();
      if (purchaseInfo.bankInfo == null) {
        return;
      }
      if (purchaseInfo.myWallet.change < value) {
        _isEnoughMoney = false;
        var v = value as int;
        var labelV = '¥${(v / 100.00).toStringAsFixed(2)}';
        _label =
            '欲购金额:$labelV元 大于 现有余额：¥${(purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元，请充值';
        if (mounted) {
          setState(() {});
        }
        return;
      }
      _purchse_amount = value;
      _label = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}';
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<AbsorberResultOR> _getAbsorberByAbsorbabler(String absorbabler) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.getAbsorberByAbsorbabler(absorbabler);
  }

  _publish() async {
    UserPrincipal user = widget.context.principal;
    var content = _contentController.text;

    var images = shower_key.currentState.files;
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    IChannelMediaService channelMediaService =
        widget.context.site.getService('/channel/messages/medias');
    var msgid = MD5Util.MD5('${Uuid().v1()}');

    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var purchaseOR = await purchaserRemote.doPurchase(
        _purchaseInfo.bankInfo.id,
        _purchse_amount,
        'netflow',
        '${user.person}/$msgid',
        '在管道${_channel.name}');

    String absorbabler = '${_channel.owner}/${_channel.id}';
    AbsorberResultOR absorberResultOR;
    if (!StringUtil.isEmpty(absorbabler)) {
      absorberResultOR = await _getAbsorberByAbsorbabler(absorbabler);
    }

    await channelMessageService.addMessage(
      ChannelMessage(
        msgid,
        null,
        null,
        null,
        _channel.id,
        user.person,
        DateTime.now().millisecondsSinceEpoch,
        null,
        null,
        null,
        'sended',
        content,
        purchaseOR.sn,
        null,
        absorberResultOR?.absorber?.id,
        widget.context.principal.person,
      ),
    );

    for (MediaFile file in images) {
      var type = 'image';
      switch (file.type) {
        case MediaFileType.image:
          break;
        case MediaFileType.video:
          type = 'video';
          break;
        case MediaFileType.audio:
          type = 'audio';
          break;
      }
      var media = Media(
        '${Uuid().v1()}',
        type,
        '${file.src.path}',
        null,
        msgid,
        null,
        _channel.id,
        widget.context.principal.person,
      );
      await channelMediaService.addMedia(media);

      widget.context.ports.portTask.addUploadTask('/app', [file.src.path],
          callbackUrl:
              '/network/channel/doc?mediaid=${media.id}&type=$type&localFile=${file.src.path}&docid=$msgid&channel=${_channel.id}&creator=${user.person}&text=${media.text ?? ''}&leading=${media.leading ?? ''}');
    }

    var doc = {
      'id': msgid,
      'channel': _channel.id,
      'creator': user.person,
      'content': content,
      'Location': null,
      'purchaseSn': purchaseOR.sn,
    };
    var portsUrl =
        widget.context.site.getService('@.prop.ports.document.network.channel');
    widget.context.ports.portTask.addPortPOSTTask(
      portsUrl,
      'publishDocument',
      callbackUrl:
          '/network/channel/doc?docid=$msgid&channel=${_channel.id}&creator=${user.person}',
      data: {
        'document': jsonEncode(doc),
      },
    );

    var refreshMessages = widget.context.parameters['refreshMessages'];
    if (refreshMessages != null) {
      await refreshMessages();
    }

    widget.context.backward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: !_canPublish ||
                    StringUtil.isEmpty(_contentController.text) ||
                    StringUtil.isEmpty(_districtCode)
                ? null
                : () {
                    _publish();
                  },
            child: Text(
              '发表',
              style: TextStyle(
                color: !_canPublish ||
                        StringUtil.isEmpty(_contentController.text) ||
                        StringUtil.isEmpty(_districtCode)
                    ? Colors.grey[400]
                    : Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 10,
                  autofocus: true,
                  onChanged: (v) {
                    _canPublish = !StringUtil.isEmpty(v);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '输入内容',
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _MediaShower(
                key: shower_key,
                initialMedia: widget.context.parameters['mediaFile'],
              ),
            ),
            !_isVideoCompressing
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 0,
                      width: 0,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                        bottom: 10,
                        top: 10,
                      ),
                      child: Text(
                        '正在压缩视频，请稍候...',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
            SliverFillRemaining(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Container(
                      child: Wrap(
                        runSpacing: 5,
                        spacing: 10,
                        alignment: WrapAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              String cnt = _contentController.text;
                              var image = await ImagePicker().getImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                                maxHeight: Adapt.screenH(),
                              );
                              if (image == null) {
                                return;
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: File(image.path),
                                  type: MediaFileType.image));
                              _contentController.text = cnt;
                              _contentController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: cnt?.length,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.image,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    '选图片',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              String cnt = _contentController.text;
                              var image = await ImagePicker().getVideo(
                                source: ImageSource.gallery,
                                maxDuration: Duration(
                                  seconds: 15,
                                ),
                              );
                              if (image == null) {
                                return;
                              }
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = true;
                                });
                              }
                              var videoCompress = FlutterVideoCompress();
                              var info = await videoCompress.compressVideo(
                                image.path,
                                quality: VideoQuality.MediumQuality,
                                // 默认(VideoQuality.DefaultQuality)
                                deleteOrigin: true, // 默认(false)
                                // frameRate: 10,
                              );
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = false;
                                });
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: info.file, type: MediaFileType.video));
                              _contentController.text = cnt;
                              _contentController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: cnt?.length,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.movie,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    '选视频',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              String cnt = _contentController.text;
                              var image = await ImagePicker().getImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                                maxHeight: Adapt.screenH(),
                              );
                              if (image == null) {
                                return;
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: File(image.path),
                                  type: MediaFileType.image));
                              _contentController.text = cnt;
                              _contentController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: cnt?.length,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.camera_enhance,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    '拍照',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              String cnt = _contentController.text;
                              var image = await ImagePicker().getVideo(
                                source: ImageSource.camera,
                                maxDuration: Duration(seconds: 15),
                              );
                              if (image == null) {
                                return;
                              }
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = true;
                                });
                              }
                              var videoCompress = FlutterVideoCompress();
                              var info = await videoCompress.compressVideo(
                                image.path,
                                quality: VideoQuality.MediumQuality,
                                // 默认(VideoQuality.DefaultQuality)
                                deleteOrigin: true, // 默认(false)
                                // frameRate: 10,
                              );
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = false;
                                });
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: info.file, type: MediaFileType.video));
                              _contentController.text = cnt;
                              _contentController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: cnt?.length,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.videocam,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    '录视频',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 15,
                          top: 15,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                right: 10,
                              ),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: Icon(
                                  Icons.spellcheck,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    '购买该服务',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '${!_isLoaded ? '正在搜寻当地的服务商...' : (StringUtil.isEmpty(_districtCode) ? '没找到当地服务商，因此无法提供发布服务' : _label)}',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey,
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
                      behavior: HitTestBehavior.opaque,
                      onTap: StringUtil.isEmpty(_districtCode)
                          ? null
                          : () async {
                              _buywy();
                            },
                    ),
                    Divider(
                      height: 1,
                      indent: 30,
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
}

class _MediaShower extends StatefulWidget {
  MediaFile initialMedia;

  @override
  _MediaShowerState createState() => _MediaShowerState(initialMedia);

  _MediaShower({this.initialMedia, Key key}) : super(key: key);
}

class _MediaShowerState extends State<_MediaShower> {
  var files = <MediaFile>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    files.clear();
    super.dispose();
  }

  _MediaShowerState(initialMediaFile) {
    if (initialMediaFile != null && initialMediaFile.src != null) {
      files.add(initialMediaFile);
    }
  }

  //type:image|video|audio
  addImage(MediaFile _media) {
    if (_media == null || _media.src == null) {
      return;
    }
    setState(() {
      files.add(_media);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: files.map((mediaFile) {
          Widget mediaRegion;
          switch (mediaFile.type) {
            case MediaFileType.image:
              mediaRegion = Image.file(
                mediaFile.src,
                width: 150,
              );
              break;
            case MediaFileType.video:
              mediaRegion = AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoView(
                  src: mediaFile.src,
                ),
              );
              break;
            case MediaFileType.audio:
              mediaRegion = Container(
                width: 0,
                height: 0,
              );
              break;
            default:
              mediaRegion = Container(
                width: 0,
                height: 0,
              );
              break;
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () {
              setState(() {
                showDialog(
                  context: context,
                  barrierDismissible: true, //点击dialog外部 是否可以销毁
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text('确认删除？'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            '确认',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop({'action': 'ok'});
                          },
                        ),
                        FlatButton(
                          child: Text(
                            '取消',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop({'action': 'cancel'});
                          },
                        ),
                      ],
                    );
                  },
                ).then((result) {
                  if (result == null || result['action'] != 'ok') return;
                  setState(() {
                    mediaFile.delete();
                    files.remove(mediaFile);
                  });
                });
              });
            },
            child: mediaRegion,
          );
        }).toList(),
      ),
    );
  }
}
