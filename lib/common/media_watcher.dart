import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import 'medias_widget.dart';
import 'my_photo_view_gallery.dart';

class MediaWatcher extends StatefulWidget {
  MediaWatcher({
    this.pageContext,
  });

  final PageContext pageContext;

  @override
  State<StatefulWidget> createState() {
    return _MediaWatcherState();
  }
}

class _MediaWatcherState extends State<MediaWatcher> {
  int currentIndex;
  PageController _pageController;
  List<MediaSrc> _thumbGalleryItems;
  Decoration _backgroundDecoration;
  int _initialIndex;
  Axis _scrollDirection;
  bool _isSaving = false;
  double _baifenbi = 0.0;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSink _deleteEvent;

  @override
  void initState() {
    var _content = widget.pageContext;
    _thumbGalleryItems = _content.parameters['medias'];
    _backgroundDecoration = _content.parameters['backgroundDecoration'];
    _deleteEvent = _content.parameters['deleteEvent'];
    if (_backgroundDecoration == null) {
      _backgroundDecoration = const BoxDecoration(
        color: Colors.black,
      );
    }
    _scrollDirection = Axis.horizontal;
    _initialIndex = _content.parameters['index'] ?? 0;
    currentIndex = _initialIndex;
    _pageController = PageController(initialPage: _initialIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> _saveMedia(MediaSrc src) async {
    if (_isSaving) {
      return;
    }
    _isSaving = true;
    setState(() {});
    var file = src.src;
    if (!file.startsWith('/')) {
      var dir = await getApplicationDocumentsDirectory();
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
      body: Container(
        decoration: _backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            MyPhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: _thumbGalleryItems.length,
              backgroundDecoration: _backgroundDecoration,
              pageController: _pageController,
              onPageChanged: onPageChanged,
              scrollDirection: _scrollDirection,
            ),
            _renderActions(),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                child: Text(
                  "${currentIndex + 1}" + "/" + "${_thumbGalleryItems.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    decoration: null,
                  ),
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }

  Widget _renderActions() {
    var items = <Widget>[];
    if (_deleteEvent != null) {
      items.add(
        GestureDetector(
          onTap: _isSaving
              ? null
              : () {
                  _saveMedia(_thumbGalleryItems[currentIndex]);
                },
          child: _renderSaveButton(),
        ),
      );
      items.add(
        SizedBox(
          width: 25,
        ),
      );
      items.add(
        GestureDetector(
          onTap: () {
            _deleteEvent.add(_thumbGalleryItems[currentIndex].src);
            _thumbGalleryItems.removeAt(currentIndex);
            if (mounted) {
              setState(() {});
            }
            if(_thumbGalleryItems.isEmpty) {
              widget.pageContext.backward();
            }
          },
          child: Icon(
            Icons.delete_forever,
            size: 18,
            color: Colors.white,
          ),
        ),
      );
    } else {
      items.add(
        GestureDetector(
          onTap: _isSaving
              ? null
              : () {
                  _saveMedia(_thumbGalleryItems[currentIndex]);
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

  MyPhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    MediaSrc media;
    media = _thumbGalleryItems[index];
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
          child: _renderVideo(widget.pageContext, item),
        );
      case 'audio':
        return MyPhotoViewGalleryPageOptions.customChild(
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
          maxScale: PhotoViewComputedScale.covered * 1.1,
          heroAttributes: PhotoViewHeroAttributes(tag: item),
          child: ClipRect(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: MyAudioWidget(
                    audioFile: item,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _renderVideo(PageContext pageContext, src) {
    return _VideoWatcher(
      autoPlay: true,
      src: src,
      context: pageContext,
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
  VideoController controller;
  _VideoWatcher({this.autoPlay,this.controller, this.context,this.src});

  @override
  __VideoWatcherState createState() => __VideoWatcherState();
}

class __VideoWatcherState extends State<_VideoWatcher> {
  VideoPlayerController controller;
  int _currentActionIndex = 0;
  var start;
  bool _isLoading=true;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _currentActionIndex = 0;
    start = null;
    try{
      controller.dispose();
    }catch(e){

    }
    super.dispose();
  }

  @override
  void didUpdateWidget(_VideoWatcher oldWidget) {
    if(oldWidget.src!=widget.src) {
      oldWidget.src=widget.src;
      //重新加载会导致VideoPlayerController实体太多没释放，会报错:Failed to initialize decoder: OMX.hisi.video.decoder.avc
      //可是注掉又不能刷新了
      _load();
    }
    super.didUpdateWidget(oldWidget);

  }
  Future<void> _load() async {
    if (controller != null) {
      VideoPlayerController oldController = controller;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        try {
          oldController.dispose();
        } catch (e) {}
      });
      setState(() {
        controller=null;
      });
    }
    String src = widget.src;
    if (src.startsWith('/')) {
      controller = VideoPlayerController.file(File(src));
    } else {
      controller = VideoPlayerController.network(
          getUrlWithAccessToken(src, widget.context.principal.accessToken));
    }
    if (widget.controller != null) {
      widget.controller.controller = controller;
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
    await waitfor_inited();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> waitfor_inited() async {
    try {
      await controller.initialize();
      start = controller.value.position;
      if (widget.controller != null) {
        widget.controller.start = start;
      }
      if (widget.autoPlay) {
        await controller.play();
      }
    }catch(e){
      print('视频加载失败:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic display;
    if(_isLoading){
      display=Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      );
    }else{
      display=ClipRect(
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
    }
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
          child: display,
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
