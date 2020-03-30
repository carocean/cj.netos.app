import 'dart:convert';

import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_remote_ports.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/system/local/entities.dart';

mixin IGeoReceptorRemote {
  Future<void> addReceptor(GeoReceptor receptor);

  Future<void> removeReceptor(String category, String id);

  Future<void> updateLeading(String rleading, String category, String id) {}

  Future<void> updateForeground(String category, String receptor, mode) {}

  Future<void> emptyBackground(String category, String receptor) {}

  Future<void> updateBackground(
      String category, String receptor, mode, String file) {}

  Future<void> publishMessage(GeosphereMessageOR geosphereMessageOR) {}

  Future<void> removeMessage(String category, String receptor, String msgid);

  Future<void> like(
      String category, String receptor, String msgid, String person) {}

  Future<void> unlike(
      String category, String receptor, String msgid, String liker) {}

  Future<void> addComment(String category, String receptor, String msgid,
      String person, String commentid, String text) {}

  Future<void> removeComment(
      String category, String receptor, String msgid, String commentid) {}

  Future<void> uploadMedia(String category, GeosphereMediaOL geosphereMediaOL) {}

}

class GeoReceptorRemote implements IGeoReceptorRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _receptorPortsUrl =>
      site.getService('@.prop.ports.document.geo.receptor');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    return null;
  }

  @override
  Future<Function> addReceptor(GeoReceptor receptor) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'addGeoReceptor',
      parameters: {
        'id': receptor.id,
        'title': receptor.title,
        'category': receptor.category,
        'leading': receptor.leading,
        'location': receptor.location,
        'radius': receptor.radius,
        'uDistance': receptor.uDistance,
      },
    );
  }

  @override
  Future<Function> removeReceptor(String category, String id) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'removeGeoReceptor',
      parameters: {
        'id': id,
        'category': category,
      },
    );
  }

  @override
  Future<Function> updateLeading(
      String leading, String category, String id) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'updateLeading',
      parameters: {
        'id': id,
        'category': category,
        'leading': leading,
      },
    );
  }

  @override
  Future<Function> updateForeground(
      String category, String receptor, mode) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'updateForeground',
      parameters: {
        'id': receptor,
        'category': category,
        'mode': mode,
      },
    );
  }

  @override
  Future<Function> emptyBackground(String category, String receptor) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'emptyBackground',
      parameters: {
        'id': receptor,
        'category': category,
      },
    );
  }

  @override
  Future<Function> updateBackground(
      String category, String receptor, mode, String file) async {
    remotePorts.portTask.addUploadTask(
      '/app/geosphere',
      [file],
      callbackUrl:
          '/geosphere/receptor/settings?category=$category&receptor=$receptor&mode=$mode&background=$file',
    );
  }

  @override
  Future<Function> publishMessage(GeosphereMessageOR geosphereMessageOR) async {
    var docMap = jsonEncode(geosphereMessageOR.toMap());
    remotePorts.portTask.addPortPOSTTask(
      _receptorPortsUrl,
      'publishArticle',
      parameters: {
        'category': geosphereMessageOR.category,
      },
      data: {
        'document': docMap,
      },
      callbackUrl:
          '/geosphere/receptor/docs/publishMessage?receptor=${geosphereMessageOR.id}&category=${geosphereMessageOR.category}',
    );
  }

  @override
  Future<Function> removeMessage(
      String category, String receptor, String msgid) async {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'removeArticle',
      parameters: {
        'receptor': receptor,
        'category': category,
        'docid': msgid,
      },
      callbackUrl:
          '/geosphere/receptor/docs/removeMessage?category=$category&receptor=$receptor&msgid=$msgid',
    );
  }

  @override
  Future<Function> removeComment(
      String category, String receptor, String msgid, String commentid) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'removeComment',
      parameters: {
        'receptor': receptor,
        'category': category,
        'docid': msgid,
        'commentid': commentid,
      },
      callbackUrl:
          '/geosphere/receptor/docs/removeComment?category=$category&receptor=$receptor&msgid=$msgid&commentid=$commentid',
    );
  }

  @override
  Future<Function> addComment(String category, String receptor, String msgid,
      String person, String commentid, String text) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'addComment',
      parameters: {
        'receptor': receptor,
        'category': category,
        'docid': msgid,
        'commenter': person,
        'commentid': commentid,
        'content': text,
      },
      callbackUrl:
          '/geosphere/receptor/docs/addComment?category=$category&receptor=$receptor&msgid=$msgid&commenter=$person&commentid=$commentid&content=$text',
    );
  }

  @override
  Future<Function> unlike(
      String category, String receptor, String msgid, String unliker) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'unlike',
      parameters: {
        'receptor': receptor,
        'category': category,
        'docid': msgid,
        'unliker': unliker,
      },
      callbackUrl:
          '/geosphere/receptor/docs/unlike?category=$category&receptor=$receptor&msgid=$msgid&unliker=$unliker',
    );
  }

  @override
  Future<Function> like(
      String category, String receptor, String msgid, String person) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'like',
      parameters: {
        'receptor': receptor,
        'category': category,
        'docid': msgid,
        'liker': person,
      },
      callbackUrl:
          '/geosphere/receptor/docs/like?category=$category&receptor=$receptor&msgid=$msgid&liker=$person',
    );
  }

  @override
  Future<Function> uploadMedia(
      String category, GeosphereMediaOL geosphereMediaOL) {
    remotePorts.portTask.addUploadTask(
      '/app/geosphere',
      [geosphereMediaOL.src],
      callbackUrl:
      '/geosphere/receptor/docs/uploadMedia'
          '?category=$category'
          '&receptor=${geosphereMediaOL.receptor}'
          '&msgid=${geosphereMediaOL.msgid}'
          '&id=${geosphereMediaOL.id}'
          '&type=${geosphereMediaOL.type}'
          '&src=${geosphereMediaOL.src}'
          '&text=${geosphereMediaOL.text}'
          '&leading=${geosphereMediaOL.leading}',
    );
  }
}
