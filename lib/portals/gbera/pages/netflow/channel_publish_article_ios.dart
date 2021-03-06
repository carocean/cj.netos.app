import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import 'article_entities.dart';

class ChannelPublishArticleIos extends StatefulWidget {
  PageContext context;

  ChannelPublishArticleIos({this.context});

  @override
  _ChannelPublishArticleIosState createState() =>
      _ChannelPublishArticleIosState();
}

class _ChannelPublishArticleIosState extends State<ChannelPublishArticleIos> {
  GlobalKey<_MediaShowerState> shower_key;
  bool _isVideoCompressing = false;
  TextEditingController _contentController;
  Channel _channel;
  var _type;
  int _publishingState = 0; //1正在发布；3发布出错；0成功完成且跳转

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
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
  }



  Future<void> _doPublish() async {
    UserPrincipal user = widget.context.principal;
    var content = _contentController.text;
    var msgid = MD5Util.MD5('${Uuid().v1()}');

    if (mounted) {
      setState(() {
        _publishingState = 1;
      });
    }
    await _publishImpl(user, content, msgid,);
    if (mounted) {
      setState(() {
        _publishingState = 0;
      });
    }
    print('发布完成');
    widget.context.backward();
  }


  Future<AbsorberResultOR> _getAbsorberByAbsorbabler(String absorbabler) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.getAbsorberByAbsorbabler(absorbabler);
  }

  _publishImpl(user, content, msgid) async {
    var images = shower_key.currentState.files;
    IChannelMessageService channelMessageService =
        widget.context.site.getService('/channel/messages');
    IChannelMediaService channelMediaService =
        widget.context.site.getService('/channel/messages/medias');

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
        null,
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
      'purchaseSn': null,
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
  }

  bool _isDisableButton() {
    return StringUtil.isEmpty(_contentController.text);
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
            onPressed: _isDisableButton()
                ? null
                : () {
                    _doPublish();
                  },
            child: Text(
              '发表',
              style: TextStyle(
                color: _isDisableButton() ? Colors.grey[400] : Colors.blueGrey,
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
                context: widget.context,
                initialMedia: widget.context.parameters['mediaFile'],
              ),
            ),
            ..._renderProcessing(),
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
                                // maxHeight: Adapt.screenH(),
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
                              var path=image.path;
                              if(!Platform.isIOS) {
                                var info= await VideoCompress.compressVideo(
                                  image.path,
                                  quality: VideoQuality.HighestQuality,
                                  // deleteOrigin: true, // It's false by default
                                );
                                var newfile=await copyVideoCompressFile(info.file);
                                path=newfile;
                              }
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = false;
                                });
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: File(path),
                                  type: MediaFileType.video));
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
                                // maxHeight: Adapt.screenH(),
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
                              var info = await VideoCompress.compressVideo(
                                image.path,
                                quality: VideoQuality.DefaultQuality,
                                deleteOrigin: true, // It's false by default
                              );
                              var newfile=await copyVideoCompressFile(info.file);
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = false;
                                });
                              }
                              shower_key.currentState.addImage(MediaFile(
                                  src: File(newfile), type: MediaFileType.video));
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

  List<Widget> _renderProcessing() {
    var items = <Widget>[];
    if (_isVideoCompressing) {
      items.add(
        SliverToBoxAdapter(
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
      );
      return items;
    }
    if (_publishingState > 0) {
      var tips = '';
      switch (_publishingState) {
        case 1:
          tips = '正在申购发文服务..';
          break;
        case 0:
          tips = '成功发表';
          break;
      }
      items.add(
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              bottom: 10,
              top: 10,
              left: 15,
              right: 15,
            ),
            child: Text(
              '$tips',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }
}

class _MediaShower extends StatefulWidget {
  MediaFile initialMedia;
  PageContext context;

  @override
  _MediaShowerState createState() => _MediaShowerState(initialMedia);

  _MediaShower({this.initialMedia, this.context, Key key}) : super(key: key);
}

class _MediaShowerState extends State<_MediaShower> {
  var files = <MediaFile>[];
  StreamController _streamController = StreamController.broadcast();
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    files.clear();
    _streamController?.close();
    _streamSubscription?.cancel();
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
    var mediaSrcs = files.map((e) => e.toMediaSrc()).toList();
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
                  src: mediaFile.src.path,
                  context: widget.context,
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
            onTap: () async {
              var index = 0;
              for (var i = 0; i < files.length; i++) {
                var f = files[i];
                if (f.src == mediaFile.src) {
                  index = i;
                  break;
                }
              }
              _streamSubscription = _streamController.stream.listen((event) {
                if (event == null) {
                  return;
                }
                var hasDF;
                for (var f in files) {
                  if (f.src.path == event) {
                    hasDF = f;
                    break;
                  }
                }
                if (hasDF != null) {
                  hasDF.delete();
                  files.remove(hasDF);
                  if (mounted) {
                    setState(() {});
                  }
                }
              });
              await widget.context.forward('/images/viewer', arguments: {
                'index': index,
                'medias': mediaSrcs,
                'deleteEvent': _streamController.sink
              });
            },
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
