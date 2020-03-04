import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:objectdb/objectdb.dart';
import 'package:uuid/uuid.dart';

typedef OnQueueCount = void Function(int count);

class DefaultEventQueue implements IEventQueue {
  ObjectDB _db;
  OnQueueCount _onQueueCount;

  @override
  Future<void> open(String path, [OnQueueCount onQueueCount]) async {
    _onQueueCount = onQueueCount;
    final db = ObjectDB(path);
    _db = await db.open();
    if (_onQueueCount != null) {
      _onQueueCount(await count());
    }
  }

  @override
  Future<void> close() async {
    return await _db.close();
  }

  @override
  Future<void> add(Map frameMap) async {
    var url = frameMap['headers']['url'];
    frameMap['path'] = getPath(url);
    await _db.insert(frameMap);
    if (_onQueueCount != null) {
      _onQueueCount(await count());
    }
  }

  @override
  Future<List<Map>> find(String person, String path) async {
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    var query = {'headers.to-person': '$person', 'path': '$path'};
    List<Map<dynamic, dynamic>> list = await _db.find(query);
    return list;
  }

  @override
  Future<void> remove(Map<dynamic, dynamic> frameMap) async {
    var query = {'_id': '${frameMap['_id']}'};
    var i = await _db.remove(query);
    if (_onQueueCount != null) {
      _onQueueCount(await count());
    }
  }

  @override
  Future<List<Map<dynamic, dynamic>>> findAll() async {
    var query = {};
    List<Map<dynamic, dynamic>> list = await _db.find(query);
    return list;
  }

  @override
  Future<int> count() async {
    var query = {};
    List<Map<dynamic, dynamic>> list = await _db.find(query);
    return list.length;
  }
}

mixin IEventQueue {
  Future<void> open(String path, [OnQueueCount onQueueCount]);

  Future<void> close();

  Future<int> count() {}

  Future<void> add(Map frameMap);

  Future<List<Map<dynamic, dynamic>>> find(
      String person, String path);

  Future<List<Map<dynamic, dynamic>>> findAll() {}

  Future<void> remove(Map<dynamic, dynamic> frameMap) {}
}
