import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/system/remote/persons.dart';

import '../../../../system/local/cache/person_cache.dart';
import '../../../../system/local/dao/daos.dart';
import '../../../../system/local/dao/database.dart';
import '../remotes.dart';

class SyncPersonService implements ISyncPersonService, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IPersonCache personCache;
  IPersonService personService;
  IFriendService friendService;
  IChatRoomService chatRoomService;
  IChatRoomRemote chatRoomRemote;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    personCache = site.getService('/cache/persons');
    personService = site.getService('/gbera/persons');
    friendService = site.getService('/gbera/friends');
    chatRoomService = site.getService('/chat/rooms');
    chatRoomRemote = site.getService('/remote/chat/rooms');
    return null;
  }

  @override
  Future<bool> syncPerson(String official) async {
    var sendPersonOnRemote =
        await personService.fetchPerson(official, isDownloadAvatar: true);
    var sendPersonOnLocal = await personService.getPersonOnLocal(official);
    if (sendPersonOnLocal == null || sendPersonOnRemote == null) {
      return false;
    }
    bool updated = false;
    if (!StringUtil.isEmpty(sendPersonOnRemote.avatar) &&
        sendPersonOnLocal.avatar != sendPersonOnRemote.avatar) {
      await personService.updateAvatar(official, sendPersonOnRemote.avatar);
      await friendService.updateAvatar(official, sendPersonOnRemote.avatar);
      updated = true;
    }
    if (!StringUtil.isEmpty(sendPersonOnRemote.nickName) &&
        sendPersonOnLocal.nickName != sendPersonOnRemote.nickName) {
      await personService.updateNickName(official, sendPersonOnRemote.nickName);
      await friendService.updateNickName(official, sendPersonOnRemote.nickName);
      updated = true;
    }
    if (!StringUtil.isEmpty(sendPersonOnRemote.signature) &&
        sendPersonOnLocal.signature != sendPersonOnRemote.signature) {
      await personService.updateSignature(
          official, sendPersonOnRemote.signature);
      await friendService.updateSignature(
          official, sendPersonOnRemote.signature);
      updated = true;
    }
    if (!StringUtil.isEmpty(sendPersonOnRemote.pyname) &&
        sendPersonOnLocal.pyname != sendPersonOnRemote.pyname) {
      await personService.updatePyname(official, sendPersonOnRemote.pyname);
      await friendService.updatePyname(official, sendPersonOnRemote.pyname);
      updated = true;
    }
    if (updated) {
      await personCache.update(sendPersonOnRemote);
    }
    return updated;
  }

  @override
  Future<bool> syncChatroom(String creator, String room, String member) async {
    var roomOnRemote = await chatRoomService.fetchRoom(creator, room);
    var roomOnLocal = await chatRoomService.get(room, isOnlyLocal: true);
    if (roomOnLocal == null || roomOnRemote == null) {
      return false;
    }
    bool _updated = false;
    if (!StringUtil.isEmpty(roomOnRemote.leading) &&
        roomOnLocal.leading != roomOnRemote.leading) {
      await chatRoomService.updateRoomLeading(room, roomOnRemote.leading,
          isOnlyLocal: true);
      _updated = true;
    }
    if (!StringUtil.isEmpty(roomOnRemote.title) &&
        roomOnLocal.title != roomOnRemote.title) {
      await chatRoomService.updateRoomTitle(room, roomOnRemote.title,
          isOnlyLocal: true);
      _updated = true;
    }
    if (!StringUtil.isEmpty(roomOnRemote.background) &&
        roomOnLocal.p2pBackground != roomOnRemote.background) {
      await chatRoomService.updateRoomBackground(
          roomOnLocal, roomOnRemote.background,
          isOnlyLocal: true);
      _updated = true;
    }
    if (roomOnRemote.isForegroundWhite != null &&
        roomOnLocal.isForegoundWhite !=
            ((roomOnRemote.isForegroundWhite ?? false) ? 'true' : 'false')) {
      await chatRoomService.updateRoomForeground(
          roomOnLocal, roomOnRemote.isForegroundWhite,
          isOnlyLocal: true);
      _updated = true;
    }
    var isSeal = roomOnRemote.isSeal ?? false;
    if (roomOnLocal.isSeal != (isSeal?'true':'false')) {
      if (isSeal) {
        await chatRoomService.sealRoom(roomOnLocal.creator, roomOnLocal.id);
      } else {
        await chatRoomService.unsealRoom(roomOnLocal.creator, roomOnLocal.id);
      }
      _updated = true;
    }
    var memberOnRomete =
        await chatRoomRemote.getMemberOfPerson(creator, room, member);
    var memberOnLocal = await chatRoomService.getMemberOnLocal(room, member);
    if (memberOnLocal == null || memberOnRomete == null) {
      return _updated;
    }
    if (!StringUtil.isEmpty(memberOnRomete.nickName) &&
        memberOnLocal.nickName != memberOnRomete.nickName) {
      await chatRoomService.updateRoomNickname(
          creator, room, memberOnRomete.nickName,
          isOnlyLocal: true);
    }
    return _updated;
  }
}
