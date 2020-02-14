import 'package:framework/core_lib/_scene.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_utimate.dart';

mixin ISharedPreferences {
  Future<ISharedPreferences> init(IServiceProvider site);

  Future<bool> setStringList(String key, List<String> value,
      {String scene, String person});

  Future<bool> setInt(String key, int value, {String scene, String person});

  Future<bool> setDouble(String key, double value,
      {String scene, String person});

  Future<bool> setBool(String key, bool value, {String scene, String person});

  Future<bool> setString(String key, String value,
      {String scene, String person});

  bool containsKey(String key, {String scene, String person});

  String getString(String key, {String scene, String person});

  dynamic get(String key, {String scene, String person});

  Future<bool> remove(String key, {String scene, String person});

  Future<bool> clear();

  String toString();

  Future<void> reload();

  Set<String> getKeys({String scene, String person});
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

  String _getStoreKey(String key, {String scene, String person}) {
   String _key='/';
   if(!StringUtil.isEmpty(scene)) {
     _key='$_key/$scene';
   }
   if(!StringUtil.isEmpty(person)) {
     _key='$_key/$person';
   }
   if(_key.endsWith('/')) {
     _key='$_key$key';
   }else{
     _key='$_key/$key';
   }
    return _key;
  }

  @override
  Future<bool> setStringList(String key, List<String> value,
      {String scene, String person}) {
    return _sharedPreferences.setStringList(
        _getStoreKey(key, scene: scene,person: person), value);
  }

  @override
  Future<bool> setInt(String key, int value, {String scene, String person}) {
    return _sharedPreferences.setInt(_getStoreKey(key, scene: scene,person: person), value);
  }

  @override
  Future<bool> setDouble(String key, double value,
      {String scene, String person}) {
    return _sharedPreferences.setDouble(_getStoreKey(key, scene: scene,person: person), value);
  }

  @override
  Future<bool> setBool(String key, bool value, {String scene, String person}) {
    return _sharedPreferences.setBool(_getStoreKey(key, scene: scene,person: person), value);
  }

  @override
  Future<bool> setString(String key, String value,
      {String scene, String person}) {
    return _sharedPreferences.setString(_getStoreKey(key, scene: scene,person: person), value);
  }

  @override
  List<String> getStringList(String key, {String scene, String person}) {
    return _sharedPreferences.getStringList(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  int getInt(String key, {String scene, String person}) {
    return _sharedPreferences.getInt(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  double getDouble(String key, {String scene, String person}) {
    return _sharedPreferences.getDouble(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  bool getBool(String key, {String scene, String person}) {
    return _sharedPreferences.getBool(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  bool containsKey(String key, {String scene, String person}) {
    return _sharedPreferences.containsKey(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  String getString(String key, {String scene, String person}) {
    return _sharedPreferences.getString(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  dynamic get(String key, {String scene, String person}) {
    _sharedPreferences.get(_getStoreKey(key, scene: scene,person: person));
  }

  @override
  Future<bool> remove(String key, {String scene, String person}) {
    return _sharedPreferences.remove(_getStoreKey(key, scene: scene,person: person));
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
  Set<String> getKeys({String scene, String person}) {
    String prefix = _getStoreKey(null, scene: scene,person: person);
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
