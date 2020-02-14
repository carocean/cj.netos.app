import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../entities.dart';
import 'daos.dart';

part 'database.g.dart';

@Database(version: 1, entities: [
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
  RoomNick,
  P2PMessage,
  Principal,
])
abstract class AppDatabase extends FloorDatabase {
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
