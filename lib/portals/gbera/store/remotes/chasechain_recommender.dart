import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../remotes.dart';
import 'geo_receptors.dart';

class ContentBoxOR {
  String id;
  BoxPointer pointer;
  LatLng location;
  int ctime;
  String pool;

  ContentBoxOR({this.id, this.pointer, this.location, this.ctime, this.pool});
}

class BoxPointer {
  String id;
  String title;
  String type;
  String creator;
  int ctime;

  BoxPointer({this.id, this.title, this.type, this.creator, this.ctime});
}

class RecommenderConfig {
  //最大每次推荐的内空数
  int maxRecommendItemCount;
  double countryRecommendWeight; //国家级别的推荐权重
  double normalRecommendWeight; //常规级别的推荐权重
  double provinceRecommendWeight; //省级别的推荐权重
  double cityRecommendWeight; //市级别的推荐权重
  double districtRecommendWeight; //区县级别的推荐权重
  double townRecommendWeight; //乡镇级别的推荐权重
  double weightCapacity;

  RecommenderConfig(
      {this.maxRecommendItemCount,
      this.countryRecommendWeight,
      this.normalRecommendWeight,
      this.provinceRecommendWeight,
      this.cityRecommendWeight,
      this.districtRecommendWeight,
      this.townRecommendWeight,
      this.weightCapacity}); //每权可分配的内容数

}

class ContentItemOR {
  String id; //标识来自由pointer的类型+标识的md5，所以在所有流量池中都是唯一的，只要告诉内容物在哪个池，就可以在池中找到它
  ItemPointer pointer;
  String box; //归属的内容盒
  LatLng location; //内容物可能有位置属性
  String upstreamPool; //来自上游的流量池，一般是低级池
  int ctime;
  String pool; //多一个多余字段，用于客户端识别是哪个池的内容
  bool isBubbled;

  ContentItemOR(
      {this.id,
      this.pointer,
      this.box,
      this.location,
      this.upstreamPool,
      this.ctime,
      this.pool,
      this.isBubbled});

  ContentItemOR.load(ContentItemOL item) {
    this.id = item.id;
    this.box = item.box;
    this.upstreamPool = item.upstreamPool;
    this.ctime = item.ctime;
    this.pool = item.pool;
    this.isBubbled = item.isBubbled;
    this.location = StringUtil.isEmpty(item.location)
        ? null
        : LatLng.fromJson(jsonDecode(item.location));
    this.pointer = ItemPointer(
      id: item.pointerId,
      ctime: item.pointerCtime,
      creator: item.pointerCreator,
      type: item.pointerType,
    );
  } //是否已冒泡了

  ContentItemOL toOL(String sandbox, int atime) {
    var locationJson;
    if (location != null) {
      locationJson = jsonEncode(location.toJson());
    }
    return ContentItemOL(
      id,
      sandbox,
      box,
      locationJson,
      upstreamPool,
      ctime,
      atime,
      pool,
      isBubbled,
      pointer.id,
      pointer.type,
      pointer.creator,
      pointer.ctime,
    );
  }
}

class ItemPointer {
  String id;
  String type;
  String creator;
  int ctime;

  ItemPointer({this.id, this.type, this.creator, this.ctime});
}

class RecommenderMessageOR {
  String id;
  String item;
  String type; //geosphere,netflow
  String creator;
  String content;
  String inbox;
  int layout;
  LatLng location;
  int ctime;
  double wy;

  RecommenderMessageOR({
    this.id,
    this.item,
    this.creator,
    this.type,
    this.content,
    this.inbox,
    this.layout,
    this.location,
    this.ctime,
    this.wy,
  });

  static load(RecommenderMessageOL msg) {
    return RecommenderMessageOR(
      ctime: msg.ctime,
      id: msg.id,
      type: msg.type,
      item: msg.item,
      wy: msg.wy,
      content: msg.content,
      location: !StringUtil.isEmpty(msg.location)
          ? LatLng.fromJson(jsonDecode(msg.location))
          : null,
      creator: msg.creator,
      inbox: msg.inbox,
      layout: msg.layout,
    );
  }

  RecommenderMessageOL toOL(String sandbox, int layout, int atime) {
    return RecommenderMessageOL(
        id,
        item,
        type,
        creator,
        content,
        inbox,
        layout,
        location == null ? null : jsonEncode(location.toJson()),
        ctime,
        atime,
        wy,
        sandbox);
  }
}

class RecommenderMediaOR {
  String id;
  String docid;
  String type;
  String src;
  String text;
  String leading;
  int ctime;

  RecommenderMediaOR({
    this.id,
    this.docid,
    this.type,
    this.src,
    this.text,
    this.leading,
    this.ctime,
  });

  static List<MediaSrc> toMediaSrcList(List<RecommenderMediaOR> list) {
    var medias = <MediaSrc>[];
    for (var e in list) {
      medias.add(
        MediaSrc(
          msgid: e.docid,
          text: e.text,
          id: e.id,
          type: e.type,
          leading: e.leading,
          src: e.src,
          sourceType: 'recommender',
        ),
      );
    }
    return medias;
  }

  static convertFrom(List<RecommenderMediaOL> medias) {
    var list = <RecommenderMediaOR>[];
    for (var media in medias) {
      list.add(
        RecommenderMediaOR(
          type: media.type,
          id: media.id,
          ctime: media.ctime,
          text: media.text,
          src: media.src,
          docid: media.docid,
          leading: media.leading,
        ),
      );
    }
    return list;
  }

  RecommenderMediaOL toOL(String sandbox) {
    return RecommenderMediaOL(
        id, docid, type, src, text, leading, ctime, sandbox);
  }

  static RecommenderMediaOR load(RecommenderMediaOL media) {
    return RecommenderMediaOR(
      src: media.src,
      leading: media.leading,
      type: media.type,
      id: media.id,
      text: media.text,
      docid: media.docid,
      ctime: media.ctime,
    );
  }
}

class RecommenderDocument {
  ContentItemOR item;
  RecommenderMessageOR message;
  List<RecommenderMediaOR> medias;

  RecommenderDocument({this.item, this.message, this.medias});
}

class TrafficPool {
  String id;
  String title;
  String icon;
  bool isGeosphere;
  int state;
  int level;
  int index;
  String parent; //归属的上级流量池
  int ctime;

  TrafficPool(
      {this.id,
      this.title,
      this.icon,
      this.isGeosphere,
      this.state,
      this.level,
      this.index,
      this.parent,
      this.ctime});
}

class TrafficDashboard {
  String pool;
  int itemCount;
  int lastBubbleTime;
  int innateLikes;
  double innateLikeRatio;
  int innateComments;
  double innateCommentRatio;
  int innateRecommends;
  double innateRecommendsRatio;
  int innerLikes;
  double innerLikeRatio;
  int innerComments;
  double innerCommentRatio;
  int innerRecommends;
  double innerRecommendRatio;

  TrafficDashboard({
    this.pool,
    this.itemCount,
    this.lastBubbleTime,
    this.innateLikes,
    this.innateLikeRatio,
    this.innateComments,
    this.innateCommentRatio,
    this.innateRecommends,
    this.innateRecommendsRatio,
    this.innerLikes,
    this.innerLikeRatio,
    this.innerComments,
    this.innerCommentRatio,
    this.innerRecommends,
    this.innerRecommendRatio,
  });
}

class ItemBehavior {
  String item; //唯一
  int likes;
  int comments;
  int recommends;
  int utime; //更新时间
  String pool;

  ItemBehavior(
      {this.item,
      this.likes,
      this.comments,
      this.recommends,
      this.utime,
      this.pool});
}

class BehaviorDetails {
  String person;
  String item;
  String behave; //如：like,comment,recommended
  String attachment; //行为附件
  int ctime;
  String pool;

  BehaviorDetails(
      {this.person,
      this.item,
      this.behave,
      this.attachment,
      this.ctime,
      this.pool});
}

mixin IChasechainRecommenderRemote {
  Future<List<ContentItemOR>> loadItemsFromSandbox(int pageSize, int currPage);

  Future<List<ContentItemOR>> pullItem(String towncode);

  Future<RecommenderConfig> getPersonRecommenderConfig();

  Future<void> configPersonRecommender(
    int maxRecommendItemCount,
    double countryRecommendWeight,
    double normalRecommendWeight,
    double provinceRecommendWeight,
    double cityRecommendWeight,
    districtRecommendWeight,
    townRecommendWeight,
  );

  Future<RecommenderDocument> getDocument(ContentItemOR item);

  Future<RecommenderMediaOR> getAndCacheMedia(RecommenderMediaOR src) {}

  Future<TrafficPool> getTrafficPool(String pool) {}

  Future<TrafficPool> getCountryPool() {}

  Future<ContentBoxOR> getContentBox(String pool, String box) {}

  Future<TrafficDashboard> getTrafficDashboard(String pool) {}

  Future<ItemBehavior> getItemInnerBehavior(String pool, String item) {}

  Future<ItemBehavior> getItemInnateBehavior(String pool, String item) {}

  Future<int> hasBehave(String pool, String item, String s) {}

  Future<void> doBehave(
      String pool, String item, String behave, String attachment) {}

  Future<void> undoBehave(String pool, String item, String behave) {}

  Future<List<BehaviorDetails>> pageBehave(
      String pool, String item, String behave, int limit, int offset) {}

  Future<ContentItemOR> getContentItem(String pool, String item) {}

  Future<List<TrafficPool>> pageChildrenPool(
      String pool, int limit, int offset) {}

  Future<List<TrafficPool>> pageChildrenPoolByLevel(
      String pool, int level, int limit, int offset) {}

  Future<int> countContentProvidersOfPool(String pool) {}

  Future<List<ContentItemOR>> pageContentItem(
      String pool, int limit, int offset) {}

  Future<TrafficPool> getTownTrafficPool(towncode) {}
}

class ChasechainRecommenderRemote
    implements IChasechainRecommenderRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get recommenderPorts =>
      site.getService('@.prop.ports.chasechain.recommender');

  get trafficPoolPorts =>
      site.getService('@.prop.ports.chasechain.trafficPool');

  IRecommenderDAO recommenderDAO;
  IGeoReceptorRemote geoReceptorRemote;
  IChannelRemote channelRemote;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    recommenderDAO = db.chasechainDAO;
    geoReceptorRemote = site.getService('/remote/geo/receptors');
    channelRemote = site.getService('/remote/channels');
  }

  @override
  Future<void> configPersonRecommender(
      int maxRecommendItemCount,
      double countryRecommendWeight,
      double normalRecommendWeight,
      double provinceRecommendWeight,
      double cityRecommendWeight,
      districtRecommendWeight,
      townRecommendWeight) async {
    await remotePorts.portGET(
      recommenderPorts,
      'configPersonRecommender',
      parameters: {
        'cityRecommendWeight': cityRecommendWeight,
        'countryRecommendWeight': countryRecommendWeight,
        'districtRecommendWeight': districtRecommendWeight,
        'maxRecommendItemCount': maxRecommendItemCount,
        'normalRecommendWeight': normalRecommendWeight,
        'provinceRecommendWeight': provinceRecommendWeight,
        'townRecommendWeight': townRecommendWeight,
      },
    );
  }

  @override
  Future<RecommenderConfig> getPersonRecommenderConfig() async {
    var obj = await remotePorts.portGET(
      recommenderPorts,
      'getPersonRecommenderConfig',
    );
    if (obj == null) {
      return null;
    }
    return RecommenderConfig(
      cityRecommendWeight: obj['cityRecommendWeight'],
      countryRecommendWeight: obj['countryRecommendWeight'],
      districtRecommendWeight: obj['districtRecommendWeight'],
      maxRecommendItemCount: obj['maxRecommendItemCount'],
      normalRecommendWeight: obj['normalRecommendWeight'],
      provinceRecommendWeight: obj['provinceRecommendWeight'],
      townRecommendWeight: obj['townRecommendWeight'],
      weightCapacity: obj['weightCapacity'],
    );
  }

  @override
  Future<List<ContentItemOR>> pullItem(String towncode) async {
    var list = await remotePorts.portGET(
      recommenderPorts,
      'pullItem',
      parameters: {
        'towncode': towncode,
      },
    );
    List<ContentItemOR> items = [];
    for (var obj in list) {
      var objPointer = obj['pointer'];
      var pointer = ItemPointer(
        id: objPointer['id'],
        ctime: objPointer['ctime'],
        type: objPointer['type'],
        creator: objPointer['creator'],
      );
      var location =
          obj['location'] != null ? LatLng.fromJson(obj['location']) : null;
      var item = ContentItemOR(
        ctime: obj['ctime'],
        id: obj['id'],
        location: location,
        box: obj['box'],
        isBubbled: obj['isBubbled'],
        pointer: pointer,
        pool: obj['pool'],
        upstreamPool: obj['upstreamPool'],
      );
      items.add(item);
      await _saveItem(item);
    }
    return items;
  }

  @override
  Future<List<ContentItemOR>> pageContentItem(
      String pool, int limit, int offset) async {
    var list = await remotePorts.portGET(
      trafficPoolPorts,
      'pageContentItem',
      parameters: {
        'pool': pool,
        'limit': limit,
        'offset': offset,
      },
    );
    List<ContentItemOR> items = [];
    for (var obj in list) {
      var objPointer = obj['pointer'];
      var pointer = ItemPointer(
        id: objPointer['id'],
        ctime: objPointer['ctime'],
        type: objPointer['type'],
        creator: objPointer['creator'],
      );
      var location =
          obj['location'] != null ? LatLng.fromJson(obj['location']) : null;
      var item = ContentItemOR(
        ctime: obj['ctime'],
        id: obj['id'],
        location: location,
        box: obj['box'],
        isBubbled: obj['isBubbled'],
        pointer: pointer,
        pool: obj['pool'],
        upstreamPool: obj['upstreamPool'],
      );
      items.add(item);
      await _saveItem(item);
    }
    return items;
  }

  @override
  Future<List<ContentItemOR>> loadItemsFromSandbox(
      int pageSize, int currPage) async {
    var list = await recommenderDAO.pageContentItem(
        principal.person, pageSize, currPage);
    var items = <ContentItemOR>[];
    for (var item in list) {
      items.add(ContentItemOR.load(item));
    }
    return items;
  }

  Future<void> _saveItem(ContentItemOR item) async {
    if ((await recommenderDAO.countContentItem(item.id, principal.person))
            .value >
        0) {
      return;
    }
    await recommenderDAO.addContentItem(
        item.toOL(principal.person, DateTime.now().millisecondsSinceEpoch));
  }

  @override
  Future<RecommenderDocument> getDocument(ContentItemOR item) async {
    if (await _existsContentItem(item)) {
      return await _getDocumentFromLocal(item);
    }
    var doc = await _getDocumentFromRemote(item);
    await _cacheDocument(doc);
    return doc;
  }

  Future<bool> _existsContentItem(ContentItemOR item) async {
    var counter = await recommenderDAO.countMessage(item.id, principal.person);
    return counter.value > 0;
  }

  Future<RecommenderDocument> _getDocumentFromRemote(ContentItemOR item) async {
    var msg = await _fetchMessage(item);
    if (msg == null) {
      return null;
    }
    var medias = await _getRecommenderMedia(item.pointer, msg);
    return RecommenderDocument(
      message: msg,
      item: item,
      medias: medias,
    );
  }

  Future<RecommenderMessageOR> _fetchMessage(ContentItemOR contentItem) async {
    var pointer = contentItem.pointer;
    var type = pointer.type;
    if (!type.startsWith('geo.receptor.')) {
      var message = await channelRemote.getMessage(type, pointer.id);
      return RecommenderMessageOR(
        creator: message.creator,
        ctime: message.ctime,
        id: message.id,
        location: message.location,
        content: message.content,
        inbox: message.channel,
        item: contentItem.id,
        wy: message.wy,
        type: 'netflow',
      );
    }
    //geo.receptor.mobiles.docs
    type =
        type.substring('geo.receptor'.length + 1, type.length - '.docs'.length);
    var message = await geoReceptorRemote.getMessage(type, pointer.id);
    return RecommenderMessageOR(
      creator: message.creator,
      ctime: message.ctime,
      id: message.id,
      location: message.location,
      content: message.text,
      inbox: message.receptor,
      item: contentItem.id,
      wy: message.wy,
      type: 'geosphere',
    );
  }

  Future<List<RecommenderMediaOR>> _getRecommenderMedia(
      ItemPointer pointer, RecommenderMessageOR message) async {
    switch (message.type) {
      case 'netflow':
        var medias = await _getChannelMedias(message);
        return medias;
      case 'geosphere':
        var medias = await _getGeosphereMedias(pointer, message);
        return medias;
    }
  }

  Future<List<RecommenderMediaOR>> _getChannelMedias(
      RecommenderMessageOR message) async {
    var medias = await channelRemote.listExtraMedia(
        message.id, message.creator, message.inbox);
    var items = <RecommenderMediaOR>[];
    for (var media in medias) {
      items.add(
        RecommenderMediaOR(
          leading: media.leading,
          docid: media.docid,
          src: media.src,
          text: media.text,
          ctime: media.ctime,
          id: media.id,
          type: media.type,
        ),
      );
    }
    return items;
  }

  Future<List<RecommenderMediaOR>> _getGeosphereMedias(
      ItemPointer pointer, RecommenderMessageOR message) async {
    var category = pointer.type;
    category = category.substring(0, category.lastIndexOf('.'));
    category = category.substring(category.lastIndexOf('.') + 1);
    var medias = await geoReceptorRemote.listExtraMedia(
      category,
      message.id,
    );
    var items = <RecommenderMediaOR>[];
    for (var media in medias) {
      items.add(
        RecommenderMediaOR(
          leading: media.leading,
          docid: media.docid,
          src: media.src,
          text: media.text,
          ctime: DateTime.now().millisecondsSinceEpoch,
          id: media.id,
          type: media.type,
        ),
      );
    }
    return items;
  }

  Future<RecommenderDocument> _getDocumentFromLocal(ContentItemOR item) async {
    var msg =
        await recommenderDAO.getMessageByContentItem(item.id, principal.person);
    var medias = await recommenderDAO.listMedia(msg.id, principal.person);
    return RecommenderDocument(
      medias: RecommenderMediaOR.convertFrom(medias),
      item: item,
      message: RecommenderMessageOR.load(msg),
    );
  }

  _cacheDocument(RecommenderDocument doc) async {
    int layout;
    var mediaCount = doc.medias.length;
    if (mediaCount == 0 ||
        StringUtil.isEmpty(doc.message.content) ||
        doc.message.content.length >= 50) {
      layout = 0;
    } else if (mediaCount == 1) {
      layout = doc.item.id.hashCode.abs() % 3;
    } else if (mediaCount > 1) {
      layout = 0;
    }
    doc.message.layout = layout;
    await recommenderDAO.addMessage(doc.message?.toOL(
        principal.person, layout, DateTime.now().millisecondsSinceEpoch));
    for (var m in doc.medias) {
      var media = m?.toOL(principal.person);
      await recommenderDAO.addMedia(media);
    }
  }

  @override
  Future<RecommenderMediaOR> getAndCacheMedia(RecommenderMediaOR m) async {
    var media = await recommenderDAO.getMedia(m.id, principal.person);
    if (media != null) {
      if (media.src.startsWith('/')) {
        return RecommenderMediaOR.load(media);
      }
      m.src = await _downloadMedia(m.src);
      await recommenderDAO.updateMediaSrc(m.src, principal.person, m.id);
      return m;
    }
    m.src = await _downloadMedia(m.src);
    await recommenderDAO.addMedia(m.toOL(principal.person));
    return m;
  }

  Future<String> _downloadMedia(String src) async {
    if (src.startsWith('/')) {
      return src;
    }
    var home = await getApplicationDocumentsDirectory();
    var dir = '${home.path}/chasechain/images';
    var dirFile = Directory(dir);
    if (!dirFile.existsSync()) {
      dirFile.createSync(recursive: true);
    }
    var localFile = '${dirFile.path}/${MD5Util.MD5(Uuid().v1())}';
    var ext = fileExt(src);
    if (!StringUtil.isEmpty(ext)) {
      localFile = '$localFile.$ext';
    }
    print('准备下载多媒体文件:${src}');
    await remotePorts.download(
        '${src}?accessToken=${principal.accessToken}', localFile);
    print('完成下载多媒体文件:${src}存储到：$localFile');
    return localFile;
  }

  @override
  Future<TrafficPool> getTrafficPool(String pool) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getPool',
      parameters: {
        'pool': pool,
      },
    );
    if (obj == null) {
      return null;
    }
    return TrafficPool(
      ctime: obj['ctime'],
      id: obj['id'],
      state: obj['state'],
      title: obj['title'],
      icon: obj['icon'],
      index: obj['index'],
      isGeosphere: obj['isGeosphere'],
      level: obj['level'],
      parent: obj['parent'],
    );
  }

  @override
  Future<TrafficPool> getCountryPool() async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getCountryPool',
    );
    if (obj == null) {
      return null;
    }
    return TrafficPool(
      ctime: obj['ctime'],
      id: obj['id'],
      state: obj['state'],
      title: obj['title'],
      icon: obj['icon'],
      index: obj['index'],
      isGeosphere: obj['isGeosphere'],
      level: obj['level'],
      parent: obj['parent'],
    );
  }

  @override
  Future<TrafficPool> getTownTrafficPool(towncode) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getTownTrafficPool',
      parameters: {
        'towncode':towncode,
      },
    );
    if (obj == null) {
      return null;
    }
    return TrafficPool(
      ctime: obj['ctime'],
      id: obj['id'],
      state: obj['state'],
      title: obj['title'],
      icon: obj['icon'],
      index: obj['index'],
      isGeosphere: obj['isGeosphere'],
      level: obj['level'],
      parent: obj['parent'],
    );
  }
  @override
  Future<List<TrafficPool>> pageChildrenPool(
      String pool, int limit, int offset) async {
    var list = await remotePorts.portGET(
      trafficPoolPorts,
      'pageChildrenPool',
      parameters: {
        'pool': pool,
        'limit': limit,
        'offset': offset,
      },
    );
    var pools = <TrafficPool>[];
    for (var obj in list) {
      pools.add(
        TrafficPool(
          ctime: obj['ctime'],
          id: obj['id'],
          state: obj['state'],
          title: obj['title'],
          icon: obj['icon'],
          index: obj['index'],
          isGeosphere: obj['isGeosphere'],
          level: obj['level'],
          parent: obj['parent'],
        ),
      );
    }
    return pools;
  }

  @override
  Future<List<TrafficPool>> pageChildrenPoolByLevel(
      String pool, int level, int limit, int offset) async {
    var list = await remotePorts.portGET(
      trafficPoolPorts,
      'pageChildrenPoolByLevel',
      parameters: {
        'pool': pool,
        'level': level,
        'limit': limit,
        'offset': offset,
      },
    );
    var pools = <TrafficPool>[];
    for (var obj in list) {
      pools.add(
        TrafficPool(
          ctime: obj['ctime'],
          id: obj['id'],
          state: obj['state'],
          title: obj['title'],
          icon: obj['icon'],
          index: obj['index'],
          isGeosphere: obj['isGeosphere'],
          level: obj['level'],
          parent: obj['parent'],
        ),
      );
    }
    return pools;
  }

  @override
  Future<ContentBoxOR> getContentBox(String pool, String box) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getContentBox',
      parameters: {
        'pool': pool,
        'box': box,
      },
    );
    if (obj == null) {
      return null;
    }
    var pointer = obj['pointer'];
    var location = obj['location'];
    return ContentBoxOR(
      id: obj['id'],
      ctime: obj['ctime'],
      location: location == null ? null : LatLng.fromJson(location),
      pool: obj['pool'],
      pointer: BoxPointer(
        ctime: pointer['ctime'],
        id: pointer['id'],
        title: pointer['title'],
        type: pointer['type'],
        creator: pointer['creator'],
      ),
    );
  }

  @override
  Future<TrafficDashboard> getTrafficDashboard(String pool) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getTrafficDashboard',
      parameters: {
        'pool': pool,
      },
    );
    if (obj == null) {
      return null;
    }
    return TrafficDashboard(
      pool: obj['pool'],
      innateCommentRatio: obj['innateCommentRatio'],
      innateComments: obj['innateComments'],
      innateLikeRatio: obj['innateLikeRatio'],
      innateLikes: obj['innateLikes'],
      innateRecommends: obj['innateRecommends'],
      innateRecommendsRatio: obj['innateRecommendsRatio'],
      innerCommentRatio: obj['innerCommentRatio'],
      innerComments: obj['innerComments'],
      innerLikeRatio: obj['innerLikeRatio'],
      innerLikes: obj['innerLikes'],
      innerRecommendRatio: obj['innerRecommendRatio'],
      innerRecommends: obj['innerRecommends'],
      itemCount: obj['itemCount'],
      lastBubbleTime: obj['lastBubbleTime'],
    );
  }

  @override
  Future<ItemBehavior> getItemInnerBehavior(String pool, String item) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getItemInnerBehavior',
      parameters: {
        'pool': pool,
        'item': item,
      },
    );
    if (obj == null) {
      return null;
    }
    return ItemBehavior(
      pool: obj['pool'],
      item: obj['item'],
      comments: obj['comments'],
      likes: obj['likes'],
      recommends: obj['recommends'],
      utime: obj['utime'],
    );
  }

  @override
  Future<ItemBehavior> getItemInnateBehavior(String pool, String item) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getItemInnateBehavior',
      parameters: {
        'pool': pool,
        'item': item,
      },
    );
    if (obj == null) {
      return null;
    }
    return ItemBehavior(
      pool: obj['pool'],
      item: obj['item'],
      comments: obj['comments'],
      likes: obj['likes'],
      recommends: obj['recommends'],
      utime: obj['utime'],
    );
  }

  @override
  Future<int> hasBehave(String pool, String item, String behave) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'hasBehave',
      parameters: {
        'pool': pool,
        'item': item,
        'behave': behave,
      },
    );
    return obj;
  }

  @override
  Future<void> doBehave(
      String pool, String item, String behave, String attachment) async {
    await remotePorts.portGET(
      trafficPoolPorts,
      'doBehave',
      parameters: {
        'pool': pool,
        'item': item,
        'behave': behave,
        'attachment': attachment,
      },
    );
  }

  @override
  Future<void> undoBehave(String pool, String item, String behave) async {
    await remotePorts.portGET(
      trafficPoolPorts,
      'undoBehave',
      parameters: {
        'pool': pool,
        'item': item,
        'behave': behave,
      },
    );
  }

  @override
  Future<List<BehaviorDetails>> pageBehave(
      String pool, String item, String behave, int limit, int offset) async {
    var list = await remotePorts.portGET(
      trafficPoolPorts,
      'pageBehave',
      parameters: {
        'pool': pool,
        'item': item,
        'behave': behave,
        'limit': limit,
        'offset': offset,
      },
    );
    var details = <BehaviorDetails>[];
    for (var obj in list) {
      details.add(
        BehaviorDetails(
          pool: obj['pool'],
          item: obj['item'],
          ctime: obj['ctime'],
          person: obj['person'],
          attachment: obj['attachment'],
          behave: obj['behave'],
        ),
      );
    }
    return details;
  }

  @override
  Future<ContentItemOR> getContentItem(String pool, String item) async {
    var obj = await remotePorts.portGET(
      trafficPoolPorts,
      'getContentItem',
      parameters: {
        'pool': pool,
        'item': item,
      },
    );
    if (obj == null) {
      return null;
    }
    var objPointer = obj['pointer'];
    var pointer = ItemPointer(
      id: objPointer['id'],
      ctime: objPointer['ctime'],
      type: objPointer['type'],
      creator: objPointer['creator'],
    );
    var location =
        obj['location'] != null ? LatLng.fromJson(obj['location']) : null;
    return ContentItemOR(
      ctime: obj['ctime'],
      id: obj['id'],
      location: location,
      box: obj['box'],
      isBubbled: obj['isBubbled'],
      pointer: pointer,
      pool: obj['pool'],
      upstreamPool: obj['upstreamPool'],
    );
  }

  @override
  Future<int> countContentProvidersOfPool(String pool) async {
    var v = await remotePorts.portGET(
      trafficPoolPorts,
      'countContentProvidersOfPool',
      parameters: {
        'pool': pool,
      },
    );
    return v;
  }

}
