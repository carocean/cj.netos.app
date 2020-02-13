import 'package:framework/core_lib/_scene.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_utimate.dart';

mixin ISharedPreferences {
  Future<ISharedPreferences> init(IServiceProvider site);

  Future<bool> setStringList(String key, List<String> value,
      {StoreScope scope=StoreScope.personOnScene});

  Future<bool> setInt(String key, int value,
      {StoreScope scope=StoreScope.personOnScene});

  Future<bool> setDouble(String key, double value,
      {StoreScope scope=StoreScope.personOnScene});

  Future<bool> setBool(String key, bool value,
      {StoreScope scope=StoreScope.personOnScene});

  Future<bool> setString(String key, String value,
      {StoreScope scope=StoreScope.personOnScene});

  bool containsKey(String key, {StoreScope scope=StoreScope.personOnScene});

  String getString(String key, {StoreScope scope=StoreScope.personOnScene});

  dynamic get(String key, {StoreScope scope=StoreScope.personOnScene});

  Future<bool> remove(String key,
      {StoreScope scope=StoreScope.personOnScene});

  Future<bool> clear();

  String toString();

  Future<void> reload();

  Set<String> getKeys({StoreScope scope=StoreScope.personOnScene});
}
enum StoreScope{
  ///所有场景和用户下共享
  global,
  ///当前场景和场景下所有用户共享
  scene,
  ///仅当前场景下的当前用户可见
  personOnScene,
  ///当前用户的存储在所有场景下共享
  personShareScene,
}
class DefaultSharedPreferences implements ISharedPreferences {
  SharedPreferences _sharedPreferences;
  IServiceProvider _site;

  @override
  Future<ISharedPreferences> init(IServiceProvider site) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    this._site = site;
    return this;
  }

//当多用户切换时以/框架/用户号/当前登录账号/作为key持久化前缀，如: /gbera/00200202002/cj/，用于持久账号私有信息，而以/Shared/ 作为多用户的共享目录
  String _getStoreKey(String key,
      {StoreScope scope=StoreScope.personOnScene}) {

    IScene scene = _site.getService('@.scene.current');
    var _principal = scene.principal;
    var _key='';
    switch(scope) {
      case StoreScope.global:
        _key='/$key';
        break;
      case StoreScope.scene:
        _key='/${scene.name}/$key';
        break;
      case StoreScope.personOnScene:
        _key='/${scene.name}/${_principal.person}/$key';
        break;
      case StoreScope.personShareScene:
        _key='/${scene.name}/$key';
        break;
    }
    return _key;
  }

  @override
  Future<bool> setStringList(String key, List<String> value,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.setStringList(
        _getStoreKey(key,
           scope: scope),
        value);
  }

  @override
  Future<bool> setInt(String key, int value,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.setInt(
        _getStoreKey(key,
            scope: scope),
        value);
  }

  @override
  Future<bool> setDouble(String key, double value,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.setDouble(
        _getStoreKey(key,
            scope: scope),
        value);
  }

  @override
  Future<bool> setBool(String key, bool value,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.setBool(
        _getStoreKey(key,
            scope: scope),
        value);
  }

  @override
  Future<bool> setString(String key, String value,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.setString(
        _getStoreKey(key,
            scope: scope),
        value);
  }

  @override
  List<String> getStringList(String key,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.getStringList(_getStoreKey(key,
        scope: scope));
  }

  @override
  int getInt(String key, {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.getInt(_getStoreKey(key,
        scope: scope));
  }

  @override
  double getDouble(String key,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.getDouble(_getStoreKey(key,
        scope: scope));
  }

  @override
  bool getBool(String key, {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.getBool(_getStoreKey(key,
        scope: scope));
  }

  @override
  bool containsKey(String key,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.containsKey(_getStoreKey(key,
        scope: scope));
  }

  @override
  String getString(String key,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.getString(_getStoreKey(key,
        scope: scope));
  }

  @override
  dynamic get(String key, {StoreScope scope=StoreScope.personOnScene}) {
    _sharedPreferences.get(_getStoreKey(key,
        scope: scope));
  }

  @override
  Future<bool> remove(String key,
      {StoreScope scope=StoreScope.personOnScene}) {
    return _sharedPreferences.remove(_getStoreKey(key,
        scope: scope));
  }

  @override
  Future<bool> clear() {
    return _sharedPreferences.clear();
  }

  @override
  String toString() {
    return _sharedPreferences.toString();
  }

  @override
  Future<void> reload() {
    return _sharedPreferences.reload();
  }

  @override
  Set<String> getKeys({StoreScope scope=StoreScope.personOnScene}) {
    String prefix = _getStoreKey(null,
        scope: scope);
    Set<String> keys = _sharedPreferences.getKeys();
    Set<String> set = Set();
    for (String k in keys) {
      if (k.startsWith(prefix)) {
        set.add(k);
      }
    }
    return set;
  }
}
