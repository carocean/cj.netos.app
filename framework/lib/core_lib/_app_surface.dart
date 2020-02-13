import 'package:flutter/material.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_scene.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_theme.dart';

import '_app_keypair.dart';
import '_page.dart';
import '_portal.dart';
import '_principal.dart';
import '_system.dart';
import '_utimate.dart';

typedef BuildRoute = ModalRoute Function(
    RouteSettings settings, Page page, IServiceProvider site);
typedef AppBuilder = Widget Function(BuildContext, Widget);
typedef OnGenerateRoute = Route<dynamic> Function(RouteSettings);
typedef OnGenerateTitle = String Function(BuildContext);

mixin IAppSurface {
  IScene get current => null;

  AppBuilder get builder => null;

  Map<String, Widget Function(BuildContext)> get routes => null;

  String get initialRoute => null;

  OnGenerateRoute get onGenerateRoute => null;

  OnGenerateTitle get onGenerateTitle => null;

  ThemeData themeData(BuildContext context);

  Widget get home => null;

  String get title => null;

  Future<void> load([AppCreator creator]) {}

  Future<void> switchScene(String scene, String pageUrl);

  Future<void> switchTheme(String theme) {}
}

class AppCreator {
  final String title;
  final String entrypoint;
  final BuildSystem buildSystem;
  final BuildPortals buildPortals;
  final Function() onloading;
  final Function() onloaded;
  final Map<String, dynamic> props;
  final AppKeyPair appKeyPair;
  final ILocalPrincipalManager localPrincipalManager;

  AppCreator({
    this.title,
    this.entrypoint,
    this.buildSystem,
    this.buildPortals,
    this.onloading,
    this.onloaded,
    this.props,
    this.appKeyPair,
    this.localPrincipalManager,
  });
}

class DefaultAppSurface implements IAppSurface, IServiceProvider {
  String _title;
  String _entrypoint;
  String _currentScene;
  Map<String, IScene> _scenes = {};
  IServiceSite _systemServiceContainer;

  ISharedPreferences _sharedPreferences;

  IScene get current => _scenes[_currentScene];

  @override
  AppBuilder get builder {
    return null;
  }

  @override
  String get title => _title;

  @override
  Widget get home {}

  @override
  ThemeData themeData(BuildContext context) {
    var td = current.getActivedThemeData(context);
    return td;
  }

  @override
  OnGenerateTitle get onGenerateTitle {}

  @override
  OnGenerateRoute get onGenerateRoute {}

  @override
  String get initialRoute => _entrypoint;

  @override
  Map<String, Widget Function(BuildContext)> get routes => current.pages;

  @override
  getService(String name) {
    if ('@.scene.current' == name) {
      return current;
    }
    if ('@.sharedPreferences' == name) {
      return _sharedPreferences;
    }
    return null;
  }

  @override
  Future<void> load([AppCreator creator]) async {
    _title = creator.title;
    _entrypoint = creator.entrypoint;

    _systemServiceContainer = _SystemServiceContainer(this);
    _sharedPreferences = new DefaultSharedPreferences();
    await _sharedPreferences.init(_systemServiceContainer);

    var principal = UserPrincipal(manager: creator.localPrincipalManager);
    _systemServiceContainer.addService(
        '@.principal.localmanager', creator.localPrincipalManager);
    _systemServiceContainer.addService('@.principal', principal);

    await _buildSystem(creator.buildSystem);
    await _buildPortals(creator.buildPortals);
  }

  Future<void> _buildSystem(BuildSystem buildSystem) async {
    if (buildSystem == null) {
      return;
    }
    _currentScene = IScene.DEFAULT_SCENE_NAME;

    IScene scene = DefaultScene(
      name: _currentScene,
    );

    _scenes[_currentScene] = scene;

    var system = buildSystem(_systemServiceContainer);
    var pages = system?.buildPages(_systemServiceContainer);
    var systemStore = system?.buildStore(_systemServiceContainer);
    var themeStyles = system?.buildThemes(_systemServiceContainer);

    await scene.init(
      defaultTheme: system.defaultTheme,
      site: _systemServiceContainer,
      desklets: <Desklet>[],
      pages: pages,
      store: systemStore,
      themeStyles: themeStyles,
    );
  }

  Future<void> _buildPortals(BuildPortals buildPortals) async {
    if (buildPortals == null) {
      return;
    }
    List<BuildPortal> portals = buildPortals(_systemServiceContainer);
    for (var buildPortal in portals) {
      var portal = buildPortal(_systemServiceContainer);

      IScene scene = DefaultScene(
        name: portal.id,
      );
      _scenes[portal.id] = scene;

      var pages =
          portal.buildPages == null ? <Page>[] : portal.buildPages(_systemServiceContainer);
      var desklets = portal.buildDesklets == null
          ? <Desklet>[]
          : portal.buildDesklets(_systemServiceContainer);
      var portalStore =
          portal.buildStore == null ? null : portal.buildStore(_systemServiceContainer);
      var themeStyles = portal.buildThemes == null
          ? <ThemeStyle>[]
          : portal.buildThemes(_systemServiceContainer);

      await portalStore?.init(_systemServiceContainer);

      await scene.init(
        defaultTheme: portal.defaultTheme,
        site: _systemServiceContainer,
        desklets: desklets,
        pages: pages,
        store: portalStore,
        themeStyles: themeStyles,
      );
    }
  }

  @override
  Future<void> switchScene(String scene, String pageUrl) async {
    if (!_scenes.containsKey(scene)) {
      throw FlutterError('切换的场景不存在:$scene}');
    }
    _currentScene = scene;
    await switchTheme(current?.theme);
  }

  @override
  Future<void> switchTheme(String theme) async {
    IScene scene = current;
    await scene.switchTheme(theme);
  }
}

class _SystemServiceContainer implements IServiceSite {
  IServiceProvider parent;
  Map<String, dynamic> services = {};

  _SystemServiceContainer(this.parent);

  @override
  getService(String name) {
    if (services.containsKey(name)) {
      return services[name];
    }
    return parent?.getService(name);
  }

  @override
  void addService(String name, service) {
    if (services.containsKey(name)) {
      throw new FlutterError('已存在服务:$name');
    }
    services[name] = service;
  }
}
