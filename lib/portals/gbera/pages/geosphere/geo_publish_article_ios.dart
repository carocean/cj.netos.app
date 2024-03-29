import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/netflow/article_entities.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import 'geo_entities.dart';

class GeospherePublishArticleIos extends StatefulWidget {
  PageContext context;

  GeospherePublishArticleIos({this.context});

  @override
  _GeospherePublishArticleIosState createState() =>
      _GeospherePublishArticleIosState();
}

class _GeospherePublishArticleIosState extends State<GeospherePublishArticleIos> {
  GlobalKey<_MediaShowerState> shower_key;
  TextEditingController _contentController;
  String _receptor;
  AmapPoi _poi;
  bool _isLoaded = false;
  String _districtCode;
  String _districtTitle;
  bool _canPublish = false;
  GeoReceptor _receptorObj;
  bool _isVideoCompressing = false;
  int _publishingState = 0; //1正在申购；2正在发布；3发布出错；4成功完成且跳转
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    _receptor = widget.context.parameters['receptor'];
    shower_key = GlobalKey<_MediaShowerState>();
    _contentController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _poi = null;
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    var result = await geoLocation.location;
    _districtCode = result.adCode;
    _districtTitle = result.district;
    var latlng = result.latLng;
//    var city = await result.city;
    String title = result.poiName;
    String address = result.address;
    var poiId = result.adCode;
    _poi = AmapPoi(
      title: title,
      latLng: latlng,
      address: address,
      poiId: poiId,
    );
    IGeoReceptorRemote receptorRemote =
        widget.context.site.getService('/remote/geo/receptors');
    _receptorObj = await receptorRemote.getReceptor(_receptor);

    _canPublish = true;
    _isLoaded = true;
    if (mounted) {
      setState(() {});
    }
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

    await _publishImpl(user, content, msgid);
    if (mounted) {
      setState(() {
        _publishingState = 0;
      });
    }
    print('发布完成');

    widget.context.backward(result: msgid);
  }


  Future<void> _publishImpl(user, content, msgid) async {
    var content = _contentController.text;
    var location = jsonEncode(_poi.latLng.toJson());

    var images = shower_key.currentState.files;
    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    IGeosphereMediaService mediaService =
        widget.context.site.getService('/geosphere/receptor/messages/medias');

    await geoMessageService.addMessage(
      GeosphereMessageOL(
        msgid,
        null,
        null,
        null,
        null,
        null,
        null,
        _receptor,
        user.person,
        DateTime.now().millisecondsSinceEpoch,
        null,
        null,
        null,
        'sended',
        content,
        null,
        location,
        _receptorObj.channel,
        _receptorObj.category,
        _receptorObj.brand,
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
      await mediaService.addMedia(
        GeosphereMediaOL(
          MD5Util.MD5(Uuid().v1()),
          type,
          '${file.src.path}',
          null,
          msgid,
          null,
          _receptor,
          widget.context.principal.person,
        ),
      );
    }
  }

  bool _isDisableButton() {
    return !_canPublish ||
        _poi == null ||
        _publishingState > 0 ||
        StringUtil.isEmpty(_contentController.text) ||
        StringUtil.isEmpty(_districtCode);
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
            child: Container(
              color: null,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                '发表',
                style: TextStyle(
                  color: _isDisableButton() ? Colors.grey[400] : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
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
                              var image = await picker.getImage(
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
                              var image = await picker.getVideo(
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
                              // var videoCompress = FlutterVideoCompress();
                              // var info = await videoCompress.compressVideo(
                              //   image.path,
                              //   quality: VideoQuality.MediumQuality,
                              //   // 默认(VideoQuality.DefaultQuality)
                              //   deleteOrigin: true, // 默认(false)
                              //   // frameRate: 10,
                              // );
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = false;
                                });
                              }
                              shower_key.currentState.addImage(
                                MediaFile(
                                  src: File(image.path),
                                  type: MediaFileType.video,
                                ),
                              );
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
                              var image = await picker.getImage(
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
                              var image = await picker.getVideo(
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
                              var info= await VideoCompress.compressVideo(
                                image.path,
                                quality: VideoQuality.DefaultQuality,
                                deleteOrigin: true, // It's false by default
                              );
                              if (mounted) {
                                setState(() {
                                  _isVideoCompressing = false;
                                });
                              }
                              // print('-----$info');
                              shower_key.currentState.addImage(MediaFile(
                                src: info.file,
                                type: MediaFileType.video,
                              ));
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward('/geosphere/amap/near',
                            arguments: {'poi': _poi}).then((result) {
                          if (result == null) {
                            return;
                          }
                          _poi = (result as Map)['poi'];
                          setState(() {});
                        });
                      },
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
                                  Icons.location_on,
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
                                          child: Text(
                                              '${_poi == null ? '定位中...' : '${_poi.title}附近'}'),
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
          tips = '正在发文..';
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
