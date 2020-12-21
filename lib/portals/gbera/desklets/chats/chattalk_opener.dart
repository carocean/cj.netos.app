import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

import 'chat_rooms.dart';

final IChatTalkOpener messageSender = _DefaultChatTalkOpener();
mixin IChatTalkOpener {
  Future<void> open(PageContext context,
      {List<String> members,
      Future<void> Function(bool isNewRoom, ChatRoomModel chatroom) callback});

  Future<void> openOnly(PageContext context,
      {Future<void> Function(bool isNewRoom, ChatRoomModel chatroom) callback,
      String roomId});

  Future<void> sendShareMessage(PageContext context, String roomCreator,
      String roomId, String comment, Map<String, String> content) {}
}

class _DefaultChatTalkOpener implements IChatTalkOpener {
  @override
  Future<Function> sendShareMessage(PageContext context, String roomCreator,
      String roomId, String comment, Map<String, String> content) async {
    content['comment'] = comment;
    var json = jsonEncode(content);
    var message = ChatMessage(
      MD5Util.MD5(Uuid().v1()),
      context.principal.person,
      roomId,
      'share',
      json,
      'sended',
      DateTime.now().millisecondsSinceEpoch,
      null,
      null,
      null,
      context.principal.person,
    );
    IP2PMessageService messageService =
        context.site.getService('/chat/p2p/messages');
    await messageService.addMessage(roomCreator, message);
  }

  @override
  Future<void> openOnly(PageContext context,
      {Future<void> Function(bool isNewRoom, ChatRoomModel chatroom) callback,
      String roomId}) async {
    var model;
    if (!StringUtil.isEmpty(roomId)) {
      model = await _getChatroomById(context, roomId);
    }
    if (model == null) {
      return;
    }
    if (callback != null) {
      await callback(false, model);
      return;
    }
    context
        .forward('/portlet/chat/talk', clearHistoryByPagePath: '/', arguments: {
      'model': model,
    }).then((value) {
      // context.forward(
      //   "/",
      //   clearHistoryByPagePath: '/',
      //   scene: context.principal.portal ?? 'gbera',
      // );
    });
  }

  @override
  Future<void> open(PageContext context,
      {List<String> members,
      Future<void> Function(bool isNewRoom, ChatRoomModel chatroom)
          callback}) async {
    var model = await _getChatroom(context, members);
    bool isNewRoom = false;
    if (model == null) {
      isNewRoom = true;
      model = await _createChatroom(context, members);
    }
    if (callback != null && isNewRoom) {
      await callback(isNewRoom, model);
      return;
    }
    context
        .forward('/portlet/chat/talk', clearHistoryByPagePath: '/', arguments: {
      'model': model,
    }).then((value) {
      // context.forward(
      //   "/",
      //   clearHistoryByPagePath: '/',
      //   scene: context.principal.portal ?? 'gbera',
      // );
    });
  }

  Future<ChatRoomModel> _getChatroomById(PageContext context, String id) async {
    IChatRoomService chatRoomService = context.site.getService('/chat/rooms');
    var chatroom = await chatRoomService.get(id);
    if (chatroom == null) {
      return null;
    }
    IFriendService friendService = context.site.getService("/gbera/friends");

    List<RoomMember> memberList = await chatRoomService.listMember(chatroom.id);

    List<Friend> friends = [];
    for (var member in memberList) {
      var f = await friendService.getFriend(member.person);
      if (f == null) {
        continue;
      }
      friends.add(f);
    }
    return ChatRoomModel(
      chatRoom: chatroom,
      members: friends,
    );
  }

  Future<ChatRoomModel> _getChatroom(
      PageContext context, List<String> members) async {
    IChatRoomService chatRoomService = context.site.getService('/chat/rooms');
    var chatrooms = await chatRoomService.findChatroomByMembers(members);
    if (chatrooms.isEmpty) {
      return null;
    }
    IFriendService friendService = context.site.getService("/gbera/friends");
    for (var chatroom in chatrooms) {
      List<RoomMember> memberList =
          await chatRoomService.listMember(chatroom.id);
      int count = 0;
      for (var member in memberList) {
        if (members.contains(member.person)) {
          count++;
        }
      }
      if (memberList.length == count + 1) {
        //+1是因为members中少了个当前我
        List<Friend> friends = [];
        for (var member in memberList) {
          var f = await friendService.getFriend(member.person);
          if (f == null) {
            continue;
          }
          friends.add(f);
        }
        return ChatRoomModel(
          chatRoom: chatroom,
          members: friends,
        );
      }
    }
    return null;
  }

  Future<ChatRoomModel> _createChatroom(
      PageContext context, List<String> members) async {
    IChatRoomService chatRoomService = context.site.getService('/chat/rooms');
    var roomCode = MD5Util.MD5(Uuid().v1());
    var chatroom = ChatRoom(
      roomCode,
      null,
      null,
      context.principal.person,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      null,
      null,
      'false',
      'false',
      null,
      context.principal.person,
    );
    await chatRoomService.addRoom(
      chatroom,
    );

    IPersonService personService = context.site.getService('/gbera/persons');
    bool hasCreator = false;
    var roomMembers = <RoomMember>[];
    for (var i = 0; i < members.length; i++) {
      var official = members[i];
      var person = await personService.getPerson(official);
      var rmember = RoomMember(
        roomCode,
        official,
        person?.nickName,
        'false',
        null,
        'person',
        DateTime.now().millisecondsSinceEpoch,
        context.principal.person,
      );
      try {
        var exists = await chatRoomService.existsMember(roomCode, official);
        if (!exists) {
          await chatRoomService.addMember(rmember);
        }
      } catch (e) {
        print('创建聊天室：添加成员时报错。$e');
      }
      roomMembers.add(rmember);
      if (official == context.principal.person) {
        hasCreator = true;
      }
    }
    if (!hasCreator) {
      //自己为创建者也应加入
      var rmember = RoomMember(
        roomCode,
        context.principal.person,
        context.principal.nickName,
        'false',
        null,
        'person',
        DateTime.now().millisecondsSinceEpoch,
        context.principal.person,
      );
      await chatRoomService.addMember(
        rmember,
        isOnlySaveLocal: true,
      );
      roomMembers.add(rmember);
    }

    IFriendService friendService = context.site.getService("/gbera/friends");
    List<Friend> friends = [];
    for (var member in roomMembers) {
      var f = await friendService.getFriend(member.person);
      if (f == null) {
        continue;
      }
      friends.add(f);
    }
    return ChatRoomModel(
      chatRoom: chatroom,
      members: friends,
    );
  }
}
