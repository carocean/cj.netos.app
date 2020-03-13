import 'package:flutter/material.dart';

import '_utimate.dart';

class _ServiceContainer implements IServiceProvider {
  IServiceProvider parent;
  Map<String, dynamic> _services = {};
  _ServiceContainer(this.parent);

  @override
  getService(String name) {
    if (_services.containsKey(name)) {
      return _services[name];
    }
    return parent?.getService(name);
  }

  Future<void> initServices(Map<String, dynamic> services) async{
    if (services == null) {
      return;
    }
    for (var key in services.keys) {
      var service = services[key];
      if (service is IServiceBuilder) {
         await service.builder(this);
      }
    }
  }

  void addServices(Map<String, dynamic> services) {
    if (services == null) {
      return;
    }
    for (var key in services.keys) {
      var service = services[key];
      _addService(key, service);
    }
  }

  void _addService(String name, service) {
    if (_services.containsKey(name)) {
      throw new FlutterError('已存在服务:$name');
    }
    _services[name] = service;
  }
}

class ExternalServiceContainer extends _ServiceContainer
    implements IServiceProvider {
  ExternalServiceContainer(IServiceProvider parent) : super(parent);
}

class ShareServiceContainer extends _ServiceContainer
    implements IServiceProvider {
  ShareServiceContainer(IServiceProvider parent) : super(parent);
}

class SceneServiceContainer extends _ServiceContainer
    implements IServiceProvider {
  SceneServiceContainer(IServiceProvider parent) : super(parent);
}
