import 'dart:convert';
import 'dart:io';

import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

mixin IChannelCache {
  Future<void> cache(Channel channel);

  Future<CachedChannel> get(String channel);

  Future<void> updateRights(String channel, String rights) {}

  Future<List<CachedChannel>> listAll(String official) {}

  Future<void> remove(channel) {}
}

class ChannelCache implements IChannelCache, IServiceBuilder {
  ObjectDB _db;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  builder(IServiceProvider site) async {
    this.site = site;
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
  Future<Function> updateRights(String channel, String rights) {
    _db.update(
        {'id': channel, 'sandbox': principal.person}, {'rights': rights});
  }

  @override
  Future<void> cache(Channel channel) async {
    if (await get(channel.id) != null) {
      return;
    }
    var map = channel.toMap();
    await _db.insert(map);
  }

  @override
  Future<List<CachedChannel>> listAll(String official) async {
    var query = {'owner': official, 'sandbox': principal.person};
    var channels = await _db.find(query);
    var list = <CachedChannel>[];
    for (var obj in channels) {
      list.add(CachedChannel(
        id: obj['id'],
        name: obj['name'],
        owner: obj['owner'],
        leading: obj['leading'],
        site: obj['site'],
        ctime: obj['ctime'],
        sandbox: obj['sandbox'],
        rights: obj['rights'],
      ));
    }
    return list;
  }

  @override
  Future<Function> remove(channel) async {
    var query = {'id': channel, 'sandbox': principal.person};
    await _db.remove(query);
  }

  @override
  Future<CachedChannel> get(String channel) async {
    var query = {'id': channel, 'sandbox': principal.person};
    var obj = await _db.first(query);
    if (obj == null) {
      return null;
    }
    return CachedChannel(
      id: obj['id'],
      name: obj['name'],
      owner: obj['owner'],
      leading: obj['leading'],
      site: obj['site'],
      ctime: obj['ctime'],
      sandbox: obj['sandbox'],
      rights: obj['rights'],
    );
  }
}
