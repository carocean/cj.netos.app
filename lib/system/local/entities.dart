import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:floor/floor.dart';
import 'package:framework/framework.dart';
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

@Entity(primaryKeys: ['id', 'sandbox'])
class Channel {
  String id;
  final String name;
  final String owner;
  String leading;
  final String site;
  int ctime = DateTime.now().millisecondsSinceEpoch;
  final String sandbox;

  Channel(this.id, this.name, this.owner, this.leading, this.site, this.ctime,
      this.sandbox);

  toMap() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'leading': leading,
      'site': site,
      'ctime': ctime,
      'sandbox': sandbox,
    };
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
  final double wy;
  final String location;
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
    this.wy,
    this.location,
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
      wy,
      location,
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
  final double wy;
  final String location;
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
    this.wy,
    this.location,
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
      wy,
      location,
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

@entity
class ChannelInputPerson {
  @primaryKey
  final String id;
  final String channel;
  final String person;
  final String rights;
  final String sandbox;

  ChannelInputPerson(
    this.id,
    this.channel,
    this.person,
    this.rights,
    this.sandbox,
  );
}

@entity
class ChannelOutputPerson {
  @primaryKey
  final String id;
  final String channel;
  final String person;
  final String sandbox;

  ChannelOutputPerson(this.id, this.channel, this.person, this.sandbox);
}

enum PinPersonsSettingsStrategy {
  only_select,
  all_except,
}

@Entity(primaryKeys: ['official', 'sandbox'])
class Friend {
  final String official;
  final String source;
  final String uid;
  final String accountName;
  final String appid;
  final String avatar;
  final String rights;
  final String nickName;
  final String signature;
  final String pyname;
  final String sandbox;

  Friend(
      this.official,
      this.source,
      this.uid,
      this.accountName,
      this.appid,
      this.avatar,
      this.rights,
      this.nickName,
      this.signature,
      this.pyname,
      this.sandbox);
}

@entity
class ChatRoom {
  @primaryKey
  final String id;
  final String code;
  final String title;
  final String leading;
  final String creator;
  final int ctime;
  final String notice;
  final String p2pBackground;
  final String isDisplayNick;
  final String microsite;
  final String sandbox;

  ChatRoom(
    this.id,
    this.code,
    this.title,
    this.leading,
    this.creator,
    this.ctime,
    this.notice,
    this.p2pBackground,
    this.isDisplayNick,
    this.microsite,
    this.sandbox,
  );
}

@entity
class RoomMember {
  @primaryKey
  final String id;
  final String room;
  final String person;
  final String whoAdd;
  final String sandbox;

  RoomMember(
    this.id,
    this.room,
    this.person,
    this.whoAdd,
    this.sandbox,
  );
}

@entity
class RoomNick {
  @primaryKey
  final String id;
  final String person;
  final String room;
  final String nickName;
  final String sandbox;

  RoomNick(this.id, this.person, this.room, this.nickName, this.sandbox);
}

@entity
class P2PMessage {
  @primaryKey
  final String id;
  final String sender;
  final String receiver;
  final String room;
  final String type;
  final String content;
  final String state;
  final int ctime;
  final int atime;
  final int rtime;
  final int dtime;
  final String sandbox;

  P2PMessage(
      this.id,
      this.sender,
      this.receiver,
      this.room,
      this.type,
      this.content,
      this.state,
      this.ctime,
      this.atime,
      this.rtime,
      this.dtime,
      this.sandbox);
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

@Entity(primaryKeys: ['id', 'sandbox'])
class GeoReceptor {
  String id;
  String title;
  String category;
  String leading;
  String creator;
  String location;
  double radius;
  int ctime;
  String device;
  String dependon;
  String sandbox;

  GeoReceptor(
      this.id,
      this.title,
      this.category,
      this.leading,
      this.creator,
      this.location,
      this.radius,
      this.ctime,
      this.device,
      this.dependon,
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
}

class GeoCategory {
  String id;
  String title;
  int sort;
  int ctime;
  String creator;
  bool isDependon;
  GeoCategory({this.id, this.title, this.sort, this.ctime, this.creator,this.isDependon});
}
