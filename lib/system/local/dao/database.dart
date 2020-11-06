import 'dart:async';
import 'package:floor/floor.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../entities.dart';
import 'daos.dart';

part 'database.g.dart';

@Database(version: 4, entities: [
  ///欲接收限定字段的值应该像声明CountValue对象那样使用
  ///CountValue用于接收查询的统计字段，并且以 as 字段别名，别名与CountValue对应
  CountValue,
  Person,
  MicroSite,
  MicroApp,
  Channel,
  InsiteMessage,
  ChannelMessage,
  ChannelComment,
  LikePerson,
  Media,
  ChannelPin,
  ChannelInputPerson,
  ChannelOutputPerson,
  Friend,
  ChatRoom,
  RoomMember,
  ChatMessage,
  Principal,
  GeoReceptor,
  GeoCategoryOL,
  GeosphereMessageOL,
  GeosphereLikePersonOL,
  GeosphereCommentOL,
  GeosphereMediaOL,
  ContentItemOL,
  RecommenderMessageOL,
  RecommenderMediaOL,
])
abstract class AppDatabase extends FloorDatabase {
  IRecommenderDAO get chasechainDAO;

  IGeosphereMessageDAO get geosphereMessageDAO;

  IGeosphereLikePersonDAO get geosphereLikePersonDAO;

  IGeosphereCommentDAO get geosphereCommentDAO;

  IGeosphereMediaDAO get geosphereMediaDAO;

  IGeoReceptorDAO get geoReceptorDAO;

  IGeoCategoryDAO get geoCategoryDAO;

  IPrincipalDAO get principalDAO;

  IPersonDAO get upstreamPersonDAO;

  IMicroSiteDAO get microSiteDAO;

  IMicroAppDAO get microAppDAO;

  IChannelDAO get channelDAO;

  IInsiteMessageDAO get insiteMessageDAO;

  IChannelMessageDAO get channelMessageDAO;

  IChannelMediaDAO get channelMediaDAO;

  IChannelLikePersonDAO get channelLikeDAO;

  IChannelCommentDAO get channelCommentDAO;

  IChannelPinDAO get channelPinDAO;

  IChannelInputPersonDAO get channelInputPersonDAO;

  IChannelOutputPersonDAO get channelOutputPersonDAO;

  IFriendDAO get friendDAO;

  IChatRoomDAO get chatRoomDAO;

  IRoomMemberDAO get roomMemberDAO;

  IRoomNickDAO get roomNickDAO;

  IP2PMessageDAO get p2pMessageDAO;
}
