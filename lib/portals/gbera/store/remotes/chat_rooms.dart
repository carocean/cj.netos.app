import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';

import '../remotes.dart';

class ChatRoomRemote implements IChatRoomRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  String get chatPortsUrl => site.getService('@.prop.ports.link.chatroom');

  String get chatFlowPortsUrl => site.getService('@.prop.ports.flow.chatroom');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<void> addMember(RoomMember roomMember) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'addMember',
      parameters: {
        'room': roomMember.room,
        'person': roomMember.person,
        'actor': 'user',
      },
    );
  }

  @override
  Future<void> createRoom(ChatRoom chatRoom) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'createRoom',
      parameters: {
        'id': chatRoom.id,
        'title': chatRoom.title,
        'leading': chatRoom.leading,
        'microsite': chatRoom.microsite,
      },
    );
  }

  @override
  Future<void> removeChatRoom(String code) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'removeRoom',
      parameters: {
        'room': code,
      },
    );
    return null;
  }

  @override
  Future<void> removeMember(String code, official) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'removeMember',
      parameters: {
        'room': code,
        'person': official,
      },
    );
  }

  @override
  Future<Function> pushMessage(ChatMessage message) {
    var taskbarProgress = site.getService('@.prop.taskbar.progress');
    switch (message.contentType) {
      case 'text':
        remotePorts.portTask.addPortGETTask(
          chatFlowPortsUrl,
          'pushMessage',
          parameters: {
            'room': message.room,
            'msgid': message.id,
            'contentType ': message.contentType,
            'content': message.content,
            'interval': 10,
          },
        );
        break;
    }
  }
}
