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
