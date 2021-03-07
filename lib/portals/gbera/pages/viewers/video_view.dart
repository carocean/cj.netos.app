import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  String src;
  bool autoPlay = false;
  PageContext context;
  VideoController controller;

  VideoView({this.src, this.context, this.autoPlay = false, this.controller});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController controller;
  int _currentActionIndex = 0;
  var start;
  bool _isLoading = true;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void didUpdateWidget(VideoView oldWidget) {
    if (oldWidget.src != widget.src) {
      oldWidget.src = widget.src;
      //重新加载会导致VideoPlayerController实体太多没释放，会报错:Failed to initialize decoder: OMX.hisi.video.decoder.avc
      //可是注掉又不能刷新了
      _load();
    }
    super.didUpdateWidget(oldWidget);
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
    } catch (e) {
      print('视频加载失败:$e');
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return ClipRect(
      child: Container(
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.center,
              children: <Widget>[
                VideoPlayer(controller),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 38,
                    height: 38,
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
            ),
          ),
        ),
      ),
    );
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
