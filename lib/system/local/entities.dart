import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:floor/floor.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/services/geo_categories.dart';
import 'package:uuid/uuid.dart';

@Entity(primaryKeys: ['official', 'sandbox'])
class Person {
  final String official;
  final String uid;
  final String accountCode;
  final String appid;
  final String avatar;
  String rights;
  final String nickName;
  final String signature;
  final String pyname;
  final String sandbox;

  Person(this.official, this.uid, this.accountCode, this.appid, this.avatar,
      this.rights, this.nickName, this.signature, this.pyname, this.sandbox);

  toMap() {
    return {
      'official': official,
      'uid': uid,
      'accountCode': accountCode,
      'appid': appid,
      'avatar': avatar,
      'rights': rights,
      'nickName': nickName,
      'signature': signature,
      'pyname': pyname,
      'sandbox': sandbox,
    };
  }
}

@entity
class MicroSite {
  @primaryKey
  final String id;
  final String name;
  final String leading;
  final String desc;
  final String sandbox;

  MicroSite(this.id, this.name, this.leading, this.desc, this.sandbox);
}

@entity
class MicroApp {
  @primaryKey
  final String id;
  final String site;
  final String leading;
  final String sandbox;

  MicroApp(this.id, this.site, this.leading, this.sandbox);
}

@Entity(primaryKeys: [
  'id',
  'sandbox',
], indices: [
  Index(value: ['owner', 'ctime'])
])
class Channel {
  String id;
  String name;
  String owner;
  String upstreamPerson;
  String sourceCreator;
  String leading;
  String site;
  int ctime = DateTime.now().millisecondsSinceEpoch;
  int utime = DateTime.now().millisecondsSinceEpoch;
  String sandbox;

  Channel(
    this.id,
    this.name,
    this.owner,
    this.upstreamPerson,
    this.sourceCreator,
    this.leading,
    this.site,
    this.ctime,
    this.utime,
    this.sandbox,
  );

  toMapOfShare(sandbox) {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'leading': leading,
      'upstreamPerson': upstreamPerson,
      'sourceCreator': sourceCreator,
      'site': site,
      'ctime': ctime,
      'utime': utime,
      'sandbox': sandbox,
    };
  }

  Channel.fromMap(map, String person) {
    id = map['channel'];
    name = map['title'];
    owner = map['creator'];
    upstreamPerson = map['upstreamPerson'];
    sourceCreator = map['sourceCreator'];
    leading = map['leading'];
    site = map['site'];
    ctime = map['ctime'];
    utime = map['utime'];
    sandbox = person;
  }

  Channel.fromMapOfShare(map, String person) {
    id = map['id'];
    name = map['name'];
    owner = map['owner'];
    upstreamPerson = map['upstreamPerson'];
    sourceCreator = map['sourceCreator'];
    leading = map['leading'];
    site = map['site'];
    ctime = map['ctime'];
    utime = map['utime'];
    sandbox = person;
  }
}

@entity
class InsiteMessage {
  @primaryKey
  final String id;
  final String docid;
  final String upstreamPerson;
  final String upstreamChannel;
  final String sourceSite;
  final String sourceApp;
  final String creator;
  final int ctime;
  final int atime;
  final String digests;
  final String purchaseSn;
  final String location;
  final String absorber;
  final String sandbox;

  InsiteMessage(
    this.id,
    this.docid,
    this.upstreamPerson,
    this.upstreamChannel,
    this.sourceSite,
    this.sourceApp,
    this.creator,
    this.ctime,
    this.atime,
    this.digests,
    this.purchaseSn,
    this.location,
    this.absorber,
    this.sandbox,
  );

  ChannelMessage copy() {
    return ChannelMessage(
      docid,
      upstreamPerson,
      sourceSite,
      sourceApp,
      upstreamChannel,
      creator,
      ctime,
      DateTime.now().millisecondsSinceEpoch,
      null,
      null,
      null,
      digests,
      purchaseSn,
      location,
      absorber,
      sandbox,
    );
  }
}

@entity
class ChannelMessage {
  @primaryKey
  final String id;
  final String upstreamPerson;
  final String sourceSite;
  final String sourceApp;
  final String onChannel;
  final String creator;
  final int ctime;
  int atime;
  int rtime;
  int dtime;
  String state;
  final String text;
  final String purchaseSn;
  final String location;
  final String absorber;
  final String sandbox;

  ChannelMessage(
    this.id,
    this.upstreamPerson,
    this.sourceSite,
    this.sourceApp,
    this.onChannel,
    this.creator,
    this.ctime,
    this.atime,
    this.rtime,
    this.dtime,
    this.state,
    this.text,
    this.purchaseSn,
    this.location,
    this.absorber,
    this.sandbox,
  );

  InsiteMessage copy() {
    return InsiteMessage(
      Uuid().v1(),
      id,
      upstreamPerson,
      onChannel,
      sourceSite,
      sourceApp,
      creator,
      ctime,
      atime,
      text,
      purchaseSn,
      location,
      absorber,
      sandbox,
    );
  }
}

class ChannelMessageDigest {
  String text;

  int atime;
  int count;

  ChannelMessageDigest({this.text, this.atime, this.count});
}

@Entity(primaryKeys: ['id', 'sandbox'])
class LikePerson {
  @primaryKey
  final String id;
  final String person;
  final String avatar;
  final String msgid;
  final int ctime;
  final String nickName;
  final String onChannel;
  final String sandbox;

  LikePerson(this.id, this.person, this.avatar, this.msgid, this.ctime,
      this.nickName, this.onChannel, this.sandbox);
}

@Entity(primaryKeys: ['id', 'sandbox'])
class ChannelComment {
  final String id;
  final String person;
  final String avatar;
  final String msgid;
  final String text;
  final int ctime;
  final String nickName;
  final String onChannel;
  final String sandbox;

  ChannelComment(this.id, this.person, this.avatar, this.msgid, this.text,
      this.ctime, this.nickName, this.onChannel, this.sandbox);
}

@Entity(primaryKeys: ['id', 'sandbox'])
class Media {
  @primaryKey
  final String id;
  final String type;
  final String src;
  final String leading;
  final String msgid;
  final String text;
  final String onChannel;
  final String sandbox;

  Media(this.id, this.type, this.src, this.leading, this.msgid, this.text,
      this.onChannel, this.sandbox);

  MediaSrc toMediaSrc() {
    return MediaSrc(
        sourceType: 'channel',
        msgid: msgid,
        text: text,
        type: type,
        id: id,
        leading: leading,
        src: src);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'src': src,
      'leading': leading,
      'docid': msgid,
      'text': text,
      'channel': onChannel,
      'sandbox': sandbox,
    };
  }
}

@entity
class ChannelPin {
  @primaryKey
  final String id;
  final String channel;
  final String inPersonSelector;
  final String outPersonSelector;
  final String outGeoSelector;
  final String outWechatPenYouSelector;
  final String outWechatHaoYouSelector;
  final String outContractSelector;
  final String inRights;
  final String outRights;
  final String sandbox;

  ChannelPin(
    this.id,
    this.channel,
    this.inPersonSelector,
    this.outPersonSelector,
    this.outGeoSelector,
    this.outWechatPenYouSelector,
    this.outWechatHaoYouSelector,
    this.outContractSelector,
    this.inRights,
    this.outRights,
    this.sandbox,
  );
}

@Entity(primaryKeys: [
  'id',
  'channel',
  'sandbox',
], indices: [
  Index(value: ['channel', 'person', 'atime'])
])
class ChannelInputPerson {
  final String id;
  final String channel;
  final String person;
  final String rights;
  final int atime;
  final String sandbox;

  ChannelInputPerson(
    this.id,
    this.channel,
    this.person,
    this.rights,
    this.atime,
    this.sandbox,
  );
}

@Entity(primaryKeys: [
  'id',
  'channel',
  'sandbox',
], indices: [
  Index(value: ['channel', 'person', 'atime'])
])
class ChannelOutputPerson {
  final String id;
  final String channel;
  final String person;
  final String rights;
  final int atime;
  final String sandbox;

  ChannelOutputPerson(this.id, this.channel, this.person, this.rights,
      this.atime, this.sandbox);
}

enum PinPersonsSettingsStrategy {
  only_select,
  all_except,
}

@Entity(primaryKeys: ['official', 'sandbox'])
class Friend {
  String official;
  String source;
  String uid;
  String accountCode;
  String appid;
  String avatar;
  String rights;
  String nickName;
  String signature;
  String pyname;
  String sandbox;

  Friend(
      this.official,
      this.source,
      this.uid,
      this.accountCode,
      this.appid,
      this.avatar,
      this.rights,
      this.nickName,
      this.signature,
      this.pyname,
      this.sandbox);

  Friend.formPerson(Person person) {
    this.official = person.official;
    this.source = null;
    this.uid = person.uid;
    this.accountCode = person.accountCode;
    this.appid = person.appid;
    this.avatar = person.avatar;
    this.rights = person.rights;
    this.nickName = person.nickName;
    this.signature = person.signature;
    this.pyname = person.pyname;
    this.sandbox = person.sandbox;
  }

  toPerson() {
    return Person(
      official,
      uid,
      accountCode,
      appid,
      avatar,
      rights,
      nickName,
      signature,
      pyname,
      sandbox,
    );
  }
}

@entity
class ChatRoom {
  @primaryKey
  String id;
  String title;
  String leading;
  String creator;
  int ctime;
  int utime;
  String notice;
  String p2pBackground;
  String isForegoundWhite;
  String isDisplayNick;
  String isSeal;
  String microsite;
  String sandbox;

  ChatRoom(
    this.id,
    this.title,
    this.leading,
    this.creator,
    this.ctime,
    this.utime,
    this.notice,
    this.p2pBackground,
    this.isForegoundWhite,
    this.isDisplayNick,
    this.isSeal,
    this.microsite,
    this.sandbox,
  );
}

@Entity(primaryKeys: ['person', 'room', 'sandbox'])
class RoomMember {
  String room;
  String person;
  String nickName;
  String isShowNick;
  String leading; //供非person类型的成员使用，如wybank
  String type; //成员类型，有person,wybank(福利中心)等，默认是person
  int atime;
  String sandbox;

  RoomMember(
    this.room,
    this.person,
    this.nickName,
    this.isShowNick,
    this.leading,
    this.type,
    this.atime,
    this.sandbox,
  );
}

@entity
class ChatMessage {
  @primaryKey
   String id;
   String sender;
   String room;
   String contentType;
   String content;
   String state;
   String isCanceled;
   int ctime;
   int atime;
   int rtime;
   int dtime;
   String sandbox;

  ChatMessage(this.id, this.sender, this.room, this.contentType, this.content,
      this.state,this.isCanceled, this.ctime, this.atime, this.rtime, this.dtime, this.sandbox);
}

@entity
class Principal implements IPrincipal {
  @primaryKey
  String person;
  String uid;
  String accountCode;
  String nickName;
  String appid;
  String portal;
  String roles;
  String accessToken;
  String refreshToken;
  String ravatar;
  String lavatar;
  String signature;
  int ltime;
  int pubtime;
  int expiretime;
  String device;

  Principal(
      this.person,
      this.uid,
      this.accountCode,
      this.nickName,
      this.appid,
      this.portal,
      this.roles,
      this.accessToken,
      this.refreshToken,
      this.ravatar,
      this.lavatar,
      this.signature,
      this.ltime,
      this.pubtime,
      this.expiretime,
      this.device);
}

@Entity(primaryKeys: [
  'id',
  'sandbox'
], indices: [
  Index(value: ['category', 'creator'])
])
class GeoReceptor {
  String id;
  String title;
  String townCode;
  String channel;
  String category;
  String brand;
  String moveMode;
  String leading;
  String creator;
  String location;
  double radius;

  //更新距离仅在mobiles分类下的感知器有用
  int uDistance;
  int ctime;
  int utime;

  ///original,white,
  String foregroundMode;

  ///vertical|horizontal|none
  String backgroundMode;
  String background;
  String isAutoScrollMessage;
  String device;
  String canDel; //
  String sandbox;

  GeoReceptor(
      this.id,
      this.title,
      this.townCode,
      this.channel,
      this.category,
      this.brand,
      this.moveMode,
      this.leading,
      this.creator,
      this.location,
      this.radius,
      this.uDistance,
      this.ctime,
      this.utime,
      this.foregroundMode,
      this.backgroundMode,
      this.background,
      this.isAutoScrollMessage,
      this.device,
      this.canDel,
      this.sandbox);

  LatLng getLocationLatLng() {
    if (StringUtil.isEmpty(location)) {
      return null;
    }
    return LatLng.fromJson(jsonDecode(location));
  }

  void setLocationLatLng(LatLng location) {
    var map = location.toJson();
    this.location = jsonEncode(map);
  }

  GeoReceptor.load(map, String canDel, String sandbox) {
    var loc = map['location'];
    var locStr;
    if (loc is String) {
      locStr = loc;
    } else {
      locStr = jsonEncode(loc);
    }
    id = map['id'];
    title = map['title'];
    townCode = map['townCode'];
    channel = map['channel'];
    category = map['category'];
    brand = map['brand'];
    moveMode = map['moveMode'];
    leading = map['leading'];
    creator = map['creator'];
    location = locStr;
    radius = map['radius'];
    uDistance = map['uDistance'];
    ctime = map['ctime'];
    utime = map['utime'];
    foregroundMode = map['foregroundMode'] ?? 'original';
    backgroundMode = map['backgroundMode'] ?? 'none';
    background = map['background'];
    isAutoScrollMessage = map['isAutoScrollMessage'];
    device = map['device'];
    this.canDel = canDel;
    this.sandbox = sandbox;
  }

  dynamic toMap() {
    return {
      'id': id,
      'title': title,
      'townCode': townCode,
      'channel': channel,
      'category': category,
      'brand': brand,
      'moveMode': moveMode,
      'leading': leading,
      'creator': creator,
      'location': location,
      'radius': radius,
      'uDistance': uDistance,
      'ctime': ctime,
      'utime': utime,
      'foregroundMode': foregroundMode,
      'backgroundMode': backgroundMode,
      'background': background,
      'isAutoScrollMessage': isAutoScrollMessage,
      'device': device,
      'sandbox': sandbox,
    };
  }
}

enum GeoCategoryMoveableMode {
  unmoveable,
  moveableSelf,
  moveableDependon,
}

@Entity(primaryKeys: ['id', 'sandbox'])
class GeoChannelOL {
  String id;
  String title;
  String leading;
  int sort;
  String sandbox;

  GeoChannelOL(
    this.id,
    this.title,
    this.leading,
    this.sort,
    this.sandbox,
  );
}

@Entity(primaryKeys: ['id', 'sandbox'])
class GeoCategoryOL {
  String id;
  String title;
  String leading;
  int sort;
  int ctime;
  String creator;
  String channel;
  bool isHot;
  String moveMode;
  double defaultRadius;
  String sandbox;

  GeoCategoryOL(
    this.id,
    this.title,
    this.leading,
    this.sort,
    this.ctime,
    this.creator,
    this.channel,
    this.isHot,
    this.moveMode,
    this.defaultRadius,
    this.sandbox,
  );
}

class GeoChannelPortalOR {
  List<GeoChannelOR> channels;
  List<GeoCategoryOR> hotCategories;
  List<GeoBrandOR> hotBrands;

  GeoChannelPortalOR({this.channels, this.hotCategories, this.hotBrands});

  GeoChannelPortalOR.parse(obj) {
    this.channels = <GeoChannelOR>[];
    var channelList = obj['channels'];
    for (var item in channelList) {
      channels.add(
        GeoChannelOR.parse(item),
      );
    }
    this.hotCategories = <GeoCategoryOR>[];
    var categorylList = obj['hotCategories'];
    for (var item in categorylList) {
      hotCategories.add(
        GeoCategoryOR.parse(item),
      );
    }
    this.hotBrands = <GeoBrandOR>[];
    var brandlList = obj['hotBrands'];
    for (var item in brandlList) {
      hotBrands.add(
        GeoBrandOR.parse(item),
      );
    }
  }
}

class GeoChannelOR {
  String id;
  String title;
  String leading;
  int sort;
  List<GeoCategoryOR> categories;

  GeoChannelOR({this.id, this.title, this.leading, this.sort, this.categories});

  GeoChannelOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.leading = obj['leading'];
    this.sort = obj['sort'];
    var categorieObjs = obj['categories'];
    this.categories = <GeoCategoryOR>[];
    for (var item in categorieObjs) {
      this.categories.add(
            GeoCategoryOR.parse(item),
          );
    }
  }
}

class GeoBrandOR {
  String id;
  String title;
  String channel;
  String category;
  bool isHot; //是否热点品牌
  int sort;

  GeoBrandOR(
      {this.id,
      this.title,
      this.channel,
      this.category,
      this.isHot,
      this.sort});

  GeoBrandOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.channel = obj['channel'];
    this.category = obj['category'];
    this.isHot = obj['isHot'];
    this.sort = obj['sort'];
  }
}

class GeoCategoryOR {
  String id;
  String title;
  String leading;
  String channel; //所属频到标识
  String creator;
  bool isHot; //是否热点类别
  int sort;
  int ctime;
  double defaultRadius;
  GeoCategoryMoveableMode moveMode;
  List<GeoBrandOR> brands;

  GeoCategoryOR({
    this.id,
    this.title,
    this.leading,
    this.sort,
    this.ctime,
    this.creator,
    this.moveMode,
    this.defaultRadius = 500,
    this.isHot,
    this.channel,
    this.brands,
  });

  GeoCategoryOL toLocal(sandbox) {
    var mode;
    switch (moveMode) {
      case GeoCategoryMoveableMode.unmoveable:
        mode = 'unmoveable';
        break;
      case GeoCategoryMoveableMode.moveableSelf:
        mode = 'moveableSelf';
        break;
      case GeoCategoryMoveableMode.moveableDependon:
        mode = 'moveableDependon';
        break;
    }
    return GeoCategoryOL(id, title, leading, sort, ctime, creator, channel,
        isHot, mode, defaultRadius, sandbox);
  }

  GeoCategoryOR.parse(obj) {
    GeoCategoryMoveableMode mode;
    switch (obj['moveMode']) {
      case 'unmoveable':
        mode = GeoCategoryMoveableMode.unmoveable;
        break;
      case 'moveableSelf':
        mode = GeoCategoryMoveableMode.moveableSelf;
        break;
      case 'moveableDependon':
        mode = GeoCategoryMoveableMode.moveableDependon;
        break;
      default:
        mode = GeoCategoryMoveableMode.unmoveable;
        break;
    }
    this.id = obj['id'];
    this.title = obj['title'];
    this.leading = obj['leading'];
    this.sort = obj['sort'];
    this.ctime = obj['ctime'];
    this.creator = obj['creator'];
    this.moveMode = mode;
    this.defaultRadius = obj['defaultRadius'];
    this.isHot = obj['isHot'];
    this.channel = obj['channel'];
    var list = obj['brands'];
    this.brands = <GeoBrandOR>[];
    for (var item in list) {
      this.brands.add(GeoBrandOR.parse(item));
    }
  }
}

class GeoCategoryAppOR {
  String id;
  String title;
  String leading;
  String path;
  String category;
  String creator;
  int ctime;

  GeoCategoryAppOR(
      {this.id,
      this.title,
      this.leading,
      this.path,
      this.category,
      this.creator,
      this.ctime});
}

@Entity(primaryKeys: ['id', 'receptor', 'category', 'sandbox'])
class GeosphereMessageOL {
  @primaryKey
  String id;
  String upstreamPerson;
  String upstreamReceptor;
  String upstreamCategory;

//如果是从网流来的消息
  String upstreamChannel;
  String sourceSite;
  String sourceApp;
  String receptor;
  String creator;
  int ctime;
  int atime;
  int rtime;
  int dtime;
  String state;
  String text;
  String purchaseSn;

  ///location是LatLng对象
  String location;
  String channel;
  String category;
  String brand;
  String sandbox;

  GeosphereMessageOL(
      this.id,
      this.upstreamPerson,
      this.upstreamReceptor,
      this.upstreamCategory,
      this.upstreamChannel,
      this.sourceSite,
      this.sourceApp,
      this.receptor,
      this.creator,
      this.ctime,
      this.atime,
      this.rtime,
      this.dtime,
      this.state,
      this.text,
      this.purchaseSn,
      this.location,
      this.channel,
      this.category,
      this.brand,
      this.sandbox);

  GeosphereMessageOL.from(map, sandbox) {
    id = map['id'];
    upstreamPerson = map['upstreamPerson'];
    upstreamReceptor = map['upstreamReceptor'];
    upstreamCategory = map['upstreamCategory'];
    upstreamChannel = map['upstreamChannel'];
    sourceSite = map['sourceSite'];
    sourceApp = map['sourceApp'];
    receptor = map['receptor'];
    creator = map['creator'];
    ctime = map['ctime'];
    atime = map['atime'];
    rtime = map['rtime'];
    dtime = map['dtime'];
    state = map['state'];
    text = map['text'];
    purchaseSn = map['purchaseSn'];
    location = jsonEncode(map['location']);
    channel = map['channel'];
    category = map['category'];
    brand = map['brand'];
    this.sandbox = sandbox;
  }
}

@Entity(primaryKeys: ['id', 'sandbox'])
class GeosphereLikePersonOL {
  @primaryKey
  final String id;
  final String person;
  final String avatar;
  final String msgid;
  final int ctime;
  final String nickName;
  final String receptor;
  final String sandbox;

  GeosphereLikePersonOL(this.id, this.person, this.avatar, this.msgid,
      this.ctime, this.nickName, this.receptor, this.sandbox);
}

@Entity(primaryKeys: ['id', 'msgid', 'receptor', 'sandbox'])
class GeosphereCommentOL {
  final String id;
  final String person;
  final String avatar;
  final String msgid;
  final String text;
  final int ctime;
  final String nickName;
  final String receptor;
  final String sandbox;

  GeosphereCommentOL(this.id, this.person, this.avatar, this.msgid, this.text,
      this.ctime, this.nickName, this.receptor, this.sandbox);
}

@Entity(primaryKeys: [
  'id',
  'msgid',
  'receptor',
  'sandbox'
], indices: [
  Index(value: ['msgid', 'receptor'])
])
class GeosphereMediaOL {
  final String id;
  final String type;
  final String src;
  final String leading;
  final String msgid;
  final String text;
  final String receptor;
  final String sandbox;

  GeosphereMediaOL(this.id, this.type, this.src, this.leading, this.msgid,
      this.text, this.receptor, this.sandbox);

  MediaSrc toMedia() {
    return MediaSrc(
      leading: leading,
      id: id,
      type: type,
      text: text,
      msgid: msgid,
      sourceType: 'geosphere',
      src: src,
    );
  }
}

@entity
class CountValue {
  @primaryKey
  int value;

  CountValue(this.value);
}

class ChatRoomNotice {
  String room;
  String creator;
  String notice;
  int ctime;

  ChatRoomNotice.fromMap(map, sandbox) {
    this.room = map['room'];
    this.creator = map['creator'];
    this.notice = map['notice'];
    this.ctime = map['ctime'];
  }
}

@Entity(primaryKeys: [
  'id',
  'box',
  'sandbox'
], indices: [
  Index(value: ['box', 'atime'])
])
class ContentItemOL {
  String id; //标识来自由pointer的类型+标识的md5，所以在所有流量池中都是唯一的，只要告诉内容物在哪个池，就可以在池中找到它
  String sandbox;
  String box; //归属的内容盒
  String location; //内容物可能有位置属性
  String upstreamPool; //来自上游的流量池，一般是低级池
  int ctime;
  int atime; //添加到本地列表时间
  String pool; //多一个多余字段，用于客户端识别是哪个池的内容
  bool isBubbled;
  String pointerId;
  String pointerType;
  String pointerCreator;
  int pointerCtime;

  ContentItemOL(
    this.id,
    this.sandbox,
    this.box,
    this.location,
    this.upstreamPool,
    this.ctime,
    this.atime,
    this.pool,
    this.isBubbled,
    this.pointerId,
    this.pointerType,
    this.pointerCreator,
    this.pointerCtime,
  ); //是否已冒泡了

}

@Entity(primaryKeys: [
  'id',
  'item',
  'sandbox'
], indices: [
  Index(value: ['inbox', 'item', 'atime', 'sandbox'])
])
class RecommenderMessageOL {
  String id;
  String item;
  String type; //geosphere,netflow
  String creator;
  String content;
  String inbox;
  int layout; //0为上文下图；1为左文右图；2为左图右文
  String location;
  int ctime;
  int atime; //添加到本地列表时间
  String purchaseSn;
  String sandbox;

  RecommenderMessageOL(
    this.id,
    this.item,
    this.type,
    this.creator,
    this.content,
    this.inbox,
    this.layout,
    this.location,
    this.ctime,
    this.atime,
    this.purchaseSn,
    this.sandbox,
  );
}

@Entity(primaryKeys: [
  'id',
  'docid',
  'sandbox'
], indices: [
  Index(value: ['docid', 'ctime'])
])
class RecommenderMediaOL {
  String id;
  String docid;
  String type;
  String src;
  String text;
  String leading;
  int ctime;
  String sandbox;

  RecommenderMediaOL(
    this.id,
    this.docid,
    this.type,
    this.src,
    this.text,
    this.leading,
    this.ctime,
    this.sandbox,
  );
}
