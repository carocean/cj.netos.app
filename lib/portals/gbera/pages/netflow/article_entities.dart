
import 'dart:io';

///多媒体文件
class MediaFile {
  MediaFileType type;
  File src;

  MediaFile({this.type, this.src});

  void delete() {
    src?.deleteSync();
  }
}

enum MediaFileType { image, video, audio }
