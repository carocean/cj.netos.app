import 'dart:convert';

import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/main.dart';
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
  Future<ChatRoom> getRoom(String creator, String room) async {
    var map = await remotePorts.portGET(
      chatPortsUrl,
      'getRoomOfPerson',
      parameters: {
        'room': room,
        'person': creator,
      },
    );
    if (map == null) {
      return null;
    }
    return ChatRoom.fromMap(map, principal.person);
  }

  @override
  Future<List<RoomMember>> pageRoomMember(
      String creator, String room, int i, int j) async {
    print(principal.accessToken);
    var list = await remotePorts.portGET(
      chatPortsUrl,
      'pageRoomMembersOfPerson',
      parameters: {
        'room': room,
        'creator': creator,
        'limit': i,
        'offset': j,
      },
    );
    List<RoomMember> members = [];
    for (var obj in list) {
      members.add(RoomMember.formMap(obj, principal.person));
    }
    return members;
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
  Future<Function> pushMessage(String creator, ChatMessage message) {
    ProgressTaskBar taskbarProgress =
        site.getService('@.prop.taskbar.progress');
    switch (message.contentType ?? '') {
      case '':
      case 'text':
        remotePorts.portTask.addPortPOSTTask(
          chatFlowPortsUrl,
          'pushMessage',
          parameters: {
            'creator': creator,
            'room': message.room,
            'msgid': message.id,
            'contentType': 'text',
            'interval': 10,
          },
          data: {
            'content': message.content,
          },
        );
        break;
      case 'audio':
        var listenPath = '/chatroom/talk/${message.id}/audio.upload';
        remotePorts.portTask.listener(listenPath, (Frame frame) {
          if (frame.command != 'upload') {
            return;
          }
          var subcmd = frame.head('sub-command');
          switch (subcmd) {
            case 'begin':
              break;
            case 'done':
              var json = frame.contentText;
              var files = jsonDecode(json);
              var remoteFile = files[frame.parameter('localPath')];
              var content = jsonDecode(frame.parameter('content'));
              content['path'] = remoteFile;
              remotePorts.portTask.addPortPOSTTask(
                chatFlowPortsUrl,
                'pushMessage',
                parameters: {
                  'creator': frame.parameter('creator'),
                  'room': frame.parameter('room'),
                  'msgid': frame.parameter('msgid'),
                  'contentType': 'audio',
                  'content': jsonEncode(content),
                  'interval': 10,
                },
                data: {
                  'content': jsonEncode(content),
                },
              );
              remotePorts.portTask.unlistener(listenPath);
              break;
            case 'sendProgress':
              var count = frame.head('count');
              var total = frame.head('total');
              var percent = double.parse(count) / double.parse(total);
              taskbarProgress.update(percent);
              break;
          }
        });
        var content = jsonDecode(message.content);
        var localPath = content['path'];
        remotePorts.portTask.addUploadTask(
          '/app/chatroom/',
          [localPath],
          callbackUrl:
              '$listenPath?creator=$creator&room=${message.room}&msgid=${message.id}&content=${message.content}&localPath=$localPath',
        );
        break;
      case 'image':
      case 'takePhoto':
        var listenPath = '/chatroom/talk/${message.id}/image.upload';
        remotePorts.portTask.listener(listenPath, (Frame frame) {
          if (frame.command != 'upload') {
            return;
          }
          var subcmd = frame.head('sub-command');
          switch (subcmd) {
            case 'begin':
              break;
            case 'done':
              var json = frame.contentText;
              var files = jsonDecode(json);
              var remoteFile = files[frame.parameter('localPath')];
              var content = {
                'path': remoteFile,
              };
              remotePorts.portTask.addPortPOSTTask(
                chatFlowPortsUrl,
                'pushMessage',
                parameters: {
                  'creator': frame.parameter('creator'),
                  'room': frame.parameter('room'),
                  'msgid': frame.parameter('msgid'),
                  'contentType': 'image',
                  'interval': 10,
                },
                data: {
                  'content': jsonEncode(content),
                },
              );
              remotePorts.portTask.unlistener(listenPath);
              break;
            case 'sendProgress':
              var count = frame.head('count');
              var total = frame.head('total');
              var percent = double.parse(count) / double.parse(total);
              taskbarProgress.update(percent);
              break;
          }
        });
        var content = jsonDecode(message.content);
        var localPath = content['path'];
        remotePorts.portTask.addUploadTask(
          '/app/chatroom/',
          [localPath],
          callbackUrl:
              '$listenPath?creator=$creator&room=${message.room}&msgid=${message.id}&content=${message.content}&localPath=$localPath',
        );
        break;
      case 'video':
      case 'recordVideo':
        var listenPath = '/chatroom/talk/${message.id}/video.upload';
        remotePorts.portTask.listener(listenPath, (Frame frame) {
          if (frame.command != 'upload') {
            return;
          }
          var subcmd = frame.head('sub-command');
          switch (subcmd) {
            case 'begin':
              break;
            case 'done':
              var json = frame.contentText;
              var files = jsonDecode(json);
              var remoteFile = files[frame.parameter('localPath')];
              var content = {
                'path': remoteFile,
              };
              remotePorts.portTask.addPortPOSTTask(
                chatFlowPortsUrl,
                'pushMessage',
                parameters: {
                  'creator': frame.parameter('creator'),
                  'room': frame.parameter('room'),
                  'msgid': frame.parameter('msgid'),
                  'contentType': 'video',
                  'interval': 10,
                },
                data: {
                  'content': jsonEncode(content),
                },
              );
              remotePorts.portTask.unlistener(listenPath);
              break;
            case 'sendProgress':
              var count = frame.head('count');
              var total = frame.head('total');
              var percent = double.parse(count) / double.parse(total);
              taskbarProgress.update(percent);
              break;
          }
        });
        var content = jsonDecode(message.content);
        var localPath = content['path'];
        remotePorts.portTask.addUploadTask(
          '/app/chatroom/',
          [localPath],
          callbackUrl:
          '$listenPath?creator=$creator&room=${message.room}&msgid=${message.id}&content=${message.content}&localPath=$localPath',
        );
        break;
      default:
        print('不支持的消息类型:${message.contentType}');
        break;
    }
  }
}
