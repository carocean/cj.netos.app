import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/video_view.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:nineold/loader/image_with_loader.dart';
import 'package:nineold/loader/image_with_local.dart';
import 'package:nineold/watcher/gallery_watcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

import 'media_watcher.dart';
import 'util.dart';

const double _aspectRatio = 16 / 9;
class MediaWidget extends StatelessWidget {
  const MediaWidget(
    this.medias,
    this.pageContext,
  );

  final List<MediaSrc> medias;
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
        height:medias[0]?.type=='share'?90: 166,
      ),
      child: _aspectRatioImage(context, index: 0, aspectRatio: 1),
    );
  }

  Widget _buildTwoImages(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        height: 96,
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
        height: 142,
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
        height: 206,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
        height: 176,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
        height: 146,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
        height: 206,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
        height: 206,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
        height: 206,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              aspectRatio: _aspectRatio,
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
        double aspectRatio = _aspectRatio,
  }) {
    var media=medias[index];
    if('share'==media.type){
    return _MediaWithLoader(
      src: media,
      accessToken: pageContext.principal.accessToken,
      pageContext: pageContext,
      stackFit: StackFit.loose,
    );
    }
    return InkWell(
        child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Hero(
                tag: '$media?tag=${Uuid().v1()}',
                child: _MediaWithLoader(
                  src: media,
                  accessToken: pageContext.principal.accessToken,
                  pageContext: pageContext,
                ))),
        onTap: () {
          _openGalleryWatcher(context, index);
        });
  }

  _openGalleryWatcher(BuildContext context, int index) {
    pageContext.forward(
      '/images/viewer',
      arguments: {
        'medias': medias,
        'index': index,
      },
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

class _MediaWithLoader extends StatelessWidget {
   _MediaWithLoader({
    this.src,
    this.fit = BoxFit.cover,
    this.stackFit=StackFit.expand,
    this.loaderSize = 48.0,
    this.accessToken,
    this.pageContext,
  });
  final StackFit stackFit;
  final PageContext pageContext;
  final MediaSrc src;
  final String accessToken;
  final BoxFit fit;
  final double loaderSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
       ( 'video'==src?.type)?SizedBox.shrink():
        Container(
          // color: Colors.grey,
          child: Center(
            child: SizedBox(
              width: loaderSize,
              height: loaderSize,
              child: _buildCircularProgressIndicator(),
            ),
          ),
        ),

        _getMediaRender(src, accessToken, pageContext),
      ],
    );
  }

  CircularProgressIndicator _buildCircularProgressIndicator() {
    return CircularProgressIndicator(
      backgroundColor: Colors.white,
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
    );
  }

  Widget _getMediaRender(
      MediaSrc media, String accessToken, PageContext pageContext) {
    var mediaRender;
    var src = media?.src;
    switch (media.type) {
      case 'image':
        mediaRender = src.startsWith('/')
            ? Image.file(
          File(src),
          fit: BoxFit.cover,
        )
        //     : FadeInImage.memoryNetwork(
        //   image: getUrlWithAccessToken(src, accessToken) ,
        //   fit: BoxFit.contain,
        //   placeholder: kTransparentImage,
        // );
        :CachedNetworkImage(
          imageUrl:  getUrlWithAccessToken(src, accessToken) ,
          fit: BoxFit.cover,
        );
        mediaRender=ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: mediaRender,
        );
        break;
      case 'share':
        mediaRender = Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              renderShareCard(
                title: media.text,
                href: media.src,
                leading: media.leading,
                context: pageContext,
                margin: EdgeInsets.only(left: 0,right: 0),
              ),
            ],
          ),
        );
        break;
      case 'video':
        mediaRender = VideoView(
          src: src,
          context: pageContext,
        );
        mediaRender = ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: mediaRender,
        );
        break;
      case 'audio':
        mediaRender = MyAudioWidget(
          audioFile: src,
        );
        mediaRender = ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: mediaRender,
        );
        break;
      default:
        print('unknown media type');
        break;
    }
    return mediaRender;
  }

}
