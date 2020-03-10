import 'package:floor/floor.dart';
import 'package:framework/framework.dart';

@entity
class Person {
  @primaryKey
  final String id;
  final String official;
  final String uid;
  final String accountid;
  final String accountName;
  final String appid;
  final String tenantid;
  final String avatar;
  final String rights;
  final String nickName;
  final String signature;
  final String pyname;
  final String sandbox;

  Person(
      this.id,
      this.official,
      this.uid,
      this.accountid,
      this.accountName,
      this.appid,
      this.tenantid,
      this.avatar,
      this.rights,
      this.nickName,
      this.signature,
      this.pyname,
      this.sandbox);
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

@entity
class Channel {
  @primaryKey
  String id;
  final String origin;
  final String name;
  final String owner;
   String leading;
  final String site;
  int ctime = DateTime.now().millisecondsSinceEpoch;
  final String sandbox;

  Channel(this.id, this.origin, this.name, this.owner, this.leading, this.site,
      this.ctime, this.sandbox);
}

@entity
class InsiteMessage {
  @primaryKey
  final String id;
  final String docid;
  final String upstreamPerson;
  final String sourceSite;
  final String sourceApp;
  final String onChannel;
  final String creator;
  final int ctime;
  final int atime;
  final int rtime;
  final int dtime;
  final String state;
  final String digests;
  final double wy;
  final String location;
  final String sandbox;

  InsiteMessage(
    this.id,
    this.docid,
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
    this.digests,
    this.wy,
    this.location,
    this.sandbox,
  );
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
    this.text,
    this.wy,
    this.location,
    this.sandbox,
  );
}

@entity
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

@entity
class ChannelComment {
  @primaryKey
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

@entity
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
  final String sandbox;

  ChannelInputPerson(
    this.id,
    this.channel,
    this.person,
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

@entity
class Friend {
  @primaryKey
  final String id;
  final String official;
  final String source;
  final String uid;
  final String accountid;
  final String accountName;
  final String appid;
  final String tenantid;
  final String avatar;
  final String rights;
  final String nickName;
  final String signature;
  final String pyname;
  final String sandbox;

  Friend(
      this.id,
      this.official,
      this.source,
      this.uid,
      this.accountid,
      this.accountName,
      this.appid,
      this.tenantid,
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
