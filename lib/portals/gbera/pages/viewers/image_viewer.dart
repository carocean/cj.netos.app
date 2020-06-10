import 'dart:io';
import 'dart:math';

///商户站点
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';

import 'video_view.dart';

class MediaSrc {
  final String id;
  final String type;
  final String src;
  final String leading;
  final String msgid;
  final String text;

  ///来源，如：网流管道、地圈
  final String sourceType;

  MediaSrc(
      {this.id,
      this.type,
      this.src,
      this.leading,
      this.msgid,
      this.text,
      this.sourceType});
}

class ImageViewer extends StatefulWidget {
  PageContext context;
  MediaSrc viewMedia;
  List<MediaSrc> others;
  bool autoPlay = false;

  ImageViewer({this.context, this.viewMedia, this.others}) {
    this.viewMedia = context.parameters['media'];
    this.others = context.parameters['others'];
    if (this.others == null) {
      this.others = [];
    }
    autoPlay = context.parameters['autoPlay'] ?? false;
  }

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  static var select = 0;
  VideoController _controller;

  @override
  void initState() {
    this._controller = VideoController();
    super.initState();
  }

  @override
  void dispose() {
    this._controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    changeImage(int isUp) {
      if (isUp > 0) {
        select += 1;
      } else {
        select -= 1;
      }
      if (select < 0) {
        select = widget.others.length - 1;
      }
      if (select > widget.others.length - 1) {
        select = 0;
      }
      _controller.stop();
      widget.context.forward('/images/viewer', arguments: {
        'media': widget.others[select],
        'others': widget.others,
        'autoPlay': widget.context.parameters['autoPlay'],
      });
    }

    int isDemandChangeImage = 0; //0是未改变图片，1是向上，-1是向下
    Offset start;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          constraints: BoxConstraints.expand(),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        if (widget.others.isEmpty) {
                          return;
                        }
                        if (isDemandChangeImage != 0) {
                          return;
                        }
                        var distance = start.dy - details.localPosition.dy;
                        distance = distance.abs();
                        if (distance > 50) {
                          isDemandChangeImage =
                              details.localPosition.dy - start.dy < 0 ? 1 : -1;
                          changeImage(isDemandChangeImage);
                        }
                      },
                      onPanDown: (DragDownDetails details) {
                        start = details.localPosition;
                        isDemandChangeImage = 0;
                      },
                      child: _getMediaRender(widget.viewMedia),
                    ),
                  ),
                  CustomScrollView(
                    shrinkWrap: true,
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 10,
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: '${widget.viewMedia?.text ?? ''}',
                            ),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    widget.context.backward(
                      clearHistoryPageUrl: '/images/viewer',
                    );
                  },
                  color: Colors.red,
                  iconSize: 20,
                  icon: Icon(
                    Icons.clear,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMediaRender(MediaSrc media) {
    var mediaRender;
    var src = media?.src;
    if (src.startsWith('http')) {
      int pos = src.lastIndexOf('?');
      if (pos < 0) {
        src = '$src?accessToken=${widget.context.principal.accessToken}';
      }
    }
    switch (media.type) {
      case 'image':
        mediaRender = src.startsWith('/')
            ? Image.file(
                File(src),
                fit: BoxFit.fitWidth,
              )
            : Image.network(
                src,
                fit: BoxFit.fitWidth,
              );
        break;
      case 'video':
        mediaRender = VideoView(
          src: File(src),
          autoPlay: widget.autoPlay,
          controller: _controller,
        );
        break;
      case 'audio':
        break;
      default:
        print('unknown media type');
        break;
    }
    if (mediaRender == null) {
      return Container(
        width: 0,
        height: 0,
        alignment: Alignment.center,
      );
    }
    return mediaRender;
  }
}
