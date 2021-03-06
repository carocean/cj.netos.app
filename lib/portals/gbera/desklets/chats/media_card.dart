import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/my_photo_view_gallery.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class MediaCard extends StatelessWidget {
  RoomMessageMedia media;
  String room;
  int beginTime;
  PageContext pageContext;

  MediaCard({this.media, this.room, this.beginTime,this.pageContext});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Hero(
          tag: '$media?tag=${Uuid().v1()}',
          child: _rendertMediaRender(),
        ),
      ),
      onTap: () {
        pageContext.forward(
          '/images/viewer2',
          arguments: {
            'home': media,
            'room': room,
            'beginTime':beginTime,
          },
        );
      },
    );
  }

  Widget _rendertMediaRender() {
    var mediaRender;
    var src = media?.src;
    switch (media.type) {
      case 'image':
        mediaRender = src.startsWith('/')
            ? Image.file(
                File(src),
                fit: BoxFit.contain,
              )
            : FadeInImage.memoryNetwork(
                image:
                    '$src?accessToken=${this.pageContext.principal.accessToken}',
                fit: BoxFit.contain,
                placeholder: kTransparentImage,
              );
        break;

      case 'video':
        mediaRender = VideoView(
          src: src,
          context: pageContext,
        );
        break;
      case 'audio':
        mediaRender = MyAudioWidget(
          audioFile: src,
          timeLength: media.args,
        );
        break;
      default:
        print('unknown media type');
        break;
    }
    return mediaRender;
  }
}

class RoomMessageMedia {
  String type;
  String src;
  dynamic args;

  RoomMessageMedia({this.type, this.src, this.args});
}

class RoomMediaViewer extends StatefulWidget {
  RoomMediaViewer({
    this.pageContext,
  });

  final PageContext pageContext;

  @override
  _RoomMediaViewerState createState() => _RoomMediaViewerState();
}

class _RoomMediaViewerState extends State<RoomMediaViewer> {
  int _index = 0;
  List<RoomMessageMedia> _medias = [];
  bool _isSaving = false;
  double _baifenbi = 0.0;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  PageController _pageController;
  Decoration _backgroundDecoration;
  String _room;
  int _beginTime;
  bool _isLoading=true;
  @override
  void initState() {
    var _content = widget.pageContext;
    var home = _content.parameters['home'];
    _room = _content.parameters['room'];
    _beginTime = _content.parameters['beginTime'];
    _medias.add(home);
    _pageController = PageController(initialPage: _index);
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IP2PMessageService messageService =
        widget.pageContext.site.getService('/chat/p2p/messages');
    if(_beginTime==null) {
      _beginTime=DateTime.now().millisecondsSinceEpoch;
    }
    var _mediaCount = await messageService.totalMessageWithMedia(_room,_beginTime,);
    var medias = await messageService.pageMessageWithMedia(_room,_beginTime, _mediaCount, 0);
   _medias.addAll(medias);
    if (mounted) {
      setState(() {
        _isLoading=false;
      });
    }
  }

  void onPageChanged(int index) {
    setState(() {
      _index = index;
    });
  }

  Future<void> _saveMedia() async {
    if (_isSaving) {
      return;
    }
    _isSaving = true;
    setState(() {});
    var src = _medias[_index];
    var file = src.src;
    if (!file.startsWith('/')) {
      var dir = await getExternalStorageDirectory();
      var localFile = '${dir.path}/${MD5Util.MD5(file)}.${fileExt(file)}';
      await widget.pageContext.ports.download(file, localFile,
          onReceiveProgress: (i, j) {
        _baifenbi = ((i * 1.0) / j) * 100.00;
        if (mounted) {
          setState(() {});
        }
      });
    }
    var result = await ImageGallerySaver.saveFile(file);
    _globalKey.currentState.showSnackBar(
      SnackBar(
        content: Text('已保存到相册'),
      ),
    );
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MyPhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: _buildItem,
            itemCount: _medias.length,
            backgroundDecoration: _backgroundDecoration,
            pageController: _pageController,
            onPageChanged: onPageChanged,
            scrollDirection: Axis.vertical,
          ),
          ..._renderToolbars(),
        ],
      ),
    );
  }

  MyPhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    if(_isLoading&&index>0){
      return  MyPhotoViewGalleryPageOptions.customChild(
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
          maxScale: PhotoViewComputedScale.covered * 1.1,
          heroAttributes: PhotoViewHeroAttributes(tag: Uuid().v1()),
          child: SizedBox(height: 0,width: 0,),);
    }
    _index = index;
    var media = _medias[index];
    var item = media.src;
    switch (media.type) {
      case 'image':
        var src = item.indexOf('?') > 0
            ? item
            : '$item?accessToken=${widget.pageContext.principal.accessToken}';
        return MyPhotoViewGalleryPageOptions(
          imageProvider: item.startsWith('/')
              ? FileImage(File(item))
              : CachedNetworkImageProvider(src),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
          maxScale: PhotoViewComputedScale.covered * 1.1,
          heroAttributes: PhotoViewHeroAttributes(tag: item),
        );
      case 'video':
        return MyPhotoViewGalleryPageOptions.customChild(
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
          maxScale: PhotoViewComputedScale.covered * 1.1,
          heroAttributes: PhotoViewHeroAttributes(tag: item),
          child: _renderVideo(widget.pageContext),
        );
      case 'audio':
        return MyPhotoViewGalleryPageOptions.customChild(
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
          maxScale: PhotoViewComputedScale.covered * 1.1,
          heroAttributes: PhotoViewHeroAttributes(tag: item),
          child: ClipRect(
            child: Container(
             padding: EdgeInsets.only(left: 40,right: 40,),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: MyAudioWidget(
                    audioFile: item,
                    isAutoPlay: true,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _renderVideo(PageContext pageContext) {
    var media = _medias[_index];
    var src = media.src;
    return _VideoWatcher(
      src: src,
      autoPlay: true,
      context: pageContext,
    );
  }

  List<Widget> _renderToolbars() {
    var items = <Widget>[];
    items.add(
      _renderActions(),
    );
    items.add(
      Positioned(
        bottom: 20,
        right: 20,
        child: Container(
          child: Text(
            "${_index + 1}" + "/" + "${ _medias.length}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17.0,
              decoration: null,
            ),
          ),
        ),
      ),
    );
    items.add(
      Positioned(
        top: 30,
        left: 0,
        child: IconButton(
          iconSize: 20,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    return items;
  }

  Widget _renderActions() {
    var items = <Widget>[];
    var media=_medias[_index];
    if(media.type!='audio') {
      items.add(
        GestureDetector(
          onTap: _isSaving
              ? null
              : () {
            _saveMedia();
          },
          child: _renderSaveButton(),
        ),
      );
    }
    return Positioned(
      top: 40,
      right: 15,
      child: Row(
        children: items,
      ),
    );
  }

  Widget _renderSaveButton() {
    if (!_isSaving) {
      return Icon(
        Icons.save_alt,
        size: 20,
        color: Colors.white,
      );
    }
    if (_baifenbi == 0) {
      return Text(
        '正在保存...',
        style: TextStyle(
          color: Colors.white,
        ),
      );
    }
    return Text(
      '正在下载 ${_baifenbi.toStringAsFixed(2)}',
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }
}

class _VideoWatcher extends StatefulWidget {
  bool autoPlay;
  String src;
  PageContext context;
  _VideoWatcher({this.autoPlay, this.context,this.src});

  @override
  __VideoWatcherState createState() => __VideoWatcherState();
}

class __VideoWatcherState extends State<_VideoWatcher> {
  VideoPlayerController controller;
  int _currentActionIndex = 0;
  var start;
  Future<void> _future_waitfor_inited;

  @override
  void initState() {
    String src=widget.src;
    if(src.startsWith('/')) {
      controller = VideoPlayerController.file(File(src));
    }else{
      controller = VideoPlayerController.network('$src?accessToken=${widget.context.principal.accessToken}');
    }
    controller.addListener(() {
      if (controller.value.isPlaying) {
        if (_currentActionIndex == 1) {
          return;
        }
        setState(() {
          _currentActionIndex = 1;
        });
      } else {
        if (_currentActionIndex == 0) {
          return;
        }
        setState(() {
          _currentActionIndex = 0;
          //检测到结尾必须得停止，否则重定位后会继续播放
          controller.pause().whenComplete(() {
            if (start != null) {
              controller.seekTo(start);
            }
          });
        });
      }
    });
    _future_waitfor_inited = waitfor_inited();
    super.initState();
  }

  @override
  void dispose() {
    _currentActionIndex = 0;
    controller?.dispose();
    start = null;
    _future_waitfor_inited = null;
    super.dispose();
  }

  Future<void> waitfor_inited() async {
    await controller.initialize();
    start = controller.value.position;
    if (widget.autoPlay) {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            minHeight: 100,
            minWidth: 100,
            maxHeight: Adapt.screenH() - 70,
          ),
          child: FutureBuilder(
            future: _future_waitfor_inited,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('video error: ${snapshot.error}');
                return Container(
                  width: 0,
                  height: 0,
                );
              }
              return ClipRect(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 42,
          right: 15,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Align(
              child: IndexedStack(
                index: _currentActionIndex,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.play();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.pause,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.pause();
                    },
                  )
                ],
              ),
              alignment: Alignment.bottomRight,
            ),
          ),
        )
      ],
    );
  }
}
