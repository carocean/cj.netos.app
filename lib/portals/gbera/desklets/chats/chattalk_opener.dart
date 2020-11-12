import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

import 'chat_rooms.dart';

final IChatTalkOpener messageSender = _DefaultChatTalkOpener();
mixin IChatTalkOpener {
  Future<void> open(PageContext context, {List<String> members});
}

class _DefaultChatTalkOpener implements IChatTalkOpener {
  @override
  Future<void> open(PageContext context, {List<String> members}) async {
    var model = await _createChatroom(context, members);

    context.forward('/portlet/chat/talk', arguments: {
      'model': model,
      'notify': chatroomNotifyStreamController?.stream?.asBroadcastStream(),
    }).then((value) {
      context.forward(
        "/",
        clearHistoryByPagePath: '/public/',
        scene: context.principal.portal ?? 'gbera',
      );
    });
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
        var exists=await  chatRoomService.existsMember(roomCode, official);
       if(!exists){
         await chatRoomService.addMember(rmember);
       }
      }catch(e){
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
