
import 'package:flutter/material.dart';

import '../framework.dart';

typedef BuildPage = Widget Function(PageContext pageContext);
typedef BuildPages = List<Page> Function(IServiceProvider site);

class Page {
  Page({
    @required this.title,
    @required this.icon,
    this.subtitle,
    this.previousTitle,
    this.desc,
    @required this.url,
    @required this.buildPage,
    @required this.buildRoute,
  })  : assert(title != null),
        assert(url != null),
        assert(buildPage != null || buildRoute != null);
  final String title;
  final IconData icon;
  final String subtitle;
  final String previousTitle;
  final String desc;
  Map<String, Object> _parameters;

  ///构建页面。如果使用自定义动画则必须使用buildRoute，两个方法必有一个非空；当二者均有实现时则优先buildRoute
  final BuildPage buildPage;

  ///构建路由。如果使用自定义动画则必须使用buildRoute，两个方法必有一个非空；当二者均有实现时则优先buildRoute
  final BuildRoute buildRoute;
  final String url;

  @override
  String toString() {
    return '$runtimeType($title $url)';
  }

  void _parseParams(String qs) {
    int pos = qs.indexOf("&");
    var remaining = '';
    var kv = '';
    if (pos < 0) {
      kv = qs;
    } else {
      kv = qs.substring(0, pos);
      remaining = qs.substring(pos + 1, qs.length);
    }
    while (kv.startsWith(" ")) {
      kv = kv.substring(1, kv.length);
    }
    pos = kv.indexOf("=");
    var k = '';
    var v = '';
    if (pos < 0) {
      k = kv;
    } else {
      k = kv.substring(0, pos);
      v = kv.substring(pos + 1, kv.length);
    }
    while (v.startsWith(" ")) {
      v = v.substring(1, v.length);
    }
    while (v.endsWith(" ")) {
      v = v.substring(0, v.length - 1);
    }
    _parameters[k] = v;
    if (!StringUtil.isEmpty(remaining)) {
      _parseParams(remaining);
    }
  }

  Map<String, Object> get parameters => _parameters;

  void $__init(String qs) {
    _parameters = Map();
    if (!StringUtil.isEmpty(qs)) {
      _parseParams(qs);
    }
  }
}
