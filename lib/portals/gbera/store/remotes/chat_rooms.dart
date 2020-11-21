import 'dart:convert';
import 'dart:io';

import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/main.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
    await remotePorts.portGET(
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
  Future<Function> addMemberToOwner(
      String chatroomOwner, RoomMember roomMember) async {
    await remotePorts.portGET(
      chatPortsUrl,
      'addMemberToOwner',
      parameters: {
        'roomOwner': chatroomOwner,
        'room': roomMember.room,
        'person': roomMember.person,
        'actor': 'user',
      },
    );
  }

  @override
  Future<void> createRoom(ChatRoom chatRoom) async {
    await remotePorts.portGET(
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
  Future<ChatRoomOR> getRoom(String creator, String room) async {
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
    return ChatRoomOR.parse(map);
  }

  @override
  Future<List<RoomMemberOR>> pageRoomMember(
      String creator, String room, int i, int j) async {
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
    List<RoomMemberOR> members = [];
    for (var obj in list) {
      members.add(RoomMemberOR.parse(obj));
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
  Future<void> removeMember(String code, roomCreator) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'removeMember',
      parameters: {
        'room': code,
        'roomCreator': roomCreator,
      },
    );
  }

  @override
  Future<Function> updateRoomTitle(String room, String title) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'updateTitle',
      parameters: {
        'room': room,
        'title': title,
      },
    );
  }

  @override
  Future<Function> updateRoomNickname(
      String creator, String room, String nickName) {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'updateNickName',
      parameters: {
        'creator': creator,
        'room': room,
        'nickName': nickName,
      },
    );
  }

  @override
  Future<Function> updateRoomForeground(
      String room, bool isForegroundWhite) async {
    remotePorts.portTask.addPortGETTask(
      chatPortsUrl,
      'updateRoomForeground',
      parameters: {
        'room': room,
        'isForegroundWhite': isForegroundWhite,
      },
    );
  }

  @override
  Future<List<ChatRoomNotice>> pageNotice(
      ChatRoom chatRoom, int limit, int offset) async {
    var list = await remotePorts.portGET(
      chatPortsUrl,
      'pageNoticeOf',
      parameters: {
        'creator': chatRoom.creator,
        'room': chatRoom.id,
        'limit': limit,
        'offset': offset,
      },
    );
    var notices = <ChatRoomNotice>[];
    for (var map in list) {
      notices.add(
        ChatRoomNotice.fromMap(
          map,
          principal.person,
        ),
      );
    }
    return notices;
  }

  @override
  Future<Function> publishNotice(ChatRoom chatRoom, String text) async {
    await remotePorts.portPOST(
      chatPortsUrl,
      'publishNotice',
      parameters: {
        'room': chatRoom.id,
      },
      data: {
        'notice': text,
      },
    );
  }

  @override
  Future<ChatRoomNotice> getNewestNotice(ChatRoom chatRoom) async {
    var map = await remotePorts.portGET(
      chatPortsUrl,
      'getNewestNoticeOf',
      parameters: {
        'creator': chatRoom.creator,
        'room': chatRoom.id,
      },
    );
    if (map == null) {
      return null;
    }
    return ChatRoomNotice.fromMap(
      map,
      principal.person,
    );
  }

  @override
  Future<RoomMemberOR> getMember(String creator, String room) async {
    var map = await remotePorts.portGET(
      chatPortsUrl,
      'getRoomMember',
      parameters: {
        'creator': creator,
        'room': room,
      },
    );
    return RoomMemberOR.parse(map);
  }

  @override
  Future<RoomMemberOR> getMemberOfPerson(
      String creator, String room, String member) async {
    var map = await remotePorts.portGET(
      chatPortsUrl,
      'getHisRoomMember',
      parameters: {
        'creator': creator,
        'room': room,
        'person': member,
      },
    );
    if (map == null) {
      return null;
    }
    return RoomMemberOR.parse(map);
  }

  @override
  Future<List<String>> listFlagRoomMember(String creator, String id) async {
    var list= await remotePorts.portGET(
      chatPortsUrl,
      'listFlagRoomMember',
      parameters: {
        'creator': creator,
        'room': id,
      },
    );
    return (list as List).cast<String>();
  }

  @override
  Future<Function> switchNick(
      String creator, String room, bool showNick) async {
    await remotePorts.portGET(
      chatPortsUrl,
      'setShowNick',
      parameters: {
        'creator': creator,
        'room': room,
        'isShowNick': showNick,
      },
    );
  }

  @override
  Future<String> downloadBackground(String background) async {
    var home = await getApplicationDocumentsDirectory();
    var dir = '${home.path}/images';
    var dirFile = Directory(dir);
    if (!dirFile.existsSync()) {
      dirFile.createSync();
    }
    var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(background)}';
    var localFile = '$dir/$fn';

    ProgressTaskBar taskbarProgress =
        site.getService('@.prop.taskbar.progress');
    await remotePorts.download(
      '$background?accessToken=${principal.accessToken}',
      localFile,
      onReceiveProgress: (i, j) {
        var percent = i / j * 1.0;
        taskbarProgress.update(percent);
      },
    );
    return localFile;
  }

  @override
  Future<Function> updateRoomBackground(String room, background) async {
    ProgressTaskBar taskbarProgress =
        site.getService('@.prop.taskbar.progress');
    var listenPath = '/chatroom/$room/background.upload';
    remotePorts.portTask.listener(listenPath, (Frame frame) async {
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
          var localFile = frame.parameter('localFile');
          var remoteFile = files[localFile];
          var room = frame.parameter('room');

          await remotePorts.portGET(
            chatPortsUrl,
            'updateBackground',
            parameters: {
              'room': room,
              'background': remoteFile,
            },
          );
          print('成功上传leading:$localFile > $remoteFile');
          remotePorts.portTask.unlistener(listenPath);
          break;
        case 'receiveProgress':
          var count = frame.head('count');
          var total = frame.head('total');
          var percent = double.parse(count) / double.parse(total);
          taskbarProgress.update(percent);
          break;
      }
    });
    remotePorts.portTask.addUploadTask(
      '/app/chatroom',
      [background],
      callbackUrl: '$listenPath?room=$room&localFile=$background',
    );
  }

  @override
  Future<Function> updateRoomLeading(String roomid, String leading) {
    ProgressTaskBar taskbarProgress =
        site.getService('@.prop.taskbar.progress');
    var listenPath = '/chatroom/$roomid/leading.upload';
    remotePorts.portTask.listener(listenPath, (Frame frame) async {
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
          var localFile = frame.parameter('localFile');
          var remoteFile = files[localFile];
          var room = frame.parameter('room');

          await remotePorts.portGET(
            chatPortsUrl,
            'updateLeading',
            parameters: {
              'room': room,
              'leading': remoteFile,
            },
          );
          print('成功上传leading:$localFile > $remoteFile');
          remotePorts.portTask.unlistener(listenPath);
          break;
        case 'receiveProgress':
          var count = frame.head('count');
          var total = frame.head('total');
          var percent = double.parse(count) / double.parse(total);
          taskbarProgress.update(percent);
          break;
      }
    });
    remotePorts.portTask.addUploadTask(
      '/app/chatroom',
      [leading],
      callbackUrl: '$listenPath?room=$roomid&localFile=$leading',
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
      case 'transTo':
        remotePorts.portTask.addPortPOSTTask(
          chatFlowPortsUrl,
          'pushMessage',
          parameters: {
            'creator': creator,
            'room': message.room,
            'msgid': message.id,
            'contentType': 'transTo',
            'interval': 10,
          },
          data: {
            'content': message.content,
          },
        );
        break;
      default:
        print('不支持的消息类型:${message.contentType}');
        break;
    }
  }
}
