import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:just_audio/just_audio.dart';
import 'package:netos_app/common/voice_widget.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

///简单的卡片头：图 标题              折叠按钮
class _CardHeaderBase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(height: 30),
      child: Stack(
        alignment: Alignment.centerLeft,
        overflow: Overflow.visible,
        fit: StackFit.loose,
        children: <Widget>[
          Positioned(
            top: 1,
            left: 0,
            child: Icon(
              Icons.business_center,
              size: 25,
              color: Colors.grey[600],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text('卖场'),
          ),
          Positioned(
            top: 2,
            right: 0,
            child: SizedBox(
              width: 25,
              height: 25,
              child: IconButton(
                padding: EdgeInsets.all(0),
                iconSize: 15,
                onPressed: () {
                  print('pressed');
                },
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///卖场卡片
class CardStore extends StatefulWidget {
  Widget _content;

  CardStore({Widget content}) {
    _content = content;
  }

  @override
  State createState() {
    return _CardStoreState();
  }
}

class _CardStoreState extends State<CardStore> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Column(
          children: <Widget>[
            _CardHeaderBase(),
            Container(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 10,
                right: 10,
              ),
              child: widget._content,
            ),
          ],
        ),
      ),
    );
  }
}

//微博等内容区的多图展示区
class PageSelector extends StatefulWidget {
  PageContext context;
  List<MediaSrc> medias;
  Function(MediaSrc media) onMediaLongTap;
  Function(MediaSrc media) onMediaTap;
  BoxFit boxFit;
  double height;

  PageSelector(
      {this.medias,
      this.context,
      this.onMediaLongTap,
      this.onMediaTap,
      this.boxFit,
      this.height}) {
    if (medias == null) {
      this.medias = [];
    }
    if (boxFit == null) {
      this.boxFit = BoxFit.fitHeight;
    }
  }

  @override
  State createState() {
    return _PageSelectorState();
  }
}

class _PageSelectorState extends State<PageSelector> {
  bool isZoom = false;

  @override
  void dispose() {
    isZoom = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _controller = DefaultTabController.of(context);
    if(widget.medias.isEmpty) {
      return Container(height: 0,width: 0,);
    }
    return Stack(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.height ?? 150,
          ),
          child: TabBarView(
            controller: _controller,
            children: widget.medias.map((media) {
              var mediaRender;
              var src = media?.src;
              switch (media.type) {
                case 'image':
                  mediaRender = src.startsWith('/')
                      ? Image.file(
                          File(src),
                          fit: widget.boxFit ?? BoxFit.fitWidth,
                        )
                      : Image.network(
                          '$src?accessToken=${widget.context.principal.accessToken}',
                          fit: widget.boxFit ?? BoxFit.fitWidth,
                        );
                  break;
                case 'video':
                  mediaRender = VideoView(
                    src: File(src),
                  );
                  break;
                case 'audio':
                  mediaRender = MyAudioWidget(
                    audioFile: src,
                  );
                  break;
                default:
                  print('unknown media type');
                  break;
              }
              if (mediaRender == null) {
                return Container(
                  width: 0,
                  height: 0,
                );
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () {
                  if (widget.onMediaLongTap != null && media.type != 'audio') {
                    widget.onMediaLongTap(media);
                  }
                },
                onTap: () {
                  if (isZoom) {
                    widget.height = 150;
                  } else {
                    if (media.type != 'audio') {
                      widget.height = 500;
                    }
                  }
                  isZoom = !isZoom;
                  setState(() {});
                  if (widget.onMediaTap != null) {
                    widget.onMediaTap(media);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: mediaRender,
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: TabPageSelector(
            controller: _controller,
            color: Colors.white,
            selectedColor: Colors.green,
            indicatorSize: 5,
          ),
        ),
      ],
    );
  }
}


class VoiceFloatingButton extends StatefulWidget {
  PageContext context;
  double iconSize;
  Function() onStartRecord;
  Function(String path, double audioTimeLength,
      FlutterPluginRecord recordPlugin, String action) onStopRecord;

  VoiceFloatingButton(
      {this.context, this.iconSize, this.onStartRecord, this.onStopRecord});

  @override
  _VoiceFloatingButtonState createState() => _VoiceFloatingButtonState();
}

class _VoiceFloatingButtonState extends State<VoiceFloatingButton> {
  var _hover = Colors.grey[500];

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: MyVoiceWidget(
        iconSize: widget.iconSize,
        startRecord: () {
          var handler = widget.onStartRecord;
          if (handler == null) {
            handler = widget.context.parameters['onStartRecord'];
          }
          if (handler != null) {
            handler();
          }
          _hover = Colors.green;
          setState(() {});
        },
        stopRecord: (path, timelength, r, a) {
          var handler = widget.onStopRecord;
          if (handler == null) {
            handler = widget.context.parameters['onStopRecord'];
          }
          if (handler != null) {
            handler(path, timelength, r, a);
          }
          _hover = Colors.grey[500];
          setState(() {});
        },
      ),
      backgroundColor: _hover,
    );
  }
}

class MyAudioWidget extends StatefulWidget {
  String audioFile;
  double timeLength;

  MyAudioWidget({this.audioFile, this.timeLength});

  @override
  _MyAudioWidgetState createState() => _MyAudioWidgetState();
}

class _MyAudioWidgetState extends State<MyAudioWidget> {
  AudioPlayer _player;

  @override
  void initState() {
    _player = AudioPlayer();
    _player.setFilePath(widget.audioFile).then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MyAudioWidget oldWidget) {
    //在列表中的项如果是有状态的，会用同一个状态而绑定新的widget，因此在initState中的初始化仅是在第一次渲染有效，之后列表变化时，widget中的变量值变了，但由于state未变（其initstate方法仅执行一次，因此列表项在同一位置有新的替代时，
    //该状态仍是同一实例，因此需要在didUpdateWidget方法中重新为之赋值
    if (oldWidget.audioFile != widget.audioFile) {
      _player.setFilePath(widget.audioFile).then((v) {
        setState(() {});
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          StreamBuilder<AudioPlaybackState>(
            stream: _player.playbackStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              if (state == AudioPlaybackState.completed) {
                _player.stop();
              }
              return Center(
                child: IconButton(
//                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    switch (state) {
                      case AudioPlaybackState.stopped:
                        _player.play();
                        break;
                      case AudioPlaybackState.paused:
                        _player.play();
                        break;
                      case AudioPlaybackState.playing:
                        _player.pause();
                        break;
                      case AudioPlaybackState.none:
                        break;
                      case AudioPlaybackState.buffering:
                      case AudioPlaybackState.connecting:
                        break;
                      case AudioPlaybackState.completed:
                        break;
                    }
                  },
                  icon: Icon(
                    state == AudioPlaybackState.playing
                        ? FontAwesomeIcons.volumeUp
                        : FontAwesomeIcons.volumeDown,
                    size: 30,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
          StreamBuilder<Duration>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.getPositionStream(),
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > duration) {
                    position = duration;
                  }
                  var progress = ((position?.inMilliseconds ?? 0.0) * 1.0) /
                      ((duration?.inMilliseconds ?? 1.0) * 1.0);
                  var value = (progress * 100);
                  var per = (value.isNaN ? '0.00' : value.toStringAsFixed(2));
                  return Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '$per%',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            padding: EdgeInsets.only(
                              bottom: 5,
                            ),
                          ),
//                      SizedBox(
//                        height: 1,
//                        child: LinearProgressIndicator(
//                          value: progress.isNaN ? 0.0 : progress,
//                          valueColor: AlwaysStoppedAnimation(
//                            Colors.green,
//                          ),
//                          backgroundColor: Colors.grey[300],
//                        ),
                          SeekBar(
                            duration: duration,
                            position: position,
                            onChangeEnd: (newPosition) {
                              _player.seek(newPosition);
                            },
                          ),
//                      ),
                        ],
                      ),
                      if (widget.timeLength != null)
                        Positioned(
                          right: 22,
                          bottom: 8,
                          child: Text(
                            '${widget.timeLength}秒',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration.inMilliseconds.toDouble(),
      value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = null;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(Duration(milliseconds: value.round()));
        }
      },
      inactiveColor: Colors.grey[300],
      activeColor: Colors.green,
    );
  }
}
