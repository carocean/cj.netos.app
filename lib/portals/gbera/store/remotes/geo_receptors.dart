import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_remote_ports.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../gbera_entities.dart';
import '../services.dart';

class GeosphereMediaOR {
  final String id;
  final String type;
  final String src;
  final String leading;
  final String docid;
  final String text;
  final String receptor;

  GeosphereMediaOR(
      {this.id,
      this.type,
      this.src,
      this.leading,
      this.docid,
      this.text,
      this.receptor});

  MediaSrc toMedia() {
    return MediaSrc(
      leading: leading,
      id: id,
      type: type,
      text: text,
      msgid: docid,
      sourceType: 'geosphere',
      src: src,
    );
  }
}

class GeosphereLikeOR {
  String person;
  int ctime;
  String receptor;
  String docid;

  GeosphereLikeOR({
    this.person,
    this.ctime,
    this.receptor,
    this.docid,
  });

  GeosphereLikeOR.parse(obj) {
    this.person = obj['person'];
    this.ctime = obj['ctime'];
    this.receptor = obj['receptor'];
    this.docid = obj['docid'];
  }
}

class GeosphereCommentOR {
  String id;
  String person;
  int ctime;
  String receptor;
  String docid;
  String content;

  GeosphereCommentOR({
    this.id,
    this.person,
    this.ctime,
    this.receptor,
    this.docid,
    this.content,
  });

  GeosphereCommentOR.parse(obj) {
    this.id = obj['id'];
    this.person = obj['person'];
    this.ctime = obj['ctime'];
    this.receptor = obj['receptor'];
    this.docid = obj['docid'];
    this.content = obj['content'];
  }
}

mixin IGeoReceptorRemote {
  Future<void> addReceptor(GeoReceptor receptor);

  Future<void> removeReceptor(String id);

  Future<void> updateLeading(String rleading, String receptor) {}

  Future<void> updateForeground(String receptor, mode) {}

  Future<void> emptyBackground(String receptor) {}

  Future<void> updateBackground(String receptor, mode, String file) {}

  Future<void> publishMessage(GeosphereMessageOR geosphereMessageOR) {}

  Future<void> removeMessage(String receptor, String msgid);

  Future<GeosphereMessageOR> getMessage(String msgid);

  Future<void> like(String receptor, String msgid) {}

  Future<void> unlike(String receptor, String msgid) {}

  Future<void> addComment(
      String receptor, String msgid, String commentid, String text) {}

  Future<void> removeComment(String receptor, String msgid, String commentid) {}

  Future<void> uploadMedia(GeosphereMediaOL geosphereMediaOL) {}

  Future<List<GeoPOI>> searchAroundReceptors(
      {String receptor, String geoType, int limit, int offset}) {}

  Future<List<GeoPOI>> searchAroundLocation(
      LatLng location, int radius, geoType, int limit, int offset) {}

  Future<List<GeoPOF>> pageReceptorFans(
      {String receptor, int limit, int offset}) {}

  Future<List<ChannelOR>> listReceptorChannels() {}

  Future<List<GeoPOD>> searchAroundDocuments(
      {String receptor, String geoType, int limit, int offset}) {}

  Future<GeoReceptor> getReceptor(String receptorid) {}

  Future<bool> syncTaskRemote(Frame frame) async {}

  Future<GeoReceptor> getMyMobilReceptor() {}

  Future<List<GeosphereMessageOL>> pageMessage(
      String receptor, String creator, int limit, int offset) {}

  Future<List<GeosphereMessageOL>> pageDocument(
      String receptor, int limit, int offset) {}

  Future<void> follow(String receptor) {}

  Future<void> unfollow(String receptor) {}

  Future<int> countReceptorFans(String id) {}

  Future<void> updateLocation(String receptor, String json) {}

  Future<List<GeosphereMediaOR>> listExtraMedia(String docid) {}

  Future<List<GeosphereLikeOR>> pageLike(String docid, int limit, int offset) {}

  Future<List<GeosphereCommentOR>> pageComment(docid, int limit, int offset) {}

  Future<void> allowFollowSpeak(String id, Person person) {}

  Future<void> denyFollowSpeak(String id, Person person) {}

  Future<bool> isDenyFollowSpeak(String id) {}
}

class GeoReceptorRemote implements IGeoReceptorRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get _receptorPortsUrl =>
      site.getService('@.prop.ports.document.geo.receptor');

  get _geospherePortsUrl => site.getService('@.prop.ports.link.geosphere');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');
  IGeoReceptorDAO receptorDAO;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    receptorDAO = db.geoReceptorDAO;
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
        'townCode': receptor.townCode,
        'channel': receptor.channel,
        'category': receptor.category,
        'brand': receptor.brand,
        'leading': receptor.leading,
        'location': receptor.location,
        'radius': receptor.radius,
        'uDistance': receptor.uDistance,
      },
    );
  }

  @override
  Future<Function> removeReceptor(String id) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'removeGeoReceptor',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<GeoReceptor> getReceptor(String receptor) async {
    var map = await remotePorts.portGET(
      _receptorPortsUrl,
      'getGeoReceptor',
      parameters: {
        'id': receptor,
      },
    );
    if (map == null) {
      return null;
    }
    return GeoReceptor.load(map, 'true', principal.person);
  }

  @override
  Future<Function> updateLocation(String receptor, String location) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'updateLocation',
      parameters: {
        'id': receptor,
        'location': location,
      },
    );
  }

  @override
  Future<Function> updateLeading(String leading, String id) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'updateLeading',
      parameters: {
        'id': id,
        'leading': leading,
      },
    );
  }

  @override
  Future<Function> updateForeground(String receptor, mode) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'updateForeground',
      parameters: {
        'id': receptor,
        'mode': mode,
      },
    );
  }

  @override
  Future<Function> emptyBackground(String receptor) async {
    await remotePorts.portGET(
      _receptorPortsUrl,
      'emptyBackground',
      parameters: {
        'id': receptor,
      },
    );
  }

  @override
  Future<Function> updateBackground(String receptor, mode, String file) async {
    remotePorts.portTask.addUploadTask(
      '/app/geosphere',
      [file],
      callbackUrl:
          '/geosphere/receptor/settings?receptor=$receptor&mode=$mode&background=$file',
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
          '/geosphere/receptor/docs/publishMessage?receptor=${geosphereMessageOR.receptor}&msgid=${geosphereMessageOR.id}',
    );
  }

  @override
  Future<Function> removeMessage(String receptor, String msgid) async {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'removeArticle',
      parameters: {
        'receptor': receptor,
        'docid': msgid,
      },
      callbackUrl:
          '/geosphere/receptor/docs/removeMessage?receptor=$receptor&msgid=$msgid',
    );
  }

  @override
  Future<GeosphereMessageOR> getMessage(String msgid) async {
    var obj = await remotePorts.portGET(
      _receptorPortsUrl,
      'getGeoDocument',
      parameters: {
        'docid': msgid,
      },
    );
    if (obj == null) {
      return null;
    }
    return GeosphereMessageOR(
      creator: obj['creator'],
      ctime: obj['ctime'],
      id: obj['id'],
      location: LatLng.fromJson(obj['location']),
      state: obj['state'],
      text: obj['text'],
      category: obj['category'],
      dtime: obj['dtime'],
      atime: obj['atime'],
      receptor: obj['receptor'],
      rtime: obj['rtime'],
      sourceApp: obj['sourceApp'],
      sourceSite: obj['sourceSite'],
      upstreamChannel: obj['upstreamChannel'],
      upstreamPerson: obj['upstreamPerson'],
      purchaseSn: obj['purchaseSn'],
    );
  }

  @override
  Future<Function> removeComment(
      String receptor, String msgid, String commentid) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'removeComment',
      parameters: {
        'receptor': receptor,
        'docid': msgid,
        'commentid': commentid,
      },
      callbackUrl:
          '/geosphere/receptor/docs/removeComment?receptor=$receptor&msgid=$msgid&commentid=$commentid',
    );
  }

  @override
  Future<Function> addComment(
      String receptor, String msgid, String commentid, String text) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'addComment',
      parameters: {
        'docid': msgid,
        'receptor': receptor,
        'commentid': commentid,
        'content': text,
      },
      callbackUrl:
          '/geosphere/receptor/docs/addComment?receptor=$receptor&msgid=$msgid&commentid=$commentid&content=$text',
    );
  }

  @override
  Future<Function> unlike(String receptor, String msgid) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'unlike',
      parameters: {
        'receptor': receptor,
        'docid': msgid,
      },
      callbackUrl:
          '/geosphere/receptor/docs/unlike?receptor=$receptor&msgid=$msgid',
    );
  }

  @override
  Future<Function> like(String receptor, String msgid) {
    remotePorts.portTask.addPortGETTask(
      _receptorPortsUrl,
      'like',
      parameters: {
        'receptor': receptor,
        'docid': msgid,
      },
      callbackUrl:
          '/geosphere/receptor/docs/like?receptor=$receptor&msgid=$msgid',
    );
  }

  @override
  Future<Function> uploadMedia(GeosphereMediaOL geosphereMediaOL) {
    remotePorts.portTask.addUploadTask(
      '/app/geosphere',
      [geosphereMediaOL.src],
      callbackUrl: '/geosphere/receptor/docs/uploadMedia'
          '?receptor=${geosphereMediaOL.receptor}'
          '&msgid=${geosphereMediaOL.msgid}'
          '&id=${geosphereMediaOL.id}'
          '&type=${geosphereMediaOL.type ?? ''}'
          '&src=${geosphereMediaOL.src}'
          '&text=${geosphereMediaOL.text ?? ''}'
          '&leading=${geosphereMediaOL.leading ?? ''}',
    );
  }

  @override
  Future<List<GeoPOI>> searchAroundReceptors(
      {String receptor, String geoType, int limit, int offset}) async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'searchAroundReceptors',
      parameters: {
        'receptor': receptor,
        'geoType': geoType,
        'limit': limit,
        'offset': offset,
      },
    );
    IPersonService personService = await site.getService('/gbera/persons');
    List<GeoPOI> pois = [];
    for (var item in list) {
      var receptor = item['receptor'];
      var foregroundMode;
      switch (receptor['foregroundMode']) {
        case 'white':
          foregroundMode = ForegroundMode.white;
          break;
        case 'original':
          foregroundMode = ForegroundMode.original;
          break;
      }
      var backgroundMode;
      switch (receptor['backgroundMode']) {
        case 'none':
          backgroundMode = BackgroundMode.none;
          break;
        case 'vertical':
          backgroundMode = BackgroundMode.vertical;
          break;
        case 'horizontal':
          backgroundMode = BackgroundMode.horizontal;
          break;
      }
      IGeoCategoryRemote categoryRemote =
          site.getService('/remote/geo/categories');
      var category = await categoryRemote.getCategory(receptor['category']);
      var creator = await personService.getPerson(receptor['creator']);
      pois.add(
        GeoPOI(
            categoryOR: category,
            creator: creator,
            distance: item['distance'],
            receptor: ReceptorInfo(
              foregroundMode: foregroundMode,
              backgroundMode: backgroundMode,
              background: receptor['background'],
              uDistance: receptor['uDistance'],
              radius: receptor['radius'],
              latLng: LatLng.fromJson(receptor['location']),
              title: receptor['title'],
              leading: receptor['leading'],
              id: receptor['id'],
              creator: receptor['creator'],
              category: receptor['category'],
              isMobileReceptor: receptor['category'] == 'mobiles',
              isAutoScrollMessage:
                  receptor['isAutoScrollMessage'] == 'true' ? true : false,
              offset: item['distance'],
              origin: GeoReceptor.load(
                receptor,
                'true',
                principal.person,
              ),
            )),
      );
    }
    return pois;
  }

  @override
  Future<List<GeoPOI>> searchAroundLocation(
      LatLng location, int radius, geoType, int limit, int offset) async {
    AppKeyPair appKeyPair = site.getService('@.appKeyPair');
    appKeyPair = await appKeyPair.getAppKeyPair('system.netos', site);
    var nonce = MD5Util.MD5(Uuid().v1());
    var sign = appKeyPair.appSign(nonce);
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'searchAroundLocation',
      headers: {
        'App-Id': appKeyPair.appid,
        'App-Key': appKeyPair.appKey,
        'App-Nonce': nonce,
        'App-Sign': sign,
      },
      parameters: {
        'location': jsonEncode(location),
        'radius': radius,
        'geoType': geoType,
        'limit': limit,
        'offset': offset,
      },
    );
    IPersonService personService = await site.getService('/gbera/persons');
    List<GeoPOI> pois = [];
    for (var item in list) {
      var receptor = item['receptor'];
      var foregroundMode;
      switch (receptor['foregroundMode']) {
        case 'white':
          foregroundMode = ForegroundMode.white;
          break;
        case 'original':
          foregroundMode = ForegroundMode.original;
          break;
      }
      var backgroundMode;
      switch (receptor['backgroundMode']) {
        case 'none':
          backgroundMode = BackgroundMode.none;
          break;
        case 'vertical':
          backgroundMode = BackgroundMode.vertical;
          break;
        case 'horizontal':
          backgroundMode = BackgroundMode.horizontal;
          break;
      }
      IGeoCategoryRemote categoryRemote =
          site.getService('/remote/geo/categories');
      var category = await categoryRemote.getCategory(receptor['category']);
      var creator = await personService.getPerson(receptor['creator']);
      pois.add(
        GeoPOI(
            categoryOR: category,
            creator: creator,
            distance: item['distance'],
            receptor: ReceptorInfo(
              foregroundMode: foregroundMode,
              backgroundMode: backgroundMode,
              background: receptor['background'],
              uDistance: receptor['uDistance'],
              radius: receptor['radius'],
              latLng: LatLng.fromJson(receptor['location']),
              title: receptor['title'],
              leading: receptor['leading'],
              id: receptor['id'],
              creator: receptor['creator'],
              category: receptor['category'],
              isMobileReceptor: receptor['category'] == 'mobiles',
              isAutoScrollMessage:
                  receptor['isAutoScrollMessage'] == 'true' ? true : false,
              offset: item['distance'],
              origin: GeoReceptor.load(
                receptor,
                'true',
                principal.person,
              ),
            )),
      );
    }
    return pois;
  }

  @override
  Future<List<GeoPOF>> pageReceptorFans(
      {String receptor, int limit, int offset}) async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'pageReceptorFans',
      parameters: {
        'receptor': receptor,
        'limit': limit,
        'skip': offset,
      },
    );
    IPersonService personService = await site.getService('/gbera/persons');
    var pofList = <GeoPOF>[];
    for (var pof in list) {
      var follow = pof['follow'];
      var person = await personService.getPerson(follow['person']);
      pofList.add(
        GeoPOF(
          person: person,
          rights: follow['rights'],
          distance: pof['distance'],
        ),
      );
    }
    return pofList;
  }

  @override
  Future<List<ChannelOR>> listReceptorChannels() async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'listReceptorChannels',
    );
    List<ChannelOR> channels = [];
    for (var item in list) {
      channels.add(
        ChannelOR(
          creator: item['creator'],
          leading: item['leading'],
          title: item['title'],
          ctime: item['ctime'],
          channel: item['channel'],
          inPersonSelector: item['inPersonSelector'],
          outGeoSelector: item['outGeoSelector'],
          outPersonSelector: item['outPersonSelector'],
        ),
      );
    }
    return channels;
  }

  @override
  Future<List<GeoPOD>> searchAroundDocuments(
      {String category,
      String receptor,
      String geoType,
      int limit,
      int offset}) async {
    var list = await remotePorts.portGET(
      _geospherePortsUrl,
      'searchAroundDocuments',
      parameters: {
        'category': category,
        'receptor': receptor,
        'geoType': geoType ?? '',
        'limit': limit,
        'offset': offset,
      },
    );
    var podList = <GeoPOD>[];
    for (var pod in list) {
      podList.add(GeoPOD.parse(pod));
    }
    return podList;
  }

  @override
  Future<GeoReceptor> getMyMobilReceptor() async {
    var map = await remotePorts.portGET(
      _receptorPortsUrl,
      'getMobileGeoReceptor',
    );
    if (map == null) {
      return null;
    }
    return GeoReceptor.load(map, 'false', principal.person);
  }

  ///远程到本地的同步任务
  @override
  Future<bool> syncTaskRemote(Frame frame) async {
    var content = frame.contentText;
    var list = jsonDecode(content);
    bool issync = false;
    for (var item in list) {
      var receptor = GeoReceptor.load(item, 'true', principal.person);
      CountValue value =
          await receptorDAO.countReceptor(receptor.id, principal.person);
      if (value.value < 1) {
        print('感知器:${receptor.title} 正在下载...');
        var home = await getApplicationDocumentsDirectory();
        var dir = '${home.path}/images';
        var dirFile = Directory(dir);
        if (!dirFile.existsSync()) {
          dirFile.createSync();
        }
        if (!StringUtil.isEmpty(receptor.leading)) {
          var fn = '${MD5Util.MD5(Uuid().v1())}.${fileExt(receptor.leading)}';
          var localFile = '$dir/$fn';
          await remotePorts.download(
              '${receptor.leading}?accessToken=${principal.accessToken}',
              localFile);
          receptor.leading = localFile;
        }
        if (!StringUtil.isEmpty(receptor.background)) {
          var fn =
              '${MD5Util.MD5(Uuid().v1())}.${fileExt(receptor.background)}';
          var localFile = '$dir/$fn';
          await remotePorts.download(
              '${receptor.background}?accessToken=${principal.accessToken}',
              localFile);
          receptor.background = localFile;
        }
        try {
          await receptorDAO.add(receptor);
          issync = true;
          print('感知器:${receptor.title} 成功安装');
        } catch (e) {
          print('感知器:${receptor.title} 安装失败，原因:$e');
        }
      }
    }
    return issync;
  }

  @override
  Future<List<GeosphereMessageOL>> pageMessage(
      String receptor, String creator, int limit, int offset) async {
    var list = await remotePorts.portGET(
      _receptorPortsUrl,
      'pageDocument',
      parameters: {
        'id': receptor,
        'creator': creator,
        'limit': limit,
        'skip': offset,
      },
    );
    var msgs = <GeosphereMessageOL>[];
    for (var item in list) {
      msgs.add(
        GeosphereMessageOL.from(item, principal.person),
      );
    }
    return msgs;
  }

  @override
  Future<List<GeosphereMessageOL>> pageDocument(
      String receptor, int limit, int offset)async {
    var list = await remotePorts.portGET(
      _receptorPortsUrl,
      'pageDocument2',
      parameters: {
        'id': receptor,
        'limit': limit,
        'skip': offset,
      },
    );
    var msgs = <GeosphereMessageOL>[];
    for (var item in list) {
      msgs.add(
        GeosphereMessageOL.from(item, principal.person),
      );
    }
    return msgs;
  }

  @override
  Future<Function> unfollow(String receptor) async {
    await remotePorts.portGET(
      _geospherePortsUrl,
      'unfollowReceptor',
      parameters: {
        'receptor': receptor,
      },
    );
  }

  @override
  Future<Function> follow(String receptor) async {
    await remotePorts.portGET(
      _geospherePortsUrl,
      'followReceptor',
      parameters: {
        'receptor': receptor,
      },
    );
  }

  @override
  Future<Function> allowFollowSpeak(String receptor, Person fans) async {
    await remotePorts.portGET(
      _geospherePortsUrl,
      'allowFollowSpeak',
      parameters: {
        'receptor': receptor,
        'fans': fans.official,
      },
    );
  }

  @override
  Future<Function> denyFollowSpeak(String receptor, Person fans) async {
    await remotePorts.portGET(
      _geospherePortsUrl,
      'denyFollowSpeak',
      parameters: {
        'receptor': receptor,
        'fans': fans.official,
      },
    );
  }

  @override
  Future<bool> isDenyFollowSpeak(String receptor) async {
    return await remotePorts.portGET(
      _geospherePortsUrl,
      'isDenyFollowSpeak',
      parameters: {
        'receptor': receptor,
      },
    );
  }

  @override
  Future<int> countReceptorFans(String receptor) async {
    var count = await remotePorts.portGET(
      _geospherePortsUrl,
      'countReceptorFans',
      parameters: {
        'receptor': receptor,
      },
    );
    return count;
  }

  @override
  Future<List<GeosphereMediaOR>> listExtraMedia(String docid) async {
    var list = await remotePorts.portGET(
      _receptorPortsUrl,
      'listExtraMedia',
      parameters: {
        'docid': docid,
      },
    );
    var items = <GeosphereMediaOR>[];
    for (var obj in list) {
      items.add(
        GeosphereMediaOR(
          src: obj['src'],
          leading: obj['leading'],
          type: obj['type'],
          id: obj['id'],
          text: obj['text'],
          receptor: obj['receptor'],
          docid: obj['docid'],
        ),
      );
    }
    return items;
  }

  @override
  Future<List<GeosphereCommentOR>> pageComment(
      docid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      _receptorPortsUrl,
      'pageComment',
      parameters: {
        'docid': docid,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <GeosphereCommentOR>[];
    for (var obj in list) {
      items.add(
        GeosphereCommentOR.parse(obj),
      );
    }
    return items;
  }

  @override
  Future<List<GeosphereLikeOR>> pageLike(
      String docid, int limit, int offset) async {
    var list = await remotePorts.portGET(
      _receptorPortsUrl,
      'pageLike',
      parameters: {
        'docid': docid,
        'limit': limit,
        'offset': offset,
      },
    );
    var items = <GeosphereLikeOR>[];
    for (var obj in list) {
      items.add(
        GeosphereLikeOR.parse(obj),
      );
    }
    return items;
  }
}
