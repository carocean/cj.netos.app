//桌面栏
import 'package:flutter/widgets.dart';

import '../framework.dart';

typedef BuildDesklet = Widget Function(
    Desklet desklet, PageContext desktopContext);

typedef BuildDesklets = List<Desklet> Function(
     IServiceProvider site);

class Desklet {
  final String title;
  final IconData icon;
  final String subtitle;
  final String desc;
  final String url;
  final BuildDesklet buildDesklet;

  @override
  String toString() {
    return '$runtimeType($title $url)';
  }

  Desklet({
    @required this.title,
    @required this.icon,
    this.subtitle,
    this.desc,
    @required this.url,
    @required this.buildDesklet,
  })  : assert(title != null),
        assert(url != null),
        assert(icon != null),
        assert(buildDesklet != null);
}

class Portlet {
  final String id;
  final String title;
  final String imgSrc;
  final String subtitle;
  final String desc;

  ///渲染门户栏目由桌面栏目渲染
  final String deskletUrl;
  final Map<String, String> props = {};

  Portlet({
    @required this.id,
    @required this.title,
    this.imgSrc,
    this.subtitle,
    this.desc,
    @required this.deskletUrl,
  })  : assert(id != null),
        assert(title != null),
        assert(deskletUrl != null);

  Widget build({
    @required PageContext context,
  }) {
    if (context == null) {
      throw FlutterError('缺少必选参数');
    }
    var desklet = context.desklet(deskletUrl);
    if (desklet == null) {
      debugPrint('桌面栏目未定义:' + deskletUrl);
      return null;
    }
    return desklet.buildDesklet(desklet, context);
  }

  toMap() {
    var map = {};
    map['id'] = id;
    map['title'] = title;
    map['imgSrc'] = imgSrc;
    map['subtitle'] = subtitle;
    map['desc'] = desc;
    map['deskletUrl'] = deskletUrl;
//    map['props']=this.props;
    return map;
  }
}
