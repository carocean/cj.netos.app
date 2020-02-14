import 'dart:io';

import 'package:framework/framework.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class ChannelMediaService implements IChannelMediaService, IServiceBuilder {
  IChannelMediaDAO channelMediaDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  OnReadyCallback builder(IServiceProvider site)  {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelMediaDAO = db.channelMediaDAO;
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
    var list = await getMediasBy(channelid);
    for (var m in list) {
      _deleteFile(m);
    }
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

  UserPrincipal get principal => site.getService('@.principal');

  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelLikeDAO = db.channelLikeDAO;
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
  }

  @override
  Future<Function> like(LikePerson like) async {
    await channelLikeDAO.addLikePerson(like);
  }
}

class ChannelCommentService implements IChannelCommentService, IServiceBuilder {
  IChannelCommentDAO channelCommentDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelCommentDAO = db.channelCommentDAO;
  }

  @override
  Future<Function> removeBy(String channelcode) async {
    await channelCommentDAO.removeCommentBy(channelcode, principal?.person);
  }

  @override
  Future<Function> addComment(ChannelComment comment) async {
    await channelCommentDAO.addComment(comment);
  }

  @override
  Future<List<ChannelComment>> pageComments(
      String msgid, int pageSize, int offset) async {
    return await channelCommentDAO.pageLikeCommentBy(
        msgid, principal?.person, pageSize, offset);
  }

  @override
  Future<Function> removeComment(String id) async {
    await channelCommentDAO.removeComment(id, principal?.person);
  }
}
