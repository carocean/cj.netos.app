import 'dart:convert';
import 'dart:math';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/desklets/chats/media_card.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class FriendService implements IFriendService, IServiceBuilder {
  IFriendDAO friendDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IPersonService personService;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    friendDAO = db.friendDAO;
    personService = site.getService('/gbera/persons');
  }

  @override
  Future<Friend> getFriendByOfficial(String official) async {
    return await friendDAO.getFriendByOfficial(
      principal.person,
      official,
    );
  }

  @override
  Future<Friend> getFriend(String official, {bool isOnlyLocal = false}) async {
    var friend = await friendDAO.getFriendByOfficial(
      principal.person,
      official,
    );
    if (friend != null) {
      return friend;
    }
    var person = await personService.getPerson(official);
    if (person == null) {
      return null;
    }
    return Friend.formPerson(person);
  }

  @override
  Future<bool> exists(String official) async {
    return await friendDAO.getFriend(official, principal.person) != null;
  }

  @override
  Future<Function> addFriend(Friend friend) async {
    await friendDAO.addFriend(friend);
  }

  @override
  Future<Function> update(Person person) async {
    await friendDAO.update(person.nickName, person.avatar, person.signature,
        person.pyname, principal.person, person.official);
  }

  @override
  Future<void> updateAvatar(official, String avatar) async {
    if (StringUtil.isEmpty(avatar)) {
      return;
    }
    await friendDAO.updateAvatar(avatar, principal.person, official);
  }

  @override
  Future<void> updateNickName(official, String nickName) async {
    if (StringUtil.isEmpty(nickName)) {
      return;
    }
    await friendDAO.updateNickName(nickName, principal.person, official);
  }

  @override
  Future<void> updateSignature(official, String signature) async {
    if (StringUtil.isEmpty(signature)) {
      return;
    }
    await friendDAO.updateSignature(signature, principal.person, official);
  }

  @override
  Future<void> updatePyname(official, String pyname) async {
    if (StringUtil.isEmpty(pyname)) {
      return;
    }
    await friendDAO.updatePyname(pyname, principal.person, official);
  }

  @override
  Future<List<Friend>> pageFriendLikeName(
      String name, List<String> officials, int limit, int offset) async {
    return await friendDAO.pageFriendLikeName(
        principal.person, name, name, name, officials, limit, offset);
  }

  @override
  Future<List<Friend>> pageFriendNotIn(
      List<String> officials, int limit, int offset) async {
    return await friendDAO.pageFriendNotIn(
        principal.person, officials, limit, offset);
  }

  @override
  Future<List<Friend>> listMembersIn(List<String> members) async {
    return await friendDAO.listMembersIn(principal.person, members);
  }

  @override
  Future<List<Friend>> pageFriend(int limit, int offset) async {
    return await friendDAO.pageFriend(principal.person, limit, offset);
  }

  @override
  Future<Function> removeFriendByOfficial(String official) async {
    await friendDAO.removeFriendByOfficial(official, principal.person);
  }
}

class ChatRoomService implements IChatRoomService, IServiceBuilder {
  IChatRoomDAO chatRoomDAO;
  IRoomMemberDAO roomMemberDAO;
  IP2PMessageDAO messageDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IChatRoomRemote chatRoomRemote;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    chatRoomDAO = db.chatRoomDAO;
    roomMemberDAO = db.roomMemberDAO;
    messageDAO = db.p2pMessageDAO;
    chatRoomRemote = site.getService('/remote/chat/rooms');
  }

  @override
  Future<List<RoomMember>> top20Members(String code) async {
    return chatRoomDAO.top20Members(principal.person, code);
  }

  @override
  Future<List<RoomMember>> pageMember(String room, int limit, int offset) {
    return chatRoomDAO.pageMembers(room, principal.person, limit, offset);
  }

  @override
  Future<Function> removeMember(String room, official,
      {bool isOnlySaveLocal = false}) async {
    await roomMemberDAO.removeMember(room, official, principal.person);
    if (!isOnlySaveLocal) {
      await chatRoomRemote.removeMemberOnlyByCreator(room, official);
    }
  }

  @override
  Future<bool> existsMember(String code, official) async {
    CountValue value =
        await roomMemberDAO.countMember(code, official, principal.person);
    if (value == null) {
      return false;
    }
    return value.value > 0;
  }

  @override
  Future<Function> updateRoomLeading(String roomid, String file,
      {bool isOnlyLocal = false}) async {
    await chatRoomDAO.updateRoomLeading(
      file,
      principal.person,
      roomid,
    );
    if (!isOnlyLocal) {
      await chatRoomRemote.updateRoomLeading(roomid, file);
    }
  }

  @override
  Future<Function> updateRoomUtime(String room) async {
    await chatRoomDAO.updateRoomUtime(
      DateTime.now().millisecondsSinceEpoch,
      principal.person,
      room,
    );
  }

  @override
  Future<Function> updateRoom(ChatRoomOR room) async {
    await chatRoomDAO.updateRoom(room.title, room.leading, room.background,
        room.isForegroundWhite ? "true" : "false", principal.person, room.room);
  }

  @override
  Future<Function> unsealRoom(String creator, String id) async {
    await chatRoomRemote.unsealRoom(creator, id);
    await chatRoomDAO.updateRoomSeal('false', id, principal.person);
  }

  @override
  Future<Function> sealRoom(String creator, String id) async {
    await chatRoomRemote.sealRoom(creator, id);
    await chatRoomDAO.updateRoomSeal('true', id, principal.person);
  }

  @override
  Future<Function> updateRoomTitle(String room, String title,
      {bool isOnlyLocal = false}) async {
    await chatRoomDAO.updateRoomTitle(
      title,
      principal.person,
      room,
    );
    if (!isOnlyLocal) {
      await chatRoomRemote.updateRoomTitle(room, title);
    }
  }

  @override
  Future<Function> updateRoomNickname(
      String creator, String room, String nickName,
      {bool isOnlyLocal = false}) async {
    await roomMemberDAO.updateRoomNickname(
      nickName,
      principal.person,
      room,
      principal.person,
    );
    if (!isOnlyLocal) {
      await chatRoomRemote.updateRoomNickname(creator, room, nickName);
    }
  }

  @override
  Future<Function> updateRoomBackground(ChatRoom chatRoom, path,
      {bool isOnlyLocal = false}) async {
    await chatRoomDAO.updateRoomBackground(path, chatRoom.id, principal.person);
    if (!isOnlyLocal) {
      await chatRoomRemote.updateRoomBackground(chatRoom.id, path);
    }
  }

  @override
  Future<Function> updateRoomForeground(
      ChatRoom chatRoom, bool isForegroundWhite,
      {bool isOnlyLocal = false}) async {
    await chatRoomDAO.updateRoomForeground(
        isForegroundWhite ? 'true' : 'false', chatRoom.id, principal.person);
    if (!isOnlyLocal) {
      await chatRoomRemote.updateRoomForeground(chatRoom.id, isForegroundWhite);
    }
  }

  @override
  Future<int> totalMembers(String id) async {
    CountValue value = await roomMemberDAO.totalMembers(id, principal.person);
    return value == null
        ? 0
        : value.value == null
            ? 0
            : value.value;
  }

  @override
  Future<List<RoomMember>> pageMemberLike(
      String query, String room, int limit, int offset) async {
    return await roomMemberDAO.pageMemberLike(
        principal.person, room, query, query, limit, offset);
  }

  @override
  Future<List<RoomMember>> listMember(String roomCode) async {
    return await roomMemberDAO.listdMember(principal.person, roomCode);
  }

  @override
  Future<RoomMember> getMember(String creator, String room) async {
    return await getMemberOfPerson(creator, room, principal.person);
  }

  @override
  Future<RoomMember> getMemberOfPerson(
      String creator, String room, String official) async {
    var member =
        await roomMemberDAO.getMember(room, official, principal.person);
    if (member == null) {
      var m = await chatRoomRemote.getMemberOfPerson(creator, room, official);
      if (m == null) {
        return null;
      }
      member = m.toLocal(principal.person);
    }
    return member;
  }

  @override
  Future<RoomMember> getMemberOnLocal(String room, String official) async {
    return await roomMemberDAO.getMember(room, official, principal.person);
  }

  @override
  Future<Function> switchNick(
      String creator, String room, bool showNick) async {
    await roomMemberDAO.switchNick(
        showNick ? 'true' : 'false', room, principal.person);
    await chatRoomRemote.switchNick(creator, room, showNick);
  }

  @override
  Future<Function> addRoom(ChatRoom chatRoom,
      {bool isOnlySaveLocal = false}) async {
    await chatRoomDAO.addRoom(chatRoom);
    if (!isOnlySaveLocal) {
      await chatRoomRemote.createRoom(chatRoom);
    }
  }

  @override
  Future<ChatRoom> fetchAndSaveRoom(String creator, String room) async {
    var cr = await this.chatRoomRemote.getRoom(creator, room);
    if (cr == null) {
      throw FlutterError('$creator不存在聊天室$room');
    }
    var local = cr.toLocal(principal.person);
    await chatRoomDAO.addRoom(local);
    return local;
  }

  @override
  Future<ChatRoomOR> fetchRoom(String creator, String room) async {
    return await this.chatRoomRemote.getRoom(creator, room);
  }

  @override
  Future<void> loadAndSaveRoomMembers(String room, String creator) async {
    var limit = 1000;
    var skip = 0;
    var read = 0;
    var added = [];
    while (true) {
      var list =
          await this.chatRoomRemote.pageRoomMember(creator, room, limit, skip);
      read = list.length;
      if (read < 1) {
        break;
      }
      skip += read;
      for (var m in list) {
        if (added.contains(m.person)) {
          continue;
        }
        await roomMemberDAO.addMember(m.toLocal(principal.person));
        added.add(m.person);
      }
    }
  }

  @override
  Future<List<RoomMember>> fetchMembers(String room, String creator) async {
    List<RoomMember> members = [];
    var limit = 1000;
    var skip = 0;
    var read = 0;
    var added = [];
    while (true) {
      var list =
          await this.chatRoomRemote.pageRoomMember(creator, room, limit, skip);
      read = list.length;
      if (read < 1) {
        break;
      }
      skip += read;
      for (var m in list) {
        if (added.contains(m.person)) {
          continue;
        }
        members.add(m.toLocal(principal.person));
        added.add(m.person);
      }
    }
    return members;
  }

  @override
  Future<ChatRoom> get(String room, {bool isOnlyLocal = false}) async {
    return await chatRoomDAO.getChatRoomById(room, principal.person);
  }

  @override
  Future<List<ChatRoom>> findChatroomByMembers(List<String> members) async {
    //加1的原因是因为：参数members不包括自己，所以算是自已。
    //下面是成员在的聊天室且成员数为所求传入成员+1的聊天室
    return await chatRoomDAO.findChatroomByMembers(
        members, members.length + 1, principal.person);
  }

  @override
  Future<Function> addMember(RoomMember roomMember,
      {bool isOnlySaveLocal = false}) async {
    if (!isOnlySaveLocal) {
      await chatRoomRemote.addMember(roomMember);
    }
    await roomMemberDAO.addMember(roomMember);
  }

  @override
  Future<Function> addMemberToOwner(String chatroomOwner, RoomMember roomMember,
      {bool isOnlySaveLocal = false}) async {
    if (!isOnlySaveLocal) {
      await chatRoomRemote.addMemberToOwner(chatroomOwner, roomMember);
    }
    await roomMemberDAO.addMember(roomMember);
  }

  @override
  Future<List<ChatRoom>> listChatRoom() async {
    return await chatRoomDAO.listChatRoom(principal.person);
  }

  @override
  Future<List<RoomMember>> topMember10(String code) async {
    return await roomMemberDAO.topMember10(principal.person, code);
  }

  @transaction
  @override
  Future<Function> removeChatRoom(String id) async {
    var room = await chatRoomDAO.getChatRoomById(id, principal.person);
    if (room == null) {
      return null;
    }
    await chatRoomDAO.removeChatRoomById(id, principal.person);
    await roomMemberDAO.emptyRoomMembers(room.id, principal.person);
    await messageDAO.emptyRoomMessages(room.id, principal.person);
    if (room.creator != principal.person) {
      await chatRoomRemote.removeMember(room.id, room.creator);
    } else {
      await chatRoomRemote.removeChatRoom(room.id);
    }
  }

  @override
  Future<List<String>> listFlagRoomMember(String creator, String id) async {
    return await chatRoomRemote.listFlagRoomMember(creator, id);
  }

  @override
  Future<Function> removeChatMembersOnLocal(
      String id, List<String> members) async {
    await roomMemberDAO.removeChatMembersOnLocal(id, members, principal.person);
  }

  @override
  Future<Function> emptyChatMembersOnLocal(String id) async {
    await roomMemberDAO.emptyChatMembersOnLocal(id, principal.person);
  }
}

class P2PMessageService implements IP2PMessageService, IServiceBuilder {
  IP2PMessageDAO p2pMessageDAO;
  IServiceProvider site;
  IChatRoomRemote chatRoomRemote;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    p2pMessageDAO = db.p2pMessageDAO;
    chatRoomRemote = site.getService('/remote/chat/rooms');
  }

  @override
  Future<Function> addMessage(String creator, ChatMessage message,
      {bool isOnlySaveLocal = false}) async {
    await p2pMessageDAO.addMessage(message);
    if (!isOnlySaveLocal) {
      await chatRoomRemote.pushMessage(creator, message);
    }
  }

  @override
  Future<Function> cancelMessage(String roomCreator, String room, String msgid,{bool isOnlyLocal=false}) async{
    await p2pMessageDAO.updateMsgCancel('true',  room, msgid, principal.person);
    if(!isOnlyLocal) {
      await chatRoomRemote.cancelMessage(roomCreator, room, msgid);
    }
  }

  @override
  Future<List<ChatMessage>> pageMessage(
      String roomCode, int limit, int offset) {
    return p2pMessageDAO.pageMessage(principal.person, roomCode, limit, offset);
  }

  @override
  Future<int> countUnreadMessage(String room) async {
    CountValue value = await p2pMessageDAO.countUnreadMessage(
        room, principal.person, 'arrived');
    if (value == null) {
      return 0;
    }
    return value.value;
  }

  @override
  Future<ChatMessage> firstUnreadMessage(String room) async {
    return await p2pMessageDAO.firstUnreadMessage(
        room, principal.person, 'arrived');
  }

  @override
  Future<List<ChatMessage>> listUnreadMessages(String room) async {
    return await p2pMessageDAO.listUnreadMessages(
        room, 'arrived', principal.person);
  }

  @override
  Future<Function> flatReadMessages(String room) async {
    await p2pMessageDAO.updateMessagesState(
        'readed',
        DateTime.now().millisecondsSinceEpoch,
        room,
        'arrived',
        principal.person);
  }

  @override
  Future<bool> existsMessage(String msgid) async {
    CountValue value =
        await p2pMessageDAO.countMessageWhere(msgid, principal.person);
    if (value == null) {
      return false;
    }
    return value.value > 0;
  }

  @override
  Future<ChatMessage> getMessage(String msgid) async{
    return await p2pMessageDAO.getMessage(msgid,principal.person);
  }

  @override
  Future<Function> remove(String room, String id) async{
    await p2pMessageDAO.remove(id,room,principal.person);
  }

  @override
  Future<Function> empty(ChatRoom chatRoom) async {
    await p2pMessageDAO.emptyRoomMessages(chatRoom.id, principal.person);
  }

  @override
  Future<List<RoomMessageMedia>> pageMessageWithMedia(
      String roomCode,int beginTime, limit, offset) async {
    var types=['image','video','audio'];
    var msgList = await p2pMessageDAO.pageMessageWithMedia(
        principal.person, roomCode,types,beginTime, limit, offset);
    var items = <RoomMessageMedia>[];
    for (var msg in msgList) {
      var content=msg.content;
      var obj=jsonDecode(content);
      var path=obj['path'];
      items.add(
        RoomMessageMedia(
          type: msg.contentType,
          src: path,
        ),
      );
    }
    return items;
  }

  @override
  Future<int> totalMessageWithMedia(
    String roomCode,
  int beginTime
  ) async {
    var types=['image','video','audio'];
    var count =
        await p2pMessageDAO.countMessageWithMedia(principal.person ,roomCode,types,beginTime);
    if (count == null) {
      return 0;
    }
    return count.value;
  }
}
