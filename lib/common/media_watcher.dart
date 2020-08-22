import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import 'my_photo_view_gallery.dart';

class MediaWatcher extends StatefulWidget {
  MediaWatcher({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.thumbGalleryItems,
    this.originGalleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<MediaSrc> thumbGalleryItems;
  final List<MediaSrc> originGalleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _MediaWatcherState();
  }
}

class _MediaWatcherState extends State<MediaWatcher> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            MyPhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.thumbGalleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                child: Text(
                  "${currentIndex + 1}" +
                      "/" +
                      "${widget.thumbGalleryItems.length}",
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
            )
          ],
        ),
      ),
    );
  }

  MyPhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    MediaSrc media;
    if (null == widget.originGalleryItems ||
        widget.originGalleryItems.length == 0) {
      media = widget.thumbGalleryItems[index];
    } else {
      media = widget.originGalleryItems[index];
    }
    var item = media.src;
    switch (media.type) {
      case 'image':
        return MyPhotoViewGalleryPageOptions(
          imageProvider: item.startsWith('/')
              ? FileImage(File(item))
              : CachedNetworkImageProvider(item),
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
          child: _VideoWatcher(
            autoPlay: true,
            src: File(item),
          ),
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
}

class _VideoWatcher extends StatefulWidget {
  bool autoPlay;
  File src;

  _VideoWatcher({this.autoPlay, this.src});

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
    controller = VideoPlayerController.file(widget.src);
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
                  color: Colors.grey,
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
          right: 17,
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
