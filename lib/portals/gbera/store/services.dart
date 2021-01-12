import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/desklets/chats/media_card.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/remote/persons.dart';

import '../../../system/local/entities.dart';
import 'gbera_entities.dart';

mixin ISyncPersonService {
  Future<bool> syncPerson(String official);

  Future<bool> syncChatroom(String creator, String room, String member) {}
}
mixin IPersonService {
  IPersonRemote get remote;

  Future<void> empty();

  Future<bool> existsPerson(official);

  Future<Person> getPerson(official,
      {

      ///如果不存在在远程获取时是否下载其头像到本地
      bool isDownloadAvatar = false});

  Future<Person> getPersonOnLocal(official);

  Future<Person> fetchPerson(official, {bool isDownloadAvatar = false});

  Future<void> addPerson(Person person, {bool isOnlyLocal = false});

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

  Future<List<Person>> pagePersonLikeName0(String name, int limit, int offset);

  Future<void> removePerson(String person) {}

  Future<void> updateRights(String official, param1) {}

  Future<bool> existsAccount(String accountCode) {}

  Future<void> update(Person person) {}

  Future<void> updateAvatar(official, String avatar) {}

  Future<void> updateNickName(official, String nickName) {}

  Future<void> updateSignature(official, String signature) {}

  Future<void> updatePyname(official, String pyname) {}
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

  Future<void> addChannel(Channel channel,
      {String upstreamPerson,
      String localLeading,
      String remoteLeading,
      bool isOnlyLocal = false});

  Future<List<Channel>> getChannelsOfPerson(String personid);

  Future<Channel> getChannel(String channelid);

  Future<Channel> getlastChannel() {}

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

  Future<List<Person>> pageInputPersonOf(
      String channel, String person, int limit, int offset) {}

  Future<void> updateUtime(String channel) {}
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

  Future<InsiteMessage> getMessage(docid, channel) {}
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

  Future<void> loadMessageExtraTask(
      String docCreator, String docid, String channel) {}

  Future<void> setCurrentActivityTask(
      {String creator,
      String docid,
      String channel,
      String action,
      String attach}) {}

  Future<ChannelMessage> getChannelMessage(String msgid) {}
}
mixin IChannelMediaService {
  Future<void> addMedia(Media media);

  Future<List<Media>> getMedias(String msgid);

  Future<void> remove(String id);

  Future<void> removeBy(String channelid);
}

mixin IChannelLikeService {
  Future<bool> isLiked(String msgid, String person);

  Future<void> like(LikePerson likePerson, {bool onlySaveLocal = false});

  Future<void> unlike(String msgid, String person,
      {bool onlySaveLocal = false});

  Future<List<LikePerson>> pageLikePersons(
      String msgid, int pageSize, int offset);

  Future<void> remove(String id);

  Future<void> removeBy(String channelid) {}

  Future<List<LikePerson>> listLikePerson() {}
}

mixin IChannelCommentService {
  Future<List<ChannelComment>> pageComments(
      String msgid, int pageSize, int offset);

  Future<void> addComment(ChannelComment channelComment,
      {bool onlySaveLocal = false});

  Future<void> removeComment(String msgid, String commentid,
      {bool onlySaveLocal = false});

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

  Future<Function> addOutputPersonBy(
      String channelCreator, ChannelOutputPerson person);

  Future<void> removeOutputPerson(String person, String channelcode);

  Future<List<ChannelOutputPerson>> pageOutputPerson(
      String channelcode, int limit, int offset);

  Future<void> removePin(String channelcode);

  Future<List<ChannelOutputPerson>> listOutputPerson(String channelcode);

  Future<List<ChannelInputPerson>> listInputPerson(String channelcode);

  Future<void> emptyOutputPersons(String channelcode);

  Future<bool> existsInputPerson(String person, String channel) {}

  Future<bool> existsOutputPerson(String person, String channel) {}

  Future<void> emptyInputPersons(String channelid) {}

  Future<ChannelInputPerson> getInputPerson(String official, channel) {}

  Future<ChannelInputPerson> getLastInputPerson(String channel) {}

  Future<void> updateInputPersonRights(
      String official, String channel, String rights) {}

  Future<ChannelOutputPerson> getLastOutputPerson(String channel) {}

  Future<ChannelOutputPerson> getOutputPerson(
      String official, String channel) {}

  Future<void> updateOutputPersonRights(official, String channel, String s) {}
}
mixin IFriendService {
  Future<bool> exists(String official) {}

  Future<void> addFriend(Friend friend) {}

  Future<List<Friend>> pageFriend(int limit, int offset) {}

  Future<List<Friend>> pageFriendLikeName(
      String name, List<String> officials, int limit, int offset) {}

  Future<void> removeFriendByOfficial(String id) {}

  Future<Friend> getFriendByOfficial(String official) {}

  Future<Friend> getFriend(String official, {bool isOnlyLocal = false}) {}

  Future<List<Friend>> listMembersIn(List<String> members) {}

  Future<List<Friend>> pageFriendNotIn(
      List<String> officials, int limit, int offset) {}

  Future<void> update(Person person) {}

  Future<void> updateAvatar(String official, String avatar) {}

  Future<void> updateNickName(String official, String nickName) {}

  Future<void> updateSignature(String official, String signature) {}

  Future<void> updatePyname(String official, String pyname) {}
}
mixin IChatRoomService {
  Future<void> addRoom(ChatRoom chatRoom, {bool isOnlySaveLocal = false}) {}

  Future<void> addMember(RoomMember roomMember,
      {bool isOnlySaveLocal = false}) {}

  Future<void> addMemberToOwner(String chatroomOwner, RoomMember roomMember,
      {bool isOnlySaveLocal = false}) {}

  Future<List<ChatRoom>> listChatRoom() {}

  Future<List<RoomMember>> topMember10(String code) {}

  Future<void> removeChatRoom(String id) {}

  Future<List<RoomMember>> listMember(String id) {}

  Future<void> updateRoomLeading(String roomid, String file,
      {bool isOnlyLocal = false}) {}

  Future<void> updateRoomTitle(String room, String title,
      {bool isOnlyLocal = false}) {}

  Future<void> updateRoomNickname(String creator, String room, String nickname,
      {bool isOnlyLocal = false}) {}

  Future<List<RoomMember>> top20Members(String code) {}

  Future<List<RoomMember>> pageMember(String room, int limit, int offset) {}

  Future<void> removeMember(String room, official,
      {bool isOnlySaveLocal = false}) {}

  Future<bool> existsMember(String code, official) {}

  Future<ChatRoom> get(String room, {bool isOnlyLocal}) {}

  Future<ChatRoom> fetchAndSaveRoom(String creator, String room) {}

  Future<void> loadAndSaveRoomMembers(String room, String sender) {}

  Future<RoomMember> getMember(String creator, String room) {}

  Future<void> switchNick(String creator, String room, bool showNick) {}

  Future<RoomMember> getMemberOfPerson(
      String creator, String id, String official) {}

  Future<void> updateRoomBackground(ChatRoom chatRoom, path,
      {bool isOnlyLocal = false}) {}

  Future<ChatRoomOR> fetchRoom(String creator, String room) {}

  Future<List<RoomMember>> fetchMembers(String room, String creator) {}

  Future<void> updateRoomForeground(ChatRoom chatRoom, bool isForegroundWhite,
      {bool isOnlyLocal = false}) {}

  Future<int> totalMembers(String id) {}

  Future<List<RoomMember>> pageMemberLike(
      String query, String room, int limit, int offset) {}

  Future<void> updateRoomUtime(String room) {}

  Future<List<ChatRoom>> findChatroomByMembers(List<String> members) {}

  Future<void> emptyChatMembersOnLocal(String id) {}

  Future<List<String>> listFlagRoomMember(String creator, String id) {}

  Future<void> removeChatMembersOnLocal(String id, List<String> members) {}

  Future<RoomMember> getMemberOnLocal(String room, String member) {}

  Future<void> updateRoom(ChatRoomOR roomOnRemote) {}

  Future<void> unsealRoom(String creator, String id) {}

  Future<void> sealRoom(String creator, String id) {}
}
mixin IP2PMessageService {
  Future<void> addMessage(String creator, ChatMessage message,
      {bool isOnlySaveLocal = false});

  Future<List<ChatMessage>> pageMessage(
      String roomCode, int limit, int offset) {}

  Future<ChatMessage> firstUnreadMessage(String id) {}

  Future<int> countUnreadMessage(String id) {}

  Future<void> flatReadMessages(String id) {}

  Future<List<ChatMessage>> listUnreadMessages(String id) {}

  Future<bool> existsMessage(String msgid) {}

  Future<void> empty(ChatRoom chatRoom) {}

  Future<int>  totalMessageWithMedia(String roomCode,int beginTime) {}

  Future<List<RoomMessageMedia>> pageMessageWithMedia(String roomCode,int beginTime,limit, offset);

  Future<void> remove(String room, String id) {}

  Future<void> cancelMessage(String roomCreator,String room, String id,{bool isOnlyLocal=false}) {}

  Future<ChatMessage> getMessage(String msgid) {}

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

  Future<void> updateDevice(String current, String device) {}
}
mixin IGeoReceptorCache {
  Future<void> add(GeoReceptor receptor);

  Future<GeoReceptor> get(String receptorid);
}
mixin IGeoReceptorService {
  Future<bool> init(Location location);

  Future<void> add(GeoReceptor receptor, {bool isOnlySaveLocal = false});

  Future<void> remove(String id);

  Future<GeoReceptor> get(String receptorid);

  Future<GeoReceptor> getMobileReceptor(String person, String device);

  Future<List<GeoReceptor>> page(int limit, int offset);

  Future<void> updateLeading(String id, String lleading, String rleading);

  Future<void> updateTitle(String id, String title);

  Future<void> updateLocation(String receptor, LatLng location,
      {bool isOnlyLocal = false});

  Future<void> updateRadius(String id, double radius);

  Future<void> updateBackground(String id, BackgroundMode mode, String file) {}

  Future<void> emptyBackground(String id) {}

  Future<void> updateForeground(String id, ForegroundMode mode) {}

  Future<void> setAutoScrollMessage(String id, bool isAutoScrollMessage) {}

  Future<bool> existsLocal(String receptor) {}

  Future<void> updateUtime(String receptor) {}
}
mixin IGeoCategoryRemote {
  Future<List<GeoCategoryOR>> listCategory();

  Future<GeoCategoryOR> getCategory(String category) {}

  Future<List<GeoCategoryAppOR>> getApps(String category, String on) {}

  Future<GeoChannelPortalOR> getGeoPortal() {}
}
mixin IGeoCategoryLocal {
  Future<GeoCategoryOL> get(String category);

  Future<void> remove(String category);
}

mixin IGeosphereMessageService {
  Future<void> addMessage(GeosphereMessageOL geosphereMessageOL,
      {bool isOnlySaveLocal = false}) {}

  Future<List<GeosphereMessageOL>> pageMessage(
      String receptor, int limit, int offset) {}

  Future<List<GeosphereMessageOL>> pageFilterMessage(
      String receptor, String filterCategory, int limit, int offset) {}

  Future<List<GeosphereMessageOL>> pageMyMessage(
      String receptor, String creator, int limit, int offset) {}

  Future<void> removeMessage(String receptor, String msgid) {}

  Future<GeosphereMessageOL> getMessage(String receptor, msgid) {}

  Future<void> like(GeosphereLikePersonOL likePerson,
      {bool isOnlySaveLocal = false}) {}

  Future<void> unlike(String receptor, String msgid, String person,
      {bool isOnlySaveLocal = false}) {}

  Future<bool> isLiked(String receptor, String msgid, String person) {}

  Future<List<GeosphereLikePersonOL>> pageLikePersons(
      String receptor, String id, int i, int j) {}

  Future<void> addComment(GeosphereCommentOL geosphereCommentOL,
      {bool isOnlySaveLocal = false}) {}

  Future<void> removeComment(String receptor, String msgid, String commentid,
      {bool isOnlySaveLocal = false}) {}

  Future<List<GeosphereCommentOL>> pageComments(
      String receptor, String msgid, int limit, int offset) {}

  Future<GeosphereMessageOL> firstUnreadMessage(String receptor) {}

  Future<int> countUnreadMessage(String receptor) {}

  Future<void> flagMessagesReaded(String id) {}

  Future<void> loadMessageExtraTask(
      String msgCreator, String msgid, String receptor) {}
}
mixin IGeosphereMediaService {
  Future<void> addMedia(GeosphereMediaOL geosphereMediaOL,
      {bool isOnlySaveLocal = false}) {}

  Future<List<GeosphereMediaOL>> listMedia(String receptor, String messageid) {}

  Future<void> addMediaNotPush(GeosphereMediaOL media) {}
}
