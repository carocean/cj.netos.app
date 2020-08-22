import 'dart:io';

import 'package:framework/framework.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'dart:async';
import '../../../../system/local/entities.dart';
import '../remotes.dart';
import '../services.dart';

class ChannelMediaService implements IChannelMediaService, IServiceBuilder {
  IChannelMediaDAO channelMediaDAO;
  IServiceProvider site;
  IChannelRemote channelRemote;
  IChannelMessageService messageService;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelMediaDAO = db.channelMediaDAO;
    channelRemote = site.getService('/remote/channels');
    messageService = site.getService('/channel/messages');
    return null;
  }

  @override
  Future<void> remove(String id) async {
    var m = await channelMediaDAO.getMedia(id, principal?.person);
    if (m == null) {
      return;
    }
    _deleteFile(m);
    await channelMediaDAO.removeMedia(id, principal?.person);
  }

  _deleteFile(media) {
    if (StringUtil.isEmpty(media._src)) {
      return;
    }
    var f = File(media._src);
    if (f.existsSync()) {
      try {
        f.deleteSync();
      } catch (e) {
        print('$e');
      }
    }
  }

  @override
  Future<Function> removeBy(String channelid) async {
//    var list = await getMediasBy(channelid);
//    for (var m in list) {
//      _deleteFile(m);
//    }
    await channelMediaDAO.removeMedia(channelid, principal?.person);
  }

  @override
  Future<Function> addMedia(Media media) async {
    if(await channelMediaDAO.getMedia(media.id, principal.person)!=null){
      return null;
    }
    await channelMediaDAO.addMedia(media);
  }

  @override
  Future<List<Media>> getMedias(String messageid) async {
    return await channelMediaDAO.getMediaByMsgId(messageid, principal?.person);
  }

  @override
  Future<List<Media>> getMediasBy(String channelcode) async {
    return await channelMediaDAO.getMediaBychannelcode(
        channelcode, principal?.person);
  }
}

class ChannelLikeService implements IChannelLikeService, IServiceBuilder {
  IChannelLikePersonDAO channelLikeDAO;
  IServiceProvider site;

  IChannelRemote channelRemote;
  IChannelMessageService messageService;

  UserPrincipal get principal => site.getService('@.principal');

  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelLikeDAO = db.channelLikeDAO;
    channelRemote = site.getService('/remote/channels');
    messageService = site.getService('/channel/messages');
  }

  @override
  Future<Function> removeBy(String channelcode) async {
    await channelLikeDAO.removeLikePersonByChannel(
        channelcode, principal?.person);
  }

  @override
  Future<Function> remove(String id) async {
    await channelLikeDAO.removeLikePerson(id, principal?.person);
  }

  @override
  Future<List<LikePerson>> pageLikePersons(
      String msgid, int pageSize, int offset) async {
    return await channelLikeDAO.pageLikePersonBy(
        msgid, principal?.person, pageSize, offset);
  }

  @override
  Future<List<LikePerson>> listLikePerson() async {
    return await channelLikeDAO.getAllLikePerson(principal.person);
  }

  @override
  Future<bool> isLiked(String msgid, String liker) async {
    var likes =
        await channelLikeDAO.getLikePersonBy(msgid, liker, principal?.person);
    return likes.isEmpty ? false : true;
  }

  @override
  Future<Function> unlike(String msgid, String liker,
      {bool onlySaveLocal = false}) async {
    await channelLikeDAO.removeLikePersonBy(msgid, liker, principal?.person);
    if (onlySaveLocal) {
      return null;
    }
    ChannelMessage message = await messageService.getChannelMessage(msgid);
    if(message==null) {
      return null;
    }
    await channelRemote.unlike(message.id, message.onChannel, message.creator);
  }

  @override
  Future<Function> like(LikePerson like, {bool onlySaveLocal = false}) async {
    if (await channelLikeDAO.getLikePerson(like.id, principal.person)!=null) {
      return null;
    }
    await channelLikeDAO.addLikePerson(like);
    if (onlySaveLocal) {
      return null;
    }
    ChannelMessage message = await messageService.getChannelMessage(like.msgid);
    await channelRemote.like(message.id, message.onChannel, message.creator);
  }
}

class ChannelCommentService implements IChannelCommentService, IServiceBuilder {
  IChannelCommentDAO channelCommentDAO;
  IServiceProvider site;
  IChannelMessageService messageService;

  UserPrincipal get principal => site.getService('@.principal');
  IChannelRemote channelRemote;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelCommentDAO = db.channelCommentDAO;
    channelRemote = site.getService('/remote/channels');
    messageService = site.getService('/channel/messages');
  }

  @override
  Future<Function> removeBy(String channelcode) async {
    await channelCommentDAO.removeCommentBy(channelcode, principal?.person);
  }

  @override
  Future<Function> addComment(ChannelComment comment,
      {bool onlySaveLocal = false}) async {
    if (await channelCommentDAO.getComment(comment.id, principal.person) !=
        null) {
      return null;
    }
    await channelCommentDAO.addComment(comment);
    if (onlySaveLocal) {
      return null;
    }
    ChannelMessage message =
        await messageService.getChannelMessage(comment.msgid);
    await channelRemote.addComment(message.id, message.onChannel,
        message.creator, comment.text, comment.id);
  }

  @override
  Future<List<ChannelComment>> pageComments(
      String msgid, int pageSize, int offset) async {
    return await channelCommentDAO.pageLikeCommentBy(
        msgid, principal?.person, pageSize, offset);
  }

  @override
  Future<Function> removeComment(String msgid, String commentid,
      {bool onlySaveLocal = false}) async {
    await channelCommentDAO.removeComment(commentid, principal?.person);
    if (onlySaveLocal) {
      return null;
    }
    ChannelMessage message = await messageService.getChannelMessage(msgid);
    if(message==null) {
      return null;
    }
    await channelRemote.removeComment(
        message.id, message.onChannel, message.creator, commentid);
  }
}
