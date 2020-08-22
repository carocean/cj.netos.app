import 'dart:io';

import 'package:awsome_video_player/awsome_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:nineold/loader/image_with_loader.dart';
import 'package:nineold/loader/image_with_local.dart';
import 'package:nineold/watcher/gallery_watcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import 'media_watcher.dart';

class RecommenderMediaWidget extends StatelessWidget {
  const RecommenderMediaWidget(
    this.medias,
    this.pageContext,
  );

  final List<RecommenderMediaOR> medias;
  final PageContext pageContext;

  @override
  Widget build(BuildContext context) {
    return _buildImagesFrame(context);
  }

  Widget _buildImagesFrame(BuildContext context) {
    switch (medias.length) {
      case 0:
        return SizedBox.shrink();
      case 1:
        return _buildSingleImage(context);
      case 2:
        return _buildTwoImages(context);
      case 3:
        return _buildThreeImages(context);
      case 4:
        return _buildFourImages(context);
      case 5:
        return _buildFiveImages(context);
      case 6:
        return _buildSixImages(context);
      case 7:
        return _buildSevenImages(context);
      case 8:
        return _buildEightImages(context);
      case 9:
        return _buildNineImages(context);
      default:
        return _buildNineImages(context);
    }
  }

  Widget _buildSingleImage(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: _aspectRatioImage(context, index: 0, aspectRatio: 1),
    );
  }

  Widget _buildTwoImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: _aspectRatioImage(context, index: 0)),
          _spacer(),
          Expanded(child: _aspectRatioImage(context, index: 1)),
        ],
      ),
    );
  }

  Widget _buildThreeImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(flex: 196, child: _aspectRatioImage(context, index: 0)),
          _spacer(),
          Expanded(
            flex: 97,
            child: Column(
              children: <Widget>[
                _aspectRatioImage(context, index: 1),
                _spacer(),
                _aspectRatioImage(context, index: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 0)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 1)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 2)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiveImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 0)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 1)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 2)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 3)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSixImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 0)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 1)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 2)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 3)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 4)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSevenImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 0)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 1)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 2)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 3)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 4)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 5)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 6)),
              _spacer(),
              Expanded(child: _aspectRatioEmpty()),
              _spacer(),
              Expanded(child: _aspectRatioEmpty()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEightImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 0)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 1)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 2)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 3)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 4)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 5)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 6)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 7)),
              _spacer(),
              Expanded(child: _aspectRatioEmpty()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNineImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 296,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 0)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 1)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 2)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 3)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 4)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 5)),
            ],
          ),
          _spacer(),
          Row(
            children: <Widget>[
              Expanded(child: _aspectRatioImage(context, index: 6)),
              _spacer(),
              Expanded(child: _aspectRatioImage(context, index: 7)),
              _spacer(),
              Expanded(
                child: _plusMorePictures(
                  context,
                  valueCount: medias.length - 9,
                  child: _aspectRatioImage(
                    context,
                    index: 8,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _plusMorePictures(
    BuildContext context, {
    int valueCount,
    Widget child,
  }) {
    if (valueCount <= 0) {
      return child;
    } else {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          child,
          InkWell(
            onTap: () {
              _openGalleryWatcher(context, 9);
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.white30,
                child: Center(
                  child: Text(
                    "+$valueCount",
                    style:
                        TextStyle(fontSize: 32, fontFamily: "Poppins-Regular"),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  SizedBox _spacer() {
    return SizedBox.fromSize(
      size: Size(2, 2),
    );
  }

  Widget _aspectRatioImage(
    BuildContext context, {
    int index,
    double aspectRatio = 1,
  }) {
    return InkWell(
        child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Hero(
                tag: '${medias[index]}?tag=${Uuid().v1()}',
                child: _MediaCacheAndLoader(
                  src: medias[index],
                  accessToken: pageContext.principal.accessToken,
                  context: pageContext,
                ))),
        onTap: () {
          _openGalleryWatcher(context, index);
        });
  }

  _openGalleryWatcher(BuildContext context, int index) {
//    pageContext.forward(
//      '/images/viewer',
//      arguments: {
//        'media': medias[index],
//        'others': medias,
//        'autoPlay': true,
//      },
//    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaWatcher(
          thumbGalleryItems: RecommenderMediaOR.toMediaSrcList(medias),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Widget _aspectRatioEmpty({
    double aspectRatio = 1,
  }) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SizedBox(),
    );
  }
}

class _MediaCacheAndLoader extends StatefulWidget {
  _MediaCacheAndLoader({
    this.src,
    this.fit = BoxFit.cover,
    this.loaderSize = 48.0,
    this.accessToken,
    this.context,
  });

  RecommenderMediaOR src;
  String accessToken;
  BoxFit fit;
  double loaderSize;
  PageContext context;

  @override
  __MediaCacheAndLoaderState createState() => __MediaCacheAndLoaderState();
}

class __MediaCacheAndLoaderState extends State<_MediaCacheAndLoader> {
  RecommenderMediaOR _src;

  @override
  void initState() {
    _loadSrcFile().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(_MediaCacheAndLoader oldWidget) {
    if (oldWidget.src?.src != widget.src?.src) {
      oldWidget.src = widget.src;
      oldWidget.accessToken = widget.accessToken;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadSrcFile() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _src = await recommender.getAndCacheMedia(widget.src);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          color: _src == null ? Colors.black : Colors.transparent,
          child: Center(
            child: SizedBox(
              width: widget.loaderSize,
              height: widget.loaderSize,
              child: _buildCircularProgressIndicator(),
            ),
          ),
        ),
        _src == null
            ? SizedBox(
                width: 0,
                height: 0,
              )
            : _getMediaRender(_src, widget.accessToken),
      ],
    );
  }
}

CircularProgressIndicator _buildCircularProgressIndicator() {
  return CircularProgressIndicator(
    backgroundColor: Colors.white,
    strokeWidth: 3,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
  );
}

Widget _getMediaRender(RecommenderMediaOR media, String accessToken) {
  var mediaRender;
  var src = media?.src;
  switch (media.type) {
    case 'image':
      mediaRender = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Image.file(
          File(src),
          fit: BoxFit.cover,
        ),
      );
      break;
    case 'video':
      mediaRender = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: _RecommenderVideoView(
          src: File(src),
        ),
      );
      break;
    case 'audio':
      mediaRender = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: MyAudioWidget(
          audioFile: src,
        ),
      );
      break;
    default:
      print('unknown media type');
      break;
  }
  return mediaRender;
}

class _RecommenderVideoView extends StatefulWidget {
  File src;
  bool autoPlay = false;
  VideoController controller;

  _RecommenderVideoView({this.src, this.autoPlay = false, this.controller});

  @override
  _RecommenderVideoViewState createState() => _RecommenderVideoViewState();
}

class _RecommenderVideoViewState extends State<_RecommenderVideoView> {
  VideoPlayerController controller;
  int _currentActionIndex = 0;
  var start;
  Future<void> _future_waitfor_inited;

  @override
  void initState() {
    controller = VideoPlayerController.file(widget.src);
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
    _future_waitfor_inited = waitfor_inited();
    super.initState();
  }

  @override
  void dispose() {
    _currentActionIndex = 0;
    controller.dispose();
    start = null;
    _future_waitfor_inited = null;
    super.dispose();
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
          bottom: 0,
          right: 0,
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

  Future<void> waitfor_inited() async {
    await controller.initialize();
    start = controller.value.position;
    if (widget.controller != null) {
      widget.controller.start = start;
    }
    if (widget.autoPlay) {
      controller.play();
    }
  }
}

class VideoController {
  VideoPlayerController controller;
  var start;

  stop() {
    if (controller != null) {
      controller.pause().whenComplete(() {
        if (start != null) {
          controller.seekTo(start);
        }
      });
    }
  }
}
