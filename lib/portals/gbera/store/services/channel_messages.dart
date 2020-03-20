import 'dart:convert';
import 'dart:io';

import 'package:floor/floor.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:uuid/uuid.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class ChannelMessageService implements IChannelMessageService, IServiceBuilder {
  IChannelMessageDAO channelMessageDAO;
  IChannelMediaService mediaService;
  IChannelCommentService commentService;
  IChannelLikeService likeService;
  IServiceProvider site;
  IPersonService personService;

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
    personService = site.getService('/gbera/persons');
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
  Future<Function> addMessage(ChannelMessage message) async {
    if (await channelMessageDAO.getMessage(message.id, principal.person) !=
        null) {
      return null;
    }
    await channelMessageDAO.addMessage(message);
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
  Future<Function> loadMessageExtraTask(
      String docCreator, String docid, String channel) async {
    _loadExtraLikes(docCreator, docid, channel);
    _loadExtraComments(docCreator, docid, channel);
    _loadExtraMedias(docCreator, docid, channel);
  }

  void _loadExtraLikes(String docCreator, String docid, String channel) {
    int limit = 20;
    int offset = 0;
    channelRemote.listenLikeTaskCallback((likes) async {
      //[{person: cj@gbera.netos, ctime: 1584603469425, channel: 60ae7be56e638073bcefb87b7427be4f, docid: 7682784bb92f89f1f6e662582cb29bc2}]
      if (likes.isEmpty) {
        return;
      }
      for (var like in likes) {
        Person person = await personService.getPerson(like['person'],
            isDownloadAvatar: true);
        await this.likeService.like(
            LikePerson(
              MD5Util.MD5('${person.avatar}-${principal.person}'),
              person.official,
              person.avatar,
              like['docid'],
              like['ctime'],
              person.nickName,
              like['channel'],
              principal.person,
            ),
            onlySaveLocal: true);
      }
      offset += likes.length;
      channelRemote.pageLikeTask(docCreator, docid, channel, limit, offset);
    });
    channelRemote.pageLikeTask(docCreator, docid, channel, limit, offset);
  }

  void _loadExtraComments(String docCreator, String docid, String channel) {
    int limit = 20;
    int offset = 0;
    channelRemote.listenCommentTaskCallback((comments) async {
      //[{id: 8c80ea30-69b4-11ea-9bbd-9bc293980e3a, person: cj@gbera.netos, docid: 7682784bb92f89f1f6e662582cb29bc2, content: 好了，在国内生产总值结, channel: 60ae7be56e638073bcefb87b7427be4f, ctime: 1584603475293}]
      if (comments.isEmpty) {
        return;
      }
      for (var comment in comments) {
        Person person = await personService.getPerson(comment['person'],
            isDownloadAvatar: true);
        await this.commentService.addComment(
            ChannelComment(
              comment['id'],
              person.official,
              person.avatar,
              comment['docid'],
              comment['content'],
              comment['ctime'],
              person.nickName,
              comment['channel'],
              principal.person,
            ),
            onlySaveLocal: true);
      }
      offset += comments.length;
      channelRemote.pageCommentTask(docCreator, docid, channel, limit, offset);
    });
    channelRemote.pageCommentTask(docCreator, docid, channel, limit, offset);
  }

  void _loadExtraMedias(String docCreator, String docid, String channel) {
    channelRemote.listenMediaTaskCallback((medias) async {
      //{id: 0d667240-69bb-11ea-ffad-1547cdd75721, docid: c63266e02d84a5ce7d2d7a5f0e1392df, type: image, src: http://47.105.165.186:7100/app/0d690a50-69bb-11ea-f54f-0987ba0ae1f6.jpg, text: , leading: , channel: 60ae7be56e638073bcefb87b7427be4f, ctime: 1584606269975}]
      if (medias.isEmpty) {
        return;
      }
      for (var media in medias) {
        await this.mediaService.addMedia(Media(
              media['id'],
              media['type'],
              media['src'],
              media['leading'],
              media['docid'],
              media['text'],
              media['channel'],
              principal.person,
            ));
      }
    });

    channelRemote.listMediaTask(docCreator, docid, channel);
  }

  @override
  Future<Function> setCurrentActivityTask(
      {String creator,
      String docid,
      String channel,
      String action,
      String attach}) async {
    await channelRemote.setCurrentActivityTask(
        creator: creator,
        docid: docid,
        channel: channel,
        action: action,
        attach: attach);
  }
}
