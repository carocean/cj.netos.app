import 'dart:convert';
import 'dart:io';

import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

mixin IPersonCache {
  Future<void> cache(Person person);

  Future<Person> get(String person);
}

class PersonCache implements IPersonCache, IServiceBuilder {
  ObjectDB _db;

  @override
  builder(IServiceProvider site) async {
    var dir = await getApplicationDocumentsDirectory();
    var sysDir = '${dir.path}/system';
    Directory sd = Directory(sysDir);
    if (!sd.existsSync()) {
      sd.createSync();
    }
    var cacheDir = '${sysDir}/cache';
    var cd = Directory(cacheDir);
    if (!cd.existsSync()) {
      cd.createSync();
    }
    _db = ObjectDB('$cacheDir/persons.db');
    await _db.open();
  }

  @override
  Future<void> cache(Person person) async {
    var map = person.toMap();
    await _db.insert(map);
  }

  @override
  Future<Person> get(String person) async{
    var query={'official':person};
    var obj=await _db.first(query);
    if(obj==null) {
      return null;
    }
    return Person(
      obj['official'],
      obj['uid'],
      obj['accountCode'],
      obj['appid'],
      obj['avatar'],
      obj['rights'],
      obj['nickName'],
      obj['signature'],
      obj['pyname'],
      obj['sandbox'],
    );
  }
}
