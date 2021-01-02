import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class ChannelMessageOR {
  String id;
  String channel;
  String creator;
  String content;
  LatLng location;
  int ctime;
  String purchaseSn;

  ChannelMessageOR({
    this.id,
    this.channel,
    this.creator,
    this.content,
    this.location,
    this.ctime,
    this.purchaseSn,
  });

  ChannelMessageOR.parse(obj) {
    this.id = obj['id'];
    this.channel = obj['channel'];
    this.creator = obj['creator'];
    this.content = obj['content'];
    this.location =
        obj['location'] == null ? null : LatLng.fromJson(obj['location']);
    this.ctime = obj['ctime'];
    this.purchaseSn = obj['purchaseSn'];
  }

  InsiteMessage toInsiteMessage(upstreamPerson, sandbox) {
    var str;
    if (location != null) {
      str = jsonEncode(location.toJson());
    }
    return InsiteMessage(
        '${MD5Util.MD5(Uuid().v1())}',
        id,
        upstreamPerson,
        channel,
        null,
        null,
        creator,
        ctime,
        null,
        content,
        purchaseSn,
        str,
        null,
        sandbox);
  }
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

  MediaSrc toMediaSrc() {
    return MediaSrc(
        sourceType: 'channel',
        msgid: docid,
        text: text,
        type: type,
        id: id,
        leading: leading,
        src: src);
  }
}

class ChatRoomOR {
  String room;
  String title;
  String creator;
  String leading;
  String microsite;
  String background;
  int flag; //0为可用；1为已被删除
  bool isForegroundWhite;
  int ctime;

  ChatRoomOR({
    this.room,
    this.title,
    this.creator,
    this.leading,
    this.microsite,
    this.background,
    this.flag,
    this.isForegroundWhite,
    this.ctime,
  });

  ChatRoomOR.parse(obj) {
    this.room = obj['room'];
    this.title = obj['title'];
    this.creator = obj['creator'];
    this.leading = obj['leading'];
    this.microsite = obj['microsite'];
    this.background = obj['background'];
    this.flag = obj['flag'];
    this.isForegroundWhite = obj['isForegroundWhite'] ?? false;
    this.ctime = obj['ctime'];
  }

  ChatRoom toLocal(String sandbox) {
    return ChatRoom(room, title, leading, creator, ctime, ctime, null, null,
        isForegroundWhite ? 'true' : 'false', 'false', microsite, sandbox);
  }
}

class RoomMemberOR {
  String room;
  String person;
  String actor; //创建者(creator)管理员(admin)，客服(servicer)，普通成员(user)
  String nickName;
  int flag; //0为可用；1为已被删除
  bool isShowNick;
  int atime;

  RoomMemberOR(
      {this.room,
      this.person,
      this.actor,
      this.nickName,
      this.flag,
      this.isShowNick,
      this.atime}); //加入时间
  RoomMemberOR.parse(obj) {
    this.room = obj['room'];
    this.person = obj['person'];
    this.actor = obj['actor'];
    this.nickName = obj['nickName'];
    this.flag = obj['flag'];
    this.isShowNick = obj['isShowNick'] ?? false;
    this.atime = obj['atime'];
  }

  RoomMember toLocal(String sandbox) {
    return RoomMember(room, person, nickName, isShowNick ? 'true' : 'false',
        null, 'person', atime, sandbox);
  }
}

mixin IChannelRemote {
  Future<void> createChannel(
    String channel, {
    @required String title,
    @required String leading,
    @required String upstreamPerson,

    ///only_select, all_excep
    @required String outPersonSelector,
    @required bool outGeoSelector,
  });

  Future<void> removeChannel(String channel);

  Future<List<Channel>> pageChannel({int limit = 20, int offset = 0});

  Future<void> updateLeading(String channelid, String remotePath) {}

  Future<void> removeOutputPerson(String person, String channelid) {}

  Future<Function> removeOutputPersonOfCreator(String creator, String channel);

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

  Future<List<ChannelInputPerson>> getAllInputPerson(
      String channel, int atime) {}

  Future<List<ChannelOutputPerson>> getAllOutputPerson(
      String channel, int atime) {}

  Future<List<ChannelMessageOR>> pageDocument(
      String official, String id, int limit, int offset) {}

  Future<void> addOutputPersonBy(
      String channelCreator, String person, String channel) {}
}
mixin IChatRoomRemote {
  Future<void> removeMember(String code, official) {}

  Future<void> removeMemberOnlyByCreator(String code, member);

  Future<void> createRoom(ChatRoom chatRoom) {}

  Future<void> addMember(RoomMember roomMember) {}

  Future<void> addMemberToOwner(String chatroomOwner, RoomMember roomMember) {}

  Future<void> removeChatRoom(String code) {}

  Future<void> pushMessage(String creator, ChatMessage message) {}

  Future<ChatRoomOR> getRoom(String creator, String room) {}

  Future<List<RoomMemberOR>> pageRoomMember(
      String creator, String room, int i, int j) {}

  Future<void> updateRoomLeading(String roomid, String file) {}

  Future<void> updateRoomTitle(String room, String title) {}

  Future<void> updateRoomNickname(
      String creator, String room, String nickName) {}

  Future<RoomMemberOR> getMember(
    String creator,
    String room,
  ) {}

  Future<void> switchNick(String creator, String room, bool showNick) {}

  Future<RoomMemberOR> getMemberOfPerson(
      String creator, String room, String member) {}

  Future<void> updateRoomBackground(String room, path) {}

  Future<String> downloadBackground(String background) {}

  Future<List<ChatRoomNotice>> pageNotice(
      ChatRoom chatRoom, int limit, int offset) {}

  Future<void> publishNotice(ChatRoom chatRoom, String text) {}

  Future<ChatRoomNotice> getNewestNotice(ChatRoom chatRoom) {}

  Future<void> updateRoomForeground(String id, bool isForegroundWhite) {}

  Future<List<String>> listFlagRoomMember(String creator, String id) {}


  Future<int> totalMember(String roomCreator,String room) {}

}
