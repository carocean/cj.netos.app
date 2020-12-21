import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';

class GeosphereMessageService
    implements IGeosphereMessageService, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IGeosphereMessageDAO messageDAO;
  IGeosphereMediaDAO mediaDAO;
  IGeoReceptorRemote receptorRemote;
  IGeoReceptorDAO geoReceptorDAO;
  IPersonService personService;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    messageDAO = db.geosphereMessageDAO;
    mediaDAO = db.geosphereMediaDAO;
    geoReceptorDAO = db.geoReceptorDAO;
    receptorRemote = site.getService('/remote/geo/receptors');
    personService = site.getService('/gbera/persons');
  }

  @override
  Future<void> addMessage(GeosphereMessageOL geosphereMessageOL,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.addMessage(geosphereMessageOL);
    if (!isOnlySaveLocal) {
      await receptorRemote
          .publishMessage(GeosphereMessageOR.form(geosphereMessageOL));
    }
  }

  @override
  Future<List<GeosphereMessageOL>> pageMessage(
      String receptor, int limit, int offset) async {
    return await messageDAO.pageMessage(
        receptor, principal.person, limit, offset);
  }

  @override
  Future<List<GeosphereMessageOL>> pageFilterMessage(
      String receptor, String filterCategory, int limit, int offset) async {
    return await messageDAO.pageFilterMessage(
        receptor, filterCategory, principal.person, limit, offset);
  }

  @override
  Future<List<GeosphereMessageOL>> pageMyMessage(
      String receptor, String creator, int limit, int offset) async {
    return await messageDAO.pageMyMessage(
        receptor, creator, principal.person, limit, offset);
  }

  @override
  Future<Function> removeMessage(String receptor, String msgid) async {
    await messageDAO.removeMessage(receptor, msgid, principal.person);
    await mediaDAO.empty(receptor, msgid, principal.person);
    await receptorRemote.removeMessage(receptor, msgid);
  }

  @override
  Future<GeosphereMessageOL> getMessage(String receptor, msgid) async {
    return await messageDAO.getMessage(receptor, msgid, principal.person);
  }

  @override
  Future<GeosphereMessageOL> firstUnreadMessage(String receptor) async {
    return await messageDAO.firstUnreadMessage(
        receptor, 'arrived', principal.person);
  }

  @override
  Future<int> countUnreadMessage(String receptor) async {
    var value = await messageDAO.listUnreadMessage(
        receptor, 'arrived', principal.person);
    return value?.value ?? 0;
  }

  @override
  Future<Function> flagMessagesReaded(String receptor) async {
    await messageDAO.flagArrivedMessagesReaded(
        'readed', receptor, 'arrived', principal.person);
  }

  @override
  Future<bool> isLiked(String receptor, String msgid, String liker) async {
    var like = await messageDAO.getLikePersonBy(
        receptor, msgid, liker, principal?.person);
    return like != null;
  }

  @override
  Future<Function> unlike(String receptor, String msgid, String liker,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.unlike(receptor, msgid, liker, principal.person);
    if (!isOnlySaveLocal) {
      await receptorRemote.unlike(receptor, msgid);
    }
  }

  @override
  Future<Function> like(GeosphereLikePersonOL likePerson,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.unlike(likePerson.msgid, likePerson.receptor,
        likePerson.person, principal.person);
    await messageDAO.like(likePerson);
    if (!isOnlySaveLocal) {
      await receptorRemote.like(likePerson.receptor, likePerson.msgid);
    }
  }

  @override
  Future<List<GeosphereLikePersonOL>> pageLikePersons(
      String receptor, String msgid, int limit, int offset) async {
    return await messageDAO.pageLikePersons(
        receptor, msgid, principal.person, limit, offset);
  }

  @override
  Future<Function> loadMessageExtraTask(
      String docCreator, String docid, String receptor) async {
    _loadExtraLikes(docCreator, docid, receptor);
    _loadExtraComments(docCreator, docid, receptor);
    _loadExtraMedias(docCreator, docid, receptor);
  }

  void _loadExtraLikes(String docCreator, String docid, String receptor) {
    int limit = 20;
    int offset = 0;
    receptorRemote.listenLikeTaskCallback((likes) async {
      //[{person: cj@gbera.netos, ctime: 1584603469425, receptor: 60ae7be56e638073bcefb87b7427be4f, docid: 7682784bb92f89f1f6e662582cb29bc2}]
      if (likes.isEmpty) {
        return;
      }
      for (var like in likes) {
        Person person = await personService.getPerson(like['person'],
            isDownloadAvatar: true);
        var likeOL = GeosphereLikePersonOL(
          MD5Util.MD5('${person.avatar}-${principal.person}'),
          person.official,
          person.avatar,
          like['docid'],
          like['ctime'],
          person.nickName,
          like['receptor'],
          principal.person,
        );
        await this.messageDAO.like(likeOL);
      }
      offset += likes.length;
      receptorRemote.pageLikeTask(docCreator, docid, receptor, limit, offset);
    });
    receptorRemote.pageLikeTask(docCreator, docid, receptor, limit, offset);
  }

  void _loadExtraComments(String docCreator, String docid, String channel) {
    int limit = 20;
    int offset = 0;
    receptorRemote.listenCommentTaskCallback((comments) async {
      //[{id: 8c80ea30-69b4-11ea-9bbd-9bc293980e3a, person: cj@gbera.netos, docid: 7682784bb92f89f1f6e662582cb29bc2, content: 好了，在国内生产总值结, receptor: 60ae7be56e638073bcefb87b7427be4f, ctime: 1584603475293}]
      if (comments.isEmpty) {
        return;
      }
      for (var comment in comments) {
        Person person = await personService.getPerson(comment['person'],
            isDownloadAvatar: true);
        var commentOL = GeosphereCommentOL(
          comment['id'],
          person.official,
          person.avatar,
          comment['docid'],
          comment['content'],
          comment['ctime'],
          person.nickName,
          comment['receptor'],
          principal.person,
        );
        await this.messageDAO.addComment(commentOL);
      }
      offset += comments.length;
      receptorRemote.pageCommentTask(docCreator, docid, channel, limit, offset);
    });
    receptorRemote.pageCommentTask(docCreator, docid, channel, limit, offset);
  }

  void _loadExtraMedias(String docCreator, String docid, String channel) {
    receptorRemote.listenMediaTaskCallback((medias) async {
      //{id: 0d667240-69bb-11ea-ffad-1547cdd75721, docid: c63266e02d84a5ce7d2d7a5f0e1392df, type: image, src: http://47.105.165.186:7100/app/0d690a50-69bb-11ea-f54f-0987ba0ae1f6.jpg, text: , leading: , receptor: 60ae7be56e638073bcefb87b7427be4f, ctime: 1584606269975}]
      if (medias.isEmpty) {
        return;
      }
      for (var media in medias) {
        var mediaOL = GeosphereMediaOL(
          media['id'],
          media['type'],
          media['src'],
          media['leading'],
          media['docid'],
          media['text'],
          media['receptor'],
          principal.person,
        );
        await this.mediaDAO.addMedia(mediaOL);
      }
    });

    receptorRemote.listMediaTask(docCreator, docid, channel);
  }

  @override
  Future<Function> removeComment(
      String receptor, String msgid, String commentid,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.removeComment(
        receptor, msgid, commentid, principal.person);
    if (!isOnlySaveLocal) {
      await receptorRemote.removeComment(receptor, msgid, commentid);
    }
  }

  @override
  Future<Function> addComment(GeosphereCommentOL geosphereCommentOL,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.addComment(geosphereCommentOL);
    if (!isOnlySaveLocal) {
      await receptorRemote.addComment(
          geosphereCommentOL.receptor,
          geosphereCommentOL.msgid,
          geosphereCommentOL.id,
          geosphereCommentOL.text);
    }
  }

  @override
  Future<List<GeosphereCommentOL>> pageComments(
      String receptor, String msgid, int limit, int offset) async {
    return await messageDAO.pageComments(
        receptor, msgid, principal.person, limit, offset);
  }
}

class GeosphereMediaService implements IGeosphereMediaService, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IGeosphereMediaDAO mediaDAO;
  IGeoReceptorRemote receptorRemote;
  IGeoReceptorDAO geoReceptorDAO;

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    mediaDAO = db.geosphereMediaDAO;
    geoReceptorDAO = db.geoReceptorDAO;
    receptorRemote = site.getService('/remote/geo/receptors');
  }

  @override
  Future<void> addMedia(GeosphereMediaOL geosphereMediaOL,
      {bool isOnlySaveLocal = false}) async {
    await mediaDAO.addMedia(geosphereMediaOL);
    if (!isOnlySaveLocal) {
      var o =
          await geoReceptorDAO.get(geosphereMediaOL.receptor, principal.person);
      await receptorRemote.uploadMedia(geosphereMediaOL);
    }
  }

  @override
  Future<Function> addMediaNotPush(GeosphereMediaOL media) async {
    await mediaDAO.addMedia(media);
    await receptorRemote.addMedia2(media);
  }

  @override
  Future<List<GeosphereMediaOL>> listMedia(
      String receptor, String messageid) async {
    return await mediaDAO.listMedia(receptor, messageid, principal.person);
  }
}
