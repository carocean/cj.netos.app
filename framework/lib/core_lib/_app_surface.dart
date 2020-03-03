import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_connection.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_network_container.dart';
import 'package:framework/core_lib/_pump.dart';
import 'package:framework/core_lib/_scene.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_theme.dart';

import '_app_keypair.dart';
import '_exceptions.dart';
import '_page.dart';
import '_peer_manager.dart';
import '_portal.dart';
import '_principal.dart';
import '_service_containers.dart';
import '_system.dart';
import '_utimate.dart';

typedef BuildRoute = ModalRoute Function(
    RouteSettings settings, Page page, IServiceProvider site);
typedef AppDecorator = Widget Function(BuildContext, Widget);
typedef OnGenerateRoute = Route<dynamic> Function(RouteSettings);
typedef OnGenerateTitle = String Function(BuildContext);

mixin IAppSurface {
  IScene get current => null;

  AppDecorator get appDecorator => null;

  Map<String, Widget Function(BuildContext)> get routes => null;

  String get initialRoute => null;

  OnGenerateRoute get onGenerateRoute => null;

  OnGenerateTitle get onGenerateTitle => null;

  Route<dynamic> Function(RouteSettings) get onUnknownRoute => null;

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
  final BuildServices buildServices;
  final Function() onloading;
  final Function() onloaded;
  final Map<String, dynamic> props;
  final AppKeyPair appKeyPair;
  final ILocalPrincipal localPrincipal;
  final AppDecorator appDecorator;
  final Onreconnect peerOnreconnect;
  final Onopen peerOnopen;
  final Onclose peerOnclose;

  final String messageNetwork;


  AppCreator({
    this.title,
    this.messageNetwork='interactive-center',
    this.entrypoint,
    this.buildSystem,
    this.buildPortals,
    this.appDecorator,
    this.onloading,
    this.onloaded,
    this.props,
    this.buildServices,
    this.appKeyPair,
    this.localPrincipal,
    this.peerOnreconnect,
    this.peerOnclose,
    this.peerOnopen,
  });
}

class DefaultAppSurface implements IAppSurface, IServiceProvider {
  String _title;
  String _entrypoint;
  String _currentScene;
  Map<String, IScene> _scenes = {};
  ShareServiceContainer _shareServiceContainer;
  AppDecorator _appDecorator;
  ISharedPreferences _sharedPreferences;
  ExternalServiceContainer _extenalServiceProvider;
  Map<String, dynamic> _props = {};

  IScene get current => _scenes[_currentScene];

  @override
  AppDecorator get appDecorator {
    return _appDecorator;
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
  OnGenerateTitle get onGenerateTitle {
    return null;
  }

  @override
  OnGenerateRoute get onGenerateRoute {
    return (settings) {
      String path = settings?.name;
      if (StringUtil.isEmpty(path)) {
        return null;
      }
      if (!current.containsPage(path)) {
        return null;
      }
      Page page = current.getPage(path);
      if (page.buildRoute == null) {
        return null;
      }
      return page.buildRoute(settings, page, _shareServiceContainer);
    };
  }

  @override
  Route Function(RouteSettings) get onUnknownRoute {
    return (settings) {
      return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext buildContext) {
          return ErrorPage404();
        },
      );
    };
  }

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
    if (name.startsWith('@.prop.')) {
      return _props[name];
    }
    return this._extenalServiceProvider?.getService(name);
  }

  _fillDevice(AppKeyPair appKeyPair) async {
    var device = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var android = await deviceInfo.androidInfo;
      device =
          '${android.device}${android.type}${android.model}${android.product}';
    } else if (Platform.isIOS) {
      var ios = await deviceInfo.iosInfo;
      device = '${ios.name}${ios.model}${ios.identifierForVendor}';
    }
    device = MD5Util.generateMd5(device);
    appKeyPair.device = device;
  }

  @override
  Future<void> load([AppCreator creator]) async {
    _title = creator.title;
    _entrypoint = creator.entrypoint;
    _appDecorator = creator.appDecorator;
    if (creator.props != null) {
      _props.addAll(creator.props);
    }

    BaseOptions options = BaseOptions(headers: {
      'Content-Type': "text/html; charset=utf-8",
    });
    var _dio = Dio(options); //使用base配置可以通

    _shareServiceContainer = ShareServiceContainer(this);
    _sharedPreferences = new DefaultSharedPreferences();
    await _sharedPreferences.init(_shareServiceContainer);

    var principal = UserPrincipal(manager: creator.localPrincipal);

    _fillDevice(creator.appKeyPair);

    ILogicNetworkContainer _logicNetworkContainer =
        DefaultLogicNetworkContainer();
    IPeerManager _peerManager = DefaultPeerManager();
    IPump _pump = DefaultPump();

    _shareServiceContainer.addServices(<String, dynamic>{
      '@.principal.local': creator.localPrincipal,
      '@.principal': principal,
      '@.appKeyPair': creator.appKeyPair,
      '@.http': _dio,
      '@.peer.manager': _peerManager,
      '@.pump': _pump,
      '@.logic.network.container': _logicNetworkContainer,
      '@.app.creator': creator,
    });

    await _buildExternalServices(creator.buildServices);
    await _buildSystem(creator.buildSystem);
    await _buildPortals(creator.buildPortals);
  }

  Future<void> _buildExternalServices(BuildServices buildServices) async {
    if (buildServices == null) {
      return;
    }
    _extenalServiceProvider = ExternalServiceContainer(null);
    var services = await buildServices(_shareServiceContainer);
    if (services == null) {
      services = <String, dynamic>{};
    }
    _extenalServiceProvider.addServices(services);
    _extenalServiceProvider.initServices(services);
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

    var system = buildSystem(_shareServiceContainer);
    var pages = system?.buildPages(_shareServiceContainer);
    var themeStyles = system?.buildThemes(_shareServiceContainer);
    var shareServices = system.builderShareServices == null
        ? <String, dynamic>{}
        : await system.builderShareServices(_shareServiceContainer);
    var sceneServices = await system.builderSceneServices == null
        ? <String, dynamic>{}
        : await system.builderSceneServices(_shareServiceContainer);

    _shareServiceContainer.addServices(shareServices);
    _shareServiceContainer.initServices(shareServices);
    _shareServiceContainer.readyServices();

    await scene.init(
      defaultTheme: system.defaultTheme,
      site: _shareServiceContainer,
      desklets: <Desklet>[],
      pages: pages,
      services: sceneServices == null ? <String, dynamic>{} : sceneServices,
      themeStyles: themeStyles,
    );
  }

  Future<void> _buildPortals(BuildPortals buildPortals) async {
    if (buildPortals == null) {
      return;
    }
    List<BuildPortal> portals = buildPortals(_shareServiceContainer);
    for (var buildPortal in portals) {
      var portal = buildPortal(_shareServiceContainer);

      IScene scene = DefaultScene(
        name: portal.id,
      );
      _scenes[portal.id] = scene;

      var pages = portal.buildPages == null
          ? <Page>[]
          : portal.buildPages(_shareServiceContainer);
      var desklets = portal.buildDesklets == null
          ? <Desklet>[]
          : portal.buildDesklets(_shareServiceContainer);
      var themeStyles = portal.buildThemes == null
          ? <ThemeStyle>[]
          : portal.buildThemes(_shareServiceContainer);
      var shareServices = portal.builderShareServices == null
          ? <String, dynamic>{}
          : await portal.builderShareServices(_shareServiceContainer);
      var sceneServices = portal.builderSceneServices == null
          ? <String, dynamic>{}
          : await portal.builderSceneServices(_shareServiceContainer);

      _shareServiceContainer.addServices(shareServices);
      _shareServiceContainer.initServices(shareServices);
      _shareServiceContainer.readyServices();

      await scene.init(
        defaultTheme: portal.defaultTheme,
        site: _shareServiceContainer,
        desklets: desklets,
        pages: pages,
        themeStyles: themeStyles,
        services: sceneServices == null ? <String, dynamic>{} : sceneServices,
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
