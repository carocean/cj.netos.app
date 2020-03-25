// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final database = _$AppDatabase();
    database.database = await database.open(
      name ?? ':memory:',
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  IGeoReceptorDAO _geoReceptorDAOInstance;

  IPrincipalDAO _principalDAOInstance;

  IPersonDAO _upstreamPersonDAOInstance;

  IMicroSiteDAO _microSiteDAOInstance;

  IMicroAppDAO _microAppDAOInstance;

  IChannelDAO _channelDAOInstance;

  IInsiteMessageDAO _insiteMessageDAOInstance;

  IChannelMessageDAO _channelMessageDAOInstance;

  IChannelMediaDAO _channelMediaDAOInstance;

  IChannelLikePersonDAO _channelLikeDAOInstance;

  IChannelCommentDAO _channelCommentDAOInstance;

  IChannelPinDAO _channelPinDAOInstance;

  IChannelInputPersonDAO _channelInputPersonDAOInstance;

  IChannelOutputPersonDAO _channelOutputPersonDAOInstance;

  IFriendDAO _friendDAOInstance;

  IChatRoomDAO _chatRoomDAOInstance;

  IRoomMemberDAO _roomMemberDAOInstance;

  IRoomNickDAO _roomNickDAOInstance;

  IP2PMessageDAO _p2pMessageDAOInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations,
      [Callback callback]) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`official` TEXT, `uid` TEXT, `accountCode` TEXT, `appid` TEXT, `avatar` TEXT, `rights` TEXT, `nickName` TEXT, `signature` TEXT, `pyname` TEXT, `sandbox` TEXT, PRIMARY KEY (`official`, `sandbox`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MicroSite` (`id` TEXT, `name` TEXT, `leading` TEXT, `desc` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MicroApp` (`id` TEXT, `site` TEXT, `leading` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Channel` (`id` TEXT, `name` TEXT, `owner` TEXT, `leading` TEXT, `site` TEXT, `ctime` INTEGER, `sandbox` TEXT, PRIMARY KEY (`id`, `sandbox`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `InsiteMessage` (`id` TEXT, `docid` TEXT, `upstreamPerson` TEXT, `upstreamChannel` TEXT, `sourceSite` TEXT, `sourceApp` TEXT, `creator` TEXT, `ctime` INTEGER, `atime` INTEGER, `digests` TEXT, `wy` REAL, `location` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChannelMessage` (`id` TEXT, `upstreamPerson` TEXT, `sourceSite` TEXT, `sourceApp` TEXT, `onChannel` TEXT, `creator` TEXT, `ctime` INTEGER, `atime` INTEGER, `rtime` INTEGER, `dtime` INTEGER, `state` TEXT, `text` TEXT, `wy` REAL, `location` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChannelComment` (`id` TEXT, `person` TEXT, `avatar` TEXT, `msgid` TEXT, `text` TEXT, `ctime` INTEGER, `nickName` TEXT, `onChannel` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`, `sandbox`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `LikePerson` (`id` TEXT, `person` TEXT, `avatar` TEXT, `msgid` TEXT, `ctime` INTEGER, `nickName` TEXT, `onChannel` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`, `sandbox`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Media` (`id` TEXT, `type` TEXT, `src` TEXT, `leading` TEXT, `msgid` TEXT, `text` TEXT, `onChannel` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`, `sandbox`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChannelPin` (`id` TEXT, `channel` TEXT, `inPersonSelector` TEXT, `outPersonSelector` TEXT, `outGeoSelector` TEXT, `outWechatPenYouSelector` TEXT, `outWechatHaoYouSelector` TEXT, `outContractSelector` TEXT, `inRights` TEXT, `outRights` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChannelInputPerson` (`id` TEXT, `channel` TEXT, `person` TEXT, `rights` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChannelOutputPerson` (`id` TEXT, `channel` TEXT, `person` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Friend` (`official` TEXT, `source` TEXT, `uid` TEXT, `accountName` TEXT, `appid` TEXT, `avatar` TEXT, `rights` TEXT, `nickName` TEXT, `signature` TEXT, `pyname` TEXT, `sandbox` TEXT, PRIMARY KEY (`official`, `sandbox`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChatRoom` (`id` TEXT, `code` TEXT, `title` TEXT, `leading` TEXT, `creator` TEXT, `ctime` INTEGER, `notice` TEXT, `p2pBackground` TEXT, `isDisplayNick` TEXT, `microsite` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RoomMember` (`id` TEXT, `room` TEXT, `person` TEXT, `whoAdd` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RoomNick` (`id` TEXT, `person` TEXT, `room` TEXT, `nickName` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `P2PMessage` (`id` TEXT, `sender` TEXT, `receiver` TEXT, `room` TEXT, `type` TEXT, `content` TEXT, `state` TEXT, `ctime` INTEGER, `atime` INTEGER, `rtime` INTEGER, `dtime` INTEGER, `sandbox` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Principal` (`person` TEXT, `uid` TEXT, `accountCode` TEXT, `nickName` TEXT, `appid` TEXT, `portal` TEXT, `roles` TEXT, `accessToken` TEXT, `refreshToken` TEXT, `ravatar` TEXT, `lavatar` TEXT, `signature` TEXT, `ltime` INTEGER, `pubtime` INTEGER, `expiretime` INTEGER, `device` TEXT, PRIMARY KEY (`person`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GeoReceptor` (`id` TEXT, `title` TEXT, `category` TEXT, `leading` TEXT, `creator` TEXT, `location` TEXT, `radius` REAL, `ctime` INTEGER, `device` TEXT, `sandbox` TEXT, PRIMARY KEY (`id`, `sandbox`))');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  IGeoReceptorDAO get geoReceptorDAO {
    return _geoReceptorDAOInstance ??=
        _$IGeoReceptorDAO(database, changeListener);
  }

  @override
  IPrincipalDAO get principalDAO {
    return _principalDAOInstance ??= _$IPrincipalDAO(database, changeListener);
  }

  @override
  IPersonDAO get upstreamPersonDAO {
    return _upstreamPersonDAOInstance ??=
        _$IPersonDAO(database, changeListener);
  }

  @override
  IMicroSiteDAO get microSiteDAO {
    return _microSiteDAOInstance ??= _$IMicroSiteDAO(database, changeListener);
  }

  @override
  IMicroAppDAO get microAppDAO {
    return _microAppDAOInstance ??= _$IMicroAppDAO(database, changeListener);
  }

  @override
  IChannelDAO get channelDAO {
    return _channelDAOInstance ??= _$IChannelDAO(database, changeListener);
  }

  @override
  IInsiteMessageDAO get insiteMessageDAO {
    return _insiteMessageDAOInstance ??=
        _$IInsiteMessageDAO(database, changeListener);
  }

  @override
  IChannelMessageDAO get channelMessageDAO {
    return _channelMessageDAOInstance ??=
        _$IChannelMessageDAO(database, changeListener);
  }

  @override
  IChannelMediaDAO get channelMediaDAO {
    return _channelMediaDAOInstance ??=
        _$IChannelMediaDAO(database, changeListener);
  }

  @override
  IChannelLikePersonDAO get channelLikeDAO {
    return _channelLikeDAOInstance ??=
        _$IChannelLikePersonDAO(database, changeListener);
  }

  @override
  IChannelCommentDAO get channelCommentDAO {
    return _channelCommentDAOInstance ??=
        _$IChannelCommentDAO(database, changeListener);
  }

  @override
  IChannelPinDAO get channelPinDAO {
    return _channelPinDAOInstance ??=
        _$IChannelPinDAO(database, changeListener);
  }

  @override
  IChannelInputPersonDAO get channelInputPersonDAO {
    return _channelInputPersonDAOInstance ??=
        _$IChannelInputPersonDAO(database, changeListener);
  }

  @override
  IChannelOutputPersonDAO get channelOutputPersonDAO {
    return _channelOutputPersonDAOInstance ??=
        _$IChannelOutputPersonDAO(database, changeListener);
  }

  @override
  IFriendDAO get friendDAO {
    return _friendDAOInstance ??= _$IFriendDAO(database, changeListener);
  }

  @override
  IChatRoomDAO get chatRoomDAO {
    return _chatRoomDAOInstance ??= _$IChatRoomDAO(database, changeListener);
  }

  @override
  IRoomMemberDAO get roomMemberDAO {
    return _roomMemberDAOInstance ??=
        _$IRoomMemberDAO(database, changeListener);
  }

  @override
  IRoomNickDAO get roomNickDAO {
    return _roomNickDAOInstance ??= _$IRoomNickDAO(database, changeListener);
  }

  @override
  IP2PMessageDAO get p2pMessageDAO {
    return _p2pMessageDAOInstance ??=
        _$IP2PMessageDAO(database, changeListener);
  }
}

class _$IGeoReceptorDAO extends IGeoReceptorDAO {
  _$IGeoReceptorDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _geoReceptorInsertionAdapter = InsertionAdapter(
            database,
            'GeoReceptor',
            (GeoReceptor item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'category': item.category,
                  'leading': item.leading,
                  'creator': item.creator,
                  'location': item.location,
                  'radius': item.radius,
                  'ctime': item.ctime,
                  'device': item.device,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _geoReceptorMapper = (Map<String, dynamic> row) => GeoReceptor(
      row['id'] as String,
      row['title'] as String,
      row['category'] as String,
      row['leading'] as String,
      row['creator'] as String,
      row['location'] as String,
      row['radius'] as double,
      row['ctime'] as int,
      row['device'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<GeoReceptor> _geoReceptorInsertionAdapter;

  @override
  Future<GeoReceptor> getReceptor(
      String creator, String device, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM GeoReceptor WHERE creator=? and device=? and sandbox=? LIMIT 1',
        arguments: <dynamic>[creator, device, sandbox],
        mapper: _geoReceptorMapper);
  }

  @override
  Future<GeoReceptor> get(String id, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM GeoReceptor WHERE id=? and sandbox=?',
        arguments: <dynamic>[id, sandbox],
        mapper: _geoReceptorMapper);
  }

  @override
  Future<List<GeoReceptor>> page(String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM GeoReceptor WHERE sandbox=? limit ? offset ?',
        arguments: <dynamic>[sandbox, limit, offset],
        mapper: _geoReceptorMapper);
  }

  @override
  Future<void> remove(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM GeoReceptor WHERE id=? and sandbox = ?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<void> add(GeoReceptor receptor) async {
    await _geoReceptorInsertionAdapter.insert(
        receptor, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IPrincipalDAO extends IPrincipalDAO {
  _$IPrincipalDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _principalInsertionAdapter = InsertionAdapter(
            database,
            'Principal',
            (Principal item) => <String, dynamic>{
                  'person': item.person,
                  'uid': item.uid,
                  'accountCode': item.accountCode,
                  'nickName': item.nickName,
                  'appid': item.appid,
                  'portal': item.portal,
                  'roles': item.roles,
                  'accessToken': item.accessToken,
                  'refreshToken': item.refreshToken,
                  'ravatar': item.ravatar,
                  'lavatar': item.lavatar,
                  'signature': item.signature,
                  'ltime': item.ltime,
                  'pubtime': item.pubtime,
                  'expiretime': item.expiretime,
                  'device': item.device
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _principalMapper = (Map<String, dynamic> row) => Principal(
      row['person'] as String,
      row['uid'] as String,
      row['accountCode'] as String,
      row['nickName'] as String,
      row['appid'] as String,
      row['portal'] as String,
      row['roles'] as String,
      row['accessToken'] as String,
      row['refreshToken'] as String,
      row['ravatar'] as String,
      row['lavatar'] as String,
      row['signature'] as String,
      row['ltime'] as int,
      row['pubtime'] as int,
      row['expiretime'] as int,
      row['device'] as String);

  final InsertionAdapter<Principal> _principalInsertionAdapter;

  @override
  Future<List<Principal>> getAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Principal ORDER BY ltime DESC',
        mapper: _principalMapper);
  }

  @override
  Future<void> remove(String person) async {
    await _queryAdapter.queryNoReturn('delete FROM Principal WHERE person = ?',
        arguments: <dynamic>[person]);
  }

  @override
  Future<void> updateToken(
      String refreshToken, String accessToken, String person) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Principal SET refreshToken=? , accessToken = ? WHERE person=?',
        arguments: <dynamic>[refreshToken, accessToken, person]);
  }

  @override
  Future<Principal> get(String person) async {
    return _queryAdapter.query('SELECT * FROM Principal where person=?',
        arguments: <dynamic>[person], mapper: _principalMapper);
  }

  @override
  Future<void> emptyRefreshToken(String person) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Principal SET refreshToken=NULL WHERE person=?',
        arguments: <dynamic>[person]);
  }

  @override
  Future<void> updateAvatar(
      dynamic localAvatar, String remoteAvatar, String person) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Principal SET lavatar=? , ravatar=? WHERE person=?',
        arguments: <dynamic>[localAvatar, remoteAvatar, person]);
  }

  @override
  Future<void> updateNickname(String nickName, String person) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Principal SET nickName=? WHERE person=?',
        arguments: <dynamic>[nickName, person]);
  }

  @override
  Future<void> updateSignature(String signature, String person) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Principal SET signature=? WHERE person=?',
        arguments: <dynamic>[signature, person]);
  }

  @override
  Future<void> add(Principal principal) async {
    await _principalInsertionAdapter.insert(
        principal, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IPersonDAO extends IPersonDAO {
  _$IPersonDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _personInsertionAdapter = InsertionAdapter(
            database,
            'Person',
            (Person item) => <String, dynamic>{
                  'official': item.official,
                  'uid': item.uid,
                  'accountCode': item.accountCode,
                  'appid': item.appid,
                  'avatar': item.avatar,
                  'rights': item.rights,
                  'nickName': item.nickName,
                  'signature': item.signature,
                  'pyname': item.pyname,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _personMapper = (Map<String, dynamic> row) => Person(
      row['official'] as String,
      row['uid'] as String,
      row['accountCode'] as String,
      row['appid'] as String,
      row['avatar'] as String,
      row['rights'] as String,
      row['nickName'] as String,
      row['signature'] as String,
      row['pyname'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<Person> _personInsertionAdapter;

  @override
  Future<void> removePerson(String official, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM Person WHERE official = ? AND sandbox=?',
        arguments: <dynamic>[official, sandbox]);
  }

  @override
  Future<void> empty(String sandbox) async {
    await _queryAdapter.queryNoReturn('delete FROM Person where sandbox=?',
        arguments: <dynamic>[sandbox]);
  }

  @override
  Future<List<Person>> pagePerson(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Person where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _personMapper);
  }

  @override
  Future<Person> getPerson(String official, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM Person WHERE official = ? and sandbox=? LIMIT 1',
        arguments: <dynamic>[official, sandbox],
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> getAllPerson(String sandbox) async {
    return _queryAdapter.queryList('SELECT * FROM Person where sandbox=?',
        arguments: <dynamic>[sandbox], mapper: _personMapper);
  }

  @override
  Future<List<Person>> countPersons(String sandbox) async {
    return _queryAdapter.queryList('SELECT * FROM Person where sandbox=?',
        arguments: <dynamic>[sandbox], mapper: _personMapper);
  }

  @override
  Future<List<Person>> pagePersonWithout(String sandbox, List<String> officials,
      int persons_limit, int persons_offset) async {
    final valueList1 = officials.map((value) => "'$value'").join(', ');
    return _queryAdapter.queryList(
        'SELECT * FROM Person where sandbox=? and official NOT IN ($valueList1) LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, persons_limit, persons_offset],
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> pagePersonWith(String sandbox, List<String> officials,
      int persons_limit, int persons_offset) async {
    final valueList1 = officials.map((value) => "'$value'").join(', ');
    return _queryAdapter.queryList(
        'SELECT * FROM Person where sandbox=? and official IN ($valueList1) LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, persons_limit, persons_offset],
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> listPersonWith(
      String sandbox, List<String> officials) async {
    final valueList1 = officials.map((value) => "'$value'").join(', ');
    return _queryAdapter.queryList(
        'SELECT * FROM Person where sandbox=? and official IN ($valueList1)',
        arguments: <dynamic>[sandbox],
        mapper: _personMapper);
  }

  @override
  Future<Person> findPerson(
      String sandbox, String accountCode, String appid, String tenantid) async {
    return _queryAdapter.query(
        'SELECT * FROM Person WHERE sandbox=? and accountCode = ? and appid=? and tenantid=? LIMIT 1 OFFSET 0',
        arguments: <dynamic>[sandbox, accountCode, appid, tenantid],
        mapper: _personMapper);
  }

  @override
  Future<Person> getPersonByUID(String sandbox, String uid) async {
    return _queryAdapter.query(
        'SELECT * FROM Person WHERE sandbox =? and uid = ? LIMIT 1 OFFSET 0',
        arguments: <dynamic>[sandbox, uid],
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> pagePersonNotFriends(
      String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Person where sandbox=? and official NOT IN (select official from Friend) LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, limit, offset],
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> pagePersonLikeName(String sandbox, String accountCode,
      String nickName, String pyname, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Person where sandbox=? and (accountCode LIKE ? OR nickName LIKE ? OR pyname LIKE ?) and official NOT IN (select official from Friend) LIMIT ? OFFSET ?',
        arguments: <dynamic>[
          sandbox,
          accountCode,
          nickName,
          pyname,
          limit,
          offset
        ],
        mapper: _personMapper);
  }

  @override
  Future<void> updateRights(
      String rights, String sandbox, String official) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Person SET rights = ? WHERE sandbox=? and official=?',
        arguments: <dynamic>[rights, sandbox, official]);
  }

  @override
  Future<void> addPerson(Person person) async {
    await _personInsertionAdapter.insert(
        person, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IMicroSiteDAO extends IMicroSiteDAO {
  _$IMicroSiteDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _microSiteInsertionAdapter = InsertionAdapter(
            database,
            'MicroSite',
            (MicroSite item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'leading': item.leading,
                  'desc': item.desc,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _microSiteMapper = (Map<String, dynamic> row) => MicroSite(
      row['id'] as String,
      row['name'] as String,
      row['leading'] as String,
      row['desc'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<MicroSite> _microSiteInsertionAdapter;

  @override
  Future<void> removeSite(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM MicroSite WHERE id = ? and sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<List<MicroSite>> pageSite(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM MicroSite where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _microSiteMapper);
  }

  @override
  Future<MicroSite> getSite(String sandbox, String id) async {
    return _queryAdapter.query(
        'SELECT * FROM MicroSite WHERE sandbox=? and id = ?',
        arguments: <dynamic>[sandbox, id],
        mapper: _microSiteMapper);
  }

  @override
  Future<List<MicroSite>> getAllSite(String sandbox) async {
    return _queryAdapter.queryList('SELECT * FROM MicroSite where sandbox=?',
        arguments: <dynamic>[sandbox], mapper: _microSiteMapper);
  }

  @override
  Future<void> addSite(MicroSite site) async {
    await _microSiteInsertionAdapter.insert(
        site, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IMicroAppDAO extends IMicroAppDAO {
  _$IMicroAppDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _microAppInsertionAdapter = InsertionAdapter(
            database,
            'MicroApp',
            (MicroApp item) => <String, dynamic>{
                  'id': item.id,
                  'site': item.site,
                  'leading': item.leading,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _microAppMapper = (Map<String, dynamic> row) => MicroApp(
      row['id'] as String,
      row['site'] as String,
      row['leading'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<MicroApp> _microAppInsertionAdapter;

  @override
  Future<void> removeApp(String sandbox, String id) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM MicroApp WHERE sandbox=? and id = ?',
        arguments: <dynamic>[sandbox, id]);
  }

  @override
  Future<List<MicroApp>> pageApp(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM MicroApp where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _microAppMapper);
  }

  @override
  Future<MicroApp> getApp(String sandbox, String id) async {
    return _queryAdapter.query(
        'SELECT * FROM MicroApp WHERE sandbox=? and id = ?',
        arguments: <dynamic>[sandbox, id],
        mapper: _microAppMapper);
  }

  @override
  Future<List<MicroApp>> getAllApp(String sandbox) async {
    return _queryAdapter.queryList('SELECT * FROM MicroApp where sandbox=?',
        arguments: <dynamic>[sandbox], mapper: _microAppMapper);
  }

  @override
  Future<void> addApp(MicroApp site) async {
    await _microAppInsertionAdapter.insert(
        site, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelDAO extends IChannelDAO {
  _$IChannelDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _channelInsertionAdapter = InsertionAdapter(
            database,
            'Channel',
            (Channel item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'owner': item.owner,
                  'leading': item.leading,
                  'site': item.site,
                  'ctime': item.ctime,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _channelMapper = (Map<String, dynamic> row) => Channel(
      row['id'] as String,
      row['name'] as String,
      row['owner'] as String,
      row['leading'] as String,
      row['site'] as String,
      row['ctime'] as int,
      row['sandbox'] as String);

  final InsertionAdapter<Channel> _channelInsertionAdapter;

  @override
  Future<void> removeChannel(String sandbox, String id) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM Channel WHERE sandbox=? and id = ?',
        arguments: <dynamic>[sandbox, id]);
  }

  @override
  Future<List<Channel>> pageChannel(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Channel where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _channelMapper);
  }

  @override
  Future<Channel> getChannel(String sandbox, String id) async {
    return _queryAdapter.query(
        'SELECT * FROM Channel WHERE sandbox=? and id = ?',
        arguments: <dynamic>[sandbox, id],
        mapper: _channelMapper);
  }

  @override
  Future<List<Channel>> getAllChannel(String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Channel where sandbox=? ORDER BY ctime DESC',
        arguments: <dynamic>[sandbox],
        mapper: _channelMapper);
  }

  @override
  Future<void> empty(String sandbox) async {
    await _queryAdapter.queryNoReturn('delete FROM Channel where sandbox=?',
        arguments: <dynamic>[sandbox]);
  }

  @override
  Future<void> emptyOfPerson(String sandbox, String person) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM Channel WHERE sandbox=? and owner = ?',
        arguments: <dynamic>[sandbox, person]);
  }

  @override
  Future<List<Channel>> getChannelsOfPerson(
      String sandbox, String person) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Channel WHERE sandbox=? and owner = ?',
        arguments: <dynamic>[sandbox, person],
        mapper: _channelMapper);
  }

  @override
  Future<Channel> getChannelByName(
      String sandbox, String channelName, String owner) async {
    return _queryAdapter.query(
        'SELECT * FROM Channel WHERE sandbox=? and name = ? AND owner = ?',
        arguments: <dynamic>[sandbox, channelName, owner],
        mapper: _channelMapper);
  }

  @override
  Future<void> updateLeading(String path, String sandbox, String id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Channel SET leading = ? WHERE sandbox=? and id = ?',
        arguments: <dynamic>[path, sandbox, id]);
  }

  @override
  Future<void> updateName(String name, String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Channel SET name = ? WHERE id = ? and sandbox=?',
        arguments: <dynamic>[name, id, sandbox]);
  }

  @override
  Future<void> addChannel(Channel channel) async {
    await _channelInsertionAdapter.insert(
        channel, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IInsiteMessageDAO extends IInsiteMessageDAO {
  _$IInsiteMessageDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _insiteMessageInsertionAdapter = InsertionAdapter(
            database,
            'InsiteMessage',
            (InsiteMessage item) => <String, dynamic>{
                  'id': item.id,
                  'docid': item.docid,
                  'upstreamPerson': item.upstreamPerson,
                  'upstreamChannel': item.upstreamChannel,
                  'sourceSite': item.sourceSite,
                  'sourceApp': item.sourceApp,
                  'creator': item.creator,
                  'ctime': item.ctime,
                  'atime': item.atime,
                  'digests': item.digests,
                  'wy': item.wy,
                  'location': item.location,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _insiteMessageMapper = (Map<String, dynamic> row) =>
      InsiteMessage(
          row['id'] as String,
          row['docid'] as String,
          row['upstreamPerson'] as String,
          row['upstreamChannel'] as String,
          row['sourceSite'] as String,
          row['sourceApp'] as String,
          row['creator'] as String,
          row['ctime'] as int,
          row['atime'] as int,
          row['digests'] as String,
          row['wy'] as double,
          row['location'] as String,
          row['sandbox'] as String);

  final InsertionAdapter<InsiteMessage> _insiteMessageInsertionAdapter;

  @override
  Future<void> removeMessage(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM InsiteMessage WHERE id = ? and sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<List<InsiteMessage>> pageMessage(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM InsiteMessage where sandbox=? ORDER BY atime DESC , ctime ASC LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<List<InsiteMessage>> getMessageByChannel(
      String channelid, String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM InsiteMessage where upstreamChannel=? and sandbox=? ORDER BY atime DESC , ctime ASC',
        arguments: <dynamic>[channelid, sandbox],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<List<InsiteMessage>> pageMessageNotMine(
      String sandbox, String creator, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM InsiteMessage where sandbox=? AND creator!=? ORDER BY atime DESC , ctime ASC LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, creator, limit, offset],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<List<InsiteMessage>> pageMessageIsMine(
      String sandbox, String creator, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM InsiteMessage where sandbox=? AND creator=? ORDER BY atime DESC , ctime ASC LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, creator, limit, offset],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<InsiteMessage> getMessage(String id, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM InsiteMessage WHERE id = ? and sandbox=? LIMIT 1',
        arguments: <dynamic>[id, sandbox],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<InsiteMessage> getMessageByDocid(
      String docid, String upstreamChannel, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM InsiteMessage WHERE docid = ? and upstreamChannel=? and sandbox=? LIMIT 1',
        arguments: <dynamic>[docid, upstreamChannel, sandbox],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<List<InsiteMessage>> getAllMessage(String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM InsiteMessage where sandbox=?',
        arguments: <dynamic>[sandbox],
        mapper: _insiteMessageMapper);
  }

  @override
  Future<void> empty(String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM InsiteMessage where sandbox=?',
        arguments: <dynamic>[sandbox]);
  }

  @override
  Future<void> emptyChannel(String sandbox, dynamic upstreamChannel) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM InsiteMessage where sandbox=? and upstreamChannel=?',
        arguments: <dynamic>[sandbox, upstreamChannel]);
  }

  @override
  Future<void> addMessage(InsiteMessage message) async {
    await _insiteMessageInsertionAdapter.insert(
        message, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelMessageDAO extends IChannelMessageDAO {
  _$IChannelMessageDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _channelMessageInsertionAdapter = InsertionAdapter(
            database,
            'ChannelMessage',
            (ChannelMessage item) => <String, dynamic>{
                  'id': item.id,
                  'upstreamPerson': item.upstreamPerson,
                  'sourceSite': item.sourceSite,
                  'sourceApp': item.sourceApp,
                  'onChannel': item.onChannel,
                  'creator': item.creator,
                  'ctime': item.ctime,
                  'atime': item.atime,
                  'rtime': item.rtime,
                  'dtime': item.dtime,
                  'state': item.state,
                  'text': item.text,
                  'wy': item.wy,
                  'location': item.location,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _channelMessageMapper = (Map<String, dynamic> row) =>
      ChannelMessage(
          row['id'] as String,
          row['upstreamPerson'] as String,
          row['sourceSite'] as String,
          row['sourceApp'] as String,
          row['onChannel'] as String,
          row['creator'] as String,
          row['ctime'] as int,
          row['atime'] as int,
          row['rtime'] as int,
          row['dtime'] as int,
          row['state'] as String,
          row['text'] as String,
          row['wy'] as double,
          row['location'] as String,
          row['sandbox'] as String);

  final InsertionAdapter<ChannelMessage> _channelMessageInsertionAdapter;

  @override
  Future<void> removeMessage(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelMessage WHERE id = ? and sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<List<ChannelMessage>> pageMessage(
      String onChannel, String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelMessage WHERE onChannel = ? and sandbox=? ORDER BY ctime DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[onChannel, sandbox, pageSize, currPage],
        mapper: _channelMessageMapper);
  }

  @override
  Future<List<ChannelMessage>> pageMessageByChannelLoopType(
      String loopType, String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT msg.* FROM ChannelMessage msg,Channel ch WHERE msg.onChannel=ch.code AND ch.loopType=? and msg.sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[loopType, sandbox, limit, offset],
        mapper: _channelMessageMapper);
  }

  @override
  Future<List<ChannelMessage>> pageMessageBy(String onchannel, String person,
      String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT msg.* FROM ChannelMessage msg WHERE msg.onChannel=? AND msg.creator=? and msg.sandbox=? ORDER BY ctime DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[onchannel, person, sandbox, limit, offset],
        mapper: _channelMessageMapper);
  }

  @override
  Future<List<ChannelMessage>> listMessageByState(
      String channelid, String sandbox, String state) async {
    return _queryAdapter.queryList(
        'SELECT msg.* FROM ChannelMessage msg WHERE msg.onChannel=? and msg.sandbox=? and msg.state=? ORDER BY ctime DESC',
        arguments: <dynamic>[channelid, sandbox, state],
        mapper: _channelMessageMapper);
  }

  @override
  Future<void> updateStateMessage(String updateToState, String channelid,
      String sandbox, String whereState) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ChannelMessage SET state =? WHERE onChannel=? and sandbox=? and state=?',
        arguments: <dynamic>[updateToState, channelid, sandbox, whereState]);
  }

  @override
  Future<ChannelMessage> getMessage(String id, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM ChannelMessage WHERE id = ? and sandbox=? LIMIT 1',
        arguments: <dynamic>[id, sandbox],
        mapper: _channelMessageMapper);
  }

  @override
  Future<List<ChannelMessage>> getAllMessage(String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelMessage where sandbox=?',
        arguments: <dynamic>[sandbox],
        mapper: _channelMessageMapper);
  }

  @override
  Future<void> empty(String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelMessage where sandbox=?',
        arguments: <dynamic>[sandbox]);
  }

  @override
  Future<void> removeMessagesBy(String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelMessage where onChannel=? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox]);
  }

  @override
  Future<void> addMessage(ChannelMessage message) async {
    await _channelMessageInsertionAdapter.insert(
        message, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelMediaDAO extends IChannelMediaDAO {
  _$IChannelMediaDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _mediaInsertionAdapter = InsertionAdapter(
            database,
            'Media',
            (Media item) => <String, dynamic>{
                  'id': item.id,
                  'type': item.type,
                  'src': item.src,
                  'leading': item.leading,
                  'msgid': item.msgid,
                  'text': item.text,
                  'onChannel': item.onChannel,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _mediaMapper = (Map<String, dynamic> row) => Media(
      row['id'] as String,
      row['type'] as String,
      row['src'] as String,
      row['leading'] as String,
      row['msgid'] as String,
      row['text'] as String,
      row['onChannel'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<Media> _mediaInsertionAdapter;

  @override
  Future<void> removeMedia(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM Media WHERE id = ? and sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<List<Media>> pageMedia(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Media where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _mediaMapper);
  }

  @override
  Future<Media> getMedia(String id, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM Media WHERE id = ? and sandbox=? LIMIT 1',
        arguments: <dynamic>[id, sandbox],
        mapper: _mediaMapper);
  }

  @override
  Future<List<Media>> getAllMedia(String sandbox) async {
    return _queryAdapter.queryList('SELECT * FROM Media where sandbox=?',
        arguments: <dynamic>[sandbox], mapper: _mediaMapper);
  }

  @override
  Future<List<Media>> getMediaByMsgId(String msgid, String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Media WHERE msgid = ? and sandbox=?',
        arguments: <dynamic>[msgid, sandbox],
        mapper: _mediaMapper);
  }

  @override
  Future<List<Media>> getMediaBychannelcode(
      String channelcode, String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Media WHERE onChannel = ? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox],
        mapper: _mediaMapper);
  }

  @override
  Future<void> addMedia(Media media) async {
    await _mediaInsertionAdapter.insert(media, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelLikePersonDAO extends IChannelLikePersonDAO {
  _$IChannelLikePersonDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _likePersonInsertionAdapter = InsertionAdapter(
            database,
            'LikePerson',
            (LikePerson item) => <String, dynamic>{
                  'id': item.id,
                  'person': item.person,
                  'avatar': item.avatar,
                  'msgid': item.msgid,
                  'ctime': item.ctime,
                  'nickName': item.nickName,
                  'onChannel': item.onChannel,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _likePersonMapper = (Map<String, dynamic> row) => LikePerson(
      row['id'] as String,
      row['person'] as String,
      row['avatar'] as String,
      row['msgid'] as String,
      row['ctime'] as int,
      row['nickName'] as String,
      row['onChannel'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<LikePerson> _likePersonInsertionAdapter;

  @override
  Future<void> removeLikePerson(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM LikePerson WHERE id = ? and sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<List<LikePerson>> pageLikePerson(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM LikePerson where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _likePersonMapper);
  }

  @override
  Future<LikePerson> getLikePerson(String id, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM LikePerson WHERE id = ? and sandbox=? LIMIT 1',
        arguments: <dynamic>[id, sandbox],
        mapper: _likePersonMapper);
  }

  @override
  Future<List<LikePerson>> getAllLikePerson(String sandbox) async {
    return _queryAdapter.queryList('SELECT * FROM LikePerson where sandbox=?',
        arguments: <dynamic>[sandbox], mapper: _likePersonMapper);
  }

  @override
  Future<List<LikePerson>> getLikePersonBy(
      String msgid, String person, String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM LikePerson WHERE msgid = ? AND person=? and sandbox=?',
        arguments: <dynamic>[msgid, person, sandbox],
        mapper: _likePersonMapper);
  }

  @override
  Future<void> removeLikePersonBy(
      String msgid, String person, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM LikePerson WHERE msgid = ? AND person=? and sandbox=?',
        arguments: <dynamic>[msgid, person, sandbox]);
  }

  @override
  Future<List<LikePerson>> pageLikePersonBy(
      String msgid, String sandbox, int pageSize, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM LikePerson WHERE msgid=? and sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[msgid, sandbox, pageSize, offset],
        mapper: _likePersonMapper);
  }

  @override
  Future<void> removeLikePersonByChannel(
      String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM LikePerson WHERE onChannel = ? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox]);
  }

  @override
  Future<void> addLikePerson(LikePerson likePerson) async {
    await _likePersonInsertionAdapter.insert(
        likePerson, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelCommentDAO extends IChannelCommentDAO {
  _$IChannelCommentDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _channelCommentInsertionAdapter = InsertionAdapter(
            database,
            'ChannelComment',
            (ChannelComment item) => <String, dynamic>{
                  'id': item.id,
                  'person': item.person,
                  'avatar': item.avatar,
                  'msgid': item.msgid,
                  'text': item.text,
                  'ctime': item.ctime,
                  'nickName': item.nickName,
                  'onChannel': item.onChannel,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _channelCommentMapper = (Map<String, dynamic> row) =>
      ChannelComment(
          row['id'] as String,
          row['person'] as String,
          row['avatar'] as String,
          row['msgid'] as String,
          row['text'] as String,
          row['ctime'] as int,
          row['nickName'] as String,
          row['onChannel'] as String,
          row['sandbox'] as String);

  final InsertionAdapter<ChannelComment> _channelCommentInsertionAdapter;

  @override
  Future<void> removeComment(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelComment WHERE id = ? and sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<List<ChannelComment>> pageComment(
      String sandbox, int pageSize, int currPage) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelComment where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, pageSize, currPage],
        mapper: _channelCommentMapper);
  }

  @override
  Future<ChannelComment> getComment(String id, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM ChannelComment WHERE id = ? and sandbox=? LIMIT 1',
        arguments: <dynamic>[id, sandbox],
        mapper: _channelCommentMapper);
  }

  @override
  Future<List<ChannelComment>> getAllComment(String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelComment where sandbox=?',
        arguments: <dynamic>[sandbox],
        mapper: _channelCommentMapper);
  }

  @override
  Future<List<ChannelComment>> pageLikeCommentBy(
      String msgid, String sandbox, int pageSize, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelComment WHERE msgid=? and sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[msgid, sandbox, pageSize, offset],
        mapper: _channelCommentMapper);
  }

  @override
  Future<void> removeCommentBy(String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelComment WHERE onChannel = ? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox]);
  }

  @override
  Future<void> addComment(ChannelComment comment) async {
    await _channelCommentInsertionAdapter.insert(
        comment, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelPinDAO extends IChannelPinDAO {
  _$IChannelPinDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _channelPinInsertionAdapter = InsertionAdapter(
            database,
            'ChannelPin',
            (ChannelPin item) => <String, dynamic>{
                  'id': item.id,
                  'channel': item.channel,
                  'inPersonSelector': item.inPersonSelector,
                  'outPersonSelector': item.outPersonSelector,
                  'outGeoSelector': item.outGeoSelector,
                  'outWechatPenYouSelector': item.outWechatPenYouSelector,
                  'outWechatHaoYouSelector': item.outWechatHaoYouSelector,
                  'outContractSelector': item.outContractSelector,
                  'inRights': item.inRights,
                  'outRights': item.outRights,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _channelPinMapper = (Map<String, dynamic> row) => ChannelPin(
      row['id'] as String,
      row['channel'] as String,
      row['inPersonSelector'] as String,
      row['outPersonSelector'] as String,
      row['outGeoSelector'] as String,
      row['outWechatPenYouSelector'] as String,
      row['outWechatHaoYouSelector'] as String,
      row['outContractSelector'] as String,
      row['inRights'] as String,
      row['outRights'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<ChannelPin> _channelPinInsertionAdapter;

  @override
  Future<void> setOutputPersonSelector(
      dynamic selector, String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ChannelPin SET outPersonSelector = ? WHERE channel = ? and sandbox=?',
        arguments: <dynamic>[selector, channelcode, sandbox]);
  }

  @override
  Future<void> setOutputGeoSelector(
      String isset, String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ChannelPin SET outGeoSelector = ? WHERE channel = ? and sandbox=?',
        arguments: <dynamic>[isset, channelcode, sandbox]);
  }

  @override
  Future<ChannelPin> getChannelPin(String channelcode, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM ChannelPin WHERE channel=? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox],
        mapper: _channelPinMapper);
  }

  @override
  Future<void> remove(String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelPin WHERE channel=? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox]);
  }

  @override
  Future<void> addChannelPin(ChannelPin channelPin) async {
    await _channelPinInsertionAdapter.insert(
        channelPin, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelInputPersonDAO extends IChannelInputPersonDAO {
  _$IChannelInputPersonDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _channelInputPersonInsertionAdapter = InsertionAdapter(
            database,
            'ChannelInputPerson',
            (ChannelInputPerson item) => <String, dynamic>{
                  'id': item.id,
                  'channel': item.channel,
                  'person': item.person,
                  'rights': item.rights,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _channelInputPersonMapper = (Map<String, dynamic> row) =>
      ChannelInputPerson(
          row['id'] as String,
          row['channel'] as String,
          row['person'] as String,
          row['rights'] as String,
          row['sandbox'] as String);

  final InsertionAdapter<ChannelInputPerson>
      _channelInputPersonInsertionAdapter;

  @override
  Future<List<ChannelInputPerson>> pageInputPerson(
      String channelcode, String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelInputPerson WHERE channel=? and sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[channelcode, sandbox, limit, offset],
        mapper: _channelInputPersonMapper);
  }

  @override
  Future<void> removeInputPerson(
      String person, String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelInputPerson WHERE person=? AND channel = ? and sandbox=?',
        arguments: <dynamic>[person, channelcode, sandbox]);
  }

  @override
  Future<ChannelInputPerson> getInputPerson(
      String person, String channelcode, String sandbox) async {
    return _queryAdapter.query(
        'select * FROM ChannelInputPerson WHERE person=? AND channel = ? and sandbox=? LIMIT 1 OFFSET 0',
        arguments: <dynamic>[person, channelcode, sandbox],
        mapper: _channelInputPersonMapper);
  }

  @override
  Future<void> updateInputPersonRights(
      String rights, String person, String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ChannelInputPerson SET rights = ? WHERE person=? AND channel = ? and sandbox=?',
        arguments: <dynamic>[rights, person, channelcode, sandbox]);
  }

  @override
  Future<List<ChannelInputPerson>> listInputPerson(
      String channelcode, String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelInputPerson WHERE channel=? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox],
        mapper: _channelInputPersonMapper);
  }

  @override
  Future<void> emptyInputPersons(String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelInputPerson WHERE channel = ? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox]);
  }

  @override
  Future<void> addInputPerson(ChannelInputPerson person) async {
    await _channelInputPersonInsertionAdapter.insert(
        person, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChannelOutputPersonDAO extends IChannelOutputPersonDAO {
  _$IChannelOutputPersonDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _channelOutputPersonInsertionAdapter = InsertionAdapter(
            database,
            'ChannelOutputPerson',
            (ChannelOutputPerson item) => <String, dynamic>{
                  'id': item.id,
                  'channel': item.channel,
                  'person': item.person,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _channelOutputPersonMapper = (Map<String, dynamic> row) =>
      ChannelOutputPerson(row['id'] as String, row['channel'] as String,
          row['person'] as String, row['sandbox'] as String);

  final InsertionAdapter<ChannelOutputPerson>
      _channelOutputPersonInsertionAdapter;

  @override
  Future<List<ChannelOutputPerson>> pageOutputPerson(
      String channelcode, String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelOutputPerson WHERE channel=? and sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[channelcode, sandbox, limit, offset],
        mapper: _channelOutputPersonMapper);
  }

  @override
  Future<List<ChannelOutputPerson>> listOutputPerson(
      String channelcode, String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChannelOutputPerson WHERE channel=? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox],
        mapper: _channelOutputPersonMapper);
  }

  @override
  Future<void> removeOutputPerson(
      String person, String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelOutputPerson WHERE person=? AND channel = ? and sandbox=?',
        arguments: <dynamic>[person, channelcode, sandbox]);
  }

  @override
  Future<ChannelOutputPerson> getOutputPerson(
      String person, String channelcode, String sandbox) async {
    return _queryAdapter.query(
        'select * FROM ChannelOutputPerson WHERE person=? AND channel = ? and sandbox=? LIMIT 1 OFFSET 0',
        arguments: <dynamic>[person, channelcode, sandbox],
        mapper: _channelOutputPersonMapper);
  }

  @override
  Future<void> emptyOutputPersons(String channelcode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChannelOutputPerson WHERE channel = ? and sandbox=?',
        arguments: <dynamic>[channelcode, sandbox]);
  }

  @override
  Future<void> addOutputPerson(ChannelOutputPerson person) async {
    await _channelOutputPersonInsertionAdapter.insert(
        person, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IFriendDAO extends IFriendDAO {
  _$IFriendDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _friendInsertionAdapter = InsertionAdapter(
            database,
            'Friend',
            (Friend item) => <String, dynamic>{
                  'official': item.official,
                  'source': item.source,
                  'uid': item.uid,
                  'accountName': item.accountName,
                  'appid': item.appid,
                  'avatar': item.avatar,
                  'rights': item.rights,
                  'nickName': item.nickName,
                  'signature': item.signature,
                  'pyname': item.pyname,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _friendMapper = (Map<String, dynamic> row) => Friend(
      row['official'] as String,
      row['source'] as String,
      row['uid'] as String,
      row['accountName'] as String,
      row['appid'] as String,
      row['avatar'] as String,
      row['rights'] as String,
      row['nickName'] as String,
      row['signature'] as String,
      row['pyname'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<Friend> _friendInsertionAdapter;

  @override
  Future<Friend> getFriend(String official, String sandbox) async {
    return _queryAdapter.query(
        'select * FROM Friend WHERE official=? and sandbox=? LIMIT 1 OFFSET 0',
        arguments: <dynamic>[official, sandbox],
        mapper: _friendMapper);
  }

  @override
  Future<List<Friend>> pageFriendLikeName(
      String person,
      String accountCode,
      String nickName,
      String pyname,
      List<String> officials,
      int limit,
      int offset) async {
    final valueList1 = officials.map((value) => "'$value'").join(', ');
    return _queryAdapter.queryList(
        'SELECT * FROM Friend where sandbox=? and (accountCode LIKE ? OR nickName LIKE ? OR pyname LIKE ?) and official NOT IN ($valueList1) LIMIT ? OFFSET ?',
        arguments: <dynamic>[
          person,
          accountCode,
          nickName,
          pyname,
          limit,
          offset
        ],
        mapper: _friendMapper);
  }

  @override
  Future<List<Friend>> pageFriend(String sandbox, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Friend where sandbox=? LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, limit, offset],
        mapper: _friendMapper);
  }

  @override
  Future<void> removeFriendByOfficial(String official, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM Friend WHERE official = ? AND sandbox=?',
        arguments: <dynamic>[official, sandbox]);
  }

  @override
  Future<Friend> getFriendByOfficial(String sandbox, String official) async {
    return _queryAdapter.query(
        'SELECT * FROM Friend where sandbox=? and official=? LIMIT 1 OFFSET 0',
        arguments: <dynamic>[sandbox, official],
        mapper: _friendMapper);
  }

  @override
  Future<void> addFriend(Friend friend) async {
    await _friendInsertionAdapter.insert(
        friend, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IChatRoomDAO extends IChatRoomDAO {
  _$IChatRoomDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _chatRoomInsertionAdapter = InsertionAdapter(
            database,
            'ChatRoom',
            (ChatRoom item) => <String, dynamic>{
                  'id': item.id,
                  'code': item.code,
                  'title': item.title,
                  'leading': item.leading,
                  'creator': item.creator,
                  'ctime': item.ctime,
                  'notice': item.notice,
                  'p2pBackground': item.p2pBackground,
                  'isDisplayNick': item.isDisplayNick,
                  'microsite': item.microsite,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _chatRoomMapper = (Map<String, dynamic> row) => ChatRoom(
      row['id'] as String,
      row['code'] as String,
      row['title'] as String,
      row['leading'] as String,
      row['creator'] as String,
      row['ctime'] as int,
      row['notice'] as String,
      row['p2pBackground'] as String,
      row['isDisplayNick'] as String,
      row['microsite'] as String,
      row['sandbox'] as String);

  static final _roomMemberMapper = (Map<String, dynamic> row) => RoomMember(
      row['id'] as String,
      row['room'] as String,
      row['person'] as String,
      row['whoAdd'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<ChatRoom> _chatRoomInsertionAdapter;

  @override
  Future<List<ChatRoom>> listChatRoom(String sandbox) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ChatRoom where sandbox=? ORDER BY ctime DESC',
        arguments: <dynamic>[sandbox],
        mapper: _chatRoomMapper);
  }

  @override
  Future<void> removeChatRoomById(String id, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM ChatRoom WHERE id = ? AND sandbox=?',
        arguments: <dynamic>[id, sandbox]);
  }

  @override
  Future<ChatRoom> getChatRoomById(String code, String sandbox) async {
    return _queryAdapter.query(
        'SELECT * FROM ChatRoom where id=? and sandbox=?',
        arguments: <dynamic>[code, sandbox],
        mapper: _chatRoomMapper);
  }

  @override
  Future<void> updateRoomLeading(
      String path, String sandbox, String roomid) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ChatRoom SET leading = ? WHERE sandbox=? and id = ?',
        arguments: <dynamic>[path, sandbox, roomid]);
  }

  @override
  Future<List<RoomMember>> top20Members(String sandbox, String room) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RoomMember where sandbox=? and room=? LIMIT 20',
        arguments: <dynamic>[sandbox, room],
        mapper: _roomMemberMapper);
  }

  @override
  Future<void> addRoom(ChatRoom chatRoom) async {
    await _chatRoomInsertionAdapter.insert(
        chatRoom, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IRoomMemberDAO extends IRoomMemberDAO {
  _$IRoomMemberDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _roomMemberInsertionAdapter = InsertionAdapter(
            database,
            'RoomMember',
            (RoomMember item) => <String, dynamic>{
                  'id': item.id,
                  'room': item.room,
                  'person': item.person,
                  'whoAdd': item.whoAdd,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _roomMemberMapper = (Map<String, dynamic> row) => RoomMember(
      row['id'] as String,
      row['room'] as String,
      row['person'] as String,
      row['whoAdd'] as String,
      row['sandbox'] as String);

  static final _friendMapper = (Map<String, dynamic> row) => Friend(
      row['official'] as String,
      row['source'] as String,
      row['uid'] as String,
      row['accountName'] as String,
      row['appid'] as String,
      row['avatar'] as String,
      row['rights'] as String,
      row['nickName'] as String,
      row['signature'] as String,
      row['pyname'] as String,
      row['sandbox'] as String);

  final InsertionAdapter<RoomMember> _roomMemberInsertionAdapter;

  @override
  Future<List<RoomMember>> topMember10(String sandbox, String roomcode) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RoomMember where sandbox=? and room=?',
        arguments: <dynamic>[sandbox, roomcode],
        mapper: _roomMemberMapper);
  }

  @override
  Future<void> removeChatRoomByRoomCode(String roomCode, String sandbox) async {
    await _queryAdapter.queryNoReturn(
        'delete FROM RoomMember WHERE room = ? AND sandbox=?',
        arguments: <dynamic>[roomCode, sandbox]);
  }

  @override
  Future<List<Friend>> listWhoAddMember(
      String sandbox, String roomCode, String whoAdd) async {
    return _queryAdapter.queryList(
        'SELECT f.* FROM RoomMember m,Friend f where m.person=f.official and m.sandbox=? and m.room=? and m.whoAdd=?',
        arguments: <dynamic>[sandbox, roomCode, whoAdd],
        mapper: _friendMapper);
  }

  @override
  Future<void> addMember(RoomMember roomMember) async {
    await _roomMemberInsertionAdapter.insert(
        roomMember, sqflite.ConflictAlgorithm.abort);
  }
}

class _$IRoomNickDAO extends IRoomNickDAO {
  _$IRoomNickDAO(this.database, this.changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}

class _$IP2PMessageDAO extends IP2PMessageDAO {
  _$IP2PMessageDAO(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _p2PMessageInsertionAdapter = InsertionAdapter(
            database,
            'P2PMessage',
            (P2PMessage item) => <String, dynamic>{
                  'id': item.id,
                  'sender': item.sender,
                  'receiver': item.receiver,
                  'room': item.room,
                  'type': item.type,
                  'content': item.content,
                  'state': item.state,
                  'ctime': item.ctime,
                  'atime': item.atime,
                  'rtime': item.rtime,
                  'dtime': item.dtime,
                  'sandbox': item.sandbox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _p2PMessageMapper = (Map<String, dynamic> row) => P2PMessage(
      row['id'] as String,
      row['sender'] as String,
      row['receiver'] as String,
      row['room'] as String,
      row['type'] as String,
      row['content'] as String,
      row['state'] as String,
      row['ctime'] as int,
      row['atime'] as int,
      row['rtime'] as int,
      row['dtime'] as int,
      row['sandbox'] as String);

  final InsertionAdapter<P2PMessage> _p2PMessageInsertionAdapter;

  @override
  Future<List<P2PMessage>> pageMessage(
      String sandbox, String roomCode, int limit, int offset) async {
    return _queryAdapter.queryList(
        'SELECT * FROM P2PMessage where sandbox=? and room=? ORDER BY ctime DESC LIMIT ? OFFSET ?',
        arguments: <dynamic>[sandbox, roomCode, limit, offset],
        mapper: _p2PMessageMapper);
  }

  @override
  Future<void> addMessage(P2PMessage message) async {
    await _p2PMessageInsertionAdapter.insert(
        message, sqflite.ConflictAlgorithm.abort);
  }
}
