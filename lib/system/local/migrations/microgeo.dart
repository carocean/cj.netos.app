import 'package:floor/floor.dart';

final migrationsMicrogeo = <Migration>[
  Migration(
    1,
    2,
    (db) async {
      await db.transaction((txn) async {
        await db.execute('alter table Friend rename to Friend_old');
        await db.execute(
            'CREATE TABLE IF NOT EXISTS `Friend` (`official` TEXT, `source` TEXT, `uid` TEXT, `accountCode` TEXT, `appid` TEXT, `avatar` TEXT, `rights` TEXT, `nickName` TEXT, `signature` TEXT, `pyname` TEXT, `sandbox` TEXT, PRIMARY KEY (`official`, `sandbox`))');
        await db.execute('INSERT INTO Friend SELECT * FROM Friend_old');
        await db.execute('DROP TABLE Friend_old');
      });

      print('--------database onUpgrade 从版本1迁移到版本2');
    },
  ),
  Migration(
    2,
    3,
        (db) async {
      await db.transaction((txn) async {
        await db.execute('ALTER TABLE Channel ADD COLUMN upstreamPerson Text');
      });

      print('--------database onUpgrade 从版本2迁移到版本3');
    },
  ),
];
