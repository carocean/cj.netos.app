import 'package:framework/framework.dart';

import '../../../system/local/entities.dart';

mixin IPersonService {
  Future<void> empty();

  Future<bool> existsPerson(official);

  Future<Person> getPerson(official,
      {

      ///如果不存在在远程获取时是否下载其头像到本地
      bool isDownloadAvatar = false});

  Future<Person> fetchPerson(official, {bool isDownloadAvatar = false});

  Future<void> addPerson(Person person);

  Future<List<Person>> getAllPerson();

  Future<List<Person>> pagePerson(int limit, int offset);

  Future<int> count();

  Future<List<Person>> pagePersonWithout(
      List<String> personList, int persons_limit, int persons_offset);

  Future<List<Person>> pagePersonWith(
      List<String> persons, int limit, int offset) {}

  Future<List<Person>> listPersonWith(List<String> personList);

  Future<Person> getPersonByUID(String uid);

  Future<List<Person>> pagePersonLikeName(String query, int limit, int offset);

  Future<void> removePerson(String person) {}

  Future<void> updateRights(String official, param1) {}
}
mixin IChannelService {
  ///地圈管道标识
  static const GEO_CIRCUIT_CHANNEL_CODE =
      '59FC6F04-5C54-4C6F-80EC-BF2355856841';

  Future<void> initSystemChannel(UserPrincipal user);

  bool isSystemChannel(channelid);

  String getSystemChannel(String channelid);

  Iterable<String> listSystemChannel();

  Future<void> empty();

  Future<void> emptyOfPerson(String personid);

  Future<bool> existsChannel(channelid);

  Future<void> addChannel(Channel channel);

  Future<List<Channel>> getChannelsOfPerson(String personid);

  Future<Channel> getChannel(String channelid);

  Future<Channel> findChannelOfPerson(String channel, String person) {}

  Future<Channel> fetchChannelOfPerson(String channelid, String person);

  Future<bool> existsName(String channelName, String owner);

  Future<List<Channel>> getAllChannel();

  Future<void> updateLeading(
      String localPath, String remotePath, String channelid);

  Future<void> remove(String channelid);

  Future<void> updateName(String channelid, String name);

  Future<List<Channel>> fetchChannelsOfPerson(String official) {}

  Future<List<Person>> pageOutputPersonOf(
      String channel, String person, int limit, int offset) {}

  Future<List<Person>>  pageInputPersonOf(String channel, String person, int limit, int offset) {}

}
mixin IInsiteMessageService {
  Future<void> empty();

  Future<bool> existsMessage(id);

  Future<void> addMessage(InsiteMessage message);

  Future<List<InsiteMessage>> pageMessage(int pageSize, int currPage);

  Future<List<InsiteMessage>> getAllMessage();

  Future<List<InsiteMessage>> pageMessageWhere(
      String where, int limit, int offset) {}

  Future<List<InsiteMessage>> getMessageByChannel(String channelid) {}

  Future<void> remove(String msgid) {}

  Future<void> emptyChannel(channel) {}
}

mixin IChannelMessageService {
  Future<void> empty();

  Future<bool> existsMessage(id);

  Future<void> addMessage(ChannelMessage message);

  Future<List<ChannelMessage>> pageMessage(
      int pageSize, int currPage, String onChannel);

  Future<List<ChannelMessage>> getAllMessage();

  Future<void> removeMessage(String id);

  Future<void> emptyBy(String channelid);

  Future<List<ChannelMessage>> pageMessageBy(
      int limit, int offset, String onchannel, String person);

  Future<ChannelMessageDigest> getChannelMessageDigest(String channelid) {}

  Future<void> readAllArrivedMessage(String channelid);

  Future<void> loadMessageExtraTask(ChannelMessage channelMessage) {}

  Future<void> setCurrentActivityTask(ChannelMessage channelMessage) {}

  Future<ChannelMessage>  getChannelMessage(String msgid) {}


}
mixin IChannelMediaService {
  Future<void> addMedia(Media media);

  Future<List<Media>> getMedias(String msgid);

  Future<void> remove(String id);

  Future<void> removeBy(String channelid);
}

mixin IChannelLikeService {
  Future<bool> isLiked(String msgid, String person);

  Future<void> like(LikePerson likePerson,{bool onlySaveLocal=false});

  Future<void> unlike(String msgid, String person,{bool onlySaveLocal=false});

  Future<List<LikePerson>> pageLikePersons(
      String msgid, int pageSize, int offset);

  Future<void> remove(String id);

  Future<void> removeBy(String channelid) {}

  Future<List<LikePerson>>  listLikePerson() {}

}

mixin IChannelCommentService {
  Future<List<ChannelComment>> pageComments(
      String msgid, int pageSize, int offset);

  Future<void> addComment(ChannelComment channelComment,{bool onlySaveLocal=false});

  Future<void> removeComment(String msgid,String commentid,{bool onlySaveLocal=false});

  Future<void> removeBy(String channelcode) {}
}
mixin IChannelPinService {
  Future<void> initChannelPin(String channelcode);

  Future<PinPersonsSettingsStrategy> getInputPersonSelector(String channelcode);

  Future<PinPersonsSettingsStrategy> getOutputPersonSelector(
      String channelcode);

  Future<void> setOutputPersonSelector(String channelcode,
      PinPersonsSettingsStrategy outsitePersonsSettingStrategy);

  Future<bool> getOutputGeoSelector(String channelcode);

  Future<void> setOutputGeoSelector(String channelcode, bool isSet);

  Future<void> setOutputWechatCircleSelector(String channelcode, bool isSet);

  Future<void> setOutputWechatHaoYouSelector(String channelcode, bool isSet);

  Future<void> addInputPerson(ChannelInputPerson person);

  Future<void> removeInputPerson(String person, String channelcode);

  Future<List<ChannelInputPerson>> pageInputPerson(
      String channelcode, int limit, int offset);

  Future<void> addOutputPerson(ChannelOutputPerson person);

  Future<void> removeOutputPerson(String person, String channelcode);

  Future<List<ChannelOutputPerson>> pageOutputPerson(
      String channelcode, int limit, int offset);

  Future<void> removePin(String channelcode);

  Future<List<ChannelOutputPerson>> listOutputPerson(String channelcode);

  Future<List<ChannelInputPerson>> listInputPerson(String channelcode);

  Future<void> emptyOutputPersons(String channelcode);

  Future<bool> existsInputPerson(String person, String channel) {}

  Future<void> emptyInputPersons(String channelid) {}

  Future<ChannelInputPerson> getInputPerson(String official, channel) {}

  Future<void> updateInputPersonRights(String official, String channel, String rights) {}

}
mixin IFriendService {
  Future<bool> exists(String official) {}

  Future<void> addFriend(Friend friend) {}

  Future<List<Friend>> pageFriend(int limit, int offset) {}

  Future<List<Friend>> pageFriendLikeName(
      String name, List<String> officials, int limit, int offset) {}

  Future<void> removeFriendByOfficial(String id) {}

  Future<Friend> getFriendByOfficial(String official) {}
}
mixin IChatRoomService {
  Future<void> addRoom(ChatRoom chatRoom) {}

  Future<void> addMember(RoomMember roomMember) {}

  Future<List<ChatRoom>> listChatRoom() {}

  Future<List<RoomMember>> topMember10(String code) {}

  Future<void> removeChatRoomById(String id) {}

  Future<List<Friend>> listWhoAddMember(String roomCode, String creator) {}

  Future<void> updateRoomLeading(String roomid, String file) {}

  Future<List<RoomMember>> top20Members(String code) {}
}
mixin IP2PMessageService {
  Future<void> addMessage(P2PMessage message);

  Future<List<P2PMessage>> pageMessage(
      String roomCode, int limit, int offset) {}
}
mixin IPrincipalService {
  Future<void> add(Principal principal);

  Future<List<Principal>> getAll();

  Future<void> remove(String person);

  Future<void> updateToken(
      String refreshToken, String accessToken, String person);

  Future<Principal> get(String person);

  Future<void> emptyRefreshToken(String current) {}

  Future<void> updateAvatar(String person, localAvatar, String remoteAvatar) {}

  Future<void> updateNickName(String person, nickName) {}

  Future<void> updateSignature(String person, String signature) {}
}
