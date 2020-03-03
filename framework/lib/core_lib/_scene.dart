import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_connection.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_theme.dart';

import '_page.dart';
import '_service_containers.dart';
import '_utimate.dart';

mixin IScene implements IDisposable {
  static const DEFAULT_SCENE_NAME = '/';

  String get name;

  UserPrincipal get principal;

  String get defaultTheme;

  String get theme;

  Map<String, Widget Function(BuildContext)> get pages;

  ThemeData getActivedThemeData(BuildContext context);

  Future<void> switchTheme(String theme) {}

  Future<void> init({
    @required IServiceProvider site,
    Map<String, dynamic> services,
    List<Page> pages,
    List<Desklet> desklets,
    String defaultTheme,
    List<ThemeStyle> themeStyles,
  });

  bool containsPage(String path) {}

  Page getPage(String path) {}

}

class DefaultScene implements IScene, IServiceProvider {
  static const _THEME_STORE_KEY = '#theme';

  final String name;
  String _defaultTheme;
  Map<String, Page> _pages = {};
  Map<String, Desklet> _desklets = {};
  Map<String, _ThemeEntitity> _themeStyles = {};
  IServiceProvider parentSite;
  var _principal;
  SceneServiceContainer _sceneServiceContainer;

  DefaultScene({
    @required this.name,
  });

  @override
  bool containsPage(String path) {
    return _pages.containsKey(path);
  }

  @override
  Page getPage(String path) {
    return _pages[path];
  }

  @override
  getService(String name) {
    if ('@.principal' == name) {
      if (_principal == null) {
        _principal = parentSite.getService('@.principal');
      }
      return _principal;
    }
    if (name.startsWith('@.page:')) {
      String path = name.substring('@.page:'.length, name.length);
      return _pages[path];
    }
    if (name.startsWith('@.desklet:')) {
      String path = name.substring('@.desklet:'.length, name.length);
      return _desklets[path];
    }
    if ('@.desklet.names' == name) {
      return _desklets.keys;
    }
    if ('@.theme.names' == name) {
      return _themeStyles.keys;
    }
    if (name.startsWith('@.theme:')) {
      String path = name.substring('@.theme:'.length, name.length);
      return _themeStyles[path]?.define;
    }
    if (name.startsWith('@.style:')) {
      var themeEntity = _themeStyles[theme];
      String path = name.substring('@.style:'.length, name.length);
      return themeEntity?.styles[path];
    }

    return parentSite.getService(name);
  }

  @override
  Future<void> init(
      {IServiceProvider site,
      Map<String, dynamic> services,
      List<Page> pages,
      List<Desklet> desklets,
      String defaultTheme,
      List<ThemeStyle> themeStyles}) async {
    this.parentSite = site;
    _sceneServiceContainer = SceneServiceContainer(this);
    _sceneServiceContainer.addServices(services);

    for (var page in pages) {
      if (_pages.containsKey(page.url)) {
        throw FlutterErrorDetails(exception: Exception('已存在地址页:${page.url}'));
      }
      _pages[page.url] = page;
    }
    for (var let in desklets) {
      if (_desklets.containsKey(let.url)) {
        throw FlutterErrorDetails(exception: Exception('已存在栏目:${let.url}'));
      }
      _desklets[let.url] = let;
    }
    for (var _theme_ in themeStyles) {
      if (_themeStyles.containsKey(_theme_.url)) {
        throw FlutterErrorDetails(exception: Exception('已存在主题:${_theme_.url}'));
      }
      var styles = _theme_.buildStyle(_sceneServiceContainer);
      styles = styles ?? <Style>[];
      var index = <String, Style>{};
      for (var style in styles) {
        if (index.containsKey(style.url)) {
          throw FlutterErrorDetails(
              exception: Exception('主题:${_theme_.url}中已存在样式${_theme_.url}'));
        }
        index[style.url] = style;
      }
      var theme = _ThemeEntitity(
          themeUrl: _theme_.url,
          styles: index,
          buildTheme: _theme_.buildTheme,
          define: _theme_);
      _themeStyles[_theme_.url] = theme;
    }
    if (StringUtil.isEmpty(defaultTheme) && themeStyles.isNotEmpty) {
      defaultTheme = themeStyles.first?.url;
    }
    _defaultTheme = defaultTheme;

    ///如果没有设置过主题，且默认有主题则设置主题
    if (StringUtil.isEmpty(theme) && !StringUtil.isEmpty(defaultTheme)) {
      await _setTheme(themeStyles[0].url);
    }
    _sceneServiceContainer.initServices(services);
    await _sceneServiceContainer.readyServices();

    return null;
  }

  Map<String, Widget Function(BuildContext)> get pages {
    var map = <String, Widget Function(BuildContext)>{};
    for (var key in _pages.keys) {
      var page = _pages[key];
      if (page.buildPage == null) {
        continue;
      }
      map[key] = (context) {
        var pageContext = PageContext(
            page: page,
            sourceScene: name,
            sourceTheme: theme,
            site: _sceneServiceContainer,
            context: context);
        var p = page.buildPage(pageContext);
        return p;
      };
    }
    return map;
  }

  @override
  // TODO: implement principal
  UserPrincipal get principal => parentSite.getService('@.principal');

  @override
  void dispose() {
    _pages?.clear();
    _desklets?.clear();
    _themeStyles?.clear();
  }

  @override
  // TODO: implement activedTheme
  ThemeData getActivedThemeData(BuildContext context) =>
      _themeStyles[theme]?.buildTheme(context);

  @override
  // TODO: implement useTheme
  String get theme {
    ISharedPreferences sharedPreferences =
        parentSite.getService('@.sharedPreferences');
    String _theme = sharedPreferences.getString(_THEME_STORE_KEY,
        person: _principal?.person, scene: name);
    if (StringUtil.isEmpty(_theme)) {
      _theme = this._defaultTheme;
    }
    return _theme;
  }

  @override
  Future<void> switchTheme(String theme) async {
    if (!this._themeStyles.containsKey(theme)) {
      throw FlutterError('场景:$name下不存在主题:$theme');
    }
    await _setTheme(theme);
    return null;
  }

  _setTheme(String theme) async {
    ISharedPreferences sharedPreferences =
        parentSite.getService('@.sharedPreferences');
    await sharedPreferences.setString(_THEME_STORE_KEY, theme,
        person: _principal?.person, scene: name);
  }

  @override
  // TODO: implement defaultTheme
  String get defaultTheme => _defaultTheme;
}

class _ThemeEntitity {
  String themeUrl;
  Map<String, Style> styles = {};
  BuildTheme buildTheme;
  ThemeStyle define;

  _ThemeEntitity({this.themeUrl, this.styles, this.buildTheme, this.define});
}
