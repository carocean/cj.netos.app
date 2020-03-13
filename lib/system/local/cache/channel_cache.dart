import 'dart:convert';
import 'dart:io';

import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

mixin IChannelCache {
  Future<void> cache(Channel channel);

  Future<Channel> get(String channel);
}

class ChannelCache implements IChannelCache, IServiceBuilder {
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
    _db = ObjectDB('$cacheDir/channels.db');
    await _db.open();
  }

  @override
  Future<void> cache(Channel channel) async {
    var json = jsonEncode(channel);
    await _db.insert(jsonDecode(json));
  }

  @override
  Future<Channel> get(String channel) async {
    var query = {'id': channel};
    var obj = await _db.first(query);
    if(obj==null) {
      return null;
    }
    return Channel(
      obj['id'],
      obj['name'],
      obj['owner'],
      obj['leading'],
      obj['site'],
      obj['ctime'],
      obj['sandbox'],
    );
  }
}
