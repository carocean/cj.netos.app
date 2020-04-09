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

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    messageDAO = db.geosphereMessageDAO;
    mediaDAO = db.geosphereMediaDAO;
    geoReceptorDAO = db.geoReceptorDAO;
    receptorRemote = site.getService('/remote/geo/receptors');
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
      String receptor,String filterCategory, int limit, int offset) async {
    return await messageDAO.pageFilterMessage(
        receptor,filterCategory, principal.person, limit, offset);
  }
  @override
  Future<List<GeosphereMessageOL>> pageMyMessage(
      String receptor, String creator, int limit, int offset) async {
    return await messageDAO.pageMyMessage(
        receptor, creator, principal.person, limit, offset);
  }

  @override
  Future<Function> removeMessage(
      String category, String receptor, String msgid) async {
    await messageDAO.removeMessage(msgid, receptor, principal.person);
    await mediaDAO.empty(receptor, msgid, principal.person);
    await receptorRemote.removeMessage(category, receptor, msgid);
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
      var msg = await getMessage(receptor, msgid);
      var category;
      if(StringUtil.isEmpty(msg.upstreamReceptor)){
        receptor=msg.receptor;
        category=msg.category;
      }
      else{
        receptor=msg.upstreamReceptor;
        category=msg.upstreamCategory;
      }
      await receptorRemote.unlike(category, receptor, msgid);
    }
  }

  @override
  Future<Function> like(GeosphereLikePersonOL likePerson,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.unlike(likePerson.receptor, likePerson.msgid,
        likePerson.person, principal.person);
    await messageDAO.like(likePerson);
    if (!isOnlySaveLocal) {
      var msg = await getMessage(likePerson.receptor, likePerson.msgid);
      var receptor;
      var category;
      if(StringUtil.isEmpty(msg.upstreamReceptor)){
        receptor=msg.receptor;
        category=msg.category;
      }
      else{
        receptor=msg.upstreamReceptor;
        category=msg.upstreamCategory;
      }
      await receptorRemote.like(category, receptor, likePerson.msgid);
    }
  }

  @override
  Future<List<GeosphereLikePersonOL>> pageLikePersons(
      String receptor, String msgid, int limit, int offset) async {
    return await messageDAO.pageLikePersons(
        receptor, msgid, principal.person, limit, offset);
  }

  @override
  Future<Function> removeComment(
      String receptor, String msgid, String commentid,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.removeComment(
        receptor, msgid, commentid, principal.person);
    if (!isOnlySaveLocal) {
      var msg = await getMessage(receptor, msgid);
      var category;
      if(StringUtil.isEmpty(msg.upstreamReceptor)){
        receptor=msg.receptor;
        category=msg.category;
      }
      else{
        receptor=msg.upstreamReceptor;
        category=msg.upstreamCategory;
      }
      await receptorRemote.removeComment(
          category, receptor, msgid, commentid);
    }
  }

  @override
  Future<Function> addComment(GeosphereCommentOL geosphereCommentOL,
      {bool isOnlySaveLocal = false}) async {
    await messageDAO.addComment(geosphereCommentOL);
    if (!isOnlySaveLocal) {
      var msg = await getMessage(
          geosphereCommentOL.receptor, geosphereCommentOL.msgid);
      var receptor;
      var category;
      if(StringUtil.isEmpty(msg.upstreamReceptor)){
        receptor=msg.receptor;
        category=msg.category;
      }
      else{
        receptor=msg.upstreamReceptor;
        category=msg.upstreamCategory;
      }
      await receptorRemote.addComment(
          category,
          receptor,
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
      await receptorRemote.uploadMedia(o.category, geosphereMediaOL);
    }
  }

  @override
  Future<List<GeosphereMediaOL>> listMedia(
      String receptor, String messageid) async {
    return await mediaDAO.listMedia(receptor, messageid, principal.person);
  }
}