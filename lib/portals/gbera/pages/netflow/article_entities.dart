
import 'dart:io';

import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';

///多媒体文件
class MediaFile {
  MediaFileType type;
  File src;

  MediaFile({this.type, this.src});

  void delete() {
    src?.deleteSync();
  }

 MediaSrc toMediaSrc() {
    var _type;
    switch(this.type){
      case MediaFileType.image:
        _type='image';
        break;
      case MediaFileType.audio:
        _type='audio';
        break;
      case MediaFileType.video:
        _type='video';
        break;
    }
    return MediaSrc(type: _type,src: src.path);
 }

}

enum MediaFileType { image, video, audio }
