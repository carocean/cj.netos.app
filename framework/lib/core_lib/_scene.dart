import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_theme.dart';

import '_page.dart';
import '_utimate.dart';
import '_store.dart';

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
    IStore store,
    List<Page> pages,
    List<Desklet> desklets,
    String defaultTheme,
    List<ThemeStyle> themeStyles,
  });
}

class DefaultScene implements IScene, IServiceProvider {
  static const _THEME_STORE_KEY = '#theme';

  final String name;
  String _defaultTheme;
  Map<String, Page> _pages = {};
  Map<String, Desklet> _desklets = {};
  IStore store;
  Map<String, ThemeStyle> _themeStyles = {};
  IServiceProvider parentSite;
  var _principal;
  DBServiceContainer _dbcontainer;


  DefaultScene({
    @required this.name,
  });

  @override
  getService(String name) {
    if('@.principal'==name) {
      if (_principal == null) {
        _principal = parentSite.getService('@.principal');
      }
      return _principal;
    }
    if ('@.scene.current' == name) {
      return this;
    }
    if(name.startsWith('@.page:')){
      String path=name.substring('@.page:'.length,name.length);
      return _pages[path];
    }
    if(name.startsWith('@.desklet:')){
      String path=name.substring('@.desklet:'.length,name.length);
      return _desklets[path];
    }
    if(name.startsWith('@.style:')){
      String path=name.substring('@.style:'.length,name.length);
      return _themeStyles[path];
    }
    if(_dbcontainer.services.containsKey(name)) {
      return _dbcontainer.services[name];
    }
    return parentSite.getService(name);
  }

  Future _indexServices() async {
    var db = await store.loadDatabase();
    var services = store.services;
     _dbcontainer = DBServiceContainer(services: services, site: this, db: db);
    for (var key in services.keys) {
      IDBService service = services[key];
      service.init(_dbcontainer);
    }
  }

  @override
  Future<void> init(
      {IServiceProvider site,
      IStore store,
      List<Page> pages,
      List<Desklet> desklets,
      String defaultTheme,
      List<ThemeStyle> themeStyles}) async {
    this.parentSite = site;
    this.store = store;

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
    for (var style in themeStyles) {
      if (_themeStyles.containsKey(style.url)) {
        throw FlutterErrorDetails(exception: Exception('已存在主题样式:${style.url}'));
      }
      _themeStyles[style.url] = style;
    }
    if (StringUtil.isEmpty(defaultTheme) && themeStyles.isNotEmpty) {
      defaultTheme = themeStyles[0].url;
    }
    _defaultTheme = defaultTheme;

    ///如果没有设置过主题，且默认有主题则设置主题
    if (StringUtil.isEmpty(theme) && !StringUtil.isEmpty(defaultTheme)) {
      await _setTheme(themeStyles[0].url);
    }

    await _indexServices();
    return null;
  }

  Map<String, Widget Function(BuildContext)> get pages {
    var map = <String, Widget Function(BuildContext)>{};
    for (var key in _pages.keys) {
      var page = _pages[key];
      map[key] = (context) {
        var pageContext = PageContext(
            page: page,
            scene: name,
            theme: theme,
            site: this,
            context: context);
        return page.buildPage(pageContext);
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
    var scope;
    if (principal == null) {
      scope = StoreScope.scene;
    } else {
      scope = StoreScope.personOnScene;
    }
    String _theme = sharedPreferences.getString(_THEME_STORE_KEY, scope: scope);
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
    var scope;
    if (principal == null) {
      scope = StoreScope.scene;
    } else {
      scope = StoreScope.personOnScene;
    }
    ISharedPreferences sharedPreferences =
        parentSite.getService('@.sharedPreferences');
    await sharedPreferences.setString(_THEME_STORE_KEY, theme, scope: scope);
  }

  @override
  // TODO: implement defaultTheme
  String get defaultTheme => _defaultTheme;
}

class DBServiceContainer implements IServiceProvider {
  IServiceProvider site;
  dynamic db;
  Map<String, dynamic> services;

  DBServiceContainer({this.services, this.site, this.db});

  @override
  getService(String name) {
    if (services.containsKey(name)) {
      return services[name];
    }
    if ('@.db' == name && db != null) {
      return db;
    }
    return site.getService(name);
  }
}
