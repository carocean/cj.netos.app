import 'dart:io';

import 'package:buddy_push/buddy_push.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_connection.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_pump.dart';
import 'package:framework/core_lib/_scene.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_theme.dart';

import '_app_keypair.dart';
import '_device.dart';
import '_exceptions.dart';
import '_page.dart';
import '_device_manager.dart';
import '_portal.dart';
import '_principal.dart';
import '_remote_ports.dart';
import '_service_containers.dart';
import '_system.dart';
import '_utimate.dart';

typedef BuildRoute = ModalRoute Function(
    RouteSettings settings, LogicPage page, IServiceProvider site);
typedef AppDecorator = Widget Function(
    BuildContext, Widget, IServiceProvider site);
typedef OnGenerateRoute = Route<dynamic> Function(RouteSettings);
typedef OnGenerateTitle = String Function(BuildContext);
typedef OnMessageCount = void Function(int count);

mixin IAppSurface {
  IScene get current => null;

  TransitionBuilder get appDecorator => null;

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
  final Onreconnect deviceOnreconnect;
  final Onopen deviceOnopen;
  final Onclose deviceOnclose;
  final Onevent deviceOnevent;
  final Online deviceOnline;
  final Offline deviceOffline;
  final String messageNetwork;

  final OnMessageCount deviceOnmessageCount;

  AppCreator({
    this.title,
    this.messageNetwork = 'interactive-center',
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
    this.deviceOnreconnect,
    this.deviceOnclose,
    this.deviceOnopen,
    this.deviceOnevent,
    this.deviceOnline,
    this.deviceOffline,
    this.deviceOnmessageCount,
  });
}

class DefaultAppSurface implements IAppSurface, IServiceProvider {
  String _title;
  String _entrypoint;
  String _currentScene;
  Map<String, IScene> _scenes = {};
  ShareServiceContainer _shareServiceContainer;
  TransitionBuilder _appDecorator;
  ISharedPreferences _sharedPreferences;
  ExternalServiceContainer _extenalServiceProvider;
  Map<String, dynamic> _props = {};

  IScene get current => _scenes[_currentScene];

  @override
  TransitionBuilder get appDecorator {
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
      LogicPage page = current.getPage(path);
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

  Future<void> _fillDevice(AppKeyPair appKeyPair) async {
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
    device = MD5Util.MD5(device);
    appKeyPair.device = device;
  }

  @override
  Future<void> load([AppCreator creator]) async {
    _title = creator.title;
    _entrypoint = creator.entrypoint;
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

    if (creator.appDecorator != null) {
      _appDecorator = (ctx, widget) {
        return creator.appDecorator(ctx, widget, _shareServiceContainer);
      };
    }
    var principal = UserPrincipal(manager: creator.localPrincipal);

    await _fillDevice(creator.appKeyPair);

    IDeviceManager _deviceManager = DefaultDeviceManager();
    IPump _pump = DefaultPump();

    _shareServiceContainer.addServices(<String, dynamic>{
      '@.principal.local': creator.localPrincipal,
      '@.principal': principal,
      '@.appKeyPair': creator.appKeyPair,
      '@.http': _dio,
      '@.device.manager': _deviceManager,
      '@.pump': _pump,
      '@.app.creator': creator,
      '@.remote.ports': DefaultRemotePorts(_shareServiceContainer, _dio),
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
    await _extenalServiceProvider.initServices(services);
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
    await _shareServiceContainer.initServices(shareServices);

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
          ? <LogicPage>[]
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
      await _shareServiceContainer.initServices(shareServices);

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
