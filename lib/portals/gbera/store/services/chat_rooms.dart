import 'dart:math';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
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
  Future<List<Friend>> pageFriendLikeName(
      String name, List<String> officials, int limit, int offset) async {
    return await friendDAO.pageFriendLikeName(
        principal.person, name, name, name, officials, limit, offset);
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

  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IChatRoomRemote chatRoomRemote;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    chatRoomDAO = db.chatRoomDAO;
    roomMemberDAO = db.roomMemberDAO;
    chatRoomRemote = site.getService('/remote/chat/rooms');
  }

  @override
  Future<List<RoomMember>> top20Members(String code) async {
    return chatRoomDAO.top20Members(principal.person, code);
  }

  @override
  Future<Function> removeMember(String code, official,
      {bool isOnlySaveLocal = false}) async {
    await roomMemberDAO.removeMember(code, official, principal.person);
    if (!isOnlySaveLocal) {
      await chatRoomRemote.removeMember(code, official);
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
  Future<Function> updateRoomLeading(String roomid, String file) async {
    await chatRoomDAO.updateRoomLeading(
      file,
      principal.person,
      roomid,
    );
  }

  @override
  Future<List<RoomMember>> listdMember(String roomCode) async {
    return await roomMemberDAO.listdMember(principal.person, roomCode);
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
    await chatRoomDAO.addRoom(cr);
    return cr;
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
        await roomMemberDAO.addMember(m);
        added.add(m.person);
      }
    }
  }

  @override
  Future<ChatRoom> get(String room, {bool isOnlyLocal = false}) async {
    return await chatRoomDAO.getChatRoomById(room, principal.person);
  }

  @override
  Future<Function> addMember(RoomMember roomMember,
      {bool isOnlySaveLocal = false}) async {
    await roomMemberDAO.addMember(roomMember);
    if (!isOnlySaveLocal) {
      await chatRoomRemote.addMember(roomMember);
    }
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
  Future<Function> removeChatRoom(String id,
      {bool isOnlySaveLocal = false}) async {
    var room = await chatRoomDAO.getChatRoomById(id, principal.person);
    if (room == null) {
      return null;
    }
    await chatRoomDAO.removeChatRoomById(id, principal.person);
    await roomMemberDAO.emptyRoomMembers(room.id, principal.person);
    if (!isOnlySaveLocal) {
      await chatRoomRemote.removeChatRoom(room.id);
    }
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
  Future<bool> existsMessage(String msgid) async{
    CountValue value =await
        p2pMessageDAO.countMessageWhere(msgid, principal.person);
    if (value == null) {
      return false;
    }
    return value.value > 0;
  }
}
