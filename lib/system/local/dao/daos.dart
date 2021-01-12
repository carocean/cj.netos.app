import 'package:floor/floor.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';

import '../entities.dart';

@dao
abstract class IPersonDAO {
  @insert
  Future<void> addPerson(Person person);

  @Query('delete FROM Person WHERE official = :official AND sandbox=:sandbox')
  Future<void> removePerson(String official, String sandbox);

  @Query('delete FROM Person where sandbox=:sandbox')
  Future<void> empty(String sandbox);

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<Person>> pagePerson(String sandbox, int pageSize, int currPage);

  @Query(
      'SELECT * FROM Person WHERE official = :official and sandbox=:sandbox LIMIT 1')
  Future<Person> getPerson(String official, String sandbox);

  @Query('SELECT * FROM Person where sandbox=:sandbox')
  Future<List<Person>> getAllPerson(String sandbox);

  @Query("SELECT * FROM Person where sandbox=:sandbox")
  Future<List<Person>> countPersons(String sandbox);

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox and official NOT IN (:officials) LIMIT :persons_limit OFFSET  :persons_offset')
  Future<List<Person>> pagePersonWithout(String sandbox, List<String> officials,
      int persons_limit, int persons_offset);

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox and official IN (:officials) LIMIT :persons_limit OFFSET  :persons_offset')
  Future<List<Person>> pagePersonWith(String sandbox, List<String> officials,
      int persons_limit, int persons_offset);

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox and official IN (:officials)')
  Future<List<Person>> listPersonWith(String sandbox, List<String> officials);

  @Query(
      'SELECT * FROM Person WHERE sandbox=:sandbox and accountCode = :accountCode and appid=:appid and tenantid=:tenantid LIMIT 1 OFFSET 0')
  Future<Person> findPerson(
      String sandbox, String accountCode, String appid, String tenantid);

  @Query(
      'SELECT * FROM Person WHERE sandbox =:sandbox and uid = :uid LIMIT 1 OFFSET 0')
  Future<Person> getPersonByUID(String sandbox, String uid) {}

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox and official NOT IN (select official from Friend) LIMIT :limit OFFSET  :offset')
  Future<List<Person>> pagePersonNotFriends(
      String sandbox, int limit, int offset);

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox and (accountCode LIKE :accountCode OR nickName LIKE :nickName OR pyname LIKE :pyname) and official NOT IN (select official from Friend) LIMIT :limit OFFSET  :offset')
  Future<List<Person>> pagePersonLikeName(String sandbox, String accountCode,
      String nickName, String pyname, int limit, int offset);

  @Query(
      'SELECT *  FROM Person where sandbox=:sandbox and (accountCode LIKE :accountCode OR nickName LIKE :nickName OR pyname LIKE :pyname) LIMIT :limit OFFSET  :offset')
  Future<List<Person>> pagePersonLikeName0(String sandbox, String accountCode,
      String nickName, String pyname, int limit, int offset);

  @Query(
      'UPDATE Person SET rights = :rights WHERE sandbox=:sandbox and official=:official')
  Future<void> updateRights(String rights, String sandbox, String official) {}

  @Query(
      'UPDATE Person SET nickName=:nickName , avatar=:avatar , signature=:signature , pyname=:pyname WHERE sandbox=:sandbox and official=:official')
  Future<void> updateAny(
      nickName, avatar, signature, pyname, String sandbox, String official) {}

  @Query(
      'UPDATE Person SET avatar = :avatar WHERE sandbox=:sandbox and official=:official')
  Future<void> updateAvatar(String avatar, String sandbox, official) {}

  @Query(
      'UPDATE Person SET nickName = :nickName WHERE sandbox=:sandbox and official=:official')
  Future<void> updateNickName(String nickName, String sandbox, official) {}

  @Query(
      'UPDATE Person SET signature = :signature WHERE sandbox=:sandbox and official=:official')
  Future<void> updateSignature(String signature, String sandbox, official) {}

  @Query(
      'UPDATE Person SET pyname = :pyname WHERE sandbox=:sandbox and official=:official')
  Future<void> updatePyname(String pyname, String sandbox, official) {}
}

@dao
abstract class IChannelDAO {
  @insert
  Future<void> addChannel(Channel channel);

  @Query('delete FROM Channel WHERE sandbox=:sandbox and id = :id')
  Future<void> removeChannel(String sandbox, String id);

  @Query(
      'SELECT *  FROM Channel where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<Channel>> pageChannel(String sandbox, int pageSize, int currPage);

  @Query('SELECT * FROM Channel WHERE sandbox=:sandbox and id = :id')
  Future<Channel> getChannel(String sandbox, String id);

  @Query(
      'SELECT * FROM Channel where sandbox=:sandbox ORDER BY utime DESC, ctime DESC')
  Future<List<Channel>> getAllChannel(String sandbox);

  @Query('delete FROM Channel where sandbox=:sandbox')
  Future<void> empty(String sandbox);

  @Query('delete FROM Channel WHERE sandbox=:sandbox and owner = :person')
  Future<void> emptyOfPerson(String sandbox, String person);

  @Query('SELECT * FROM Channel WHERE sandbox=:sandbox and owner = :person')
  Future<List<Channel>> getChannelsOfPerson(String sandbox, String person);

  @Query(
      'SELECT * FROM Channel WHERE sandbox=:sandbox and name = :channelName AND owner = :owner')
  Future<Channel> getChannelByName(
      String sandbox, String channelName, String owner);

  @Query(
      'SELECT * FROM Channel WHERE sandbox=:sandbox ORDER BY ctime desc limit 1')
  Future<Channel> getlastChannel(String sandbox) {}

  @Query(
      'UPDATE Channel SET leading = :path WHERE sandbox=:sandbox and id = :id')
  Future<void> updateLeading(String path, String sandbox, String id);

  @Query('UPDATE Channel SET name = :name WHERE id = :id and sandbox=:sandbox')
  Future<void> updateName(String name, String id, String sandbox);

  @Query(
      'UPDATE Channel SET utime = :utime WHERE id = :id and sandbox=:sandbox')
  Future<void> updateUtime(int utime, String id, String sandbox);
}

@dao
abstract class IInsiteMessageDAO {
  @insert
  Future<void> addMessage(InsiteMessage message);

  @Query('delete FROM InsiteMessage WHERE id = :id and sandbox=:sandbox')
  Future<void> removeMessage(String id, String sandbox);

  @Query(
      'SELECT *  FROM InsiteMessage where sandbox=:sandbox ORDER BY atime DESC , ctime ASC LIMIT :pageSize OFFSET :currPage')
  Future<List<InsiteMessage>> pageMessage(
      String sandbox, int pageSize, int currPage);

  @Query(
      'SELECT *  FROM InsiteMessage where upstreamChannel=:channelid and sandbox=:sandbox ORDER BY atime DESC , ctime ASC')
  Future<List<InsiteMessage>> getMessageByChannel(
      String channelid, String sandbox) {}

  @Query(
      'SELECT *  FROM InsiteMessage where sandbox=:sandbox  AND creator!=:creator ORDER BY atime DESC , ctime ASC LIMIT :pageSize OFFSET :currPage')
  Future<List<InsiteMessage>> pageMessageNotMine(
      String sandbox, String creator, int limit, int offset) {}

  @Query(
      'SELECT *  FROM InsiteMessage where sandbox=:sandbox AND creator=:creator ORDER BY atime DESC , ctime ASC LIMIT :pageSize OFFSET :currPage')
  Future<List<InsiteMessage>> pageMessageIsMine(
      String sandbox, String creator, int limit, int offset) {}

  @Query(
      'SELECT * FROM InsiteMessage WHERE id = :id and sandbox=:sandbox  LIMIT 1')
  Future<InsiteMessage> getMessage(String id, String sandbox);

  @Query(
      'SELECT * FROM InsiteMessage WHERE docid = :docid and upstreamChannel=:upstreamChannel and sandbox=:sandbox LIMIT 1')
  Future<InsiteMessage> getMessageByDocid(
      String docid, String upstreamChannel, String sandbox);

  @Query('SELECT * FROM InsiteMessage where sandbox=:sandbox')
  Future<List<InsiteMessage>> getAllMessage(String sandbox);

  @Query('delete FROM InsiteMessage where sandbox=:sandbox')
  Future<void> empty(String sandbox);

  @Query(
      'delete FROM InsiteMessage where sandbox=:sandbox and upstreamChannel=:upstreamChannel')
  Future<void> emptyChannel(String sandbox, String upstreamChannel) {}
}

@dao
abstract class IMicroSiteDAO {
  @insert
  Future<void> addSite(MicroSite site);

  @Query('delete FROM MicroSite WHERE id = :id and sandbox=:sandbox')
  Future<void> removeSite(String id, String sandbox);

  @Query(
      'SELECT *  FROM MicroSite where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<MicroSite>> pageSite(String sandbox, int pageSize, int currPage);

  @Query('SELECT * FROM MicroSite WHERE sandbox=:sandbox and id = :id')
  Future<MicroSite> getSite(String sandbox, String id);

  @Query('SELECT * FROM MicroSite where sandbox=:sandbox')
  Future<List<MicroSite>> getAllSite(String sandbox);
}

@dao
abstract class IMicroAppDAO {
  @insert
  Future<void> addApp(MicroApp site);

  @Query('delete FROM MicroApp WHERE sandbox=:sandbox and id = :id')
  Future<void> removeApp(String sandbox, String id);

  @Query(
      'SELECT *  FROM MicroApp where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<MicroApp>> pageApp(String sandbox, int pageSize, int currPage);

  @Query('SELECT * FROM MicroApp WHERE sandbox=:sandbox and id = :id')
  Future<MicroApp> getApp(String sandbox, String id);

  @Query('SELECT * FROM MicroApp where sandbox=:sandbox')
  Future<List<MicroApp>> getAllApp(String sandbox);
}

@dao
abstract class IChannelMessageDAO {
  @insert
  Future<void> addMessage(ChannelMessage message);

  @Query('delete FROM ChannelMessage WHERE id = :id and sandbox=:sandbox')
  Future<void> removeMessage(String id, String sandbox);

  @Query(
      'SELECT *  FROM ChannelMessage WHERE onChannel = :onChannel and sandbox=:sandbox ORDER BY ctime DESC  LIMIT :pageSize OFFSET :currPage')
  Future<List<ChannelMessage>> pageMessage(
      String onChannel, String sandbox, int pageSize, int currPage);

  @Query(
      'SELECT msg.*  FROM ChannelMessage msg,Channel ch  WHERE msg.onChannel=ch.code AND ch.loopType=:loopType and msg.sandbox=:sandbox LIMIT :pageSize OFFSET :currPage')
  Future<List<ChannelMessage>> pageMessageByChannelLoopType(
      String loopType, String sandbox, int limit, int offset);

  @Query(
      'SELECT msg.*  FROM ChannelMessage msg  WHERE msg.onChannel=:onChannel  AND msg.creator=:person  and msg.sandbox=:sandbox ORDER BY ctime DESC LIMIT :limit OFFSET :offset')
  Future<List<ChannelMessage>> pageMessageBy(
    String onchannel,
    String person,
    String sandbox,
    int limit,
    int offset,
  );

  @Query(
      'SELECT msg.*  FROM ChannelMessage msg  WHERE msg.onChannel=:channelid and msg.sandbox=:sandbox and msg.state=:state ORDER BY ctime DESC')
  Future<List<ChannelMessage>> listMessageByState(
      String channelid, String sandbox, String state) {}

//
  @Query(
      'UPDATE ChannelMessage SET state =:updateToState  WHERE onChannel=:channelid and sandbox=:sandbox and state=:whereState')
  Future<void> updateStateMessage(String updateToState, String channelid,
      String sandbox, String whereState);

  @Query(
      'SELECT * FROM ChannelMessage WHERE id = :id and sandbox=:sandbox  LIMIT 1')
  Future<ChannelMessage> getMessage(String id, String sandbox);

  @Query('SELECT * FROM ChannelMessage where sandbox=:sandbox')
  Future<List<ChannelMessage>> getAllMessage(String sandbox);

  @Query('delete FROM ChannelMessage where sandbox=:sandbox')
  Future<void> empty(String sandbox);

  @Query(
      'delete FROM ChannelMessage where onChannel=:channelcode and sandbox=:sandbox')
  Future<void> removeMessagesBy(String channelcode, String sandbox) {}
}

@dao
abstract class IChannelMediaDAO {
  @insert
  Future<void> addMedia(Media media);

  @Query('delete FROM Media WHERE id = :id and sandbox=:sandbox')
  Future<void> removeMedia(String id, String sandbox);

  @Query(
      'SELECT *  FROM Media where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<Media>> pageMedia(String sandbox, int pageSize, int currPage);

  @Query('SELECT * FROM Media WHERE id = :id and sandbox=:sandbox  LIMIT 1')
  Future<Media> getMedia(String id, String sandbox);

  @Query('SELECT * FROM Media where sandbox=:sandbox')
  Future<List<Media>> getAllMedia(String sandbox);

  @Query('SELECT * FROM Media WHERE msgid = :msgid and sandbox=:sandbox')
  Future<List<Media>> getMediaByMsgId(String msgid, String sandbox);

  @Query(
      'SELECT * FROM Media WHERE onChannel = :channelcode and sandbox=:sandbox')
  Future<List<Media>> getMediaBychannelcode(String channelcode, String sandbox);
}

@dao
abstract class IChannelLikePersonDAO {
  @insert
  Future<void> addLikePerson(LikePerson likePerson);

  @Query('delete FROM LikePerson WHERE id = :id and sandbox=:sandbox')
  Future<void> removeLikePerson(String id, String sandbox);

  @Query(
      'SELECT *  FROM LikePerson where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<LikePerson>> pageLikePerson(
      String sandbox, int pageSize, int currPage);

  @Query(
      'SELECT * FROM LikePerson WHERE id = :id and sandbox=:sandbox  LIMIT 1')
  Future<LikePerson> getLikePerson(String id, String sandbox);

  @Query('SELECT * FROM LikePerson where sandbox=:sandbox')
  Future<List<LikePerson>> getAllLikePerson(String sandbox);

  @Query(
      'SELECT * FROM LikePerson WHERE msgid = :msgid AND person=:person and sandbox=:sandbox')
  Future<List<LikePerson>> getLikePersonBy(
      String msgid, String person, String sandbox);

  @Query(
      'delete FROM LikePerson WHERE msgid = :msgid AND person=:person and sandbox=:sandbox')
  Future<void> removeLikePersonBy(String msgid, String person, String sandbox);

  @Query(
      'SELECT *  FROM LikePerson WHERE msgid=:msgid and sandbox=:sandbox  LIMIT :pageSize OFFSET  :offset')
  Future<List<LikePerson>> pageLikePersonBy(
      String msgid, String sandbox, int pageSize, int offset);

  @Query(
      'delete FROM LikePerson WHERE onChannel = :channelcode and sandbox=:sandbox')
  Future<void> removeLikePersonByChannel(String channelcode, String sandbox);
}

@dao
abstract class IChannelCommentDAO {
  @insert
  Future<void> addComment(ChannelComment comment);

  @Query('delete FROM ChannelComment WHERE id = :id and sandbox=:sandbox')
  Future<void> removeComment(String id, String sandbox);

  @Query(
      'SELECT *  FROM ChannelComment where sandbox=:sandbox LIMIT :pageSize OFFSET  :currPage')
  Future<List<ChannelComment>> pageComment(
      String sandbox, int pageSize, int currPage);

  @Query(
      'SELECT * FROM ChannelComment WHERE id = :id and sandbox=:sandbox LIMIT 1')
  Future<ChannelComment> getComment(String id, String sandbox);

  @Query('SELECT * FROM ChannelComment where sandbox=:sandbox')
  Future<List<ChannelComment>> getAllComment(String sandbox);

  @Query(
      'SELECT *  FROM ChannelComment WHERE msgid=:msgid  and sandbox=:sandbox LIMIT :pageSize OFFSET  :offset')
  Future<List<ChannelComment>> pageLikeCommentBy(
      String msgid, String sandbox, int pageSize, int offset) {}

  @Query(
      'delete FROM ChannelComment WHERE onChannel = :channelcode and sandbox=:sandbox')
  Future<void> removeCommentBy(String channelcode, String sandbox);
}

@dao
abstract class IChannelPinDAO {
  @Query(
      'UPDATE ChannelPin SET outPersonSelector = :selector WHERE channel = :channelcode and sandbox=:sandbox')
  Future<void> setOutputPersonSelector(
      String selector, String channelcode, String sandbox);

  @Query(
      'UPDATE ChannelPin SET outGeoSelector = :isset WHERE channel = :channelcode and sandbox=:sandbox')
  Future<void> setOutputGeoSelector(
      String isset, String channelcode, String sandbox);

  @Query(
      'SELECT *  FROM ChannelPin WHERE channel=:channelcode and sandbox=:sandbox')
  Future<ChannelPin> getChannelPin(String channelcode, String sandbox);

  @insert
  Future<void> addChannelPin(ChannelPin channelPin);

  @Query(
      'delete FROM ChannelPin WHERE channel=:channelcode and sandbox=:sandbox')
  Future<void> remove(String channelcode, String sandbox);
}

@dao
abstract class IChannelOutputPersonDAO {
  @Query(
      'SELECT *  FROM ChannelOutputPerson WHERE channel=:channelcode and sandbox=:sandbox  LIMIT :limit OFFSET  :offset')
  Future<List<ChannelOutputPerson>> pageOutputPerson(
      String channelcode, String sandbox, int limit, int offset);

  @Query(
      'SELECT *  FROM ChannelOutputPerson WHERE channel=:channelcode and sandbox=:sandbox')
  Future<List<ChannelOutputPerson>> listOutputPerson(
      String channelcode, String sandbox);

  @Query(
      'delete FROM ChannelOutputPerson WHERE person=:person AND channel = :channelcode and sandbox=:sandbox')
  Future<void> removeOutputPerson(
      String person, String channelcode, String sandbox);

  @insert
  Future<void> addOutputPerson(ChannelOutputPerson person);

  @Query(
      'select * FROM ChannelOutputPerson WHERE person=:person AND channel = :channelcode and sandbox=:sandbox LIMIT 1 OFFSET 0')
  Future<ChannelOutputPerson> getOutputPerson(
      String person, String channelcode, String sandbox);

  @Query(
      'delete FROM ChannelOutputPerson WHERE channel = :channelcode and sandbox=:sandbox')
  Future<void> emptyOutputPersons(String channelcode, String sandbox);

  @Query(
      'select * FROM ChannelOutputPerson WHERE channel = :channel and sandbox=:sandbox ORDER BY atime desc LIMIT 1 OFFSET 0')
  Future<ChannelOutputPerson> getLastOutputPerson(
      String channel, String person) {}

  @Query(
      'UPDATE ChannelOutputPerson SET rights = :rights WHERE person=:person AND channel = :channelcode and sandbox=:sandbox')
  Future<void> updateOutputPersonRights(
      String rights, official, String channel, String person) {}
}

@dao
abstract class IChannelInputPersonDAO {
  @Query(
      'SELECT *  FROM ChannelInputPerson WHERE channel=:channelcode and sandbox=:sandbox LIMIT :limit OFFSET  :offset')
  Future<List<ChannelInputPerson>> pageInputPerson(
      String channelcode, String sandbox, int limit, int offset);

  @Query(
      'delete FROM ChannelInputPerson WHERE person=:person AND channel = :channelcode and sandbox=:sandbox')
  Future<void> removeInputPerson(
    String person,
    String channelcode,
    String sandbox,
  );

  @insert
  Future<void> addInputPerson(ChannelInputPerson person);

  @Query(
      'select * FROM ChannelInputPerson WHERE person=:person AND channel = :channelcode and sandbox=:sandbox LIMIT 1 OFFSET 0')
  Future<ChannelInputPerson> getInputPerson(
      String person, String channelcode, String sandbox);

  @Query(
      'UPDATE ChannelInputPerson SET rights = :rights WHERE person=:person AND channel = :channelcode and sandbox=:sandbox')
  Future<void> updateInputPersonRights(
      String rights, String person, String channelcode, String sandbox) {}

  @Query(
      'SELECT *  FROM ChannelInputPerson WHERE channel=:channelcode and sandbox=:sandbox')
  Future<List<ChannelInputPerson>> listInputPerson(
      String channelcode, String sandbox);

  @Query(
      'delete FROM ChannelInputPerson WHERE channel = :channelcode and sandbox=:sandbox')
  Future<void> emptyInputPersons(String channelcode, String sandbox) {}

  @Query(
      'select * FROM ChannelInputPerson WHERE channel = :channel and sandbox=:sandbox ORDER BY atime desc LIMIT 1 OFFSET 0')
  Future<ChannelInputPerson> getLastInputPerson(
      String channel, String sandbox) {}
}

@dao
abstract class IFriendDAO {
  @Query(
      'select * FROM Friend WHERE official=:official and sandbox=:sandbox LIMIT 1 OFFSET 0')
  Future<Friend> getFriend(String official, String sandbox) {}

  @insert
  Future<void> addFriend(Friend friend) {}

  @Query(
      'SELECT *  FROM Friend where sandbox=:sandbox and (accountCode LIKE :accountCode OR nickName LIKE :nickName OR pyname LIKE :pyname) and official  NOT IN (:officials) LIMIT :limit OFFSET  :offset')
  Future<List<Friend>> pageFriendLikeName(
      String person,
      String accountCode,
      String nickName,
      String pyname,
      List<String> officials,
      int limit,
      int offset) {}

  @Query(
      'SELECT *  FROM Friend where sandbox=:sandbox and official  NOT IN (:officials) LIMIT :limit OFFSET  :offset')
  Future<List<Friend>> pageFriendNotIn(
      String sandbox, List<String> officials, int limit, int offset) {}

  @Query(
      'SELECT *  FROM Friend where sandbox=:sandbox LIMIT :limit OFFSET  :offset')
  Future<List<Friend>> pageFriend(String sandbox, int limit, int offset) {}

  @Query('delete FROM Friend WHERE official = :official AND sandbox=:sandbox')
  Future<void> removeFriendByOfficial(String official, String sandbox) {}

  @Query(
      'SELECT *  FROM Friend where sandbox=:sandbox and official=:official LIMIT 1 OFFSET  0')
  Future<Friend> getFriendByOfficial(String sandbox, String official) {}

  @Query(
      'SELECT *  FROM Friend where sandbox=:sandbox and official in (:members)')
  Future<List<Friend>> listMembersIn(String sandbox, List<String> members) {}

  @Query(
      'UPDATE Friend SET nickName =:nickName , avatar=:avatar , signature=:signature , pyname=:pyname WHERE sandbox=:sandbox and official = :official')
  Future<void> update(nickName, avatar, signature, pyname, sandbox, official);

  @Query(
      'UPDATE Friend SET avatar = :avatar WHERE sandbox=:sandbox and official = :official')
  Future<void> updateAvatar(String avatar, String sandbox, String official) {}

  @Query(
      'UPDATE Friend SET nickName = :nickName WHERE sandbox=:sandbox and official = :official')
  Future<void> updateNickName(
      String nickName, String sandbox, String official) {}

  @Query(
      'UPDATE Friend SET signature = :signature WHERE sandbox=:sandbox and official = :official')
  Future<void> updateSignature(
      String signature, String sandbox, String official) {}

  @Query(
      'UPDATE Friend SET pyname = :pyname WHERE sandbox=:sandbox and official = :official')
  Future<void> updatePyname(String pyname, String sandbox, String official) {}
}

@dao
abstract class IChatRoomDAO {
  @insert
  Future<void> addRoom(ChatRoom chatRoom) {}

  @Query(
      'SELECT *  FROM ChatRoom where sandbox=:sandbox ORDER BY utime DESC, ctime DESC ')
  Future<List<ChatRoom>> listChatRoom(String sandbox) {}

  @Query('delete FROM ChatRoom WHERE id = :id AND sandbox=:sandbox')
  Future<void> removeChatRoomById(String id, String sandbox) {}

  @Query('SELECT *  FROM ChatRoom where id=:id and sandbox=:sandbox')
  Future<ChatRoom> getChatRoomById(
    String code,
    String sandbox,
  ) {}

  @Query(
      "select * from ChatRoom where id in (select n.room from (select room, count(person) memberCount from RoomMember where room in (select room from RoomMember where person in (:members) group by room) group by room) as n where n.memberCount=:memberCount) and sandbox=:sandbox")
  Future<List<ChatRoom>> findChatroomByMembers(
      List<String> members, int memberCount, String sandbox) {}

  @Query(
      'UPDATE ChatRoom SET leading = :path WHERE sandbox=:sandbox and id = :roomid')
  Future<void> updateRoomLeading(
    String path,
    String sandbox,
    String roomid,
  ) {}

  @Query(
      'UPDATE ChatRoom SET title = :title WHERE sandbox=:sandbox and id = :room')
  Future<void> updateRoomTitle(String title, String sandbox, String room) {}

  @Query(
      'UPDATE ChatRoom SET utime = :utime WHERE sandbox=:sandbox and id = :room')
  Future<void> updateRoomUtime(int utime, String sandbox, String room) {}

  @Query(
      'UPDATE ChatRoom SET title = :title , leading = :leading , p2pBackground = :p2pBackground , isForegoundWhite = :isForegoundWhite WHERE sandbox=:sandbox and id = :room')
  Future<void> updateRoom(title, leading, p2pBackground, isForegoundWhite,
      String sandbox, String room) {}

  @Query(
      'SELECT *  FROM RoomMember where sandbox=:sandbox and room=:room LIMIT 20')
  Future<List<RoomMember>> top20Members(String sandbox, String room) {}

  @Query(
      'SELECT *  FROM RoomMember where room=:room and sandbox=:sandbox LIMIT :limit OFFSET :offset')
  Future<List<RoomMember>> pageMembers(
      String room, String sandbox, int limit, int offset) {}

  @Query(
      'UPDATE ChatRoom SET p2pBackground = :p2pBackground WHERE id = :room and sandbox=:sandbox')
  Future<void> updateRoomBackground(
      String p2pBackground, String room, String sandbox) {}

  @Query(
      'UPDATE ChatRoom SET isForegoundWhite = :isForegoundWhite WHERE id = :room and sandbox=:sandbox')
  Future<void> updateRoomForeground(
      String isForegoundWhite, String room, String sandbox) {}

  @Query(
      'UPDATE ChatRoom SET isSeal = :isSeal WHERE id = :room and sandbox=:sandbox')
  Future<void> updateRoomSeal(String isSeal, String room, String sandbox) {}
}

@dao
abstract class IRoomMemberDAO {
  @insert
  Future<void> addMember(RoomMember roomMember) {}

  @Query('SELECT *  FROM RoomMember where sandbox=:sandbox and room=:roomcode ')
  Future<List<RoomMember>> topMember10(String sandbox, String roomcode) {}

  @Query('delete FROM RoomMember WHERE room = :roomCode AND sandbox=:sandbox')
  Future<void> emptyRoomMembers(String roomCode, String sandbox) {}

  @Query('SELECT *  FROM RoomMember where sandbox=:sandbox and room=:roomCode')
  Future<List<RoomMember>> listdMember(String sandbox, String roomCode) {}

  @Query(
      'delete FROM RoomMember WHERE room = :code and person=:person AND sandbox=:sandbox')
  Future<void> removeMember(String code, String person, String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM RoomMember WHERE room = :code and person=:person AND sandbox=:sandbox ')
  Future<CountValue> countMember(String code, String person, String sandbox) {}

  @Query(
      'UPDATE RoomMember SET nickName = :nickName WHERE sandbox=:sandbox and room = :room and person=:member')
  Future<void> updateRoomNickname(
      String nickName, String sandbox, String room, String member) {}

  @Query(
      'SELECT *  FROM RoomMember where room=:room and person=:member and sandbox=:sandbox LIMIT 1')
  Future<RoomMember> getMember(String room, String member, String sandbox) {}

  @Query(
      'UPDATE RoomMember SET isShowNick = :isShowNick WHERE room = :room and sandbox=:sandbox ')
  Future<void> switchNick(String isShowNick, String room, String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM RoomMember where room=:room and sandbox=:sandbox')
  Future<CountValue> totalMembers(String room, String sandbox) {}

  @Query(
      'SELECT *  FROM RoomMember where sandbox=:sandbox and room=:room and (person LIKE :person or nickName LIKE :nickName) LIMIT :limit OFFSET :offset')
  Future<List<RoomMember>> pageMemberLike(String sandbox, String room,
      String person, String nickName, int limit, int offset) {}

  @Query(
      'delete FROM RoomMember WHERE room = :room and person in (:members) AND sandbox=:sandbox')
  Future<void> removeChatMembersOnLocal(
      String room, List<String> members, String sandbox) {}

  @Query('delete FROM RoomMember WHERE room = :room AND sandbox=:sandbox')
  Future<void> emptyChatMembersOnLocal(String room, String sandbox) {}
}

@dao
abstract class IRoomNickDAO {}

@dao
abstract class IP2PMessageDAO {
  @insert
  Future<void> addMessage(ChatMessage message) {}

  @Query(
      'SELECT *  FROM ChatMessage where sandbox=:sandbox and room=:roomCode ORDER BY ctime DESC LIMIT :limit OFFSET  :offset')
  Future<List<ChatMessage>> pageMessage(
      String sandbox, String roomCode, int limit, int offset) {}

  @Query(
      "SELECT *  FROM ChatMessage where sandbox=:sandbox and room=:roomCode and contentType in (:types) and ctime > :ctime ORDER BY ctime asc LIMIT :limit OFFSET  :offset")
  Future<List<ChatMessage>> pageMessageWithMedia(String sandbox,
      String roomCode, List<String> types, int ctime, int limit, int offset) {}

  @Query(
      "SELECT count(*) as value  FROM ChatMessage where sandbox=:sandbox and room=:roomCode and contentType in (:types)  and ctime > :ctime")
  Future<CountValue> countMessageWithMedia(
      String sandbox, String roomCode, List<String> types, int ctime) {}

  @Query(
      'SELECT *  FROM ChatMessage where room=:room and state=:state and sandbox=:sandbox ORDER BY ctime DESC')
  Future<List<ChatMessage>> listUnreadMessages(
      String room, String state, String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM ChatMessage where room=:room and sandbox=:sandbox and state in (:states)')
  Future<CountValue> countUnreadMessage(
      String room, String sandbox, List<dynamic> states) {}

  @Query(
      'SELECT *  FROM ChatMessage where room=:room and sender != :sender and sandbox=:sandbox and state in (:states) ORDER BY atime DESC LIMIT 1')
  Future<ChatMessage> firstUnreadMessage(
      String room,String sender, String person, List<dynamic> states) {}

  @Query(
      'UPDATE ChatMessage SET state=:state , rtime=:rtime WHERE room=:room and state in (:wherestates) and sandbox=:sandbox')
  Future<void> updateMessagesState(String state, int rtime, String room,
      List<dynamic> wherestates, String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM ChatMessage where id=:msgid and sandbox=:sandbox')
  Future<CountValue> countMessageWhere(String msgid, String sandbox) {}

  @Query('delete FROM ChatMessage WHERE room=:room and sandbox = :sandbox')
  Future<void> emptyRoomMessages(String room, String sandbox) {}

  @Query(
      'delete FROM ChatMessage WHERE id = :id and room=:room and sandbox = :sandbox')
  Future<void> remove(String id, String room, String sandbox) {}

  @Query(
      'UPDATE ChatMessage SET state=:state WHERE room=:room and id=:msgid and sandbox=:sandbox')
  Future<void> updateMsgState(
      String state, String room, String msgid, String sandbox) {}

  @Query(
      'SELECT *  FROM ChatMessage where id=:msgid and sandbox=:sandbox LIMIT 1')
  Future<ChatMessage> getMessage(String msgid, String sandbox) {}
}

@dao
abstract class IPrincipalDAO {
  @insert
  Future<void> add(Principal principal) {}

  @Query('SELECT *  FROM Principal ORDER BY ltime DESC')
  Future<List<Principal>> getAll();

  @Query('delete FROM Principal WHERE person = :person')
  Future<void> remove(String person) {}

  @Query(
      'UPDATE Principal SET refreshToken=:refreshToken , accessToken = :accessToken WHERE person=:person')
  Future<void> updateToken(
      String refreshToken, String accessToken, String person) {}

  @Query('SELECT *  FROM Principal where person=:person')
  Future<Principal> get(String person);

  @Query('UPDATE Principal SET refreshToken=NULL WHERE person=:person')
  Future<void> emptyRefreshToken(String person) {}

  @Query(
      'UPDATE Principal SET lavatar=:localAvatar , ravatar=:remoteAvatar WHERE person=:person')
  Future<void> updateAvatar(
      String localAvatar, String remoteAvatar, String person) {}

  @Query('UPDATE Principal SET nickName=:nickName WHERE person=:person')
  Future<void> updateNickname(String nickName, String person) {}

  @Query('UPDATE Principal SET signature=:signature WHERE person=:person')
  Future<void> updateSignature(String signature, String person) {}

  @Query('UPDATE Principal SET device=:device WHERE person=:person')
  Future<void> updateDevice(String device, String person) {}
}

@dao
abstract class IGeoReceptorDAO {
  @insert
  Future<void> add(GeoReceptor receptor) {}

  @Query(
      'SELECT *  FROM GeoReceptor WHERE category=:category and creator=:creator and device=:device and sandbox=:sandbox LIMIT 1')
  Future<GeoReceptor> getReceptor(
      String category, String creator, String device, String sandbox) {}

  @Query('SELECT *  FROM GeoReceptor WHERE id=:id and sandbox=:sandbox')
  Future<GeoReceptor> get(String id, String sandbox) {}

  @Query(
      'SELECT *  FROM GeoReceptor WHERE sandbox = :sandbox ORDER BY utime desc, ctime desc, category desc limit :limit, offset :offset')
  Future<List<GeoReceptor>> page(String sandbox, int limit, int offset) {}

  @Query('delete FROM GeoReceptor WHERE id=:id and sandbox = :sandbox')
  Future<void> remove(String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET title=:title WHERE id=:id and sandbox=:sandbox')
  Future<void> updateTitle(String title, String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET leading=:leading WHERE id=:id and sandbox=:sandbox')
  Future<void> updateLeading(String leading, String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET location=:location WHERE id=:id and sandbox=:sandbox')
  Future<void> updateLocation(String location, String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET radius=:radius WHERE id=:id and sandbox=:sandbox')
  Future<void> updateRadius(double radius, String id, String person) {}

  @Query(
      'UPDATE GeoReceptor SET backgroundMode=:mode , background=:file WHERE id=:id and sandbox=:sandbox')
  Future<void> updateBackground(
      String mode, String file, String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET foregroundMode=:mode WHERE id=:id and sandbox=:sandbox')
  Future<void> updateForeground(String mode, String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET isAutoScrollMessage=:isAutoScrollMessage WHERE id=:receptor and sandbox=:sandbox')
  Future<void> setAutoScrollMessage(
      String isAutoScrollMessage, String receptor, String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM GeoReceptor WHERE id=:id and sandbox=:sandbox')
  Future<CountValue> countReceptor(String id, String sandbox) {}

  @Query(
      'UPDATE GeoReceptor SET utime=:utime WHERE id=:receptor and sandbox=:sandbox')
  Future<void> updateUtime(int utime, String receptor, String sandbox) {}
}

@dao
abstract class IGeoCategoryDAO {
  @Query(
      'SELECT *  FROM GeoCategoryOL WHERE id=:category and sandbox=:sandbox LIMIT 1')
  Future<GeoCategoryOL> get(String category, String sandbox) {}

  @Query('delete FROM GeoCategoryOL WHERE id=:category and sandbox = :sandbox')
  Future<void> remove(String category, String sandbox);

  @insert
  Future<void> add(GeoCategoryOL categoryLocal) {}
}

@dao
abstract class IGeosphereMessageDAO {
  @insert
  Future<void> addMessage(GeosphereMessageOL geosphereMessageOL) {}

  @Query(
      'SELECT *  FROM GeosphereMessageOL WHERE receptor=:receptor and sandbox=:sandbox ORDER BY ctime DESC, atime DESC  LIMIT :limit OFFSET :offset')
  Future<List<GeosphereMessageOL>> pageMessage(
      String receptor, String sandbox, int limit, int offset) {}

  @Query(
      'SELECT *  FROM GeosphereMessageOL WHERE receptor=:receptor and category=:category and sandbox=:sandbox ORDER BY ctime DESC, atime DESC  LIMIT :limit OFFSET :offset')
  Future<List<GeosphereMessageOL>> pageFilterMessage(
      String receptor, String category, String person, int limit, int offset) {}

  @Query(
      'SELECT *  FROM GeosphereMessageOL WHERE receptor=:receptor and creator=:creator and sandbox=:sandbox ORDER BY ctime DESC, atime DESC  LIMIT :limit OFFSET :offset')
  Future<List<GeosphereMessageOL>> pageMyMessage(
      String receptor, String creator, String sandbox, int limit, int offset) {}

  @Query(
      'delete FROM GeosphereMessageOL where receptor=:receptor and id=:id and sandbox=:sandbox')
  Future<void> removeMessage(String receptor, String id, String sandbox) {}

  @Query(
      'SELECT *  FROM GeosphereMessageOL WHERE receptor=:receptor and id=:id and sandbox=:sandbox LIMIT 1')
  Future<GeosphereMessageOL> getMessage(
      String receptor, String id, String sandbox) {}

  @Query(
      "SELECT *  FROM GeosphereMessageOL WHERE receptor=:receptor and state=:state and sandbox=:sandbox ORDER BY atime desc LIMIT 1")
  Future<GeosphereMessageOL> firstUnreadMessage(
      String receptor, String state, String sandbox) {}

  //欲接收限定字段的值应该像声明CountValue对象那样使用
  ///CountValue用于接收查询的统计字段，并且以 as 字段别名，别名与CountValue对应
  @Query(
      "SELECT count(*) as value  FROM GeosphereMessageOL WHERE receptor=:receptor and state=:state and sandbox=:sandbox ORDER BY atime desc")
  Future<CountValue> listUnreadMessage(
      String receptor, String state, String sandbox) {}

  @Query(
      "update GeosphereMessageOL set state=:newState WHERE receptor=:receptor and state=:oldstate and sandbox=:sandbox")
  Future<void> flagArrivedMessagesReaded(
      String newState, String receptor, String oldstate, String sandbox) {}

  @Query(
      'SELECT *  FROM GeosphereLikePersonOL WHERE receptor=:receptor and msgid=:msgid and person=:liker and sandbox=:sandbox LIMIT 1')
  Future<GeosphereLikePersonOL> getLikePersonBy(
      String receptor, String msgid, String liker, String sandbox) {}

  @Query(
      'delete FROM GeosphereLikePersonOL where receptor=:receptor and msgid=:msgid and person=:liker and sandbox=:sandbox')
  Future<void> unlike(
      String receptor, String msgid, String liker, String sandbox) {}

  @insert
  Future<void> like(GeosphereLikePersonOL likePerson) {}

  @Query(
      'SELECT *  FROM GeosphereLikePersonOL WHERE receptor=:receptor and msgid=:msgid and sandbox=:sandbox ORDER BY ctime DESC LIMIT :limit OFFSET :offset')
  Future<List<GeosphereLikePersonOL>> pageLikePersons(
      String receptor, String msgid, String sandbox, int limit, int offset) {}

  @Query(
      'delete FROM GeosphereCommentOL where receptor=:receptor and msgid=:msgid and id=:commentid and sandbox=:sandbox')
  Future<void> removeComment(
      String receptor, String msgid, String commentid, String sandbox) {}

  @insert
  Future<void> addComment(GeosphereCommentOL geosphereCommentOL) {}

  @Query(
      'SELECT *  FROM GeosphereCommentOL WHERE receptor=:receptor and  msgid=:msgid and sandbox=:sandbox ORDER BY ctime DESC LIMIT :limit OFFSET :offset')
  Future<List<GeosphereCommentOL>> pageComments(
      String receptor, String msgid, String sandbox, int limit, int offset) {}
}

@dao
abstract class IGeosphereLikePersonDAO {}

@dao
abstract class IGeosphereCommentDAO {}

@dao
abstract class IGeosphereMediaDAO {
  @insert
  Future<void> addMedia(GeosphereMediaOL geosphereMediaOL) {}

  @Query(
      'SELECT *  FROM GeosphereMediaOL WHERE receptor=:receptor and msgid=:msgid and sandbox=:sandbox')
  Future<List<GeosphereMediaOL>> listMedia(
      String receptor, String msgid, String sandbox) {}

  @Query(
      'delete FROM GeosphereMediaOL where receptor=:receptor and msgid=:msgid and sandbox=:sandbox')
  Future<void> empty(String receptor, String msgid, String sandbox) {}
}

@dao
abstract class IRecommenderDAO {
  @insert
  Future<void> addContentItem(ContentItemOL itemOL) {}

  @Query(
      'SELECT *  FROM ContentItemOL where sandbox=:sandbox ORDER BY atime DESC LIMIT :pageSize OFFSET  :currPage')
  Future<List<ContentItemOL>> pageContentItem(
      String sandbox, int pageSize, int currPage) {}

  @Query('delete FROM ContentItemOL where sandbox=:sandbox')
  Future<void> emptyContentItem(String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM ContentItemOL where id=:item and sandbox=:sandbox')
  Future<CountValue> countContentItem(String item, String sandbox) {}

  @Query(
      'SELECT count(*) as value  FROM RecommenderMessageOL where item=:item and sandbox=:sandbox')
  Future<CountValue> countMessage(String item, String sandbox) {}

  @transaction
  Future<dynamic> doTransaction(
      Future<dynamic> Function(dynamic args) action, dynamic args) async {
    if (action == null) {
      return null;
    }
    return await action(args);
  }

  @Query(
      'SELECT *  FROM RecommenderMessageOL where item=:item and sandbox=:sandbox LIMIT 1')
  Future<RecommenderMessageOL> getMessageByContentItem(
      String item, String sandbox) {}

  @Query(
      'SELECT *  FROM RecommenderMediaOL where docid=:docid and sandbox=:sandbox')
  Future<List<RecommenderMediaOL>> listMedia(String docid, String sandbox) {}

  @insert
  Future<void> addMessage(RecommenderMessageOL message) {}

  @insert
  Future<void> addMedia(RecommenderMediaOL m) {}

  @Query(
      'SELECT *  FROM RecommenderMediaOL where id=:id and sandbox=:sandbox LIMIT 1')
  Future<RecommenderMediaOL> getMedia(String id, String sandbox) {}

  @Query(
      'UPDATE RecommenderMediaOL SET src = :src WHERE sandbox=:sandbox and id=:id')
  Future<void> updateMediaSrc(String src, String sandbox, String id) {}
}
