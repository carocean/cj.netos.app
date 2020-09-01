import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:netos_app/system/local/entities.dart';

class ChannelMessageOR {
  String id;
  String channel;
  String creator;
  String content;
  LatLng location;
  int ctime;
  double wy;

  ChannelMessageOR({
    this.id,
    this.channel,
    this.creator,
    this.content,
    this.location,
    this.ctime,
    this.wy,
  });
}

class ChannelMediaOR {
  String id;
  String docid;
  String type;
  String src;
  String text;
  String leading;
  String channel;
  int ctime;

  ChannelMediaOR({
    this.id,
    this.docid,
    this.type,
    this.src,
    this.text,
    this.leading,
    this.channel,
    this.ctime,
  });
}

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

  Future<void> removeOutputPersonOfCreator(String creator, String channel) {}

  Future<void> removeInputPerson(String person, String channelid) {}

  Future<void> addInputPerson(String person, String channel) {}

  Future<void> addOutputPersonOfCreator(String creator, String channel) {}

  Future<void> updateOutGeoSelector(String channelid, String v) {}

  Future<void> updateOutPersonSelector(String channelid, selector) {}

  Future<void> addOutputPerson(String person, String channel) {}

  Future<Channel> findChannelOfPerson(String channel, String person) {}

  Future<List<Channel>> fetchChannelsOfPerson(String official) {}

  Future<List<Person>> pageOutputPersonOf(
      String channel, String person, int limit, int offset) {}

  Future<List<Person>> pageInputPersonOf(
      String channel, String person, int limit, int offset) {}

  Future<void> unlike(String msgid, String channel, String creator) {}

  Future<void> like(String msgid, String channel, String creator);

  Future<void> addComment(
      String msgid, String channel, String creator, String text, String id) {}

  Future<void> removeComment(
      String msgid, String channel, String creator, String commentid) {}

  Future<void> pageLikeTask(
      String docCreator, String docid, String channel, int limit, int offset);

  Future<void> pageCommentTask(
      String docCreator, String docid, String channel, int limit, int offset);

  Future<void> listMediaTask(String docCreator, String docid, String channel);

  Future<void> pageActivityTask(
      ChannelMessage channelMessage, int limit, int offset);

  void listenLikeTaskCallback(Function(List likes) callback);

  void listenCommentTaskCallback(Function(List comments) callback);

  void listenMediaTaskCallback(Function(List medias) callback);

  void listenActivityTaskCallback(Function(List activities) callback);

  Future<void> setCurrentActivityTask(
      {String creator,
      String docid,
      String channel,
      String action,
      String attach}) {}

  Future<ChannelMessageOR> getMessage(String person, String msgid) {}

  Future<List<ChannelMediaOR>> listExtraMedia(
      String docid, String creator, String channel) {}
}
mixin IChatRoomRemote {
  Future<void> removeMember(String code, official) {}

  Future<void> createRoom(ChatRoom chatRoom) {}

  Future<void> addMember(RoomMember roomMember) {}

  Future<void> removeChatRoom(String code) {}

  Future<void> pushMessage(String creator, ChatMessage message) {}

  Future<ChatRoom> getRoom(String creator, String room) {}

  Future<List<RoomMember>> pageRoomMember(
      String creator, String room, int i, int j) {}

  Future<void> updateRoomLeading(String roomid, String file) {}

  Future<void> updateRoomTitle(String room, String title) {}

  Future<void> updateRoomNickname(
      String creator, String room, String nickName) {}

  Future<RoomMember> getMember(
    String creator,
    String room,
  ) {}

  Future<void> switchNick(String creator, String room, bool showNick) {}

  Future<RoomMember> getMemberOfPerson(
      String creator, String room, String member) {}

  Future<void> updateRoomBackground(String room, path) {}

  Future<String> downloadBackground(String background) {}

  Future<List<ChatRoomNotice>> pageNotice(
      ChatRoom chatRoom, int limit, int offset) {}

  Future<void> publishNotice(ChatRoom chatRoom, String text) {}

  Future<ChatRoomNotice> getNewestNotice(ChatRoom chatRoom) {}

  Future<void> updateRoomForeground(String id, bool isForegroundWhite) {}
}
