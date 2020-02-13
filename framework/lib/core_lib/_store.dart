import 'package:framework/core_lib/_utimate.dart';

mixin IStore {
  Map<String, dynamic> get services;

  Future<dynamic> Function() get loadDatabase;

  Future<void> init(IServiceProvider site);
}
mixin IDBService{
  Future<void> init(IServiceProvider site);
}
class PortalStore implements IStore {
  Map<String, dynamic> services;
  Future<dynamic> Function() loadDatabase;

  PortalStore({this.services, this.loadDatabase});

  @override
  Future<void> init(IServiceProvider site) {
    // TODO: implement init
    return null;
  }
}

class SystemStore implements IStore {
  Map<String, dynamic> services;
  Future<dynamic> Function() loadDatabase;

  SystemStore({this.services, this.loadDatabase});

  @override
  Future<void> init(IServiceProvider site) {
    // TODO: implement init
    return null;
  }
}
