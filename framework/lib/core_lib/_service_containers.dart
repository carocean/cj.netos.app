import 'package:flutter/material.dart';

import '_utimate.dart';

class _ServiceContainer implements IServiceProvider {
  IServiceProvider parent;
  Map<String, dynamic> _services = {};
  Map<OnReadyCallback, bool> _onReadeys = {}; //value表示是否已经ready过
  _ServiceContainer(this.parent);

  @override
  getService(String name) {
    if (_services.containsKey(name)) {
      return _services[name];
    }
    return parent?.getService(name);
  }

  void initServices(Map<String, dynamic> services) {
    if (services == null) {
      return;
    }
    for (var key in services.keys) {
      var service = services[key];
      if (service is IServiceBuilder) {
        var onReadyCallback = service.builder(this);
        if (onReadyCallback != null) {
          _onReadeys[onReadyCallback] = false;
        }
      }
    }
  }

  Future<void> readyServices() async {
    for (var ready in _onReadeys.keys) {
      bool isReady = _onReadeys[ready];
      if (!isReady) {
        await ready();
        _onReadeys[ready] = true;
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
