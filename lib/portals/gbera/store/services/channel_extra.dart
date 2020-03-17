import 'dart:io';

import 'package:framework/framework.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';

import '../../../../system/local/entities.dart';
import '../remotes.dart';
import '../services.dart';

class ChannelMediaService implements IChannelMediaService, IServiceBuilder {
  IChannelMediaDAO channelMediaDAO;
  IServiceProvider site;
  IChannelRemote channelRemote;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelMediaDAO = db.channelMediaDAO;
    channelRemote = site.getService('/remote/channels');
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
    if (StringUtil.isEmpty(media.src)) {
      return;
    }
    var f = File(media.src);
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

  UserPrincipal get principal => site.getService('@.principal');

  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelLikeDAO = db.channelLikeDAO;
    channelRemote = site.getService('/remote/channels');
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
  Future<bool> isLiked(String msgid, String person) async {
    var likes =
        await channelLikeDAO.getLikePersonBy(msgid, person, principal?.person);
    return likes.isEmpty ? false : true;
  }

  @override
  Future<Function> unlike(String msgid, String person) async {
    await channelLikeDAO.removeLikePersonBy(msgid, person, principal?.person);
    await channelRemote.unlike(msgid);
  }

  @override
  Future<Function> like(LikePerson like) async {
    await channelLikeDAO.addLikePerson(like);
    await channelRemote.like(like.msgid);
  }
}

class ChannelCommentService implements IChannelCommentService, IServiceBuilder {
  IChannelCommentDAO channelCommentDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IChannelRemote channelRemote;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelCommentDAO = db.channelCommentDAO;
    channelRemote = site.getService('/remote/channels');
  }

  @override
  Future<Function> removeBy(String channelcode) async {
    await channelCommentDAO.removeCommentBy(channelcode, principal?.person);
  }

  @override
  Future<Function> addComment(ChannelComment comment) async {
    await channelCommentDAO.addComment(comment);
    await channelRemote.addComment(comment.msgid, comment.text, comment.id);
  }

  @override
  Future<List<ChannelComment>> pageComments(
      String msgid, int pageSize, int offset) async {
    return await channelCommentDAO.pageLikeCommentBy(
        msgid, principal?.person, pageSize, offset);
  }

  @override
  Future<Function> removeComment(String msgid, String commentid) async {
    await channelCommentDAO.removeComment(commentid, principal?.person);
    await channelRemote.removeComment(msgid, commentid);
  }
}
