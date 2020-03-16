import 'package:flutter/cupertino.dart';
import 'package:netos_app/system/local/entities.dart';

mixin IChannelRemote {
  Future<void> createChannel(
    String channel, {
    @required String title,
    @required String leading,

    ///only_select, all_excep
    @required String outPersonSelector,
    @required bool outGeoSelector,
  });

  Future<void> removeChannel(String channel);

  Future<List<Channel>> pageChannel({int limit = 20, int offset = 0});

  Future<void> updateLeading(String channelid, String remotePath) {}

  Future<void> removeOutputPerson(String person, String channelid) {}

  Future<void> removeInputPerson(String person, String channelid) {}

  Future<void> addInputPerson(String person, String channel) {}

  Future<void> updateOutGeoSelector(String channelid, String v) {}

  Future<void> updateOutPersonSelector(String channelid, selector) {}

  Future<void> addOutputPerson(String person, String channel) {}

  Future<Channel> findChannelOfPerson(String channel, String person) {}

  Future<List<Channel>> fetchChannelsOfPerson(String official) {}

  Future<List<Person>> pageOutputPersonOf(
      String channel, String person, int limit, int offset) {}

  Future<List<Person>> pageInputPersonOf(
      String channel, String person, int limit, int offset) {}
}
