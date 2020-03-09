import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
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

  TextEditingController _contentController;
  Channel _channel;
  var _type;

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _type = widget.context.parameters['type'];
    shower_key = GlobalKey<_MediaShowerState>();
    _contentController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  _publish() async {
    UserPrincipal user = widget.context.principal;
    var content = _contentController.text;

    ///纹银价格从app的更新管理中心或消息中心获取
    double wy = 38388.38827772;
    var images = shower_key.currentState.files;
    var location = null;
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    IChannelMediaService channelMediaService =
        widget.context.site.getService('/channel/messages/medias');
    var msgid = '${Uuid().v1()}';
    await channelMessageService.addMessage(
      ChannelMessage(
        msgid,
        null,
        null,
        null,
        _channel.id,
        user.person,
        DateTime.now().millisecondsSinceEpoch,
        content,
        wy,
        location,
        widget.context.principal.person,
      ),
    );
    var _medias = [];
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
      await channelMediaService.addMedia(
        Media(
          '${Uuid().v1()}',
          type,
          '${file.src.path}',
          null,
          msgid,
          null,
          _channel.id,
          widget.context.principal.person,
        ),
      );
      widget.context.ports.portTask.addUploadTask('/app', [file.src.path],
          callbackUrl:
              '/network/channel/doc?type=$type&localFile=${file.src.path}&docid=$msgid&channel=${_channel.id}&creator=${user.person}');
    }

    var doc = {
      'id': msgid,
      'channel': _channel.id,
      'creator': user.person,
      'content': content,
      'Location': location,
      'wy': 10.00,
      'medias': _medias,
    };
    var portsUrl =
        widget.context.site.getService('@.prop.ports.network.channel');
    widget.context.ports.portTask.addPortPOSTTask(
      portsUrl,
      'publishDocument',
      callbackUrl: '/network/channel/doc?docid=$msgid&channel=${_channel.id}&creator=${user.person}',
      data: {'document': jsonEncode(doc)},
    );

    var refreshMessages = widget.context.parameters['refreshMessages'];
    if (refreshMessages != null) {
      await refreshMessages();
    }

    widget.context.backward();
  }

  Future<String> _uploadMedia(String src) async {
    var map = await widget.context.ports.upload('/app', [src]);
    return map[src];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {
              _publish();
            },
            child: Text(
              '发表',
              style: TextStyle(
                color: Colors.blueGrey,
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
                              var image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (image == null) {
                                return;
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: image, type: MediaFileType.image));
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
                              var image = await ImagePicker.pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (image == null) {
                                return;
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: image, type: MediaFileType.video));
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
                              var image = await ImagePicker.pickImage(
                                  source: ImageSource.camera);
                              if (image == null) {
                                return;
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: image, type: MediaFileType.image));
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
                              var image = await ImagePicker.pickVideo(
                                source: ImageSource.camera,
                              );
                              if (image == null) {
                                return;
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: image, type: MediaFileType.video));
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
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            '需要至少现值¥1.00元的纹银',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
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
                      onTap: () async {
                        widget.context.forward('/channel/article/buywy');
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 30,
                    ),
                    Padding(
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
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '所在位置',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Text(''),
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
              mediaRegion = VideoView(
                src: mediaFile.src,
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
