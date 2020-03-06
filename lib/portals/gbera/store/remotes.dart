import 'package:flutter/cupertino.dart';
import 'package:netos_app/system/local/entities.dart';

mixin IChannelRemote {
  Future<void> createChannel(
    String channel,
    String origin, {
    @required String title,
    @required String leading,

    ///only_select, all_excep
    @required String outPersonSelector,
    @required bool outGeoSelector,
  });

  Future<void> removeChannel(String channel);

  Future<List<Channel>>pageChannel({int limit = 20, int offset = 0});
}
