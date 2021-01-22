import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netos_app/common/util.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  File src;
  bool autoPlay = false;
  VideoController controller;

  VideoView({this.src, this.autoPlay = false, this.controller});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController controller;
  int _currentActionIndex = 0;
  var start;
  Future<void> _future_waitfor_inited;
  bool _isLoading=true;
  @override
  void initState() {
    controller = VideoPlayerController.file(widget.src);
    _load();
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
  Future<void> _load()async{
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
    if(mounted){
      setState(() {
        _isLoading=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
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
