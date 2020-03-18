import 'dart:convert';
import 'dart:io';

import 'package:floor/floor.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class ChannelMessageService implements IChannelMessageService, IServiceBuilder {
  IChannelMessageDAO channelMessageDAO;
  IChannelMediaService mediaService;
  IChannelCommentService commentService;
  IChannelLikeService likeService;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IChannelRemote channelRemote;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelMessageDAO = db.channelMessageDAO;
    mediaService = site.getService('/channel/messages/medias');
    commentService = site.getService('/channel/messages/comments');
    likeService = site.getService('/channel/messages/likes');
    channelRemote = site.getService('/remote/channels');
  }

  @override
  Future<List<ChannelMessage>> pageMessageBy(
      int limit, int offset, String onchannel, String person) async {
    return await channelMessageDAO.pageMessageBy(
      onchannel,
      person,
      principal?.person,
      limit,
      offset,
    );
  }

  @transaction
  @override
  Future<Function> removeMessage(String id) async {
    await channelMessageDAO.removeMessage(id, principal?.person);
    List<Media> medias = await mediaService.getMedias(id);
    for (var m in medias) {
      mediaService.remove(m.id);
    }
    List<ChannelComment> comments =
        await commentService.pageComments(id, 100000000, 0);
    for (var m in comments) {
      await commentService.removeComment(m.msgid, m.id);
    }
    List<LikePerson> likes =
        await likeService.pageLikePersons(id, 100000000, 0);
    for (var m in likes) {
      await likeService.remove(m.id);
    }
  }

  @override
  Future<Function> emptyBy(String channelcode) async {
    //还要清除掉媒体文件
    await mediaService.removeBy(channelcode);
    await likeService.removeBy(channelcode);
    await commentService.removeBy(channelcode);
    await channelMessageDAO.removeMessagesBy(channelcode, principal?.person);
  }

  @override
  Future<List<ChannelMessage>> getAllMessage() async {
    return await channelMessageDAO.getAllMessage(principal.person);
  }

  @override
  Future<List<ChannelMessage>> pageMessage(
      int pageSize, int currPage, String onChannel) async {
    return await channelMessageDAO.pageMessage(
        onChannel, principal?.person, pageSize, currPage);
  }

  @override
  Future<Function> addMessage(ChannelMessage message) {
    channelMessageDAO.addMessage(message);
  }

  @override
  Future<bool> existsMessage(id) {}

  @override
  Future<Function> empty() {}

  @override
  Future<void> readAllArrivedMessage(String channelid) async {
    await channelMessageDAO.updateStateMessage(
        'readed', channelid, principal.person, 'arrived');
  }

  @override
  Future<ChannelMessageDigest> getChannelMessageDigest(String channelid) async {
    List<ChannelMessage> list = await channelMessageDAO.listMessageByState(
        channelid, principal.person, 'arrived');
    if (list.isEmpty) {
      return null;
    }
    ChannelMessage msg = list[0];
    return ChannelMessageDigest(
      text: msg.text,
      atime: msg.atime,
      count: list.length,
    );
  }

  @override
  Future<ChannelMessage> getChannelMessage(msgid) async {
    return await channelMessageDAO.getMessage(msgid, principal.person);
  }

  @override
  Future<Function> loadMessageExtraTask(ChannelMessage channelMessage) async {
    _loadExtraLikes(channelMessage);
    _loadExtraComments(channelMessage);
    _loadExtraMedias(channelMessage);
  }

  void _loadExtraLikes(ChannelMessage channelMessage) {
    int limit = 20;
    int offset = 0;
    channelRemote.listenLikeTaskCallback((likes) {
      print('赞---${likes}');
      if (likes.isNotEmpty) {
        offset += likes.length;
        channelRemote.pageLikeTask(channelMessage, limit, offset);
      }
    });
    channelRemote.pageLikeTask(channelMessage, limit, offset);
  }

  void _loadExtraComments(ChannelMessage channelMessage) {
    int limit = 20;
    int offset = 0;
    channelRemote.listenCommentTaskCallback((comments) {
      print('评---${comments}');
      if (comments.isNotEmpty) {
        offset += comments.length;
        channelRemote.pageCommentTask(channelMessage, limit, offset);
      }
    });
    channelRemote.pageCommentTask(channelMessage, limit, offset);
  }

  void _loadExtraMedias(ChannelMessage channelMessage) {
    channelRemote.listenMediaTaskCallback((medias) {
      print('媒体文件---${medias}');
    });
    channelRemote.listMediaTask(channelMessage);
  }

  @override
  Future<Function> setCurrentActivityTask(ChannelMessage channelMessage) async {
    await channelRemote.setCurrentActivityTask(channelMessage);
  }
}
