
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
  Map<String, Object> _parameters={};

  ///构建页面。如果使用自定义动画则必须使用buildRoute，两个方法必有一个非空；当二者均有实现时则优先buildRoute
  final BuildPage buildPage;

  ///构建路由。如果使用自定义动画则必须使用buildRoute，两个方法必有一个非空；当二者均有实现时则优先buildRoute
  final BuildRoute buildRoute;
  final String url;

  @override
  String toString() {
    return '$runtimeType($title $url)';
  }

  Map<String, Object> get parameters => _parameters;
}
