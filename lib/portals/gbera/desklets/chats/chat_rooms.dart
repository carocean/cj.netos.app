import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:badges/badges.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chattalk_opener.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/sync_tasks.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:nineold/nine_old_frame.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

import '../../../../main.dart';
import 'chatroom_handler.dart';
import 'friend_page.dart';

class ChatRoomsPortlet extends StatefulWidget {
  Portlet portlet;
  Desklet desklet;
  PageContext context;

  ChatRoomsPortlet({this.portlet, this.desklet, this.context});

  @override
  _ChatRoomsPortletState createState() => _ChatRoomsPortletState();
}

class _ChatRoomsPortletState extends State<ChatRoomsPortlet> {
  bool _isloaded = false;
  List<ChatRoomModel> _models = [];
  ProgressTaskBar taskbarProgress;
  Lock _lock;

  @override
  void initState() {
    _lock = Lock();
    taskbarProgress = widget.context.site.getService('@.prop.taskbar.progress');
    if (!widget.context.isListeningMessage(matchPath: '/chat/room/message')) {
      widget.context.listenMessage(_onmessage, matchPath: '/chat/room/message');
    }
    _load().then((v) {
      if (mounted) {
        _isloaded = true;
        setState(() {});
      }
    });
    qrcodeScanner.actions['chatroom'] = QrcodeAction(
      doit: _qrcode_doit,
      parse: _qrcode_parse,
    );
    syncTaskMananger.tasks['chatroom'] = SyncTask(
      doTask: _sync_task,
    )..run(
        syncName: 'chatroom',
        context: widget.context,
        checkRemote: _sync_check,
//        forceSync: true,
      );
    super.initState();
  }

  @override
  void dispose() {
    qrcodeScanner.actions.remove('chatroom');
    taskbarProgress = null;
    // _notifyStreamController.close();
    _models.clear();
    // widget.context.unlistenMessage(matchPath: '/chat/room/message');
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatRoomsPortlet oldWidget) {
    var changed = oldWidget.portlet != widget.portlet ||
        oldWidget.desklet != widget.desklet ||
        oldWidget.runtimeType != widget.runtimeType;
    if (changed) {
      _models.clear();
      _load().then((v) {
        if (mounted) {
          _isloaded = true;
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<SyncArgs> _sync_check(PageContext context) async {
    var portsurl = context.site.getService('@.prop.ports.link.chatroom');
    return SyncArgs(
      portsUrl: portsurl,
      restCmd: 'pageRoom',
      parameters: {
        'limit': 10000,
        /*全取出来*/
        'offset': 0,
      },
    );
  }

  Future<void> _sync_task(PageContext context, Frame frame) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");

    var data = frame.contentText;
    List rooms = jsonDecode(data);
    if (rooms.isEmpty) {
      return;
    }
    for (var map in rooms) {
      var cr = ChatRoomOR.parse(map);
      ChatRoom chatRoom = cr.toLocal(context.principal.person);
      var exists = await chatRoomService.get(chatRoom.id, isOnlyLocal: true);
      if (exists != null) {
        continue;
      }
      //添加聊天室
      await chatRoomService.addRoom(chatRoom, isOnlySaveLocal: true);
      await chatRoomService.loadAndSaveRoomMembers(
          chatRoom.id, chatRoom.creator);
    }
    _models.clear();
    await _loadChatrooms();
    if (mounted) {
      setState(() {});
    }
  }

  Future<QrcodeInfo> _qrcode_parse(String itis, String data) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    var pos = data.indexOf('/');
    var creator = data.substring(0, pos);
    var room = data.substring(pos + 1);
    var chatRoom = await chatRoomService.get(room, isOnlyLocal: true);
    if (chatRoom != null) {
      List<RoomMember> members = await chatRoomService.listMember(chatRoom.id);
      List<Friend> friends = [];
      IFriendService friendService =
          widget.context.site.getService("/gbera/friends");
      for (var member in members) {
        var f = await friendService.getFriend(member.person);
        if (f == null) {
          continue;
        }
        friends.add(f);
      }
      var model = ChatRoomModel(
        chatRoom: chatRoom,
        members: friends,
      );
      return QrcodeInfo(
        itis: 'chatroom',
        title: '已加入聊天室',
        tips: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: model.leading(widget.context.principal),
            ),
            Text(
              model.displayRoomTitle(widget.context.principal),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        props: {
          'creator': creator,
          'room': room,
        },
        isHidenYesButton: true,
      );
    }
    //添加聊天室
    var roomOL = await chatRoomService.fetchRoom(
      creator,
      room,
    );
    chatRoom = roomOL.toLocal(widget.context.principal.person);
    List<RoomMember> members =
        await chatRoomService.fetchMembers(room, creator);
    List<Friend> friends = [];
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    for (var member in members) {
      var f = await friendService.getFriend(member.person);
      if (f == null) {
        continue;
      }
      friends.add(f);
    }
    var model = ChatRoomModel(
      chatRoom: chatRoom,
      members: friends,
    );
    return QrcodeInfo(
      itis: 'chatroom',
      title: '加入聊天室',
      tips: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        children: <Widget>[
          SizedBox(
            width: 80,
            child: model.leading(widget.context.principal),
          ),
          Text(
            model.displayRoomTitle(widget.context.principal),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      props: {
        'creator': creator,
        'room': room,
      },
    );
  }

  Future<Function> _qrcode_doit(QrcodeInfo info) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    var creator = info.props['creator'];
    var room = info.props['room'];
    var chatRoom = await chatRoomService.get(room, isOnlyLocal: true);
    if (chatRoom == null) {
      //添加聊天室
      chatRoom = await chatRoomService.fetchAndSaveRoom(
        creator,
        room,
      );
      await chatRoomService.loadAndSaveRoomMembers(room, creator);
    }
    _models.clear();
    await _loadChatrooms();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onmessage(Frame frame) async {
    if (!frame.url.startsWith('/chat/room/message')) {
      return;
    }
    switch (frame.command) {
      case 'pushMessage':
        await _lock.synchronized(() async {
          await _arrivePushMessageCommand(frame);
          if (mounted) {
            setState(() {});
          }
        });
        break;
    }
  }

  Future<void> _arriveAbsorbMessage(frame, content) async {
    var room = frame.parameter('room');
    var msgid = frame.parameter('msgid');
    var ctime = frame.parameter('ctime');
    var roomCreator = frame.parameter('roomCreator');
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');

    if (await messageService.existsMessage(msgid)) {
      //消息已存在
      return;
    }
    var record = jsonDecode(content);
    var nodejson = record['note'];
    if (nodejson == null) {
      return;
    }
    var map = jsonDecode(nodejson);
    var outTradeType = map['outTradeType'];
    var outTradeSn = map['outTradeSn'];
    var encourageCode = map['encourageCode'];
    var encourageCause = map['encourageCause'];

    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var info = await robotRemote.getRecipientsRecordInfo(outTradeSn);
    if (info == null) {
      return;
    }

    var chatRoom = await chatRoomService.get(room);
    if (chatRoom == null) {
      //添加聊天室
      chatRoom = ChatRoom(
        room,
        '招财猫',
        'http://47.105.165.186:7100/app/cats/cat-red.gif',
        widget.context.principal.person,
        int.parse(ctime),
        DateTime.now().millisecondsSinceEpoch,
        null,
        null,
        'false',
        'false',
        null,
        widget.context.principal.person,
      );
      var existOnRemote = await chatRoomService.fetchRoom(
          widget.context.principal.person, room);
      try {
        await chatRoomService.addRoom(
          chatRoom,
          isOnlySaveLocal: existOnRemote != null,
        );
      } catch (e) {
        print('$e');
      }
    }

    var msgcontext = jsonEncode({
      'sn': record['sn'],
      'amount': record['realAmount'],
      'ctime': record['ctime'],
      'title': record['sourceTitle'],
      'encourageCode': encourageCode,
      'encourageCause': encourageCause,
      'recordInfo': jsonEncode(info.toMap()),
    });
    var sender;
    if (info.order == 0) {
      sender = info.bankid; //添加福利中心成员
      if (!(await chatRoomService.existsMember(room, sender))) {
        IWyBankRemote wyBankRemote =
            widget.context.site.getService('/remote/wybank');
        var bank = await wyBankRemote.getWenyBank(sender);
        try {
          await chatRoomService.addMember(
              RoomMember(
                room,
                sender,
                bank.title,
                'false',
                bank.icon,
                'wybank',
                DateTime.now().millisecondsSinceEpoch,
                widget.context.principal.person,
              ),
              isOnlySaveLocal: true);
        } catch (e) {
          print('$e');
        }
      }
    } else {
      sender = info.person;
      // if (!(await chatRoomService.existsMember(room, sender))) {
      //   var person = await personService.getPerson(sender);
      //   if (person != null) {
      //     await chatRoomService.addMember(
      //         RoomMember(
      //           room,
      //           sender,
      //           person.nickName,
      //           'false',
      //           person.avatar,
      //           'person',
      //           DateTime.now().millisecondsSinceEpoch,
      //           widget.context.principal.person,
      //         ),
      //         isOnlySaveLocal: true);
      //   }
      // }
    }
    var message = ChatMessage(
      msgid,
      sender,
      room,
      '/pay/absorbs',
      msgcontext,
      'arrived',
      StringUtil.isEmpty(ctime)
          ? DateTime.now().millisecondsSinceEpoch
          : int.parse(ctime),
      DateTime.now().millisecondsSinceEpoch,
      null,
      null,
      widget.context.principal.person,
    );
    await messageService.addMessage(sender, message, isOnlySaveLocal: true);
    chatroomNotifyStreamController
        .add({'action': 'arrivePushMessageCommand', 'message': message});

    await chatRoomService.updateRoomUtime(room);
    await _topChatroom(room);
    if (mounted) {
      setState(() {});
    }
  }

  //体验金到账通知
  Future<void> _arriveTrialMessage(frame, content) async {
    var room = frame.parameter('room');
    var msgid = frame.parameter('msgid');
    var ctime = frame.parameter('ctime');
    var roomCreator = frame.parameter('roomCreator');
    var sender = frame.head('sender-person');
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');

    if (await messageService.existsMessage(msgid)) {
      //消息已存在
      return;
    }
    var obj = jsonDecode(content);
    var record = DepositTrialOR.parse(obj);

    var chatRoom = await chatRoomService.get(room);
    if (chatRoom == null) {
      //添加聊天室
      chatRoom = ChatRoom(
        room,
        '体验金',
        'http://47.105.165.186:7100/app/trials/trial.png',
        widget.context.principal.person,
        int.parse(ctime),
        DateTime.now().millisecondsSinceEpoch,
        null,
        null,
        'false',
        'false',
        null,
        widget.context.principal.person,
      );
      var existOnRemote = await chatRoomService.fetchRoom(
          widget.context.principal.person, room);
      try {
        await chatRoomService.addRoom(
          chatRoom,
          isOnlySaveLocal: existOnRemote != null,
        );
      } catch (e) {
        print('$e');
      }
    }

    if (!(await chatRoomService.existsMember(room, sender))) {
      var person = await personService.fetchPerson(sender);
      try {
        await chatRoomService.addMember(
            RoomMember(
              room,
              sender,
              person.nickName,
              'false',
              person?.avatar,
              'person',
              DateTime.now().millisecondsSinceEpoch,
              widget.context.principal.person,
            ),
            isOnlySaveLocal: true);
       await _refresh();
      } catch (e) {
        print('$e');
      }
    }
    var message = ChatMessage(
      msgid,
      sender,
      room,
      '/pay/trials',
      content,
      'arrived',
      StringUtil.isEmpty(ctime)
          ? DateTime.now().millisecondsSinceEpoch
          : int.parse(ctime),
      DateTime.now().millisecondsSinceEpoch,
      null,
      null,
      widget.context.principal.person,
    );
    await messageService.addMessage(sender, message, isOnlySaveLocal: true);
    chatroomNotifyStreamController
        .add({'action': 'arrivePushMessageCommand', 'message': message});

    await chatRoomService.updateRoomUtime(room);
    await _topChatroom(room);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _arrivePushMessageCommand(Frame frame) async {
    var content = frame.contentText;
    if (StringUtil.isEmpty(content)) {
      print('消息为空，被丢弃。');
      return null;
    }
    var room = frame.parameter('room');
    var contentType = frame.parameter('contentType');
    var msgid = frame.parameter('msgid');
    var ctime = frame.parameter('ctime');
    var roomCreator = frame.parameter('roomCreator');
    var sender = frame.head('sender-person');

    if (!StringUtil.isEmpty(contentType) && contentType == '/pay/absorbs') {
      await _arriveAbsorbMessage(frame, content);
      return null;
    }
    if (!StringUtil.isEmpty(contentType) && contentType == '/pay/trials') {
      await _arriveTrialMessage(frame, content);
      return null;
    }
    if (frame.head('sender-person') == widget.context.principal.person) {
//      print('自已的消息又发给自己，被丢弃。');
      return null;
    }

    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    if (!(await personService.existsPerson(sender))) {
      var sendPerson =
          await personService.getPerson(sender, isDownloadAvatar: true);
      if (sendPerson != null) {
        personService.addPerson(sendPerson, isOnlyLocal: true);
      }
    }

    var chatRoom = await chatRoomService.get(room, isOnlyLocal: true);
    if (chatRoom == null) {
      //添加聊天室
      chatRoom = await chatRoomService.fetchAndSaveRoom(
        roomCreator,
        room,
      );
      await chatRoomService.loadAndSaveRoomMembers(room, roomCreator);
      _models.clear();
      await _loadChatrooms();
    }

    if (!(await chatRoomService.existsMember(room, sender))) {
      var member =
          await chatRoomService.getMemberOfPerson(roomCreator, room, sender);
      if (member != null) {
        await chatRoomService.addMember(member, isOnlySaveLocal: true);
      }
    } else {
      IChatRoomRemote chatRoomRemote =
          widget.context.site.getService('/remote/chat/rooms');
      var member =
          await chatRoomRemote.getMemberOfPerson(roomCreator, room, sender);
      var exists =
          await chatRoomService.getMemberOfPerson(roomCreator, room, sender);
      if (exists.nickName != member.nickName ||
          exists.isShowNick != member.isShowNick) {
        await chatRoomService.removeMember(room, sender, isOnlySaveLocal: true);
        await chatRoomService.addMember(
            member.toLocal(widget.context.principal.person),
            isOnlySaveLocal: true);
      }
    }

    if (await messageService.existsMessage(msgid)) {
      //消息已存在
      return;
    }

    switch (contentType ?? '') {
      case '':
      case 'text':
        var message = ChatMessage(
          msgid,
          sender,
          room,
          contentType,
          content,
          'arrived',
          StringUtil.isEmpty(ctime)
              ? DateTime.now().millisecondsSinceEpoch
              : int.parse(ctime),
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          widget.context.principal.person,
        );
        await messageService.addMessage(sender, message, isOnlySaveLocal: true);
        chatroomNotifyStreamController
            .add({'action': 'arrivePushMessageCommand', 'message': message});
        await chatRoomService.updateRoomUtime(room);
        await _topChatroom(room);
        if (mounted) {
          setState(() {});
        }
        break;
      case 'audio':
        var contentmap = jsonDecode(content);
        String path = contentmap['path'];
        var home = await getApplicationDocumentsDirectory();
        var dir = '${home.path}/audios';
        var dirFile = Directory(dir);
        if (!dirFile.existsSync()) {
          dirFile.createSync();
        }
        var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(path)}';
        var localFile = '$dir/$fn';
        var listenPath = '/chatroom/message/$msgid/audio.download';
        widget.context.ports.portTask.listener(listenPath, _downloadMedia);
        widget.context.ports.portTask.addDownloadTask(
          '${path}?accessToken=${widget.context.principal.accessToken}',
          localFile,
          callbackUrl:
              '${listenPath}?msgid=$msgid&sender=$sender&room=$room&contentType=$contentType&content=$content&ctime=$ctime',
        );
        break;
      case 'image':
        var contentmap = jsonDecode(content);
        String path = contentmap['path'];
        var home = await getApplicationDocumentsDirectory();
        var dir = '${home.path}/images';
        var dirFile = Directory(dir);
        if (!dirFile.existsSync()) {
          dirFile.createSync();
        }
        var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(path)}';
        var localFile = '$dir/$fn';
        var listenPath = '/chatroom/message/$msgid/image.download';
        widget.context.ports.portTask.listener(listenPath, _downloadMedia);
        widget.context.ports.portTask.addDownloadTask(
          '${path}?accessToken=${widget.context.principal.accessToken}',
          localFile,
          callbackUrl:
              '${listenPath}?msgid=$msgid&sender=$sender&room=$room&contentType=$contentType&content=$content&ctime=$ctime',
        );
        break;
      case 'video':
        var contentmap = jsonDecode(content);
        String path = contentmap['path'];
        var home = await getApplicationDocumentsDirectory();
        var dir = '${home.path}/videos';
        var dirFile = Directory(dir);
        if (!dirFile.existsSync()) {
          dirFile.createSync();
        }
        var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(path)}';
        var localFile = '$dir/$fn';
        var listenPath = '/chatroom/message/$msgid/video.download';
        widget.context.ports.portTask.listener(listenPath, _downloadMedia);
        widget.context.ports.portTask.addDownloadTask(
          '${path}?accessToken=${widget.context.principal.accessToken}',
          localFile,
          callbackUrl:
              '${listenPath}?msgid=$msgid&sender=$sender&room=$room&contentType=$contentType&content=$content&ctime=$ctime',
        );
        break;
      case 'transTo':
        var message = ChatMessage(
          msgid,
          sender,
          room,
          contentType,
          content,
          'arrived',
          StringUtil.isEmpty(ctime)
              ? DateTime.now().millisecondsSinceEpoch
              : int.parse(ctime),
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          widget.context.principal.person,
        );
        await messageService.addMessage(sender, message, isOnlySaveLocal: true);
        chatroomNotifyStreamController
            .add({'action': 'arrivePushMessageCommand', 'message': message});
        await chatRoomService.updateRoomUtime(room);
        await _topChatroom(room);
        if (mounted) {
          setState(() {});
        }
        break;
      default:
        print('收到未知的消息类型：$contentType');
        break;
    }
  }

  Future<void> _topChatroom(room) async {
    var current;
    for (var model in _models) {
      if (model.chatRoom.id == room) {
        current = model;
        break;
      }
    }
    if (current != null) {
      _models.removeWhere((element) => element.chatRoom.id == room);
      _models.insert(0, current);
    }
  }

  Future<void> _downloadMedia(Frame frame) async {
    var subcmd = frame.head('sub-command');
    switch (subcmd) {
      case 'begin':
        break;
      case 'done':
        widget.context.ports.portTask.unlistener(frame.path);
        var ctime = frame.parameter('ctime');
        var msgid = frame.parameter('msgid');
        var sender = frame.parameter('sender');
        var room = frame.parameter('room');
        var contentType = frame.parameter('contentType');
        var contentmap = jsonDecode(frame.parameter('content'));
        var localFile = frame.head('localFile');
        contentmap['path'] = localFile;
        var content = jsonEncode(contentmap);
        var message = ChatMessage(
          msgid,
          sender,
          room,
          contentType,
          content,
          'arrived',
          StringUtil.isEmpty(ctime)
              ? DateTime.now().millisecondsSinceEpoch
              : int.parse(ctime),
          DateTime.now().millisecondsSinceEpoch,
          null,
          null,
          widget.context.principal.person,
        );
        IP2PMessageService messageService =
            widget.context.site.getService('/chat/p2p/messages');
        await messageService.addMessage(sender, message, isOnlySaveLocal: true);
        try {
          chatroomNotifyStreamController
              .add({'action': 'arrivePushMessageCommand', 'message': message});
        } catch (e) {
          print('流已关闭:$e');
        }
        IChatRoomService chatRoomService =
            widget.context.site.getService('/chat/rooms');
        await chatRoomService.updateRoomUtime(room);
        await _topChatroom(room);
        if (mounted) {
          setState(() {});
        }
        break;
      case 'error':
        print('下载失败');
        break;
      case 'receiveProgress':
        var count = frame.head('count');
        var total = frame.head('total');
        var percent = double.parse(count) / double.parse(total);
        if (mounted) {
          taskbarProgress.update(percent);
        }
        break;
    }
  }

  Future<void> _refresh() async {
    _models.clear();
    await _load();
  }

  Future<void> _load() async {
    await _loadChatrooms();
  }

  Future<void> _loadChatrooms() async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    IFriendService friendService =
        widget.context.site.getService("/gbera/friends");
    List<ChatRoom> rooms = await chatRoomService.listChatRoom();
    for (var room in rooms) {
      List<RoomMember> members = await chatRoomService.listMember(room.id);
      List<Friend> friends = [];
      for (var member in members) {
        if (!StringUtil.isEmpty(member.type) && member.type != 'person') {
          continue;
        }
        var f = await friendService.getFriend(member.person);
        if (f == null) {
          continue;
        }
        friends.add(f);
      }
      _models.add(
        ChatRoomModel(
          chatRoom: room,
          members: friends,
        ),
      );
    }
  }

  Future<void> _removeChatRoom(ChatRoom room) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.removeChatRoom(room.id);
    return;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isloaded) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('加载中，请稍候...',style: TextStyle(color: Colors.grey,),),
      );
    }
    var content;

    if (_models.isEmpty) {
      content = Padding(
        padding: EdgeInsets.only(
          bottom: 20,
          top: 20,
        ),
        child: Center(
          child: Text.rich(
            TextSpan(
              text: '没有聊天室！ ',
              style: TextStyle(
                color: Colors.grey[400],
              ),
              children: [
                TextSpan(
                  text: '点击此处建立',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      var result = await widget.context
                          .forward('/contacts/friend/selector') as List<String>;
                      if (result == null || result.isEmpty) {
                        return;
                      }
                      messageSender.open(widget.context, members: result,
                          callback: (isNewRoom) async {
                        _models.clear();
                        _loadChatrooms().then((v) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      });
                    },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      var index = 0;
      content = ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
        ),
        children: _models.map((ChatRoomModel model) {
          index++;
          return _ChatroomItem(
            context: widget.context,
            model: model,
            isBottom: index == _models.length,
            onDelete: () {
              _removeChatRoom(model.chatRoom).then((v) {
                _models.removeWhere((m) {
                  return m.chatRoom.id == model.chatRoom.id;
                });
                if (mounted) {
                  setState(() {});
                }
              });
            },
          );
        }).toList(),
      );
    }
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(
        bottom: 5,
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 0,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(''),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  var result = await widget.context
                      .forward('/contacts/friend/selector') as List<String>;
                  if (result == null || result.isEmpty) {
                    return;
                  }
                  messageSender.open(widget.context, members: result,
                      callback: (isNewRoom) async {
                    _models.clear();
                    _loadChatrooms().then((v) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  });
                },
                child: SizedBox(
                  width: 40,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
          NotificationListener(
            child: content,
            onNotification: (notification) {
              if (notification is _NotifyRoomListRefresh) {
                _models.clear();
                _load().then((v) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              }
              return false;
            },
          ),
        ],
      ),
    );
  }
}

class _ChatroomItem extends StatefulWidget {
  PageContext context;
  ChatRoomModel model;
  Function() onDelete;
  bool isBottom;

  _ChatroomItem({this.context, this.model, this.onDelete, this.isBottom});

  @override
  __ChatroomItemState createState() => __ChatroomItemState();
}

class __ChatroomItemState extends State<_ChatroomItem> {
  double _percentage = 0.0;
  _ChatroomItemStateBar _stateBar;
  bool _isLoading = false;

  @override
  void initState() {
    _stateBar = _ChatroomItemStateBar();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(_ChatroomItem oldWidget) {
    if (oldWidget.model?.chatRoom?.id != widget.model?.chatRoom?.id) {
      oldWidget.model = widget.model;
      oldWidget.isBottom = widget.isBottom;
      oldWidget.onDelete = widget.onDelete;
    }
    _load();
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    await _loadUnreadMessage();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadMessage() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    ChatMessage message =
        await messageService.firstUnreadMessage(widget.model.chatRoom.id);

    if (message == null) {
      _stateBar.count = 0;
      _stateBar.atime = null;
      _stateBar.isShow = false;
      _stateBar.brackets = null;
      _stateBar.tips = null;
      return;
    }
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');

    var count =
        await messageService.countUnreadMessage(widget.model.chatRoom.id);
    _stateBar.count = count;
    _stateBar.atime = message?.atime;
    var person = await personService.getPerson(message.sender);
    var member = await chatRoomService.getMemberOfPerson(
        widget.model.chatRoom.creator,
        widget.model.chatRoom.id,
        message.sender);
    var whois;
    if (member != null &&
        member.isShowNick == 'true' &&
        !StringUtil.isEmpty(member.nickName)) {
      whois = member?.nickName;
    } else {
      whois = person?.nickName;
    }
    _stateBar.brackets = '${count > 0 ? '$count条' : '$whois'}';
    _stateBar.isShow = true;
    switch (message?.contentType ?? '') {
      case '':
      case 'text':
        _stateBar.tips = '$whois:${message?.content}';
        break;
      case 'audio':
        var cnt = message?.content;
        var map = jsonDecode(cnt);
        double timelength = map['timelength'];
        _stateBar.tips = '$whois: 发来语音, 长度:${timelength.toStringAsFixed(0)}秒';
        break;
      case 'image':
//        var cnt = message?.content;
//        var map = jsonDecode(cnt);
        _stateBar.tips = '$whois: 发来图片';
        break;
      case 'video':
//        var cnt = message?.content;
//        var map = jsonDecode(cnt);
        _stateBar.tips = '$whois: 发来视频';
        break;
      case 'transTo':
        _stateBar.tips = '$whois: 转账给我';
        break;
      case '/pay/absorbs':
        var cnt = message?.content;
        var map = jsonDecode(cnt);
        var amount = map['amount'];
        var title = map['title'];
        var infoText = map['recordInfo'];
        var info = jsonDecode(infoText);
        var order = info['order'];
        whois = order == 0 ? member?.nickName ?? '' : whois;
        _stateBar.tips =
            '$whois: 通过招财猫[$title]发洇金给我\r\n¥${(amount / 100.00).toStringAsFixed(14)}';
        break;
      case '/pay/trials':
        var cnt = message?.content;
        var map = jsonDecode(cnt);
        var record=DepositTrialOR.parse(map);
        whois = record.payerName;
        _stateBar.tips =
        '$whois: 发体验金给我: ¥${(record.amount / 100.00).toStringAsFixed(2)}元';
        break;
      default:
        print('收到不支持的消息类型:${message.contentType}');
        break;
    }
  }

  Future<void> _updateRoomLeading(String file) async {
    IChatRoomService chatRoomService =
        widget.context.site.getService('/chat/rooms');
    await chatRoomService.updateRoomLeading(
      widget.model.chatRoom.id,
      file,
    );
  }

  @override
  Widget build(BuildContext context) {
    var imgSrc = widget.model.leading(widget.context.principal);

    var item = Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: 15,
              left: 10,
              right: 10,
              top: 15,
            ),
            child: Row(
              crossAxisAlignment: _stateBar.isShow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      //如果不是自己的管道则不能改图标
                      if (widget.context.principal.person !=
                          widget.model.chatRoom.creator) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('不可修改图标！原因：不是您创建的聊天室'),
                          ),
                        );
                        return;
                      }
                      widget.context.forward(
                        '/widgets/avatar',
                        arguments: {
                          'file': widget.model.chatRoom.leading,
                        },
                      ).then((path) {
                        if (StringUtil.isEmpty(path)) {
                          return;
                        }
                        widget.model.chatRoom.leading = path;
                        setState(() {});
                        _updateRoomLeading(path);
                      });
                    },
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: imgSrc,
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -3,
                          child: !_stateBar.isShow
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Badge(
                                  position: BadgePosition.topEnd(
                                    end: -3,
                                    top: 3,
                                  ),
                                  elevation: 0,
                                  showBadge: (_stateBar.count ?? 0) != 0,
                                  badgeContent: Text(
                                    '',
                                  ),
                                  child: null,
                                ),
                        ),
                        _percentage > 0 && _percentage < 1.0
                            ? Positioned(
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  value: _percentage,
                                ),
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: widget.model
                                    .displayRoomTitle(widget.context.principal),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      !_stateBar.isShow
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.start,
                                spacing: 5,
                                runSpacing: 3,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      text: '[${_stateBar.brackets}]',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ',
                                        ),
                                        TextSpan(
                                          text: _stateBar.tips,
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _stateBar?.atime != null
                                        ? '${TimelineUtil.format(
                                            _stateBar?.atime,
                                            locale: 'zh',
                                            dayFormat: DayFormat.Simple,
                                          )}'
                                        : '',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          widget.isBottom
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Divider(
                  height: 1,
                  indent: 60,
                ),
        ],
      ),
    );
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '删除',
          foregroundColor: Colors.grey[500],
          icon: Icons.delete,
          onTap: () {
            if (widget.onDelete != null) {
              widget.onDelete();
            }
          },
        ),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          //打开聊天室
          widget.context.forward('/portlet/chat/talk', arguments: {
            'model': widget.model,
          }).then((v) {
            if (v == 'remove') {
              _NotifyRoomListRefresh().dispatch(context);
              return;
            }
            _loadUnreadMessage().then((v) {
              setState(() {});
            });
          });
        },
        child: item,
      ),
    );
  }
}

class _ChatroomItemStateBar {
  String brackets; //括号
  String tips; //提示栏
  int atime; //时间
  int count = 0; //消息数提示，0表示无提示
  bool isShow = false; //是否显示提供
  _ChatroomItemStateBar(
      {this.brackets, this.tips, this.atime, this.count, this.isShow = false});

  Future<void> update(String command, dynamic args) async {}
}

class ChatRoomModel {
  ChatRoom chatRoom;
  List<Friend> members;

  ChatRoomModel({
    this.chatRoom,
    this.members,
  });

  ///创建者添加的成员,当聊天室无标题和头像时根据创建者添加的成员生成它
  String displayRoomTitle(UserPrincipal principal) {
    if (!StringUtil.isEmpty(chatRoom.title)) {
      return chatRoom.title;
    }
    if (members == null || members.isEmpty) {
      return "";
    }
    String name = '';
    for (int i = 0; i < members.length; i++) {
      var f = members[i];
      if (f.official == principal.person) {
        continue;
      }
      name += '${f.nickName ?? f.accountCode},';
      if (i >= 6) {
        break;
      }
    }
    if (name.endsWith(',')) {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }

  Widget leading(UserPrincipal principal) {
    if (!StringUtil.isEmpty(this.chatRoom.leading)) {
      if (this.chatRoom.leading.startsWith('/')) {
        return Image.file(
          File(this.chatRoom.leading),
          width: 40,
          height: 40,
        );
      }
      return Image.network(
        '${this.chatRoom.leading}?accessToken=${principal.accessToken}',
        height: 40,
        width: 40,
      );
    }
    //九宫格
    var list = <String>[];
    for (var i = 0; i < members.length; i++) {
      if (list.length == 9) {
        break;
      }
      var m = members[i];
      if (m.official == principal.person) {
        continue;
      }
      if (m.avatar.startsWith('/')) {
        list.add(m.avatar);
      } else {
        list.add('${m.avatar}?accessToken=${principal.accessToken}');
      }
    }
    return NineOldWidget(list);
  }
}

class _NotifyRoomListRefresh extends Notification {}
