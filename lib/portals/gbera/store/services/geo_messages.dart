import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
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

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    messageDAO = db.geosphereMessageDAO;
    mediaDAO = db.geosphereMediaDAO;
  }

  @override
  Future<void> addMessage(GeosphereMessageOL geosphereMessageOL) async {
    await messageDAO.addMessage(geosphereMessageOL);
  }

  @override
  Future<List<GeosphereMessageOL>> pageMessage(
      String receptor, int limit, int offset) async {
    return await messageDAO.pageMessage(
        receptor, principal.person, limit, offset);
  }

  @override
  Future<Function> removeMessage(String receptor, String id) async {
    await messageDAO.removeMessage(id, receptor, principal.person);
    await mediaDAO.empty(receptor, id, principal.person);
  }

  @override
  Future<GeosphereMessageOL> getMessage(String receptor, msgid) async {
    return await messageDAO.getMessage(receptor, msgid, principal.person);
  }

  @override
  Future<bool> isLiked(String receptor, String msgid, String liker) async {
    var like = await messageDAO.getLikePersonBy(
        receptor, msgid, liker, principal?.person);
    return like != null;
  }

  @override
  Future<Function> unlike(String receptor, String msgid, String liker) async {
    await messageDAO.unlike(receptor, msgid, liker, principal.person);
  }

  @override
  Future<Function> like(GeosphereLikePersonOL likePerson) async {
    await messageDAO.unlike(likePerson.receptor, likePerson.msgid,
        likePerson.person, principal.person);
    await messageDAO.like(likePerson);
  }

  @override
  Future<List<GeosphereLikePersonOL>> pageLikePersons(
      String receptor, String msgid, int limit, int offset) async {
    return await messageDAO.pageLikePersons(
        receptor, msgid, principal.person, limit, offset);
  }

  @override
  Future<Function> removeComment(
      String receptor, String msgid, String commentid) async {
    await messageDAO.removeComment(
        receptor, msgid, commentid, principal.person);
  }

  @override
  Future<Function> addComment(GeosphereCommentOL geosphereCommentOL) async {
    await messageDAO.addComment(geosphereCommentOL);
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

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    mediaDAO = db.geosphereMediaDAO;
  }

  @override
  Future<void> addMedia(GeosphereMediaOL geosphereMediaOL) async {
    await mediaDAO.addMedia(geosphereMediaOL);
  }

  @override
  Future<List<GeosphereMediaOL>> listMedia(
      String receptor, String messageid) async {
    return await mediaDAO.listMedia(receptor, messageid, principal.person);
  }
}
